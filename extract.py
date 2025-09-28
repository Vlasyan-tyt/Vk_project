import os
import requests
import psycopg2
import logging
from datetime import datetime

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def get_db_connection():
    return psycopg2.connect(
        host=os.getenv('DB_HOST', 'localhost'),
        database=os.getenv('DB_NAME', 'analytics'),
        user=os.getenv('DB_USER', 'postgres'),
        password=os.getenv('DB_PASSWORD', 'password'),
        port=5432
    )

def main():
    api_url = os.getenv('API_URL', 'https://jsonplaceholder.typicode.com/posts')
    
    try:
        logger.info("Starting data extraction from: %s", api_url)
        response = requests.get(api_url, timeout=30)
        response.raise_for_status()
        posts = response.json()
        logger.info("Received %d posts from API", len(posts))
        
        conn = get_db_connection()
        cur = conn.cursor()
        
        inserted = 0
        for post in posts:
            try:
                cur.execute("""
                    INSERT INTO raw_users_by_posts (user_id, post_id, title, body) 
                    VALUES (%s, %s, %s, %s)
                    ON CONFLICT (user_id, post_id) DO UPDATE SET
                        title = EXCLUDED.title,
                        body = EXCLUDED.body,
                        loaded_at = CURRENT_TIMESTAMP
                """, (post['userId'], post['id'], post['title'], post['body']))
                inserted += 1
            except Exception as e:
                logger.error("Error inserting post %d: %s", post['id'], e)
        
        conn.commit()
        logger.info("Successfully processed %d posts", inserted)
        
    except requests.exceptions.RequestException as e:
        logger.error("API request failed: %s", e)
    except Exception as e:
        logger.error("Unexpected error: %s", e)
    finally:
        if 'conn' in locals():
            conn.close()

if __name__ == "__main__":
    main()