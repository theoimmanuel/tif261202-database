# Final Project: SQL Data Integration

**Course:** TIF1202 - Database Technology  
**Instructor:** Dr. Guntur Dharma Putra  
**Due Date:** Thursday, 1 October 2026 at **12.59** with a presentation during our last class  

## Overview  
In modern enterprises, data is rarely handed to analysts in a clean, unified relational format. These raw data streams suffer from common data hygiene problems: redundant spaces, missing values, inconsistent casing, duplicate primary records, and references to discontinued products. You and your team will act as Data Engineers that process raw data in the forms of **CSV** and **JSON** files into a presentable, analytical, and structured relational database.  

Feel free to use any code editor software to write the SQL script, although you are encouraged to use a **PostgreSQL GUI** of your choice (e.g. pgAdmin 4, DBeaver) to ease your data loading scheme.  

## Provided Data Files  
| File Name | Format | Description |
| :--- | :---: | :--- |
| `schema.sql` | SQL DDL and DML| Reference schema definition containing the staging tables, core tables, and relational constraints (PK, FK, UNIQUE, CHECK), along with master reference data populating `stores` (or branches), `categories`, and `products`. |
| `customers_raw.csv` | CSV | Raw customer registration records containing whitespaces, missing cities, and duplicate records. |
| `transactions_raw.json` | JSON | Raw checkout logs containing order headers and nested transaction line items, including potential duplicate transaction IDs and invalid product entries. |

## Tasks  
### Task 1: Schema Understanding, Logical Schema & ERD Design
Before writing transformation queries, analyze `schema.sql` and `seed_master.sql`:
1. **Logical Schema:** Document all core tables, column data types, nullability, primary keys, foreign keys (with on update/delete actions), and unique/check constraints in standard relational notation.
2. **ERD (Entity-Relationship Diagram):** Draw a complete ERD (using Crow’s Foot notation) illustrating:
   - Entities: `stores`, `categories`, `products`, `customers`, `orders`, and `order_items`.
   - Cardinalities: 1-to-1, 1-to-many, or many-to-many relationships.
   - All Primary Keys (`PK`) and Foreign Keys (`FK`).

### Task 2: GUI Data Loading into Staging Tables
Using your PostgreSQL GUI interface (pgAdmin 4, DBeaver, or TablePlus):
1. Execute `schema.sql` and `seed_master.sql` to initialize the database and master tables.
2. **Load CSV:** Ingest `customers_raw.csv` into `staging_customers_csv` using the GUI's native Import/Export tool or `COPY`.
3. **Load JSON:** Ingest `transactions_raw.json` into `staging_transactions_json` (e.g., using GUI file import or direct JSONB payload insert).

### Task 3: Pure SQL Data Cleansing & Transformation (DML)
Populate the core relational tables from staging using **only pure SQL DML** (`INSERT INTO ... SELECT`, Common Table Expressions, conditional expressions, and window functions). **No Views, Stored Procedures, Functions, or Triggers are permitted.**

#### A. Customer Cleaning Rules (`staging_customers_csv` → `customers`):
- **Whitespace & Case Normalization:** Strip leading and trailing spaces from customer names and lowercase all email addresses.
- **Handling Incomplete Data:** If the city is blank, null, or empty whitespace, substitute with `'Unknown'`.
- **Deduplication:** Ensure each customer is loaded only once based on their natural/business key. Retain the earliest record if duplicates occur.
- **Type Casting:** Properly cast strings to target types (e.g., `DATE`, `INTEGER`).

#### B. Order & Order Items Integration Rules (`staging_transactions_json` → `orders`, `order_items`):
- **JSON Unnesting:** Unnest the nested array of items from the JSON payload into individual rows.
- **Deduplication:** Skip or deduplicate identical order codes so transactions are not double-counted.
- **Referential Integrity Validation:**
  - Resolve `store_name` to `store_id` and `customer_code` to `customer_id`.
  - Discard or ignore line items that reference invalid/discontinued products not found in the `products` table.
- **Reconciliation:**
  - Compute `subtotal = quantity * unit_price` for each line item.
  - Update or set `orders.total_amount` such that it matches the exact sum of subtotals of its valid line items.

### Task 4: DDL Schema Extensions (Summary & Aggregate Tables)
As part of your analytical tasks, you are required to design and create **two summary/aggregate tables** using `CREATE TABLE` DDL statements, then populate them via `INSERT INTO ... SELECT`:
1. **`monthly_store_sales_summary`**: Stores pre-aggregated metrics per store and per month:
   - Required columns: `summary_id` (PK), `store_id` (FK), `year_month` (VARCHAR(7) or DATE), `total_orders`, `total_revenue`, `avg_order_value`, `last_refreshed_at`.
2. **`customer_lifetime_value`**: Stores customer-level aggregate analytical metrics:
   - Required columns: `customer_id` (PK, FK), `first_order_date`, `last_order_date`, `total_orders_placed`, `total_lifetime_spend`, `customer_segment` (e.g., 'Bronze', 'Silver', 'Gold' based on spending thresholds).

---

## 4. Mandatory Analytical Queries (Q1 – Q15)

