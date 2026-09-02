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

# 3. Configure Dual File Loggers
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')

# Routes logging.INFO to the access log
info_handler = RotatingFileHandler('/var/log/quickbasket/backend-access.log', maxBytes=10485760, backupCount=5)
info_handler.setLevel(logging.INFO)
info_handler.setFormatter(formatter)

# Routes logging.ERROR to the error log
error_handler = RotatingFileHandler('/var/log/quickbasket/backend-error.log', maxBytes=10485760, backupCount=5)
error_handler.setLevel(logging.ERROR)
error_handler.setFormatter(formatter)

app.logger.setLevel(logging.INFO)
app.logger.addHandler(info_handler)
app.logger.addHandler(error_handler)

# 4. Global API Middleware (Automatically logs every request)
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