from flask import Blueprint, request, jsonify
from db import get_db_connection
from auth_middleware import token_required

users_bp = Blueprint('users', __name__)

@users_bp.route('/api/users/profile', methods=['GET'])
@token_required
def get_profile(current_user_id):
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute(
                "SELECT id, username, email, default_address, created_at FROM users WHERE id = %s",
                (current_user_id,)
            )
            user = cursor.fetchone()
            if not user:
                return jsonify({"error": "User not found"}), 404
            return jsonify({"user": user}), 200
    finally:
        connection.close()

@users_bp.route('/api/users/profile', methods=['PUT'])
@token_required
def update_profile(current_user_id):
    data = request.json
    default_address = data.get('default_address')

    if not default_address:
        return jsonify({"error": "Address is required"}), 400

    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute(
                "UPDATE users SET default_address = %s WHERE id = %s",
                (default_address, current_user_id)
            )
            connection.commit()
            return jsonify({"message": "Profile updated successfully"}), 200
    finally:
        connection.close()