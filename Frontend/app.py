import requests
from flask import Flask, render_template, request, redirect, url_for, flash, session

app = Flask(__name__)
app.secret_key = 'a_secure_random_secret_key'  # Replace with a real secret key

# Configuration for backend services
# These URLs will likely need to be updated based on your service discovery/k8s setup.
AUTH_SERVICE_URL = "http://auth-service:8080"
CATALOG_SERVICE_URL = "http://catalog-service:8080"

@app.route('/')
def home():
    """
    Renders the home page, fetching deals from the catalog service.
    """
    deals = []
    error = None
    try:
        # Fetch deals from the catalog service
        response = requests.get(f"{CATALOG_SERVICE_URL}/api/deals")
        response.raise_for_status()  # Raise an exception for bad status codes
        deals = response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error fetching deals: {e}")
        error = "Could not load deals at the moment. Please try again later."

    return render_template('index.html', deals=deals, error=error, user=session.get('user'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    """
    Handles user login.
    """
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        
        try:
            response = requests.post(f"{AUTH_SERVICE_URL}/api/auth/login", json={'username': username, 'password': password})
            
            if response.ok:
                data = response.json()
                session['user'] = data.get('uid')
                session['token'] = data.get('token')
                flash('Login successful!', 'success')
                return redirect(url_for('home'))
            else:
                error_data = response.json()
                flash(error_data.get('error', 'Login failed.'), 'danger')
        except requests.exceptions.RequestException as e:
            flash('An error occurred while trying to log in.', 'danger')

    return render_template('login.html', is_login_mode=True)

@app.route('/signup', methods=['GET', 'POST'])
def signup():
    """
    Handles user registration.
    """
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        email = request.form['email']
        
        try:
            response = requests.post(f"{AUTH_SERVICE_URL}/api/auth/signup", json={'username': username, 'password': password, 'email': email})

            if response.status_code == 201:
                flash('Account created successfully! Please log in.', 'success')
                return redirect(url_for('login'))
            else:
                error_data = response.json()
                flash(error_data.get('error', 'Signup failed.'), 'danger')
        except requests.exceptions.RequestException as e:
            flash('An error occurred during signup.', 'danger')
            
    return render_template('login.html', is_login_mode=False)

@app.route('/logout')
def logout():
    """
    Logs the user out.
    """
    session.pop('user', None)
    session.pop('token', None)
    flash('You have been logged out.', 'info')
    return redirect(url_for('home'))

if __name__ == '__main__':
    # Use host='0.0.0.0' to be accessible from outside the container
    app.run(host='0.0.0.0', port=5000, debug=True)
