from flask import Flask,session,request,jsonify,Blueprint
import psycopg2.extras
import app
from flask_cors import CORS
from flask_jwt_extended import get_jwt_identity,jwt_required

bp = Blueprint('recommendation', __name__)
CORS(bp)

@bp.route('/api/get_recommended_users', methods=['GET','POST'])
@jwt_required()
def get_recommendations():
    current_user = get_jwt_identity()
    conn = app.get_db()
    cur = conn.cursor()

    try:
        cur.execute('SELECT title FROM review '
                    'WHERE user_id = %s',
                    (current_user,))
        data = cur.fetchall()
        data = list(data)

        ex = []
        for ele in data:
            cur.execute('SELECT user_id,title, description FROM review '
                        'WHERE user_id != %s AND title = %s'
                        'ORDER BY user_id DESC',
                        (current_user, ele))

            ex.append(cur.fetchall())

        ex2 = [x for x in ex if ex if x]
        res_list = [item for sublist in ex2 for item in sublist]

        data = dict()
        for key,title,desc in res_list:
            if key in data.keys():
                data[key] = data[key] + f'/{title}' + f'/{desc}'
            else:
                data[key] = f'{title}/' + desc

        for key in data:
            data[key] = data[key].split('/')
    except:
        return {'Error': 'Error'},400

    return {'Recommended':data},200
