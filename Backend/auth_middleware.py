import os
import jwt
from functools import wraps
from flask import request, jsonify, current_app
from db import get_db_connection

SECRET_KEY = os.getenv("JWT_SECRET", "super-secret-fallback-key")

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            current_app.logger.error("AUTH MIDDLEWARE: Request rejected - Missing or malformed Authorization header.")
            return jsonify({"error": "Missing token."}), 401
        
        token = auth_header.split(" ")[1]
        try:
            data = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
            current_user_id = data['user_id']
            role = data.get('role', 'user')
        except jwt.ExpiredSignatureError:
            current_app.logger.error("AUTH MIDDLEWARE: Request rejected - Token has expired.")
            return jsonify({"error": "Token expired. Please log in again."}), 401
        except Exception as e:
            current_app.logger.error(f"AUTH MIDDLEWARE: Request rejected - Invalid session token. Details: {str(e)}")
            return jsonify({"error": "Invalid session."}), 401
        
        return f(current_user_id, role, *args, **kwargs)
    return decorated

def admin_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get('Authorization')
        if not auth_header:
            current_app.logger.error("AUTH MIDDLEWARE (ADMIN): Request rejected - Missing Authorization header.")
            return jsonify({"error": "Missing token."}), 401
        
        token = auth_header.split(" ")[1]
        try:
            data = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
            if data.get('role') != 'admin':
                current_app.logger.error(f"AUTH MIDDLEWARE (ADMIN): Request rejected - User ID {data.get('user_id')} attempted admin action without admin role.")
                return jsonify({"error": "Admin access required."}), 403
        except jwt.ExpiredSignatureError:
            current_app.logger.error("AUTH MIDDLEWARE (ADMIN): Request rejected - Token has expired.")
            return jsonify({"error": "Token expired. Please log in again."}), 401
        except Exception as e:
            current_app.logger.error(f"AUTH MIDDLEWARE (ADMIN): Request rejected - Invalid session token. Details: {str(e)}")
            return jsonify({"error": "Invalid session."}), 401
        
        return f(*args, **kwargs)
    return decorated