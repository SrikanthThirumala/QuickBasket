from flask import Blueprint, request, jsonify, current_app

logs_bp = Blueprint('logs', __name__)

@logs_bp.route('/api/logs/client', methods=['POST'])
def ingest_client_logs():
    try:
        data = request.json
        level = data.get('level', 'error')
        message = data.get('message', 'Unknown frontend error')
        details = data.get('details', '')
        
        log_string = f"FRONTEND {level.upper()}: {message} | Details: {details}"
        
        if level == 'info':
            current_app.logger.info(log_string)
        else:
            current_app.logger.error(log_string)
            
        return jsonify({"status": "logged"}), 200
    except Exception as e:
        current_app.logger.error(f"LOG INGESTION ERROR: Failed to parse frontend log. Details: {str(e)}")
        return jsonify({"error": "Failed to log"}), 500