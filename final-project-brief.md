# Final Project: PostgreSQL Schema Design, Data Integration & Analytical DQL

**Course:** Database Systems (Relational Databases & SQL)  
**Target Environment:** PostgreSQL (using GUI Tools: pgAdmin 4 / DBeaver / TablePlus)  
**Scope:** Schema Architecture, DDL, DML (Staging, Cleaning & Transformation), and Analytical DQL  

## 1. Executive Summary & Objective

In modern business environments, raw enterprise data frequently originates from disparate sources—such as flat CSV exports from legacy CRMs and nested JSON logs from modern e-commerce checkout APIs. This data routinely exhibits serious quality defects, including untrimmed whitespaces, inconsistent casing, missing values, duplicate business keys, and unreferenced entities.

In this capstone project, your team will act as Data Engineers & Database Designers to:
1. **Design and execute a normalized relational OLTP database schema (3NF)** in PostgreSQL.
2. **Ingest raw CSV and JSON datasets into staging tables** using a PostgreSQL GUI (such as pgAdmin 4 or DBeaver).
3. **Perform data cleansing, deduplication, and relational integration** using robust pure SQL DML (`INSERT ... SELECT`, `ON CONFLICT`, CTEs, window functions, and string/null handling).
4. **Author analytical SQL queries (DQL)** to extract business insights, calculate KPIs, and verify relational integrity.

## 2. Provided Files & Deliverables Package

You are provided with a complete starter kit containing the following files:

schema.sql: Contains full DDL for staging tables, normalized OLTP tables, primary/foreign keys, check constraints, and seed master data (`stores`, `categories`, `products`).
customers_raw.csv: Raw customer export containing missing cities, whitespace inconsistencies, formatting variations, and duplicate entries.
transactions_raw.json: Raw multi-line JSON payload representing checkout events with nested item arrays, occasional unknown products, and duplicate order codes.


## 3. Table Specifications:
- **`stores`**: Master table for physical/digital branches (`store_id`, `store_name`, `city`, `state_province`).
- **`categories`**: Product classifications (`category_id`, `category_name`, `description`).
- **`products`**: Catalog items (`product_id`, `category_id`, `product_name`, `sku`, `base_price`).
- **`customers`**: Cleansed unique customers (`customer_id`, `customer_code`, `full_name`, `email`, `phone`, `city`, `registered_date`).
- **`orders`**: Transaction header (`order_id`, `order_code`, `customer_id`, `store_id`, `order_date`, `total_amount`, `payment_method`).
- **`order_items`**: Transaction line-items (`order_item_id`, `order_id`, `product_id`, `quantity`, `unit_price`, `subtotal`).

---

## 4. Step-by-Step Mission & Instructions

### Phase 1: Database Setup & DDL Execution (PostgreSQL GUI)
1. Open your PostgreSQL GUI (**pgAdmin 4**, **DBeaver**, or **TablePlus**) and create a new database named `retail_db`.
2. Open the SQL Query Tool, load `schema.sql`, and execute the entire script.
3. Verify that all 6 core tables and 2 staging tables are created and master tables (`stores`, `categories`, `products`) are populated.

### Phase 2: Ingestion into Staging Layer
1. **Import CSV:** Using your GUI's Import Tool or `COPY` command, load `customers_raw.csv` into `staging_customers_csv`.
   - *pgAdmin tip:* Right-click `staging_customers_csv` -> *Import/Export Data* -> Select CSV -> Enable Header -> Delimiter `,`.
2. **Import JSON:** Load `transactions_raw.json` into `staging_transactions_json`.
   - *Tip:* Ingest the JSON either by using your GUI's import mechanism, reading via `jsonb_populate_recordset` / `pg_read_file`, or using a multi-row `INSERT INTO staging_transactions_json (payload) VALUES ('[{"order_code":...}]'::jsonb);`.

### Phase 3: Data Cleansing & Transformation (Pure SQL DML)
Write SQL `INSERT INTO ... SELECT` statements (using CTEs, `DISTINCT ON`, `CASE`, string functions, and `JOIN`s) to migrate staging records into final tables according to these strict rules:

