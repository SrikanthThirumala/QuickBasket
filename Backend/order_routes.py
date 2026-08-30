from flask import Blueprint, request, jsonify
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
                return jsonify({"error": "Invalid or expired promo code"}), 400
            return jsonify({"discount_percent": promo['discount_percent']}), 200
    finally:
        connection.close()

@orders_bp.route('/api/orders/checkout', methods=['POST'])
@token_required
def checkout(current_user_id, role):
    data = request.json
    cart = data.get('cart', [])
    address = data.get('address') # Now a dict: street, city, state, zip
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
                    return jsonify({"error": f"Item out of stock."}), 400
                
                subtotal = float(product['price']) * item['quantity']
                total_amount += subtotal
                total_calories += product['calories'] * item['quantity']
                items_to_insert.append((item['product_id'], item['quantity'], product['price']))

            # Apply Promo
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
            
            # Send Email
            send_order_email(user['email'], order_id, total_amount, total_calories)
            
            return jsonify({"message": "Order confirmed", "order_id": order_id}), 201
    finally:
        connection.close()