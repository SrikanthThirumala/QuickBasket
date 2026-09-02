import logging
from flask import Blueprint, request, jsonify, current_app

logs_bp = Blueprint('logs', __name__)
frontend_logger = logging.getLogger('frontend')

@logs_bp.route('/api/logs/client', methods=['POST'])
def ingest_client_logs():
    try:
        data = request.json
        level = data.get('level', 'error')
        message = data.get('message', 'Unknown frontend error')
        details = data.get('details', '')
        
        log_string = f"FRONTEND {level.upper()}: {message} | Details: {details}"
        
        # Route to /var/log/quickbasket/frontend/
        if level == 'info':
            frontend_logger.info(log_string)
        else:
            frontend_logger.error(log_string)
            
        return jsonify({"status": "logged"}), 200
    except Exception as e:
        # If the ingestion itself fails, log it to the backend error file
        current_app.logger.error(f"LOG INGESTION ERROR: Failed to parse frontend log. Details: {str(e)}")
        return jsonify({"error": "Failed to log"}), 500