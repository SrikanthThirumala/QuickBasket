from flask import Blueprint, request, jsonify
from db import get_db_connection

products_bp = Blueprint('products', __name__)

@products_bp.route('/api/products', methods=['GET'])
def get_products():
    category = request.args.get('category', 'All')
    search = request.args.get('search', '')
    
    query = "SELECT id, name, price, image_url, category, unit, stock_quantity FROM products WHERE is_active = TRUE"
    params = []

    if category and category != 'All':
        query += " AND category = %s"
        params.append(category)
        
    if search:
        query += " AND name LIKE %s"
        params.append(f"%{search}%")

    query += " ORDER BY id ASC"
    
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute(query, tuple(params))
            products = cursor.fetchall()
            for p in products:
                p['price'] = float(p['price'])
            return jsonify({"products": products}), 200
    finally:
        connection.close()