import smtplib, os
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from flask import current_app

def get_smtp_server():
    server = smtplib.SMTP(
        os.getenv("MAIL_SERVER", "smtp.gmail.com"), 
        int(os.getenv("MAIL_PORT", 587))
    )
    server.starttls()
    server.login(os.getenv("MAIL_USERNAME"), os.getenv("MAIL_PASSWORD"))
    return server

def send_otp_email(recipient_email, otp_code):
    sender_email = os.getenv("MAIL_USERNAME")
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
    sender_email = os.getenv("MAIL_USERNAME")
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