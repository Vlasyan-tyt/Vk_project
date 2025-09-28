#!/bin/bash

# Создаем необходимые директории
mkdir -p docker-entrypoint-initdb.d

# Создаем init.sql если его нет
if [ ! -f docker-entrypoint-initdb.d/init.sql ]; then
    cat > docker-entrypoint-initdb.d/init.sql << 'EOF'
-- Таблица для сырых данных
CREATE TABLE IF NOT EXISTS raw_users_by_posts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    post_id INTEGER NOT NULL,
    title TEXT,
    body TEXT,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, post_id)
);

-- Витрина данных
CREATE TABLE IF NOT EXISTS top_users_by_posts (
    user_id INTEGER PRIMARY KEY,
    posts_cnt INTEGER NOT NULL,
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
EOF
    echo "Created init.sql file"
fi

# Создаем .env файл если его нет
if [ ! -f .env ]; then
    cat > .env << EOF
DB_NAME=analytics
DB_USER=postgres
DB_PASSWORD=password
API_URL=https://jsonplaceholder.typicode.com/posts
EOF
    echo "Created .env file with default values"
fi
# Загружаем переменные окружения
set -a
source .env
set +a

# Останавливаем и пересобираем контейнеры
echo "Stopping and rebuilding containers..."
docker-compose down
docker-compose build --no-cache
docker-compose up -d

echo "Waiting for services to start..."
sleep 10

# Выполняем первоначальный ETL
echo "Running initial ETL process..."
docker-compose exec etl python /app/scripts/extract.py
docker-compose exec etl python /app/scripts/transform.py

# Показываем результат
echo "Top 5 users by posts:"
docker-compose exec postgres psql -U $DB_USER -d $DB_NAME -c "SELECT * FROM top_users_by_posts ORDER BY posts_cnt DESC LIMIT 5;"

echo "Setup completed successfully!"
echo "PostgreSQL is running on port 5432"
echo "ETL service will run automatically via cron"