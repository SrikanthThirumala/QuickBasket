import os
from flask import Flask
from flask_cors import CORS
from dotenv import load_dotenv

from auth_routes import auth_bp
from order_routes import orders_bp
from product_routes import products_bp
from user_routes import users_bp
from health_routes import health_bp
from admin_routes import admin_bp

load_dotenv()

app = Flask(__name__)
CORS(app, resources={r"/api/*": {"origins": "*"}})

app.register_blueprint(auth_bp)
app.register_blueprint(orders_bp)
app.register_blueprint(products_bp)
app.register_blueprint(users_bp)
app.register_blueprint(health_bp)
app.register_blueprint(admin_bp)

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)