import requests
from flask import Flask, render_template, request, redirect, url_for, flash, session

app = Flask(__name__)
app.secret_key = 'a_secure_random_secret_key'  # Replace with a real secret key

# Configuration for backend services
BFF_API_URL = "http://nginx-proxy:80/api"

@app.route('/')
def home():
    """
    Renders the home page or a partial for AJAX requests.
    Fetches deals and categories from the BFF, supporting filters and login status.
    """
    deals = []
    categories = []
    error = None
    
    search_query = request.args.get('search', '')
    category_filter = request.args.get('category', '')
    limit = 12 if 'user' in session else 4

    try:
        deal_params = {'limit': limit, 'search': search_query, 'category': category_filter}
        deal_params = {k: v for k, v in deal_params.items() if v}
        
        deals_response = requests.get(f"{BFF_API_URL}/deals", params=deal_params)
        deals_response.raise_for_status()
        deals = deals_response.json()

        if 'user' in session:
            categories_response = requests.get(f"{BFF_API_URL}/categories")
            categories_response.raise_for_status()
            categories = categories_response.json()

    except requests.exceptions.RequestException as e:
        print(f"Error fetching data from BFF: {e}")
        error = "Could not load data at the moment. Please try again later."

    # If this is an AJAX request, return only the deal cards partial
    if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
        return render_template(
            'deal_cards.html',
            deals=deals,
            error=error,
            search_query=search_query,
            category_filter=category_filter
        )

    # Otherwise, render the full page
    return render_template(
        'index.html',
        deals=deals,
        categories=categories,
        error=error,
        user=session.get('user'),
        search_query=search_query,
        category_filter=category_filter
    )

@app.route('/login', methods=['GET', 'POST'])
def login():
    """
    Handles user login by calling the auth service via the BFF.
    """
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        
        try:
            response = requests.post(f"{BFF_API_URL}/auth/login", json={'username': username, 'password': password})
            
            if response.ok:
                data = response.json()
                session['user'] = data.get('uid')
                session['token'] = data.get('token')
                flash('Login successful!', 'success')
                return redirect(url_for('home'))
            else:
                flash('Invalid username or password.', 'danger')
        except requests.exceptions.RequestException as e:
            flash('An error occurred while trying to log in. Please try again later.', 'danger')

    return render_template('login.html', is_login_mode=True)

@app.route('/signup', methods=['GET', 'POST'])
def signup():
    """
    Handles user registration by calling the auth service via the BFF.
    """
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        email = request.form['email']
        
        try:
            response = requests.post(f"{BFF_API_URL}/auth/signup", json={'username': username, 'password': password, 'email': email})

            if response.status_code == 201:
                flash('Account created successfully! Please log in.', 'success')
                return redirect(url_for('login'))
            else:
                try:
                    error_data = response.json()
                    flash(error_data.get('error', 'Signup failed. Please try again.'), 'danger')
                except ValueError:
                    flash('Signup failed due to a server error. Please try again later.', 'danger')
        except requests.exceptions.RequestException as e:
            flash('An error occurred during signup. Please try again later.', 'danger')
            
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
    app.run(host='0.0.0.0', port=5000, debug=True)