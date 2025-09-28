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
);); 
 
-- Витрина данных 
CREATE TABLE IF NOT EXISTS top_users_by_posts ( 
    user_id INTEGER PRIMARY KEY, 
    posts_cnt INTEGER NOT NULL, 
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
); 
); 
 
-- Витрина данных 
CREATE TABLE IF NOT EXISTS top_users_by_posts ( 
    user_id INTEGER PRIMARY KEY, 
    posts_cnt INTEGER NOT NULL, 
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
); 
); 
 
-- Витрина данных 
CREATE TABLE IF NOT EXISTS top_users_by_posts ( 
    user_id INTEGER PRIMARY KEY, 
    posts_cnt INTEGER NOT NULL, 
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
); 
