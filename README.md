# Olist E-Commerce Analytics

> End-to-end SQL analytics project on 100k+ Brazilian e-commerce orders — uncovering revenue trends, delivery performance, customer segmentation, and payment behaviour using PostgreSQL.

---

## Business Context

Olist is a Brazilian e-commerce marketplace that connects small merchants to major retail channels. This project analyses the complete order lifecycle — from purchase to delivery — across 9 relational tables spanning 2016 to 2018, to answer key business questions around revenue growth, operational efficiency, and customer retention.

---

## Key Findings

**Revenue**
- Total product revenue across the dataset: **R$13.6M+**
- Top revenue category: **Health & Beauty** at R$1,258,681 across 8,836 orders
- Second highest: **Watches & Gifts** at R$1,205,005 — high value, lower volume
- Average order value: **R$137.75**

**Delivery Performance**
- Overall on-time delivery rate: **91%** (88,649 of 96,476 delivered orders)
- 7,827 orders delivered late — potential churn risk
- Significant delivery time variance by state: northern and remote states show materially longer average delivery days than São Paulo and southern states

**Customer Segmentation (RFM Analysis)**
- 97% of customers placed exactly **1 order** — repeat purchase rate is critically low
- Champion customers: **4,232** (4.5% of base)
- At Risk customers: **44,330** (47% of base) — the single largest segment
- Lost customers: **11,100**
- RFM model reveals recency dominates scoring due to near-zero frequency variance — traditional loyalty segmentation has limited effectiveness on this platform
- Core business implication: **retention, not acquisition**, is Olist's primary growth lever

**Payments**
- Credit card is the dominant payment method
- 4,446 orders (~4.5%) used split payment methods — direct aggregation of `order_payments` without deduplication inflates revenue figures
- Instalment usage concentrated in credit card transactions

---

## Dataset

| Property | Detail |
|----------|--------|
| Source | [Olist Brazilian E-Commerce — Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) |
| Tables | 9 relational tables |
| Orders | ~100,000 |
| Period | 2016 – 2018 |
| Geography | Brazil (27 states) |

---

## Schema

```
geolocation (zip_code_prefix — lookup table)
        |
customers ──< orders ──< order_items >── products
                 |                           |
          order_payments                  sellers
                 |
          order_reviews
```

Full ERD: [`schema/olist_database_erd.png`](schema/olist_database_erd.png)

---

## Tech Stack

| Tool | Purpose |
|------|---------|
| PostgreSQL 16 | Database + all analytical queries |
| Python + pandas + SQLAlchemy | ETL — loading CSVs into PostgreSQL |
| python-dotenv | Secure credential management |
| SQLTools (VS Code) | Query execution + result export |
| GitHub Codespaces | Cloud development environment |

---

## Project Structure

```
olist-ecommerce-analytics/
├── data/                          # Raw CSVs (9 Olist dataset files)
│   ├── olist_customers_dataset.csv
│   ├── olist_geolocation_dataset.csv
│   ├── olist_order_items_dataset.csv
│   ├── olist_order_payments_dataset.csv
│   ├── olist_order_reviews_dataset.csv
│   ├── olist_orders_dataset.csv
│   ├── olist_products_dataset.csv
│   ├── olist_sellers_dataset.csv
│   └── product_category_name_translation.csv
├── schema/
│   └── olist_database_erd.png     # Entity relationship diagram
├── queries/                       # SQL analysis queries
│   ├── explore_orders.sql         # Initial data exploration
│   ├── revenue_analysis.sql       # Monthly trends, category revenue, AOV
│   ├── delivery_performance.sql   # State-wise delivery times, on-time rates
│   ├── seller_analysis.sql        # Seller revenue ranking, window functions
│   ├── rfm_segmentation.sql       # Customer RFM scoring + segmentation
│   └── payment_analysis.sql       # Payment method breakdown, instalments
├── dashboard/                     # Exported result CSVs for visualisation
│   ├── monthly_revenue.csv
│   ├── category_wise_revenue.csv
│   ├── delivery_performance.csv
│   ├── state_wise_delivery_performance.csv
│   ├── segmentation_summary.csv
│   ├── raw_segmentation.csv
│   ├── payment_methods.csv
│   ├── installments.csv
│   └── seller_revenue.csv
├── notebooks/                     # Jupyter notebooks (for exploratory analysis)
├── load_data.py                   # ETL script — CSV to PostgreSQL
├── .env                           # DB credentials (not tracked)
├── .gitignore
└── README.md
```

---

## How to Run

### Prerequisites
- GitHub Codespaces (or any Linux environment)
- PostgreSQL 16
- Python 3.10+

### Setup

**1. Clone the repo and open in Codespace**
```bash
git clone https://github.com/geeky-utkarsh-2307/olist-ecommerce-analytics
cd olist-ecommerce-analytics
```

**2. Install PostgreSQL**
```bash
sudo apt-get update
sudo apt-get install postgresql postgresql-contrib -y
sudo service postgresql start
```

**3. Create database and user**
```bash
sudo su - postgres -c "psql"
```
```sql
CREATE DATABASE olist_sales_db;
CREATE USER utkarsh_admin WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE olist_sales_db TO utkarsh_admin;
ALTER SCHEMA public OWNER TO utkarsh_admin;
\q
```

