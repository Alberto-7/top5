import os
import psycopg2
from flask import Flask,session
from backend import auth, category, recommendation
from flask_cors import CORS
from flask_jwt_extended import JWTManager

app = Flask(__name__)
app.config['SECRET_KEY'] = 'abc123'
app.config['JWT_SECRET_KEY'] = 'super-secret'
jwt = JWTManager(app)
CORS(app, supports_credentials=True)

def get_db():
    conn = psycopg2.connect(
    host = 'localhost',
    database = 'top5db',
    user = os.environ['DB_USERNAME'],
    password = os.environ['DB_PASSWORD'],
)
    return conn

app.register_blueprint(auth.bp)
app.register_blueprint(category.bp)
app.register_blueprint(recommendation.bp)

if __name__ == '__main__':
    session.clear()
    app.run(debug=True)
