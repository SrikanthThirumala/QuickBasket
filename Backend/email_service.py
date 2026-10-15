import smtplib, os, json, boto3
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from flask import current_app
from botocore.exceptions import ClientError

def get_email_credentials():
    secret_name = os.getenv("MAIL_SECRET_NAME")
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
        if current_app:
            current_app.logger.error(f"EMAIL CONFIG ERROR: Failed to retrieve secret from AWS: {str(e)}")
        return None

def get_smtp_server():
    # 1. Fetch credentials from AWS Secrets Manager (Prod) or fallback to .env (Local Dev)
    creds = get_email_credentials()
    
    mail_user = creds.get('MAIL_USERNAME') if creds else os.getenv("MAIL_USERNAME")
    mail_pass = creds.get('MAIL_PASSWORD') if creds else os.getenv("MAIL_PASSWORD")
    
    if not mail_user or not mail_pass:
        raise ValueError("Email credentials are missing in both AWS Secrets Manager and .env fallback.")

    # 2. Establish connection
    server = smtplib.SMTP(
        os.getenv("MAIL_SERVER", "smtp.gmail.com"), 
        int(os.getenv("MAIL_PORT", 587))
    )
    server.starttls()
    server.login(mail_user, mail_pass)
    return server

def send_otp_email(recipient_email, otp_code):
    creds = get_email_credentials()
    sender_email = creds.get('MAIL_USERNAME') if creds else os.getenv("MAIL_USERNAME")
    
    msg = MIMEMultipart()
    msg['From'] = sender_email
    msg['To'] = recipient_email
    msg['Subject'] = "QuickBasket - Verify Your Account"
    
    body = f"Your verification code is: {otp_code}\nThis code will expire in 10 minutes."
    msg.attach(MIMEText(body, 'plain'))
    
    try:
        server = get_smtp_server()
        server.sendmail(sender_email, recipient_email, msg.as_string())
        server.quit()
        current_app.logger.info(f"SUCCESS: OTP email sent to {recipient_email}")
        return True
    except Exception as e:
        current_app.logger.error(f"FAILURE: Failed to send OTP to {recipient_email}. Details: {str(e)}")
        return False

def send_order_email(recipient_email, *args, **kwargs):
    creds = get_email_credentials()
    sender_email = creds.get('MAIL_USERNAME') if creds else os.getenv("MAIL_USERNAME")
    
    msg = MIMEMultipart()
    msg['From'] = sender_email
    msg['To'] = recipient_email
    msg['Subject'] = "QuickBasket - Order Confirmation"
    
    body = "Thank you for your order! Your items are being prepared for shipment."
    msg.attach(MIMEText(body, 'plain'))
    
    try:
        server = get_smtp_server()
        server.sendmail(sender_email, recipient_email, msg.as_string())
        server.quit()
        current_app.logger.info(f"SUCCESS: Order email sent to {recipient_email}")
        return True
    except Exception as e:
        current_app.logger.error(f"FAILURE: Failed to send order confirmation to {recipient_email}. Details: {str(e)}")
        return False