**4. Configure credentials**
```bash
# Create .env file with your database credentials
echo "DB_USER=utkarsh_admin" > .env
echo "DB_PASSWORD=your_password" >> .env
echo "DB_HOST=localhost" >> .env
echo "DB_NAME=olist_sales_db" >> .env
```

**5. Download dataset**
```bash
# Install Kaggle CLI if not already installed
pip install kaggle

# Download and extract dataset
kaggle datasets download -d olistbr/brazilian-ecommerce -p data/
cd data && unzip -o brazilian-ecommerce.zip && cd ..
```

**6. Install Python dependencies**
```bash
pip install pandas sqlalchemy psycopg2-binary python-dotenv
```

**7. Load data into PostgreSQL**
```bash
python3 load_data.py
```

**8. Run queries**
Open any `.sql` file in `queries/` folder using SQLTools in VS Code:
- Connect to `olist_sales_db` database
- Execute the query to generate results
- Export results as CSV to `dashboard/` folder for visualization

---

## Notable SQL Techniques Used

- **CTEs** — multi-step RFM segmentation pipeline across 3 chained CTEs
- **Window functions** — `NTILE()` for RFM scoring, `RANK()` for seller performance, `SUM() OVER()` for payment percentage calculation
- **Subqueries** — average order value calculation
- **CASE WHEN** — conditional counting for on-time vs late delivery
- **DATE_TRUNC + EPOCH** — timestamp arithmetic for monthly aggregation and delivery day calculation
- **LEFT JOIN + COALESCE** — handling NULL categories without data loss
- **Type casting** — `::numeric`, `::timestamp` for PostgreSQL precision

---

## Data Quality Observations

- `customer_id` is order-scoped (regenerated per order); `customer_unique_id` is the true customer identifier — using the wrong one inflates frequency to 1 for all customers
- 4,446 orders used split payment methods — aggregating `order_payments` without `GROUP BY order_id` first causes double-counting
- Some products have unmapped category names (no translation entry) — handled with `LEFT JOIN` + `COALESCE` rather than silent exclusion
- Timestamp columns required explicit `parse_dates` in pandas during ETL — default string inference loses date arithmetic capability in PostgreSQL

---

## Key Learnings & Recommendations

### Business Strategy
- **Focus on Retention**: With 97% of customers being one-time buyers, customer acquisition efficiency becomes critical. Implement loyalty programs and repeat purchase incentives.
- **Address Late Deliveries**: The 9% late delivery rate (7,827 orders) directly impacts customer satisfaction and retention. Prioritize logistics optimization in remote/northern states.
- **Payment Method Insights**: The dominance of credit cards + instalment payments suggests high-value customer segment. Optimize credit offerings and payment flexibility.

### Data Engineering
- Always use `customer_unique_id` for customer analytics, not `customer_id`.
- Aggregate split payment orders by `order_id` before performing financial calculations.
- Validate timestamp parsing during ETL to preserve date arithmetic capabilities.

---

## Results & Outputs

### Generated Dashboards (in `dashboard/` folder)
| File | Contains |
|------|----------|
| `monthly_revenue.csv` | Time-series revenue trends |
| `category_wise_revenue.csv` | Category performance ranking |
| `delivery_performance.csv` | On-time vs late delivery stats |
| `state_wise_delivery_performance.csv` | Geographic delivery analysis |
| `segmentation_summary.csv` | RFM segment distribution |
| `raw_segmentation.csv` | Customer-level RFM scores |
| `payment_methods.csv` | Payment method breakdown |
| `installments.csv` | Instalment usage patterns |
| `seller_revenue.csv` | Top-performing sellers |

---

## Tools & Dependencies

### System Requirements
- OS: Linux (Ubuntu 20.04+) / macOS / Windows (with WSL)
- PostgreSQL: v14.0+
- Python: 3.9+

### Python Packages
```
pandas==1.5.3
sqlalchemy==2.0.+
psycopg2-binary==2.9.+
python-dotenv==0.21.+
```

---

## Troubleshooting

### Connection Issues
**Problem**: `psycopg2.OperationalError: could not connect to server`
- Verify PostgreSQL is running: `sudo service postgresql status`
- Check `.env` credentials match database setup
- Confirm database `olist_sales_db` exists: `psql -l`

### Data Loading Issues
**Problem**: `FileNotFoundError` during `python3 load_data.py`
- Ensure data files are downloaded to `data/` folder
- Run from project root directory
- Check file names match exactly in `load_data.py`

### Query Execution Issues
**Problem**: Column not found errors in SQL queries
- Confirm data was successfully loaded: `SELECT * FROM information_schema.tables WHERE table_schema='public';`
- Check table and column names are lowercase in queries

---

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request with:
- Bug fixes or improvements to SQL queries
- New analytical insights or queries
- Documentation enhancements
- ETL improvements

---

## License

This project is open source and available under the **MIT License**. See the LICENSE file for details.

---

## Author

**Utkarsh Tyagi**
- GitHub: [@geeky-utkarsh-2307](https://github.com/geeky-utkarsh-2307)
- Project: Brazilian E-Commerce Analytics with PostgreSQL

---

## References

- **Dataset**: [Olist Brazilian E-Commerce — Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- **SQL Documentation**: [PostgreSQL Official Docs](https://www.postgresql.org/docs/)
- **Python ETL**: [SQLAlchemy Documentation](https://docs.sqlalchemy.org/)
- **RFM Analysis**: [Customer Segmentation Strategy](https://en.wikipedia.org/wiki/RFM_(customer_value))
