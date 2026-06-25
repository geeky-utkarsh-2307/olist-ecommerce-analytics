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
├── schema/
│   └── olist_database_erd.png     # Entity relationship diagram
├── queries/
│   ├── explore_orders.sql         # Initial data exploration
│   ├── revenue_analysis.sql       # Monthly trends, category revenue, AOV
│   ├── delivery_performance.sql   # State-wise delivery times, on-time rates
│   ├── seller_analysis.sql        # Seller revenue ranking, window functions
│   ├── rfm_segmentation.sql       # Customer RFM scoring + segmentation
│   └── payment_analysis.sql       # Payment method breakdown, instalments
├── dashboard/                     # Exported CSVs for visualisation
│   ├── monthly_revenue.csv
│   ├── category_wise_revenue.csv
│   ├── delivery_performance.csv
│   ├── state_wise_delivery_performance.csv
│   ├── segmentation_summary.csv
│   ├── raw_segmentation.csv
│   ├── payment_methods.csv
│   ├── installments.csv
│   └── seller_revenue.csv
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
git clone https://github.com/tyagiut1232002-spec/olist-ecommerce-analytics
```

**2. Install PostgreSQL**
```bash
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
cp .env.example .env
# Edit .env with your DB credentials
```

**5. Download dataset**
```bash
kaggle datasets download -d olistbr/brazilian-ecommerce --path data/
cd data && unzip brazilian-ecommerce.zip
```

**6. Load data**
```bash
pip install pandas sqlalchemy psycopg2-binary python-dotenv
python3 load_data.py
```

**7. Run queries**
Open any `.sql` file in `queries/` using SQLTools in VS Code, connect to `olist_sales_db`, and execute.

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
