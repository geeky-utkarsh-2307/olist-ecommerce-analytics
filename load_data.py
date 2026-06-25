import pandas as pd 
from sqlalchemy import create_engine
import os
from dotenv import load_dotenv
from urllib.parse import quote_plus

date_columns_map = {
    "orders": ["order_purchase_timestamp", "order_approved_at",
               "order_delivered_carrier_date", "order_delivered_customer_date",
               "order_estimated_delivery_date"],
    "order_reviews": ["review_creation_date", "review_answer_timestamp"],
    "order_itmes": ['shipping_limit_date']
}

load_dotenv()

DB_USER = os.getenv('DB_USER')
DB_PASSWORD = quote_plus(os.getenv('DB_PASSWORD'))
DB_HOST = os.getenv('DB_HOST')
DB_NAME = os.getenv('DB_NAME')

engine = create_engine(f'postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}')

csv_table_map = {
    'olist_customers_dataset.csv': 'customers',
    'olist_geolocation_dataset.csv': 'geolocation',
    'olist_order_items_dataset.csv': 'order_items',
    'olist_order_payments_dataset.csv': 'order_payments',
    'olist_order_reviews_dataset.csv': 'order_reviews',
    'olist_orders_dataset.csv': 'orders',
    'olist_products_dataset.csv': 'products',
    'olist_sellers_dataset.csv': 'sellers',
    'product_category_name_translation.csv': 'category_translation',
}

data_dir = 'data'

for csv_file, table_name in csv_table_map.items():
    file_path = os.path.join(data_dir,csv_file)
    print(f"Loading {csv_file} into table {table_name}")
    parse_dates = date_columns_map.get(table_name, None)
    df = pd.read_csv(file_path, parse_dates=parse_dates)
    df.to_sql(table_name, engine, if_exists='replace', index=False)
    print(f'Loaded {len(df)} rows into {table_name}')

print('\nAll tables loaded successfully...')