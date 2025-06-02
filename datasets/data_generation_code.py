import random
import pandas as pd
from faker import Faker
import gender_guesser.detector as gender

fake = Faker()
d = gender.Detector()

# Function to determine gender based on first name
def get_gender(first_name):
    # Use gender-guesser to infer gender
    result = d.get_gender(first_name)
    if result in ['male', 'mostly_male']:
        return "Male"
    elif result in ['female', 'mostly_female']:
        return "Female"
    else:
        return random.choice(["Male", "Female"])  # Fallback for unknown names

# Generate Customers (1,200)
customers = []
for i in range(1, 1201):
    first_name = fake.first_name()
    customers.append({
        "CustomerID": i,
        "FirstName": first_name,
        "LastName": fake.last_name(),
        "Gender": get_gender(first_name),  # Assign gender based on first name
        "Email": fake.email(),
        "Phone": fake.phone_number(),
        "Address": fake.street_address(),
        "City": fake.city(),
        "State": fake.state(),
        "Country": fake.country(),
        "DateRegistered": fake.date_between(start_date="-5y", end_date="today")
    })

# Save to CSV
pd.DataFrame(customers).to_csv("customers.csv", index=False)


# Generate Categories (10 categories)
categories = [
    {"CategoryID": 1, "CategoryName": "Electronics"},
    {"CategoryID": 2, "CategoryName": "Clothing"},
    {"CategoryID": 3, "CategoryName": "Books"},
    {"CategoryID": 4, "CategoryName": "Home & Kitchen"},
    {"CategoryID": 5, "CategoryName": "Sports"},
    {"CategoryID": 6, "CategoryName": "Beauty"},
    {"CategoryID": 7, "CategoryName": "Toys"},
    {"CategoryID": 8, "CategoryName": "Grocery"},
    {"CategoryID": 9, "CategoryName": "Automotive"},
    {"CategoryID": 10, "CategoryName": "Health"}
]
pd.DataFrame(categories).to_csv("categories.csv", index=False)


# Generate Products (150 products)
products = []
categories = {
    1: {"name": "Electronics", "items": ["Smartphone", "Laptop", "Headphones", "Smartwatch", "Tablet"], "price_range": (100, 2000)},
    2: {"name": "Clothing", "items": ["T-Shirt", "Jeans", "Jacket", "Sweater", "Shoes"], "price_range": (10, 200)},
    3: {"name": "Books", "items": ["Novel", "Biography", "Science Fiction", "Cookbook", "Art Book"], "price_range": (5, 50)},
    4: {"name": "Home & Kitchen", "items": ["Blender", "Coffee Maker", "Cutting Board", "Air Fryer", "Knife Set"], "price_range": (20, 500)},
    5: {"name": "Sports", "items": ["Treadmill", "Yoga Mat", "Dumbbells", "Resistance Bands", "Skipping Rope"], "price_range": (30, 1000)},
    6: {"name": "Beauty", "items": ["Moisturizer", "Mascara", "Lipstick", "Foundation", "Serum"], "price_range": (5, 100)},
    7: {"name": "Toys", "items": ["LEGO Set", "Puzzle", "Remote Control Car", "Action Figures", "Toy Piano"], "price_range": (10, 150)},
    8: {"name": "Grocery", "items": ["Quinoa", "Rice", "Almond Butter", "Spinach", "Milk"], "price_range": (2, 50)},
    9: {"name": "Automotive", "items": ["Engine Oil", "Car Wax", "Tires", "GPS System", "Headlights"], "price_range": (20, 500)},
    10: {"name": "Health", "items": ["Multivitamins", "Protein Shake", "Sleep Aid", "Immunity Syrup", "Omega-3 Softgels"], "price_range": (10, 100)}
}

for i in range(1, 151):
    # Randomly select a category
    category_id = random.choice(list(categories.keys()))
    category = categories[category_id]
    
    # Randomly select an item from the category's list of items
    product_name = random.choice(category["items"]) + " " + fake.word().capitalize()
    
    # Generate a realistic price within the category's price range
    price_range = category["price_range"]
    price = round(random.uniform(price_range[0], price_range[1]), 2)
    
    # Add the product to the list
    products.append({
        "ProductID": i,
        "ProductName": product_name,
        "CategoryID": category_id,
        "SupplierID": random.choice(list(range(1, 21))),
        "Price": price,
        "Description": fake.sentence(),
        "DateAdded": fake.date_between(start_date="-3y", end_date="today")
    })

