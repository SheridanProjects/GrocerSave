import logging
from flask import Flask, jsonify, render_template, request, url_for, redirect
from pydantic import BaseModel
app=Flask(__name__)

#creating the inventory system
class Inventory(BaseModel):
    name:str
    quantity:int
    price:float

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
                    inventory= Inventory(name=name, quantity=int(quantity), price=float(price))
                    emptyList.append({'name': name, 'quantity': int(quantity), 'price': float(price)})
        return {"inventory": emptyList}
    
    #adding to inventory
    def addToInventory(self, name, quantity, price):
        with open(self.fileName, 'a') as f:
            f.write(f"{name},{quantity},{price}\n")
        return {"message": "Item added to inventory"}
    
inventoryManager = InventoryManager('inventory.txt')

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

if __name__ == '__main__':
    app.run(debug=True)

#notes
#change the entire thing to write the data into a file
#change the inventory system to be able to pull from said file
#maybe change that to SQLite later but rn Idk how to fix everything 
#work work work 
