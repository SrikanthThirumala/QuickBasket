import os
import smtplib
from email.mime.text import MIMEText

def get_smtp_server():
    host = os.getenv("SMTP_HOST", "smtp.gmail.com")
    port = int(os.getenv("SMTP_PORT", 587))
    user = os.getenv("SMTP_USER", os.getenv("GMAIL_USER"))
    password = os.getenv("SMTP_PASSWORD", os.getenv("GMAIL_APP_PASSWORD"))
    return host, port, user, password

def send_otp_email(recipient_email, otp_code):
    host, port, user, password = get_smtp_server()
    if not user or not password:
        return False

    msg = MIMEText(f"Welcome to QuickBasket!\n\nYour 6-digit verification code is: {otp_code}")
    msg['Subject'] = 'Your QuickBasket Verification Code'
    msg['From'] = f"QuickBasket <{user}>"
    msg['To'] = recipient_email
    
    try:
        with smtplib.SMTP(host, port) as server:
            server.starttls()
            server.login(user, password)
            server.sendmail(user, recipient_email, msg.as_string())
        return True
    except Exception as e:
        print(f"OTP Email Error: {e}")
        return False

def send_order_email(recipient_email, order_id, amount, calories):
    host, port, user, password = get_smtp_server()
    if not user or not password:
        return False

    body = f"Thank you for your order!\n\nOrder ID: #{order_id}\nTotal Amount: ₹{amount}\nEstimated Calories Gained: {calories} kcal\n\nYour delicious groceries are on the way!"
    msg = MIMEText(body)
    msg['Subject'] = f'QuickBasket Order Confirmation #{order_id}'
    msg['From'] = f"QuickBasket <{user}>"
    msg['To'] = recipient_email
    
    try:
        with smtplib.SMTP(host, port) as server:
            server.starttls()
            server.login(user, password)
            server.sendmail(user, recipient_email, msg.as_string())
        return True
    except Exception as e:
        print(f"Order Email Error: {e}")
        return False