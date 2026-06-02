# Blog Server - Infrastructure as Code Setup

This project uses **Infrastructure as Code (IaC)** principles to configure and deploy the blog server.

## Quick Start

### 1. Automated Setup (Recommended)

Run the setup script to automatically:
- Generate a secure `FLASK_KEY`
- Create a `.env` file with all configuration
- Generate `docker-compose.yml` with best practices

```bash
chmod +x setup.sh
./setup.sh
```

### 2. Manual Setup (If needed)

If you prefer manual control:

```bash
# Create .env file from template
cp .env.example .env

# Edit .env and set your own FLASK_KEY:
# FLASK_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")
```

### 3. Start the Services

```bash
docker-compose up --build
```

## Environment Variables

All configuration is in `.env` file:

| Variable | Default | Purpose |
|----------|---------|---------|
| `FLASK_ENV` | production | Flask environment mode |
| `FLASK_KEY` | (generated) | Flask session/CSRF secret key |
| `POSTGRES_USER` | postgres | PostgreSQL username |
| `POSTGRES_PASSWORD` | postgres | PostgreSQL password |
| `POSTGRES_DB` | yuanhang_blogs | Database name |
| `POSTGRES_PORT` | 5432 | PostgreSQL port |
| `DB_URI` | (auto) | SQLAlchemy connection string |

## Services

1. **PostgreSQL** (`postgres:5432`) - Local database
2. **Flask Blog** (`localhost:5000`) - Main app
3. **Nginx Proxy Manager** (`localhost:81`) - Reverse proxy & SSL/TLS

## Accessing the Application

- Blog: `http://localhost:5000`
- Nginx Admin: `http://localhost:81`
- PostgreSQL: `localhost:5432` (from host)

## Files Generated/Modified

- `.env` - Environment variables (auto-generated, add to .gitignore)
- `docker-compose.yml` - Container orchestration
- `setup.sh` - Infrastructure setup script
- `.env.example` - Template for .env file

## Troubleshooting

### Register/Login Not Working

Check that:
1. `FLASK_KEY` is set in `.env`
2. PostgreSQL container is healthy: `docker-compose ps`
3. Flask container can reach postgres: `docker-compose logs flask-blog`

### Database Issues

```bash
# Reset database (CAUTION: deletes all data)
docker-compose down -v
docker-compose up --build
```

## Security Notes

- **Never commit `.env` file** to Git
- Regenerate `FLASK_KEY` for production
- Change PostgreSQL password for production
- Use strong secrets in production environment
