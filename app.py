from flask import Flask, render_template, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
import yaml
import os


app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL', 'sqlite:///default.db')
db = SQLAlchemy(app)
CORS(app)


class User(db.Model):
    __tablename__ = "users"
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255))
    age = db.Column(db.String(255))

    def __init__(self, name, age):
        self.name = name
        self.age = age

    def __repr__(self):
        return '%s/%s/%s' % (self.id, self.name, self.age)


@app.route('/')
def index():
    return render_template('home.html')


@app.route('/data', methods=['POST', 'GET'])
def data():
    # POST a data to database
    if request.method == 'POST':
        body = request.json
        name = body['name']
        age = body['age']

        data = User(name, age)
        db.session.add(data)
        db.session.commit()

        return jsonify({
            'status': 'Data is posted to PostgreSQL!',
            'name': name,
            'age': age
        })

    # GET all data from database & sort by id
    if request.method == 'GET':
        data = User.query.order_by(User.id).all()
        data_json = []
        for i in range(len(data)):
            data_dict = {
                'id': str(data[i]).split('/')[0],
                'name': str(data[i]).split('/')[1],
                'age': str(data[i]).split('/')[2]
            }
            data_json.append(data_dict)
        return jsonify(data_json)


@app.route('/data/<string:id>', methods=['GET', 'DELETE', 'PUT'])
def onedata(id):
    # GET a specific data by id
    if request.method == 'GET':
        data = User.query.get(id)
        data_dict = {
            'id': str(data).split('/')[0],
            'name': str(data).split('/')[1],
            'age': str(data).split('/')[2]
        }
        return jsonify(data_dict)

    # DELETE a data
    if request.method == 'DELETE':
        del_data = User.query.filter_by(id=id).first()
        db.session.delete(del_data)
        db.session.commit()
        return jsonify({'status': f'Data {id} is deleted from PostgreSQL!'})

    # UPDATE a data by id
    if request.method == 'PUT':
        body = request.json
        new_name = body['name']
        new_age = body['age']
        edit_data = User.query.filter_by(id=id).first()
        edit_data.name = new_name
        edit_data.age = new_age
        db.session.commit()
        return jsonify({'status': f'Data {id} is updated from PostgreSQL!'})


with app.app_context():
    db.create_all()


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000)  # nosec B104
