from flask import Blueprint, request, jsonify
from db import get_db_connection
from auth_middleware import admin_required

admin_bp = Blueprint('admin', __name__)

@admin_bp.route('/api/admin/orders', methods=['GET'])
@admin_required
def get_all_orders():
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM orders ORDER BY created_at DESC")
            return jsonify({"orders": cursor.fetchall()}), 200
    finally:
        connection.close()

@admin_bp.route('/api/admin/orders/<int:order_id>/status', methods=['PUT'])
@admin_required
def update_order_status(order_id):
    status = request.json.get('status')
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("UPDATE orders SET status = %s WHERE id = %s", (status, order_id))
            connection.commit()
            return jsonify({"message": "Status updated"}), 200
    finally:
        connection.close()

@admin_bp.route('/api/admin/promocodes', methods=['POST'])
@admin_required
def create_promo():
    data = request.json
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("INSERT INTO promocodes (code, discount_percent) VALUES (%s, %s)", 
                           (data['code'].upper(), data['discount_percent']))
            connection.commit()
            return jsonify({"message": "Promo code created"}), 201
    finally:
        connection.close()

@admin_bp.route('/api/admin/products', methods=['POST'])
@admin_required
def add_product():
    data = request.json
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                INSERT INTO products (name, price, image_url, category, unit, stock_quantity, calories) 
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """, (data['name'], data['price'], data['image_url'], data['category'], data['unit'], data['stock_quantity'], data['calories']))
            connection.commit()
            return jsonify({"message": "Product added successfully"}), 201
    finally:
        connection.close()

@admin_bp.route('/api/admin/products/<int:product_id>', methods=['PUT'])
@admin_required
def update_product(product_id):
    data = request.json
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                UPDATE products 
                SET name=%s, price=%s, image_url=%s, category=%s, unit=%s, stock_quantity=%s, calories=%s 
                WHERE id=%s
            """, (data['name'], data['price'], data['image_url'], data['category'], data['unit'], data['stock_quantity'], data['calories'], product_id))
            connection.commit()
            return jsonify({"message": "Product updated successfully"}), 200
    finally:
        connection.close()