#### A. Customers Cleansing Rules:
- **Trimming & Normalization:** Remove leading and trailing spaces from `raw_name` and convert `raw_email` to lower case.
- **Handling Missing Values:** If `raw_city` is empty or null, replace it with `'Unknown'`.
- **Deduplication:** A customer is uniquely identified by `customer_code` (and unique `full_name`). If duplicate records exist in staging, keep only the most representative record (e.g. using `ROW_NUMBER() OVER (...)` or `DISTINCT ON`).
- **Type Casting:** Cast `raw_registered_date` to `DATE`.

#### B. Orders & Order Items Integration Rules:
- **JSON Unnesting:** Use PostgreSQL JSONB set-returning functions (e.g., `jsonb_array_elements(payload)`) to extract order headers and nested items.
- **Deduplication:** Duplicate transactions with the same `order_code` must be ignored (load only once).
- **Referential Validity:**
  - Map `customer_code` and `store_name` to their respective foreign keys (`customer_id`, `store_id`).
  - For line items, match `product_name` with `products.product_id`. **Discard/ignore any order item whose product does not exist in `products`**.
- **Financial Precision:**
  - `subtotal = quantity * unit_price`.
  - Update or populate `orders.total_amount` such that it **strictly equals** the exact `SUM(subtotal)` of all valid line items for that order.

---

## 5. Required Verification & Analytical Queries (Q1 – Q12)

You must execute the following 12 queries in your PostgreSQL GUI, record the results, and capture fullscreen screenshots displaying the query and the resulting grid.

### Relational Integrity & Data Quality Verifications:
1. **Q1 - Total Cleansed Customers:** Count total rows in the `customers` table.
2. **Q2 - Total Processed Orders:** Count total rows in the `orders` table.
3. **Q3 - Total Valid Order Line Items:** Count total rows in `order_items`.
4. **Q4 - Missing City Count:** Count customers having `city = 'Unknown'`.
5. **Q5 - Duplicate Full Name Check:** Query to detect any duplicate `full_name` in `customers` (Must return `0` rows).
6. **Q6 - Orphaned Foreign Keys Verification:** Check if any `order_items` point to non-existent `order_id` or `product_id` (Must return `0` rows).
7. **Q7 - Order Amount Reconcile Check:** Find any orders where `orders.total_amount != (SELECT SUM(subtotal) FROM order_items WHERE order_items.order_id = orders.order_id)` (Must return `0` rows).
8. **Q8 - Grand Total Revenue Fingerprint:** Calculate the exact `SUM(total_amount)` across all orders.

### Business Intelligence & Analytical DQL:
9. **Q9 - Top Revenue Generating Store:** List the top store name, its city, and total generated revenue.
10. **Q10 - Category Sales Distribution:** Total revenue and units sold per product category, sorted from highest to lowest revenue.
11. **Q11 - Top 3 VIP Customers:** Top 3 customers by total spend, displaying full name, city, order count, and total spent.
12. **Q12 - High-Value Basket Analysis:** List all orders with a total amount greater than 5,000,000 IDR along with the customer name and number of distinct items purchased.

---

## 6. Submission Guidelines & Rubric

### Deliverables:
1. **Written PDF Report (3–5 pages):**
   - Team Information & Member Contributions.
   - Conceptual & Logical Data Model narrative with Cardinality details.
   - Data Cleansing & ETL strategy documentation (explaining your pure SQL DML scripts).
   - Validation & Analytical Output Table (Q1–Q12) with full-screen GUI execution screenshots.
2. **SQL Script File (`etl_and_analysis.sql`):**
   - Containing all data migration queries and validation queries.

### Grading Rubric:

| Criteria | Points | Description |
| :--- | :---: | :--- |
| **Schema Setup & Integrity** | 20% | Proper implementation of constraints (PK, FK, UNIQUE, CHECK, NOT NULL, DEFAULT). |
| **GUI Data Loading & Staging** | 15% | Successful raw ingestion into PostgreSQL staging tables via GUI. |
| **Data Cleansing & Transformation (DML)** | 30% | Correct pure SQL transformation (handling whitespaces, nulls, JSON unnesting, deduplication, and referential filtering). |
| **Analytical DQL & Verification (Q1-Q12)** | 25% | 100% mathematical and relational correctness of the 12 queries with evidence. |
| **Report Polish & Documentation** | 10% | Professional formatting, clear explanations, and readable screenshots. |
