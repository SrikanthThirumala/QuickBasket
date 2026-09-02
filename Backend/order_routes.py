from flask import Blueprint, request, jsonify, current_app
from db import get_db_connection
from auth_middleware import token_required
from email_service import send_order_email

orders_bp = Blueprint('orders', __name__)

@orders_bp.route('/api/orders/validate-promo', methods=['POST'])
@token_required
def validate_promo(current_user_id, role):
    code = request.json.get('code', '').upper()
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT discount_percent FROM promocodes WHERE code = %s AND is_active = TRUE", (code,))
            promo = cursor.fetchone()
            if not promo:
                current_app.logger.error(f"ORDER ERROR: Invalid or expired promo code attempted: {code}")
                return jsonify({"error": "Invalid or expired promo code"}), 400
            
            current_app.logger.info(f"ORDER SUCCESS: Promo code {code} validated for User ID {current_user_id}")
            return jsonify({"discount_percent": promo['discount_percent']}), 200
    except Exception as e:
        current_app.logger.error(f"ORDER ERROR: Promo validation crashed. Details: {str(e)}")
        return jsonify({"error": "Failed to validate promo code"}), 500
    finally:
        connection.close()

@orders_bp.route('/api/orders/checkout', methods=['POST'])
@token_required
def checkout(current_user_id, role):
    data = request.json
    cart = data.get('cart', [])
    address = data.get('address') 
    payment_method = data.get('payment_method', 'Card')
    promo_code = data.get('promo_code')
    
    if not cart or not address:
        return jsonify({"error": "Cart and address required."}), 400

    full_address = f"{address.get('street')}, {address.get('city')}, {address.get('state')} {address.get('zip')}"
    
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            total_amount = 0
            total_calories = 0
            items_to_insert = []
            
            for item in cart:
                cursor.execute("SELECT price, stock_quantity, calories FROM products WHERE id = %s", (item['product_id'],))
                product = cursor.fetchone()
                if not product or product['stock_quantity'] < item['quantity']:
                    current_app.logger.error(f"ORDER ERROR: Checkout failed for User ID {current_user_id} - Item {item['product_id']} out of stock")
                    return jsonify({"error": f"Item out of stock."}), 400
                
                subtotal = float(product['price']) * item['quantity']
                total_amount += subtotal
                total_calories += product['calories'] * item['quantity']
                items_to_insert.append((item['product_id'], item['quantity'], product['price']))

            if promo_code:
                cursor.execute("SELECT discount_percent FROM promocodes WHERE code = %s AND is_active = TRUE", (promo_code,))
                promo = cursor.fetchone()
                if promo:
                    discount = total_amount * (promo['discount_percent'] / 100.0)
                    total_amount -= discount

            cursor.execute(
                "INSERT INTO orders (user_id, total_amount, total_calories, delivery_address, payment_method, promo_code) VALUES (%s, %s, %s, %s, %s, %s)",
                (current_user_id, total_amount, total_calories, full_address, payment_method, promo_code)
            )
            order_id = cursor.lastrowid

            for prod_id, qty, price in items_to_insert:
                cursor.execute("INSERT INTO order_items (order_id, product_id, quantity, price_at_purchase) VALUES (%s, %s, %s, %s)",
                               (order_id, prod_id, qty, price))
                cursor.execute("UPDATE products SET stock_quantity = stock_quantity - %s WHERE id = %s", (qty, prod_id))

            cursor.execute("SELECT email FROM users WHERE id = %s", (current_user_id,))
            user = cursor.fetchone()
            
            connection.commit()
            
            send_order_email(user['email'], order_id, total_amount, total_calories)
            current_app.logger.info(f"ORDER SUCCESS: Order {order_id} successfully processed for User ID {current_user_id}")
            
            return jsonify({"message": "Order confirmed", "order_id": order_id}), 201
    except Exception as e:
        current_app.logger.error(f"ORDER ERROR: Checkout crashed for User ID {current_user_id}. Details: {str(e)}")
        return jsonify({"error": "Order processing failed"}), 500
    finally:
        connection.close()

@orders_bp.route('/api/orders/history', methods=['GET'])
@token_required
def order_history(current_user_id, role):
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute(
                "SELECT id, total_amount, status, created_at, delivery_address, total_calories FROM orders WHERE user_id = %s ORDER BY created_at DESC",
                (current_user_id,)
            )
            orders = cursor.fetchall()
            for order in orders:
                order['total_amount'] = float(order['total_amount'])
                cursor.execute(
                    """SELECT oi.quantity, oi.price_at_purchase, p.name, p.image_url 
                       FROM order_items oi 
                       JOIN products p ON oi.product_id = p.id 
                       WHERE oi.order_id = %s""",
                    (order['id'],)
                )
                items = cursor.fetchall()
                for item in items:
                    item['price_at_purchase'] = float(item['price_at_purchase'])
                order['items'] = items
            return jsonify({"orders": orders}), 200
    except Exception as e:
        current_app.logger.error(f"ORDER ERROR: Failed to fetch history for User ID {current_user_id}. Details: {str(e)}")
        return jsonify({"error": "Failed to fetch order history"}), 500
    finally:
        connection.close()