Execute the following 15 queries using **DQL (`SELECT`)** in your PostgreSQL GUI. Include the SQL code, execution results, and a brief description/interpretation of the findings in your final report.

### Category A: Relational Integrity & Data Hygiene Verification
* **Q1 - Total Cleansed Customer Count:** Total number of unique customers successfully loaded into `customers`.
* **Q2 - Total Processed Orders Count:** Total number of orders loaded into `orders`.
* **Q3 - Total Valid Order Line Items:** Total number of line items loaded into `order_items`.
* **Q4 - Default Value Verification:** Number of customers with `city = 'Unknown'`.
* **Q5 - Duplicate Full Name Check:** Query to verify that no duplicate customer names exist in `customers` (must return 0 rows).
* **Q6 - Orphaned Foreign Key Check:** Query to confirm that no line items reference non-existent orders or products (must return 0 rows).
* **Q7 - Financial Reconciliation Check:** Verify that every order's `total_amount` matches the sum of its associated `order_items.subtotal` (must return 0 discrepancies).
* **Q8 - Database Grand Revenue Fingerprint:** Calculate the exact grand total revenue across all processed orders (`SUM(total_amount)`).

### Category B: Summary Tables Creation & Validation (DDL + DML + DQL)
* **Q9 - Build & Populate Monthly Store Summary:** 
  - Execute DDL to create `monthly_store_sales_summary`.
  - Populate the table using `INSERT INTO ... SELECT`.
  - Display the complete contents ordered by store and `year_month`.
* **Q10 - Build & Populate Customer Lifetime Value (CLV):** 
  - Execute DDL to create `customer_lifetime_value` with automated tier segmentation:
    - *Gold:* Lifetime spend $\ge$ 5,000,000 IDR
    - *Silver:* Lifetime spend between 2,000,000 and 4,999,999 IDR
    - *Bronze:* Lifetime spend $<$ 2,000,000 IDR
  - Populate the table using `INSERT INTO ... SELECT`.
  - Query the count of customers and total revenue generated per `customer_segment`.

### Category C: Business Intelligence & Decision Support Queries (DQL)
* **Q11 - Top-Performing Store by Revenue:** Identify the store generating the highest total revenue, including store name, city, total order count, and total revenue.
* **Q12 - Revenue Contribution by Product Category:** List all categories, total units sold, total revenue generated, and their percentage share of overall company revenue, ordered descending by revenue.
* **Q13 - Top 5 Best-Selling Products:** Top 5 products by total units sold, displaying product name, category name, units sold, and total sales volume.
* **Q14 - Payment Method Popularity & Basket Size:** Aggregate total transaction count, total sales amount, and average order value (AOV) grouped by `payment_method`.
* **Q15 - Repeat Customer Behavior:** Identify customers who placed more than 1 order, displaying their name, city, number of orders, and days between their first and most recent order.

---

## 5. Required Submission Deliverables

Each team must submit two items packaged into a single archive (`FinalProject_GroupXX.zip`):

### 1. Final Project Report (PDF, 4–6 pages)
The report must include:
1. **Team Information:** Group number, student names, and student IDs.
2. **Relational Architecture:**
   - Logical Schema specification (tables, attributes, data types, PK/FK, constraints).
   - Entity-Relationship Diagram (ERD) using Crow's Foot notation.
3. **Data Cleansing & Transformation Strategy:**
   - Explanation of how raw CSV/JSON issues were resolved using set-based pure SQL DML.
   - Explanation of summary table DDL designs (`monthly_store_sales_summary` and `customer_lifetime_value`).
4. **Validation & Analytical Results (Q1–Q15):**
   - A structured summary table containing: Query Code, Query Objective, SQL Statement, and Output Result.
   - Fullscreen GUI screenshots showing query execution and results in PostgreSQL (pgAdmin/DBeaver).
   - Brief analysis (1–2 sentences) explaining the business insight derived from each query.

### 2. SQL Script File (`project_solution.sql`)
A clean, runnable PostgreSQL script structured into the following sections:
- **Section 1: Data Cleansing & Loading (DML)** (`INSERT INTO ... SELECT` for customers, orders, order items, and reconciliation update).
- **Section 2: Summary Tables DDL & Population (DDL & DML)**.
- **Section 3: Mandatory Queries Q1–Q15 (DQL)**.

---

## 6. Evaluation & Grading Rubric

| Assessment Component | Weight | Criteria |
| :--- | :---: | :--- |
| **Logical Schema & ERD** | 20% | Correct relational mapping, proper normalization (3NF), accurate cardinalities, and primary/foreign key definitions. |
| **Data Cleansing & ETL (DML)** | 25% | Clean execution of string trimming, null replacement, deduplication, JSON unnesting, and referential validation using pure DML. |
| **Summary Table Design (DDL & DML)** | 15% | Well-structured DDL constraints, appropriate data types, and accurate population logic for summary tables. |
| **Analytical DQL & Verification (Q1–Q15)** | 30% | Correctness of SQL syntax, accurate output values, and proper handling of aggregations, joins, and window functions. |
| **Report Presentation & Evidence** | 10% | Professional formatting, clear rationale, complete fullscreen GUI screenshots, and clean SQL script organization. |
| **Total** | **100%** | |
