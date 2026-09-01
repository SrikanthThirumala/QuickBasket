import os, uuid, boto3
from flask import Blueprint, request, jsonify
from db import get_db_connection
from auth_middleware import admin_required

admin_bp = Blueprint('admin', __name__)

s3_client = boto3.client('s3', region_name=os.getenv('AWS_REGION', 'us-west-2'))

def upload_to_s3(file):
    bucket = os.getenv('S3_BUCKET_NAME')
    cloudfront_domain = os.getenv('CLOUDFRONT_DOMAIN')
    
    if not bucket or not file: 
        return None
    
    ext = file.filename.rsplit('.', 1)[1].lower() if '.' in file.filename else 'jpg'
    filename = f"{uuid.uuid4().hex}.{ext}"
    
    try:
        s3_client.upload_fileobj(
            file, 
            bucket, 
            filename, 
            ExtraArgs={'ContentType': file.content_type}
        )
        
        if cloudfront_domain:
            return f"https://{cloudfront_domain}/{filename}"
        else:
            return f"https://{bucket}.s3.{os.getenv('AWS_REGION', 'us-west-2')}.amazonaws.com/{filename}"
            
    except Exception as e:
        print(f"S3 Upload Error: {e}")
        return None

# --- ORDERS ---
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

# --- PROMO CODES ---
@admin_bp.route('/api/admin/promocodes', methods=['GET'])
@admin_required
def get_promos():
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM promocodes ORDER BY id DESC")
            return jsonify({"promocodes": cursor.fetchall()}), 200
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

@admin_bp.route('/api/admin/promocodes/<int:promo_id>', methods=['DELETE'])
@admin_required
def delete_promo(promo_id):
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("DELETE FROM promocodes WHERE id = %s", (promo_id,))
            connection.commit()
            return jsonify({"message": "Promo code deleted"}), 200
    finally:
        connection.close()

# --- PRODUCTS ---
@admin_bp.route('/api/admin/products', methods=['GET'])
@admin_required
def get_all_products():
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM products ORDER BY category, id DESC")
            return jsonify({"products": cursor.fetchall()}), 200
    finally:
        connection.close()

@admin_bp.route('/api/admin/products', methods=['POST'])
@admin_required
def add_product():
    data = request.form
    file = request.files.get('image')
    image_url = data.get('image_url', '')

    if file:
        uploaded_url = upload_to_s3(file)
        if uploaded_url: 
            image_url = uploaded_url

    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                INSERT INTO products (name, price, image_url, category, unit, stock_quantity, calories) 
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """, (data['name'], data['price'], image_url, data['category'], data['unit'], data['stock_quantity'], data['calories']))
            connection.commit()
            return jsonify({"message": "Product added successfully"}), 201
    finally:
        connection.close()

@admin_bp.route('/api/admin/products/<int:product_id>', methods=['PUT'])
@admin_required
def update_product(product_id):
    data = request.form
    file = request.files.get('image')
    image_url = data.get('image_url', '')

    if file:
        new_url = upload_to_s3(file)
        if new_url: 
            image_url = new_url

    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                UPDATE products 
                SET name=%s, price=%s, image_url=%s, category=%s, unit=%s, stock_quantity=%s, calories=%s 
                WHERE id=%s
            """, (
                data['name'], data['price'], image_url, data['category'], 
                data['unit'], data['stock_quantity'], data['calories'], product_id
            ))
            connection.commit()
            return jsonify({"message": "Product updated successfully"}), 200
    finally:
        connection.close()

@admin_bp.route('/api/admin/products/<int:product_id>', methods=['DELETE'])
@admin_required
def delete_product(product_id):
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("DELETE FROM products WHERE id = %s", (product_id,))
            connection.commit()
            return jsonify({"message": "Product deleted successfully"}), 200
    finally:
        connection.close()