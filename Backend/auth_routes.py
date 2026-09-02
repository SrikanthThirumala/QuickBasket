import os, jwt, random, datetime, re
from flask import Blueprint, request, jsonify, current_app
from werkzeug.security import generate_password_hash, check_password_hash
from db import get_db_connection
from email_service import send_otp_email
from auth_middleware import token_required

auth_bp = Blueprint('auth', __name__)
SECRET_KEY = os.getenv("JWT_SECRET", "super-secret-fallback-key")

def generate_token(user_id, role):
    payload = {
        'user_id': user_id,
        'role': role,
        'exp': datetime.datetime.utcnow() + datetime.timedelta(days=7)
    }
    return jwt.encode(payload, SECRET_KEY, algorithm='HS256')

def is_valid_password(password):
    if len(password) < 8: return False
    if not re.search(r"[a-z]", password): return False
    if not re.search(r"[A-Z]", password): return False
    if not re.search(r"[0-9]", password): return False
    if not re.search(r"[\W_]", password): return False
    return True

@auth_bp.route('/api/auth/signup', methods=['POST'])
def signup():
    data = request.json
    username, email, password = data.get('username'), data.get('email'), data.get('password')
    
    if not all([username, email, password]):
        return jsonify({"error": "All fields are required"}), 400

    if not is_valid_password(password):
        return jsonify({"error": "Password must be at least 8 characters and include an uppercase letter, lowercase letter, number, and special character."}), 400

    hashed_pw = generate_password_hash(password)
    otp_code = str(random.randint(100000, 999999))
    expires_at = datetime.datetime.utcnow() + datetime.timedelta(minutes=10)

    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT id FROM users WHERE email = %s OR username = %s", (email, username))
            if cursor.fetchone():
                current_app.logger.error(f"AUTH ERROR: Signup failed for {email} - User already exists")
                return jsonify({"error": "User already exists"}), 409
            
            cursor.execute(
                "INSERT INTO users (username, email, password_hash, is_verified) VALUES (%s, %s, %s, FALSE)",
                (username, email, hashed_pw)
            )
            cursor.execute(
                "INSERT INTO otp_verifications (email, otp_code, expires_at) VALUES (%s, %s, %s)",
                (email, otp_code, expires_at)
            )
            connection.commit()
            
            send_otp_email(email, otp_code)
            current_app.logger.info(f"AUTH SUCCESS: New user created and OTP sent - {email}")
            return jsonify({"message": "OTP sent to your email. Please verify to continue.", "email": email}), 201
    except Exception as e:
        current_app.logger.error(f"AUTH ERROR: Signup process crashed for {email}. Details: {str(e)}")
        return jsonify({"error": "Signup failed"}), 500
    finally:
        connection.close()

@auth_bp.route('/api/auth/verify-otp', methods=['POST'])
def verify_otp():
    data = request.json
    email, otp_code = data.get('email'), data.get('otp_code')

    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute(
                "SELECT id FROM otp_verifications WHERE email = %s AND otp_code = %s AND is_used = FALSE AND expires_at > NOW() ORDER BY created_at DESC LIMIT 1",
                (email, otp_code)
            )
            otp_record = cursor.fetchone()

            if not otp_record:
                current_app.logger.error(f"AUTH ERROR: OTP validation failed for {email} - Invalid or expired")
                return jsonify({"error": "Invalid or expired OTP"}), 400

            cursor.execute("UPDATE otp_verifications SET is_used = TRUE WHERE id = %s", (otp_record['id'],))
            cursor.execute("UPDATE users SET is_verified = TRUE WHERE email = %s", (email,))
            cursor.execute("SELECT id, role FROM users WHERE email = %s", (email,))
            user = cursor.fetchone()
            
            connection.commit()
            current_app.logger.info(f"AUTH SUCCESS: User verified successfully - {email}")
            return jsonify({"message": "Account verified", "token": generate_token(user['id'], user['role'])}), 200
    except Exception as e:
        current_app.logger.error(f"AUTH ERROR: OTP verification crashed for {email}. Details: {str(e)}")
        return jsonify({"error": "Verification failed"}), 500
    finally:
        connection.close()

