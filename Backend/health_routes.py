from flask import Blueprint, jsonify, current_app

health_bp = Blueprint('health', __name__)

@health_bp.route('/health', methods=['GET'])
def health_check():
    try:
        from db import get_db_connection
        conn = get_db_connection()
        conn.close()
        return jsonify({"status": "healthy", "database": "connected"}), 200
    except Exception as e:
        current_app.logger.error(f"HEALTH CHECK CRITICAL: Database connection failed during ELB ping. Details: {str(e)}")
        return jsonify({"status": "unhealthy", "error": str(e)}), 500