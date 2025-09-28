@echo off
chcp 65001 >nul

echo Creating necessary directories...
if not exist docker-entrypoint-initdb.d mkdir docker-entrypoint-initdb.d

echo Creating init.sql if it doesn't exist...
if not exist docker-entrypoint-initdb.d\init.sql (
    echo -- Таблица для сырых данных > docker-entrypoint-initdb.d\init.sql
    echo CREATE TABLE IF NOT EXISTS raw_users_by_posts ( >> docker-entrypoint-initdb.d\init.sql
    echo     id SERIAL PRIMARY KEY, >> docker-entrypoint-initdb.d\init.sql
    echo     user_id INTEGER NOT NULL, >> docker-entrypoint-initdb.d\init.sql
    echo     post_id INTEGER NOT NULL, >> docker-entrypoint-initdb.d\init.sql
    echo     title TEXT, >> docker-entrypoint-initdb.d\init.sql
    echo     body TEXT, >> docker-entrypoint-initdb.d\init.sql
    echo     loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, >> docker-entrypoint-initdb.d\init.sql
    echo     UNIQUE(user_id, post_id) >> docker-entrypoint-initdb.d\init.sql
    echo ); >> docker-entrypoint-initdb.d\init.sql
    echo. >> docker-entrypoint-initdb.d\init.sql
    echo -- Витрина данных >> docker-entrypoint-initdb.d\init.sql
    echo CREATE TABLE IF NOT EXISTS top_users_by_posts ( >> docker-entrypoint-initdb.d\init.sql
    echo     user_id INTEGER PRIMARY KEY, >> docker-entrypoint-initdb.d\init.sql
    echo     posts_cnt INTEGER NOT NULL, >> docker-entrypoint-initdb.d\init.sql
    echo     calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP >> docker-entrypoint-initdb.d\init.sql
    echo ); >> docker-entrypoint-initdb.d\init.sql
    echo Created init.sql file
)

echo Creating .env file if it doesn't exist...
if not exist .env (
    echo DB_NAME=analytics > .env
    echo DB_USER=postgres >> .env
    echo DB_PASSWORD=password >> .env
    echo API_URL=https://jsonplaceholder.typicode.com/posts >> .env
    echo Created .env file with default values
)

echo Stopping and rebuilding containers...
docker-compose down
docker-compose build --no-cache
docker-compose up -d

echo Waiting for services to start...
timeout /t 15 /nobreak >nul

echo Running initial ETL process...
docker-compose exec -T etl python /app/scripts/extract.py
docker-compose exec -T etl python /app/scripts/transform.py

echo Top 5 users by posts:
docker-compose exec -T postgres psql -U postgres -d analytics -c "SELECT * FROM top_users_by_posts ORDER BY posts_cnt DESC LIMIT 5;"

echo Setup completed successfully!
echo PostgreSQL is running on port 5432
echo ETL service will run automatically via cron
pause