# Save to CSV
pd.DataFrame(products).to_csv("products.csv", index=False)

# Generate Orders (60,000 orders)
orders = []
product_price_map = {product["ProductID"]: product["Price"] for product in products}
customers_ids = list(range(1, 1201))  # 1,200 customers
for i in range(1, 60001):
    product_id = random.randint(1, 150)  # Random product for each order
    quantity = random.randint(1, 10)  # Random quantity between 1 and 10
    price = product_price_map[product_id]  # Get the price of the selected product
    total_amount = round(quantity * price, 2)  # Calculate TotalAmount
    order_date = fake.date_between(start_date="-2y", end_date="today")
    status = random.choice(["Pending", "Shipped", "Delivered", "Cancelled"])
    
    orders.append({
        "OrderID": i,
        "ProductID": product_id,
        "CustomerID": random.choice(customers_ids),
        "OrderDate": order_date,
        "OrderQuantity": quantity,
        "TotalAmount": total_amount,
        "Status": status
    })

# Save the orders data to a CSV file
pd.DataFrame(orders).to_csv("orders.csv", index=False)

# Generate Payments (60,000 payments)
payments = []
payment_methods = ["Credit Card", "Debit Card", "PayPal", "Bank Transfer"]
for order in orders:
    if order["Status"] not in ["Cancelled", "Pending"]:  # Only paid orders have payments
        payment_date = fake.date_between_dates(
            date_start=order["OrderDate"], 
            date_end=fake.date_between(start_date=order["OrderDate"], end_date="+1y")
        )
        payments.append({
            "PaymentID": len(payments) + 1,
            "OrderID": order["OrderID"],
            "PaymentMethod": random.choice(payment_methods),
            "Amount": order["TotalAmount"],  # Payment amount matches order total
            "PaymentDate": payment_date
        })

# Save the payments data to a CSV file
pd.DataFrame(payments).to_csv("payments.csv", index=False)

# Generate Shipments (Only for Shipped/Delivered orders)
shipments = []
carriers = ["FedEx", "UPS", "DHL", "USPS"]
for order in orders:
    if order["Status"] in ["Shipped", "Delivered"]:  # Only shipped/delivered orders have shipments
        shipment_date = fake.date_between_dates(
            date_start=order["OrderDate"], 
            date_end=fake.date_between(start_date=order["OrderDate"], end_date="+10d")
        )
        shipments.append({
            "ShipmentID": len(shipments) + 1,
            "OrderID": order["OrderID"],
            "ShipmentDate": shipment_date,
            "Carrier": random.choice(carriers),
            "TrackingNumber": fake.uuid4()
        })

# Save the shipments data to a CSV file
pd.DataFrame(shipments).to_csv("shipments.csv", index=False)

# Generate Reviews (~30 reviews per product, ~4,500 total reviews)
reviews = []
ordered_products = [(order["ProductID"], order["CustomerID"]) for order in orders]
for product_id in range(1, 151):  # 150 products
    for _ in range(random.randint(25, 35)):  # ~30 reviews per product
        # Ensure the reviewer is a customer who ordered the product
        valid_customers = [customer_id for pid, customer_id in ordered_products if pid == product_id]
        if valid_customers:
            customer_id = random.choice(valid_customers)
            review_date = fake.date_between(start_date="-1y", end_date="today")
            reviews.append({
                "ReviewID": len(reviews) + 1,
                "ProductID": product_id,
                "CustomerID": customer_id,
                "Rating": random.randint(1, 5),
                "Comment": fake.sentence(),
                "ReviewDate": review_date
            })

# Save the reviews data to a CSV file
pd.DataFrame(reviews).to_csv("reviews.csv", index=False)

# Generate Inventory (150 inventory records)
inventory = []
for i in range(1, 151):
    inventory.append({
        "InventoryID": i,
        "ProductID": i,
        "QuantityInStock": random.randint(0, 500),
        "ReorderLevel": random.randint(10, 50)
    })

# Save the inventory data to a CSV file
pd.DataFrame(inventory).to_csv("inventory.csv", index=False)

print("All CSV files have been generated successfully!")