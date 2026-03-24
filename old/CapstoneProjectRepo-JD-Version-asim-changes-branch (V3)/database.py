import sqlite3
from flask import g

DATABASE = "app.db"

def get_db():
    db = getattr(g, "_database", None)
    if db is None:
        db = g._database = sqlite3.connect(DATABASE)
        db.row_factory = sqlite3.Row
    return db

def close_db(exception):
    db = getattr(g, "_database", None)
    if db is not None:
        db.close()

def init_db():
    db = get_db()
    cursor = db.cursor()

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL
        );
    """)

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS inventory (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            quantity INTEGER NOT NULL,
            price REAL NOT NULL
        );
    """)

def migrate_from_text_files():
    db = get_db()
    cursor = db.cursor()

    # --- Migrate Users ---
    try:
        with open("UserDatabase.txt", "r") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                username, password = line.split(",")
                try:
                    cursor.execute(
                        "INSERT INTO users (username, password) VALUES (?, ?)",
                        (username, password)
                    )
                except sqlite3.IntegrityError:
                    pass  # user already exists
    except FileNotFoundError:
        pass

    # --- Migrate Inventory ---
    try:
        with open("inventoryDatabase.txt", "r") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                name, quantity, price = line.split(",")
                cursor.execute(
                    "INSERT INTO inventory (name, quantity, price) VALUES (?, ?, ?)",
                    (name, int(quantity), float(price))
                )
    except FileNotFoundError:
        pass

    db.commit()
