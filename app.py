from flask import Flask, render_template, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from flask_caching import Cache
import os
import time

app = Flask(__name__)

# Database configuration
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URI', 'sqlite:///default.db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Cache configuration with Redis
app.config['CACHE_TYPE'] = 'redis'
app.config['CACHE_REDIS_URL'] = os.getenv('REDIS_URL', 'redis://localhost:6379/0')
app.config['CACHE_DEFAULT_TIMEOUT'] = 300  # 5 minutes

# Initialize extensions
db = SQLAlchemy(app)
cache = Cache(app)
CORS(app)


class User(db.Model):
    __tablename__ = "users"
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    age = db.Column(db.String(255), nullable=False)

    def __init__(self, name, age):
        self.name = name
        self.age = age

    def __repr__(self):
        return '%s/%s/%s' % (self.id, self.name, self.age)

    def to_dict(self):
        """Convert user object to dictionary"""
        return {
            'id': self.id,
            'name': self.name,
            'age': self.age
        }


@app.route('/')
def index():
    return render_template('home.html')


@app.route('/crud')
def crud():
    return render_template('crud.html')


@app.route('/data', methods=['POST', 'GET'])
def data():
    # POST - Create a new user
    if request.method == 'POST':
        body = request.json
        name = body.get('name')
        age = body.get('age')

        if not name or not age:
            return jsonify({'error': 'Name and age are required'}), 400

        new_user = User(name, age)
        db.session.add(new_user)
        db.session.commit()

        # Clear cache after creating new user
        cache.delete('all_users')
        print(f"✅ Cache cleared after creating user: {name}")

        return jsonify({
            'status': 'User created successfully!',
            'user': new_user.to_dict()
        }), 201

    # GET - Retrieve all users (with caching)
    if request.method == 'GET':
        # Try to get from cache first
        cached_users = cache.get('all_users')
        
        if cached_users:
            print("📦 Returning users from cache")
            return jsonify(cached_users)

        # If not in cache, query database
        print("🔍 Cache miss - querying database")
        users = User.query.order_by(User.id).all()
        users_list = [user.to_dict() for user in users]
        
        # Store in cache for future requests
        cache.set('all_users', users_list, timeout=300)
        print(f"💾 Cached {len(users_list)} users")

        return jsonify(users_list)


@app.route('/data/<int:id>', methods=['GET', 'DELETE', 'PUT'])
def onedata(id):
    # GET - Retrieve a specific user (with caching)
    if request.method == 'GET':
        cache_key = f'user_{id}'
        cached_user = cache.get(cache_key)
        
        if cached_user:
            print(f"📦 Returning user {id} from cache")
            return jsonify(cached_user)

        print(f"🔍 Cache miss - querying database for user {id}")
        user = User.query.get(id)
        
        if not user:
            return jsonify({'error': 'User not found'}), 404

        user_dict = user.to_dict()
        cache.set(cache_key, user_dict, timeout=300)
        print(f"💾 Cached user {id}")

        return jsonify(user_dict)

    # DELETE - Remove a user
    if request.method == 'DELETE':
        user = User.query.get(id)
        
        if not user:
            return jsonify({'error': 'User not found'}), 404

        db.session.delete(user)
        db.session.commit()

        # Clear cache after deletion
        cache.delete('all_users')
        cache.delete(f'user_{id}')
        print(f"✅ Cache cleared after deleting user {id}")

        return jsonify({
            'status': f'User {id} deleted successfully!'
        })

    # PUT - Update a user
    if request.method == 'PUT':
        body = request.json
        new_name = body.get('name')
        new_age = body.get('age')

        if not new_name or not new_age:
            return jsonify({'error': 'Name and age are required'}), 400

        user = User.query.get(id)
        
        if not user:
            return jsonify({'error': 'User not found'}), 404

        user.name = new_name
        user.age = new_age
        db.session.commit()

        # Clear cache after update
        cache.delete('all_users')
        cache.delete(f'user_{id}')
        print(f"✅ Cache cleared after updating user {id}")

        return jsonify({
            'status': f'User {id} updated successfully!',
            'user': user.to_dict()
        })


@app.route('/cache/clear', methods=['POST'])
def clear_cache():
    """Endpoint to manually clear all cache"""
    cache.clear()
    return jsonify({'status': 'Cache cleared successfully!'}), 200


@app.route('/cache/stats', methods=['GET'])
def cache_stats():
    """Endpoint to check cache status"""
    try:
        # Test Redis connection
        cache.set('test_key', 'test_value', timeout=10)
        test_value = cache.get('test_key')
        cache.delete('test_key')
        
        return jsonify({
            'status': 'Cache is working',
            'backend': 'Redis',
            'url': os.getenv('REDIS_URL'),
            'test_passed': test_value == 'test_value'
        })
    except Exception as e:
        return jsonify({
            'status': 'Cache error',
            'error': str(e)
        }), 500


# Initialize database with retry logic
def init_db():
    max_retries = 5
    retry_count = 0
    
    while retry_count < max_retries:
        try:
            with app.app_context():
                db.create_all()
                print("✅ Database tables created successfully!")
                
                # Test cache connection
                cache.set('init_test', 'success', timeout=10)
                if cache.get('init_test') == 'success':
                    print("✅ Redis cache connected successfully!")
                    cache.delete('init_test')
                break
        except Exception as e:
            retry_count += 1
            print(f"⚠️ Initialization attempt {retry_count}/{max_retries} failed: {e}")
            if retry_count < max_retries:
                time.sleep(2)
            else:
                print("❌ Failed to initialize after maximum retries")
                raise


if __name__ == '__main__':
    init_db()
    app.run(host="0.0.0.0", port=5000, debug=True)