@auth_bp.route('/api/auth/signin', methods=['POST'])
def signin():
    data = request.json
    email = data.get('email')
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT id, password_hash, role, is_verified FROM users WHERE email = %s", (email,))
            user = cursor.fetchone()
            if not user or not check_password_hash(user['password_hash'], data.get('password')):
                current_app.logger.error(f"AUTH ERROR: Failed signin attempt for {email} - Invalid credentials")
                return jsonify({"error": "Invalid credentials"}), 401
            if not user['is_verified']:
                current_app.logger.error(f"AUTH ERROR: Failed signin attempt for {email} - Unverified account")
                return jsonify({"error": "Account not verified."}), 403
            
            current_app.logger.info(f"AUTH SUCCESS: User logged in - {email}")
            return jsonify({"token": generate_token(user['id'], user['role'])}), 200
    except Exception as e:
        current_app.logger.error(f"AUTH ERROR: Signin crashed for {email}. Details: {str(e)}")
        return jsonify({"error": "Signin failed"}), 500
    finally:
        connection.close()

@auth_bp.route('/api/auth/change-password', methods=['POST'])
@token_required
def change_password(current_user_id, role):
    data = request.json
    old_password = data.get('old_password')
    new_password = data.get('new_password')
    
    if not is_valid_password(new_password):
        return jsonify({"error": "New password does not meet security requirements."}), 400

    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT password_hash FROM users WHERE id = %s", (current_user_id,))
            user = cursor.fetchone()
            if not check_password_hash(user['password_hash'], old_password):
                current_app.logger.error(f"AUTH ERROR: Password change denied for User ID {current_user_id} - Incorrect old password")
                return jsonify({"error": "Incorrect old password."}), 400
                
            cursor.execute("UPDATE users SET password_hash = %s WHERE id = %s", 
                           (generate_password_hash(new_password), current_user_id))
            connection.commit()
            current_app.logger.info(f"AUTH SUCCESS: Password successfully changed for User ID {current_user_id}")
            return jsonify({"message": "Password updated successfully"}), 200
    except Exception as e:
        current_app.logger.error(f"AUTH ERROR: Password change crashed for User ID {current_user_id}. Details: {str(e)}")
        return jsonify({"error": "Password update failed"}), 500
    finally:
        connection.close()

@auth_bp.route('/api/auth/change-email', methods=['PUT'])
@token_required
def change_email(current_user_id, role):
    data = request.json
    new_email = data.get('new_email')
    password = data.get('password')

    if not new_email or not password:
        return jsonify({"error": "New email and current password are required."}), 400

    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT password_hash FROM users WHERE id = %s", (current_user_id,))
            user = cursor.fetchone()
            if not check_password_hash(user['password_hash'], password):
                current_app.logger.error(f"AUTH ERROR: Email change denied for User ID {current_user_id} - Incorrect password")
                return jsonify({"error": "Incorrect password. Email update denied."}), 401
                
            cursor.execute("SELECT id FROM users WHERE email = %s", (new_email,))
            if cursor.fetchone():
                current_app.logger.error(f"AUTH ERROR: Email change failed for User ID {current_user_id} - Email {new_email} already in use")
                return jsonify({"error": "That email is already in use by another account."}), 409
                
            cursor.execute("UPDATE users SET email = %s WHERE id = %s", (new_email, current_user_id))
            connection.commit()
            current_app.logger.info(f"AUTH SUCCESS: Email successfully updated to {new_email} for User ID {current_user_id}")
            return jsonify({"message": "Email address updated successfully"}), 200
    except Exception as e:
        current_app.logger.error(f"AUTH ERROR: Email change crashed for User ID {current_user_id}. Details: {str(e)}")
        return jsonify({"error": "Email update failed"}), 500
    finally:
        connection.close()