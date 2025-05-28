import random
import pandas as pd
from faker import Faker

fake = Faker()

# Generate Customers (1,200)
customers = []
for i in range(1, 1201):
    customers.append({
        "CustomerID": i,
        "FirstName": fake.first_name(),
        "LastName": fake.last_name(),
        "Email": fake.email(),
        "Phone": fake.phone_number(),
        "Address": fake.street_address(),
        "City": fake.city(),
        "State": fake.state(),
        "Country": fake.country(),
        "DateRegistered": fake.date_between(start_date="-5y", end_date="today")
    })
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

# Generate Suppliers (20 suppliers)
suppliers = []
for i in range(1, 21):
    suppliers.append({
        "SupplierID": i,
        "SupplierName": fake.company(),
        "ContactName": fake.name(),
        "Phone": fake.phone_number(),
        "Email": fake.email(),
        "Address": fake.address().replace("\n", ", ")
    })
pd.DataFrame(suppliers).to_csv("suppliers.csv", index=False)

# Generate Products (150 products)
products = []
categories_ids = list(range(1, 11))
suppliers_ids = list(range(1, 21))
for i in range(1, 151):
    products.append({
        "ProductID": i,
        "ProductName": fake.word().capitalize() + " " + fake.word().capitalize(),
        "CategoryID": random.choice(categories_ids),
        "SupplierID": random.choice(suppliers_ids),
        "Price": round(random.uniform(10, 1000), 2),
        "Description": fake.sentence(),
        "DateAdded": fake.date_between(start_date="-3y", end_date="today")
    })
pd.DataFrame(products).to_csv("products.csv", index=False)

# Generate Orders (60,000 orders)
orders = []
customers_ids = list(range(1, 1201))  # 1,200 customers
for i in range(1, 60001):
    orders.append({
        "OrderID": i,
        "CustomerID": random.choice(customers_ids),
        "OrderDate": fake.date_between(start_date="-2y", end_date="today"),
        "TotalAmount": round(random.uniform(50, 5000), 2),
        "Status": random.choice(["Pending", "Shipped", "Delivered", "Cancelled"])
    })
pd.DataFrame(orders).to_csv("orders.csv", index=False)

# Generate Payments (60,000 payments)
payments = []
payment_methods = ["Credit Card", "Debit Card", "PayPal", "Bank Transfer"]
for i in range(1, 60001):
    payments.append({
        "PaymentID": i,
        "OrderID": i,
        "PaymentMethod": random.choice(payment_methods),
        "Amount": round(random.uniform(50, 5000), 2),
        "PaymentDate": fake.date_between(start_date="-2y", end_date="today")
    })
pd.DataFrame(payments).to_csv("payments.csv", index=False)

# Generate Reviews (~30 reviews per product, ~4,500 total reviews)
reviews = []
products_ids = list(range(1, 151))  # 150 products
customers_ids = list(range(1, 1201))  # 1,200 customers
for product_id in products_ids:
    for _ in range(random.randint(25, 35)):  # ~30 reviews per product
        reviews.append({
            "ReviewID": len(reviews) + 1,
            "ProductID": product_id,
            "CustomerID": random.choice(customers_ids),
            "Rating": random.randint(1, 5),
            "Comment": fake.sentence(),
            "ReviewDate": fake.date_between(start_date="-1y", end_date="today")
        })
pd.DataFrame(reviews).to_csv("reviews.csv", index=False)

# Generate Shipments (60,000 shipments)
shipments = []
carriers = ["FedEx", "UPS", "DHL", "USPS"]
for i in range(1, 60001):
    shipments.append({
        "ShipmentID": i,
        "OrderID": i,
        "ShipmentDate": fake.date_between(start_date="-2y", end_date="today"),
        "Carrier": random.choice(carriers),
        "TrackingNumber": fake.uuid4()
    })
pd.DataFrame(shipments).to_csv("shipments.csv", index=False)

# Generate Inventory (150 inventory records)
inventory = []
for i in range(1, 151):
    inventory.append({
        "InventoryID": i,
        "ProductID": i,
        "QuantityInStock": random.randint(0, 500),
        "ReorderLevel": random.randint(10, 50)
    })
pd.DataFrame(inventory).to_csv("inventory.csv", index=False)

# Generate Discounts (20% chance of applying a discount, ~12,000 discounts)
discounts = []
for i in range(1, 60001):
    if random.random() < 0.2:  # 20% chance of applying a discount
        discounts.append({
            "DiscountID": len(discounts) + 1,
            "OrderID": i,
            "DiscountAmount": round(random.uniform(5, 100), 2),
            "DiscountCode": fake.lexify(text="DISCOUNT-????")
        })
pd.DataFrame(discounts).to_csv("discounts.csv", index=False)

print("All CSV files have been generated successfully!")