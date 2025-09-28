# ETL Pipeline for User Posts Analytics

# Quick Start
# Make script executable and run in Linux
./run.sh
# Make script executable and run in Windows
./run.bat

Скрипт extract.py  (Сбор данных)
Что делает:
-Подключается к API JSONPlaceholder и загружает список всех постов
-Каждый пост содержит: ID пользователя, ID поста, заголовок и текст
-Сохраняет данные в таблицу raw_users_by_posts в PostgreSQL
-Защита от дубликатов: при повторном запуске обновляет существующие записи

Скрипт transform.py (Преобразование данных)
Что делает:
-Анализирует сырые данные из таблицы raw_users_by_posts
-Группирует посты по пользователям и подсчитывает количество постов
-Сортирует пользователей по убыванию количества постов
-Сохраняет результат в витрину top_users_by_posts

Допы выполнить не смог


