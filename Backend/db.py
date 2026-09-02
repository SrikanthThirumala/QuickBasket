import os
import json
import pymysql
import boto3
import logging
from botocore.exceptions import ClientError

def get_db_credentials():
    secret_name = os.getenv("DB_SECRET_NAME")
    region_name = os.getenv("AWS_REGION", "us-west-2")
    if not secret_name:
        return None
    session = boto3.session.Session()
    client = session.client(service_name='secretsmanager', region_name=region_name)
    
    try:
        get_secret_value_response = client.get_secret_value(SecretId=secret_name)
        if 'SecretString' in get_secret_value_response:
            return json.loads(get_secret_value_response['SecretString'])
    except ClientError as e:
        logging.error(f"DATABASE CONFIG ERROR: Failed to retrieve database secret from AWS Secrets Manager: {str(e)}")
        return None

def get_db_connection():
    creds = get_db_credentials()
    host = os.getenv("RDS_HOSTNAME", creds.get('host') if creds else 'localhost')
    user = creds.get('username') if creds else os.getenv("DB_USER", "admin")
    password = creds.get('password') if creds else os.getenv("DB_PASSWORD", "")
    db = os.getenv("DB_NAME", creds.get('dbname', 'quickbasket_db') if creds else 'quickbasket_db')
    port = int(os.getenv("DB_PORT", creds.get('port', 3306) if creds else 3306))
    
    return pymysql.connect(
        host=host,
        user=user,
        password=password,
        database=db,
        port=port,
        cursorclass=pymysql.cursors.DictCursor
    )