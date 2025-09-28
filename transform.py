import os
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
    try:
        logger.info("Starting transformation")
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute("SELECT COUNT(*) FROM raw_users_by_posts")
        count = cur.fetchone()[0]
        
        if count == 0:
            logger.warning("No data found in raw_users_by_posts table")
            return
        
        cur.execute("""
            INSERT INTO top_users_by_posts (user_id, posts_cnt)
            SELECT user_id, COUNT(*) as posts_cnt
            FROM raw_users_by_posts
            GROUP BY user_id
            ORDER BY posts_cnt DESC
            ON CONFLICT (user_id) DO UPDATE SET
                posts_cnt = EXCLUDED.posts_cnt,
                calculated_at = CURRENT_TIMESTAMP
        """)
        
        conn.commit()
        logger.info("Successfully updated top users table")
        
    except Exception as e:
        logger.error("Transformation failed: %s", e)
    finally:
        if 'conn' in locals():
            conn.close()

if __name__ == "__main__":
    main()