import os
import psycopg2

conn = psycopg2.connect(
    host = 'localhost',
    database = 'top5db',
    user = os.environ['DB_USERNAME'],
    password = os.environ['DB_PASSWORD'],
)

cur = conn.cursor()

cur.execute('DROP TABLE IF EXISTS users CASCADE')
cur.execute('DROP TABLE IF EXISTS user_followers')
cur.execute('DROP TABLE IF EXISTS category CASCADE')
cur.execute('DROP TABLE IF EXISTS review')

cur.execute('CREATE TABLE users (id SERIAL PRIMARY KEY,'
            'username VARCHAR(20) UNIQUE NOT NULL,'
            'password VARCHAR(254) NOT NULL,'
            'email VARCHAR(254) UNIQUE NOT NULL,'
            'profile_pic VARCHAR(254),'
            'background_pic VARCHAR(254));'
)

cur.execute('CREATE TABLE user_followers (id SERIAL PRIMARY KEY,'
            'user_id INT,'
            'CONSTRAINT fk_followers_users FOREIGN KEY (user_id) REFERENCES users (id),'
            'follower_id INT,'
            'CONSTRAINT fk_folo_usr FOREIGN KEY (follower_id) REFERENCES users (id));'
)
cur.execute('CREATE TABLE category (id SERIAL PRIMARY KEY,'
            'user_id INT,'
            'CONSTRAINT fk_category_user FOREIGN KEY (user_id) REFERENCES users (id),'
            'title VARCHAR(15) NOT NULL);'
)
cur.execute('CREATE TABLE review (id SERIAL PRIMARY KEY,'
            'category_id INT,'
            'CONSTRAINT fk_category_review FOREIGN KEY (category_id) REFERENCES category (id),'
            'user_id INT,'
            'CONSTRAINT fk_review_users FOREIGN KEY (user_id) REFERENCES users (id),'
            'title VARCHAR(50) NOT NULL,'
            'position INT NOT NULL,'
            'description TEXT);'
)

conn.commit()
cur.close()
conn.close()