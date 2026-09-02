from flask import Blueprint, request, jsonify, current_app
from db import get_db_connection
from auth_middleware import token_required

users_bp = Blueprint('users', __name__)

@users_bp.route('/api/users/profile', methods=['GET'])
@token_required
def get_profile(current_user_id, *args, **kwargs):
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute(
                "SELECT id, username, email, default_address, created_at FROM users WHERE id = %s",
                (current_user_id,)
            )
            user = cursor.fetchone()
            if not user:
                current_app.logger.error(f"USER ERROR: Profile lookup failed - User ID {current_user_id} not found")
                return jsonify({"error": "User not found"}), 404
            
            return jsonify({"user": user}), 200
    except Exception as e:
        current_app.logger.error(f"USER ERROR: Failed to fetch profile for User ID {current_user_id}. Details: {str(e)}")
        return jsonify({"error": "Failed to fetch profile"}), 500
    finally:
        connection.close()

@users_bp.route('/api/users/profile', methods=['PUT'])
@token_required
def update_profile(current_user_id, *args, **kwargs):
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
            
            current_app.logger.info(f"USER SUCCESS: Profile address updated for User ID {current_user_id}")
            return jsonify({"message": "Profile updated successfully"}), 200
    except Exception as e:
        current_app.logger.error(f"USER ERROR: Failed to update profile for User ID {current_user_id}. Details: {str(e)}")
        return jsonify({"error": "Failed to update profile"}), 500
    finally:
        connection.close()