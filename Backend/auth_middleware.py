import os
import jwt
from functools import wraps
from flask import request, jsonify
from db import get_db_connection

SECRET_KEY = os.getenv("JWT_SECRET", "super-secret-fallback-key")

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({"error": "Missing token."}), 401
        
        token = auth_header.split(" ")[1]
        try:
            data = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
            current_user_id = data['user_id']
            role = data.get('role', 'user')
        except Exception:
            return jsonify({"error": "Invalid session."}), 401
        
        return f(current_user_id, role, *args, **kwargs)
    return decorated

def admin_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get('Authorization')
        if not auth_header:
            return jsonify({"error": "Missing token."}), 401
        
        token = auth_header.split(" ")[1]
        try:
            data = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
            if data.get('role') != 'admin':
                return jsonify({"error": "Admin access required."}), 403
        except Exception:
            return jsonify({"error": "Invalid session."}), 401
        
        return f(*args, **kwargs)
    return decorated