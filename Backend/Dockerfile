# 1. Base Image
FROM python:3.9-slim

# 2. Working Directory
WORKDIR /app

# 3. Install Dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 4. Copy Source Code
COPY . .



RUN mkdir -p /var/log/quickbasket/backend /var/log/quickbasket/frontend

# 5. Expose Port
EXPOSE 5000

# 6. Start Command
CMD ["gunicorn", "--workers", "3", "--bind", "0.0.0.0:5000", "app:app"]

#test