import logging
from flask import Flask, render_template, request, redirect, url_for
from database import get_db, init_db, close_db, migrate_from_text_files

app = Flask(__name__, template_folder='./templates')

# Register teardown
app.teardown_appcontext(close_db)

#User Repository
class UserRepository:
    def validate_user(self, username, password):
        db = get_db()
        cursor = db.cursor()
        cursor.execute("SELECT * FROM users WHERE username=? AND password=?", (username, password))
        return cursor.fetchone() is not None

#Inventory Repository
class InventoryRepository:
    def add_item(self, name, quantity, price):
        db = get_db()
        cursor = db.cursor()
        cursor.execute(
            "INSERT INTO inventory (name, quantity, price) VALUES (?, ?, ?)",
            (name, quantity, price)
        )
        db.commit()

    def get_inventory(self):
        db = get_db()
        cursor = db.cursor()
        cursor.execute("SELECT * FROM inventory")
        rows = cursor.fetchall()
        return rows

user_repo = UserRepository()
inventory_repo = InventoryRepository()

#App routes
@app.route('/')
def main():
    return render_template('main.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']

        if user_repo.validate_user(username, password):
            return redirect(url_for('userMain'))

    return render_template('login.html')

@app.route('/userMain')
def userMain():
    return render_template('userMain.html')

@app.route('/enterData', methods=['GET', 'POST'])
def enter_data():
    if request.method == 'POST':
        name = request.form['item_name']
        quantity = int(request.form['quantity'])
        price = float(request.form['price'])

        inventory_repo.add_item(name, quantity, price)
        return redirect(url_for('submission'))

    return render_template('enterData.html')

@app.route('/submission')
def submission():
    return render_template('submission.html')

@app.route('/inventory')
def view_inventory():
    items = inventory_repo.get_inventory()
    return render_template('inventory.html', items=items)

#Code for startup
if __name__ == '__main__':
    with app.app_context():
        init_db()
        migrate_from_text_files()
    app.run(debug=True)
