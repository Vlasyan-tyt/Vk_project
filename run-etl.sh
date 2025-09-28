#!/bin/sh

# Ждем готовности PostgreSQL
until pg_isready -h postgres -U $DB_USER -d $DB_NAME; do
  echo "Waiting for database..."
  sleep 2
done

# Запускаем ETL процесс
echo "Starting ETL process..."
python /app/scripts/extract.py
python /app/scripts/transform.py

# Запускаем cron для регулярного выполнения
crond -f