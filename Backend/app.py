import os
import logging
from logging.handlers import RotatingFileHandler
from flask import Flask, request
from flask_cors import CORS
from dotenv import load_dotenv

# 1. Load environment variables FIRST
load_dotenv()

# 2. Import blueprints
from auth_routes import auth_bp
from order_routes import orders_bp
from product_routes import products_bp
from user_routes import users_bp
from health_routes import health_bp
from admin_routes import admin_bp
from log_routes import logs_bp

app = Flask(__name__)
CORS(app, resources={r"/api/*": {"origins": "*"}})

# 3. Configure File Loggers
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')

# --- BACKEND LOGGERS ---
backend_info = RotatingFileHandler('/var/log/quickbasket/backend/access.log', maxBytes=10485760, backupCount=5)
backend_info.setLevel(logging.INFO)
backend_info.setFormatter(formatter)

backend_error = RotatingFileHandler('/var/log/quickbasket/backend/error.log', maxBytes=10485760, backupCount=5)
backend_error.setLevel(logging.ERROR)
backend_error.setFormatter(formatter)

app.logger.setLevel(logging.INFO)
app.logger.addHandler(backend_info)
app.logger.addHandler(backend_error)

# --- FRONTEND LOGGERS (For React/Client crashes) ---
frontend_logger = logging.getLogger('frontend')
frontend_logger.setLevel(logging.INFO)

frontend_info = RotatingFileHandler('/var/log/quickbasket/frontend/access.log', maxBytes=10485760, backupCount=5)
frontend_info.setLevel(logging.INFO)
frontend_info.setFormatter(formatter)

frontend_error = RotatingFileHandler('/var/log/quickbasket/frontend/error.log', maxBytes=10485760, backupCount=5)
frontend_error.setLevel(logging.ERROR)
frontend_error.setFormatter(formatter)

frontend_logger.addHandler(frontend_info)
frontend_logger.addHandler(frontend_error)

# 4. Global API Middleware (Automatically logs backend requests)
@app.after_request
def log_api_activity(response):
    log_msg = f"API Called: {request.method} {request.path} - Status: {response.status_code}"
    
    if response.status_code >= 400:
        app.logger.error(log_msg)
    else:
        app.logger.info(log_msg)
        
    return response

@app.errorhandler(Exception)
def log_unhandled_exceptions(e):
    app.logger.error(f"CRITICAL API CRASH: {request.method} {request.path} - Error: {str(e)}")
    return {"error": "Internal Server Error"}, 500

# 5. Register blueprints
app.register_blueprint(auth_bp)
app.register_blueprint(orders_bp)
app.register_blueprint(products_bp)
app.register_blueprint(users_bp)
app.register_blueprint(health_bp)
app.register_blueprint(admin_bp)
app.register_blueprint(logs_bp)

# 6. AWS ELB Health Check
@app.route('/')
def elb_health_check():
    return "OK", 200

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)