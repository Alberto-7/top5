import ast, app
from flask import (Flask,Blueprint,g,request,session,jsonify)
import psycopg2.extras

from flask_cors import CORS
from flask_jwt_extended import get_jwt_identity,jwt_required,JWTManager


bp = Blueprint('category',__name__)
CORS(bp)

@bp.route('/api/get_all_category/<int:user_id>', methods=['GET'])
def get_all_category(user_id):
    conn = app.get_db()
    cur = conn.cursor(cursor_factory= psycopg2.extras.RealDictCursor)

    try:
        cur.execute('SELECT id, title FROM category '
                    'WHERE user_id = %s',
                    (user_id,))

        data = cur.fetchall()
        cur.close()
        conn.close()
    except conn.IntegrityError:
        return {'Error': 'None'},400

    return data,200

@bp.route('/api/get_cat_reviews/<int:cat_id>', methods=['GET'])
def get_cat_reviews(cat_id):
    conn = app.get_db()
    cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)

    try:
        cur.execute('SELECT category_id, title, position, description FROM review '
                    'WHERE category_id = %s '
                    'ORDER BY position ASC',
                    (cat_id,))
        data = cur.fetchall()
        cur.close()
        conn.close()
    except conn.IntegrityError:
        return {'Error': 'Unable to fetch reviews'},400

    dict_result = []
    for row in data:
        dict_result.append(dict(row))

    return dict_result,200

@bp.route('/api/create_review/<int:category_id>', methods=['POST'])
@jwt_required()
def create_review(category_id):
    if request.method == 'POST':
        data = request.data.decode('utf-8')
        data = ast.literal_eval(data)

        title = data['title']
        description = data['description']
        position = data['position']
        current_user = get_jwt_identity()

        conn = app.get_db()
        cur = conn.cursor()

        cur.execute('SELECT position FROM review '
                            'WHERE category_id = %s AND position = %s ',
                            (category_id,position))

        pos_exists = cur.fetchone()
        print(pos_exists)
        if pos_exists:
            return {'Error': f'{pos_exists}, CHANGE RANK OR DELETE REVIEW'},404
        try:
            cur.execute('INSERT INTO review (user_id, category_id, title, description, position)'
                        'VALUES (%s, %s, %s, %s, %s)',
                        (current_user, category_id, title, description, position))
            conn.commit()
            cur.close()
            conn.close()
        except conn.IntegrityError:
            return {'Error': 'Error'},400

    return {'Sucess': f'{title} Inserted'},200

@bp.route('/api/edit_review/<int:cat_id>/<string:category_title>',methods=['PUT']) #Grab category_id
@jwt_required()
def edit_review(cat_id,category_title):
    data = request.data.decode('utf-8')
    data = ast.literal_eval(data)

    new_title = data['title']
    if new_title is None:
        return {'Error': 'Must enter a title.'},400

    new_description = data['description']
    new_position = data['position']

    if new_position < 1 or new_position > 5:
        return {'Error': 'RANK MUST BE BETWEEN 1 - 5.'},404

    conn = app.get_db()
    cur = conn.cursor()
    pos_exists = cur.execute('SELECT position FROM review '
                            'WHERE category_id = %s AND position = %s ',
                            (cat_id,new_position))

    pos_exists = cur.fetchone()

    if pos_exists:
        return {'Error': f'{pos_exists}, CHANGE RANK OR DELETE REVIEW'},404
    try:
        cur.execute('UPDATE review '
                    'SET title = %s, description = %s, position = %s '
                    'WHERE category_id = %s AND title = %s;',
                    (new_title, new_description, new_position, cat_id, category_title))
        conn.commit()
        cur.close()
        conn.close()
    except conn.IntegrityError:
        return {'Error': 'Error'},400

    return {'Updated': f'{category_title} updated to {new_title}'},200

@bp.route('/api/create', methods=['POST'])
@jwt_required()
def create_category():
    if request.method == 'POST':
        data = request.data.decode('utf-8')
        data = ast.literal_eval(data)

        title = data['title']
        current_user = get_jwt_identity()

        conn = app.get_db()
        cur = conn.cursor()
        try:
            cur.execute('SELECT title FROM category '
                        'WHERE user_id = %s AND title = %s',
                        (current_user, title))
            exists = cur.fetchone()
        except:
            return {'Error': 'Database error'},400

        if exists is None:
            try:
                cur.execute('INSERT INTO category (title, user_id)'
                            'VALUES (%s,%s) RETURNING id',
                            (title,current_user))
                conn.commit()
                data = cur.fetchone()
                cur.close()
                conn.close()
            except conn.IntegrityError:
                return {'Error': f'{conn.IntegrityError} Unable to add category.'}

            # dict_result = []
            # for row in data:
            #     dict_result.append(dict(row))

            return {'Success':data[0]},200
        return {"Error": "CATEGORY EXISTS"},400

@bp.route('/api/delete_category/<int:id>',methods=['DELETE'])
@jwt_required()
def delete_category(id):
    conn = app.get_db()
    cur = conn.cursor()

    try:
        cur.execute('DELETE FROM review '
                    'WHERE category_id = %s RETURNING *',
                    (id,))
        deleted_reviews = cur.fetchall()
        cur.execute('DELETE FROM category '
                    'WHERE id = %s RETURNING *',
                    (id,))
        deleted_category = cur.fetchone()
        conn.commit()
        cur.close()
        conn.close()
    except:
        return {'Error': 'Error'},400

    return {'Deleted Category': deleted_category,
            'Deleted Reviews': deleted_reviews},200

@bp.route('/api/delete_review/<string:review_title>', methods=['DELETE'])
@jwt_required()
def delete_review(review_title):
    current_user = get_jwt_identity()
    conn = app.get_db()
    cur = conn.cursor()

    try:
        cur.execute('DELETE FROM review '
                    'WHERE user_id = %s AND title = %s RETURNING *',
                    (current_user,review_title))
        deleted_review = cur.fetchone()
        conn.commit()
        cur.close()
        conn.close()

        if deleted_review is None:
            return {'Error': 'Unable to delete.'},404
    except conn.IntegrityError:
        return {'Error': 'Unable to delete.'},400

    return {'Deleted Review': deleted_review},200