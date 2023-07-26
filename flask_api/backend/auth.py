from flask import Flask,Blueprint,request,g,session,flash,jsonify
from werkzeug.security import check_password_hash, generate_password_hash
import app, ast
from flask_session import Session
from flask_cors import CORS
from flask_jwt_extended import create_access_token,get_jwt_identity,jwt_required

bp = Blueprint('auth', __name__)

CORS(bp)

@bp.route('/api/is_following/<int:folo_id>', methods=['GET'])
@jwt_required()
def is_following(folo_id):
    conn = app.get_db()
    cur = conn.cursor()
    curr_user = get_jwt_identity()

    cur.execute('SELECT id FROM user_followers '
                    'WHERE user_id = %s AND follower_id = %s',
                    (curr_user, folo_id))
    is_following = cur.fetchone()
    cur.close()
    conn.close()
    if is_following is None:
        return {'Following': 'NOOO'},201

    return {'Following?': 'YES'},200

def get_following(user_id):
    conn = app.get_db()
    cur = conn.cursor()

    try:
        cur.execute('SELECT COUNT(follower_id) '
                    'FROM user_followers '
                    'WHERE user_id = %s;',
                    (user_id,))
        data = cur.fetchone()
        cur.close()
        conn.close()

        return data[0]
    except conn.IntegrityError:
        return {'ERROR': 'ERROR'},400

def get_followers(user_id):
    conn = app.get_db()
    cur = conn.cursor()

    try:
        cur.execute('SELECT COUNT(follower_id) '
                    'FROM user_followers '
                    'WHERE follower_id = %s;',
                    (user_id,))
        data = cur.fetchone()
        cur.close()
        conn.close()
        return data[0]
    except conn.IntegrityError:
        return {'ERROR': 'ERROR'},400

@bp.route('/api/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        data = request.data.decode('utf-8')
        data = ast.literal_eval(data)

        username = data['username']
        password = data['password']
        email = data['email']

        error = None

        conn = app.get_db()
        cur = conn.cursor()

        if error is None:
            try:
                cur.execute('INSERT INTO users (username, password, email)'
                            'VALUES (%s, %s, %s)',
                            (username, generate_password_hash(password), email)
                )
                conn.commit()
                cur.close()
                conn.close()
            except conn.IntegrityError:
                error = f'User {email} is already registered. Please login'
                return {'Error': 'User registered already'},400

    return {'Success': f'{username} Registered'},200

@bp.route('/api/login', methods=['POST'])
def login():
    if request.method == 'POST':
        data = request.data.decode('utf-8')
        data = ast.literal_eval(data)

        username = data['username']
        password = data['password']
        error = None
        conn = app.get_db()
        cur = conn.cursor()

        cur.execute('SELECT * FROM users WHERE username = (%s)', (username,))
        user = cur.fetchone()

        if user is None:
            error = 'Incorrect username.'
            return {'Error': error},400

        elif not check_password_hash(user[2], password):
            error = 'Incorrect password.'
            return {'Error': error},400

        if error is None:
            access_token = create_access_token(identity=user[0],expires_delta=False)

            following = get_followers(user[0])
            followers = get_following(user[0])

            return {'Success': 'Logged in.',
                    'UID': user[0],
                    'username': data['username'],
                    'following': followers,
                    'followers': following,
                    'token':access_token,
                    'prof_pic': user[4],
                    'background_pic':user[5]},200

    return {'Error': 'Error'},400

@bp.route('/api/get_info/<int:id>', methods=['GET'])
#@jwt_required()
def get_user_info(id):
    #current_user = get_jwt_identity()
    conn = app.get_db()
    cur = conn.cursor()

    try:
        cur.execute('SELECT * FROM users WHERE id = (%s)', (id,))
        user = cur.fetchone()
    except:
        return {'Error': 'Error'},400

    following = get_followers(user[0])
    followers = get_following(user[0])

    return {'Success': 'Logged in.',
                    'UID': user[0],
                    'username': user[1],
                    'following': followers,
                    'followers': following,
                    'token': None,
                    'prof_pic': user[4],
                    'background_pic':user[5]},200

@bp.route('/api/logout')
def logout():
    session.clear()
    return {'Response': 'Logged out succesfully.'},200

@bp.route('/api/follow/<int:folo_id>', methods=['POST',])
@jwt_required()
def follow(folo_id):
    conn = app.get_db()
    cur = conn.cursor()
    user_id = get_jwt_identity()

    if user_id is None:
        return {'Error': 'Unable to follow'},400


    try:
        cur.execute('INSERT INTO user_followers (user_id, follower_id) '
                    'SELECT %s, %s'
                    'WHERE '
                    'NOT EXISTS (SELECT 1 FROM user_followers WHERE user_id = %s AND follower_id = %s)',
                    (user_id,folo_id,user_id,folo_id))
        conn.commit()
        cur.close()
        conn.close()
    except conn.IntegrityError:
        return {'Error': 'Unable to'},400

    return {'Success': f'{folo_id} added to friends.'},200

@bp.route('/api/unfollow/<int:folo_id>', methods=['DELETE'])
@jwt_required()
def unfollow(folo_id):
    conn = app.get_db()
    cur = conn.cursor()
    user_id = get_jwt_identity()
    print(user_id)

    #CHECK IF FOLLOWING?
    try:
        cur.execute('SELECT id FROM user_followers '
                    'WHERE user_id = %s AND follower_id = %s',
                    (user_id, folo_id))
        is_following = cur.fetchone()

        if is_following:
            cur.execute('DELETE FROM user_followers '
                        'WHERE id = %s',
                        (is_following[0],))
            conn.commit()
            cur.close()
            conn.close()
            return {'Deleted': f'{is_following[0]} was deleted.'},200

    except conn.IntegrityError:
        return {'ERROR', f'{conn.IntegrityError}'},400

    # try:
    #     cur.execute('DELETE FROM user_followers '
    #                 'WHERE user_id = %s AND folLower_id = %s RETURNING *',
    #                 (user_id,folo_id))

    #     deleted_row = cur.fetchone()
    #     conn.commit()
    #     cur.close()
    #     conn.close()
    # except conn.IntegrityError:
    #     return {'Error': 'Error'},400

    return {'Error': 'Unable to process.'},400

@bp.route('/api/add_profile_pic/<string:asset>', methods=['PUT'])
@jwt_required()
def add_profile_pic(asset):
    conn = app.get_db()
    cur = conn.cursor()

    current_user = get_jwt_identity()
    print(type(asset))

    try:
        cur.execute('UPDATE users '
                    'SET profile_pic = %s '
                    'WHERE id = %s;',
                    (asset,current_user))
        conn.commit()
        cur.close()
        conn.close()
    except conn.IntegrityError:
        return {'BAD':'BAD'},400

    return {'Added': asset},200

@bp.route('/api/add_background_pic/<string:asset>', methods=['PUT'])
@jwt_required()
def add_background_pic(asset):
    conn = app.get_db()
    cur = conn.cursor()

    current_user = get_jwt_identity()
    print(type(asset))

    try:
        cur.execute('UPDATE users '
                    'SET background_pic = %s '
                    'WHERE id = %s;',
                    (asset,current_user))
        conn.commit()
        cur.close()
        conn.close()
    except conn.IntegrityError:
        return {'BAD':'BAD'},400

    return {'Added': asset},200
