FROM python:3.11-slim

# Prevent Python from writing .pyc files and buffer streams
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Upgrade pip and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Copy the rest of your blog application files
COPY . .

EXPOSE 5000

# Tuned to exactly 2 workers for your 1 vCPU shape
CMD ["gunicorn", "--workers", "2", "--bind", "0.0.0.0:5000", "app:app"]
