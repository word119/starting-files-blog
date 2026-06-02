#!/bin/bash

# Blog Server Setup Script - Infrastructure as Code

set -e  # Exit on any error

echo "=== Blog Server Setup ==="
echo ""

# Generate a secure Flask key
echo "Generating FLASK_KEY..."
FLASK_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")
echo "Generated FLASK_KEY: $FLASK_KEY"
echo ""

# Create .env file for docker-compose
echo "Creating .env file..."
cat > .env << EOF
# Flask Configuration
FLASK_ENV=production
FLASK_KEY=$FLASK_KEY

# PostgreSQL Configuration
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=yuanhang_blogs
POSTGRES_PORT=5432

# Flask-SQLAlchemy Configuration
DB_URI=postgresql+psycopg2://postgres:postgres@postgres:5432/yuanhang_blogs
EOF

echo ".env file created with:"
cat .env
echo ""

# Backup existing docker-compose.yml
if [ -f docker-compose.yml ]; then
    echo "Backing up existing docker-compose.yml to docker-compose.yml.bak"
    cp docker-compose.yml docker-compose.yml.bak
fi

# Create docker-compose.yml with environment variables
echo "Creating docker-compose.yml..."
cat > docker-compose.yml << 'COMPOSE'
services:
  postgres:
    image: postgres:15-alpine
    restart: always
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - '${POSTGRES_PORT}:5432'
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5

  nginx-proxy-manager:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: always
    ports:
      - '80:80'
      - '443:443'
      - '81:81'
    volumes:
      - ./npm/data:/data
      - ./npm/letsencrypt:/etc/letsencrypt
    depends_on:
      - flask-blog

  flask-blog:
    build: .
    restart: always
    environment:
      FLASK_ENV: ${FLASK_ENV}
      FLASK_KEY: ${FLASK_KEY}
      DB_URI: ${DB_URI}
    ports:
      - "5000:5000"
    depends_on:
      postgres:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
    driver: local
COMPOSE

echo "docker-compose.yml created"
echo ""

echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "1. Build and start containers:"
echo "   docker-compose up --build"
echo ""
echo "2. Access the blog at:"
echo "   http://localhost:5000"
echo ""
echo "3. Access nginx-proxy-manager admin at:"
echo "   http://localhost:81"
echo ""
echo "Your FLASK_KEY has been saved in .env and docker-compose.yml"
echo ""
