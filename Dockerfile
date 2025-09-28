FROM python:3.9-alpine

# Установка зависимостей
RUN apk add --no-cache postgresql-client

# Установка Python пакетов
RUN pip install requests psycopg2-binary

WORKDIR /app
COPY scripts/ /app/scripts/

# Создаем скрипт для запуска ETL
COPY run-etl.sh /app/
RUN chmod +x /app/run-etl.sh

CMD ["/app/run-etl.sh"]