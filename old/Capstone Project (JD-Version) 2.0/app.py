import logging
from flask import Flask, json, render_template, request, url_for, redirect
from pydantic import BaseModel
app = Flask(__name__, template_folder='./templates')


#creating the inventory system
class Inventory(BaseModel):
    name:str
    quantity:int
    price:float

class User(BaseModel):
    username:str
    password:str

class UserManager():

    def __init__(self, fileName):
        self.fileName = fileName

    def getUser(self):
        emptyList = []
        with open(self.fileName, 'r') as f:
            for line in f:
                line=line.strip()
                if line:
                    username, password = line.split(',')
                    user = User(username=username, password=password)
                    emptyList.append(user)
        return emptyList

    def getUserJson(self):
        users = []
        with open(self.fileName, 'r') as f:
            for line in f:
                line=line.strip()
                if line:
                    username, password = line.split(',')
                    user = {
                        "username": username,
                        "password": password
                    }
                    users.append(user)
        return {"users": users}
                    

    
    #checking if user is valid
    def validateUser(self, username:str, password:str):
        userFound = False
        with open(self.fileName, 'r') as f:
            for line in f:
                line=line.strip()
                if not line:
                    continue
                parts=line.split(',')
                if len(parts)!=2:
                    continue
                u_name, u_password = parts
                if u_name == username and u_password == password:
                    userFound = True

        #return print(userFound)
                    
        if userFound:
            #return True
            return True
        else:
            return False
        


class InventoryManager():

    #writing everything to a file // Will do SQLLite later
    def __init__(self, fileName):
        self.fileName = fileName

    #Getting inventory from a file
    def getInventory(self):
        emptyList = []
        with open(self.fileName, 'r') as f:
            for line in f:
                line=line.strip()
                if line:
                    name, quantity, price = line.split(',')
                    inventory = Inventory(name=name, quantity=int(quantity), price=float(price))
                    emptyList.append(inventory)
        return {"inventory": emptyList}
    
    def getInventoryJson(self):
        products = []
        with open(self.fileName, 'r') as f:
            for line in f:
                line = line.strip()
                if line:
                    name, quantity, price = line.split(',')
                    product = {
                        "name": name,
                        "quantity": quantity,
                        "price": price
                    }
                    products.append(product)
        return {"inventory": products}   

    #adding to inventory
    def addToInventory(self, name, quantity, price):
        with open(self.fileName, 'a') as f:
            f.write(f"{name},{quantity},{price}\n")
        return {"message": "Item added to inventory"}

#simulating API Calls
inventoryManager = InventoryManager('inventoryDatabase.txt')
userManager = UserManager('UserDatabase.txt')

@app.route('/')
def main():
    return render_template('main.html')

#submitting data into a form
@app.route('/enterData', methods=['GET', 'POST'])
def enter_data():

    #Grabs data from the form
    if request.method == 'POST':
        item_name = request.form['item_name']
        quantity = request.form['quantity']
        price = request.form['price']
        
        logging.info(f"Received data: Item Name: {item_name}, Quantity: {quantity}, Price: {price}")
        
        inventoryManager.addToInventory(name=item_name, quantity=int(quantity), price=float(price))

        #renders the submission successfull page
        return redirect(url_for('submission'))
    
    #Renders the form page
    return render_template('enterData.html')

#Successfull submission page
@app.route('/submission')
def submission():
    return render_template('submission.html')


#get inventory // Now works
@app.route('/inventory')
def view_inventory():
    getInventory = inventoryManager.getInventory()
    return render_template('inventory.html', content=getInventory)

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        logging.info(f"Received login attempt: Username: {username}, Password: {password}")
        checkUser = userManager.validateUser(username=username, password=password)
        if checkUser == True:
            return redirect(url_for('userMain'))  
    return render_template('login.html')

@app.route('/userMain')
def userMain():
    return render_template('userMain.html')

#Calls functions that convert the data into JSON and outputs it to a file
userData = userManager.getUserJson()
inventoryData = inventoryManager.getInventoryJson()
userJson = json.dumps(userData)
inventoryJson = json.dumps(inventoryData)
with open('appData.json', 'w') as f:
    f.write(userJson)
    f.write('\n')
    f.write(inventoryJson)


if __name__ == '__main__':
    app.run(debug=True)


#notes
#both inventory data and user data is being written to a file
#all data is being written in a JSON format and output to a JSON file