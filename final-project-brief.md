# Final Project: SQL Data Integration

**Course:** TIF1202 - Database Technology  
**Instructor:** Dr. Guntur Dharma Putra  
**Due Date:** Thursday, 1 October 2026 at **12.59** with a presentation during our last class  

## Overview  
In modern enterprises, data is rarely handed to analysts in a clean, unified relational format. These raw data streams suffer from common data hygiene problems: redundant spaces, missing values, inconsistent casing, duplicate primary records, and references to discontinued products. You and your team will act as Data Engineers that process raw data in the forms of **CSV** and **JSON** files into a presentable, analytical, and structured relational database.  

Feel free to use any code editor software to write the SQL script, although you are encouraged to use a **PostgreSQL GUI** of your choice (e.g. pgAdmin 4, DBeaver) to ease your data loading scheme.  

## Provided Data Files  
| File Name | Description |
| :--- | :--- |
| `schema.sql` | Reference schema definition containing the staging tables, core tables, and relational constraints (PK, FK, UNIQUE, CHECK), along with master reference data populating `stores`, `categories`, and `products`. |
| `customers_raw.csv` | Raw customer registration records containing whitespaces, missing cities, and duplicate records. |
| `transactions_raw.json` | Raw checkout logs containing order headers and nested transaction line items, including potential duplicate transaction IDs and invalid product entries. |

## Tasks  
### Task 1: Logical Schema & ERD Design
Based on your understanding of `schema.sql`:
1. **Logical Schema:** Document all core tables, column data types, nullability, primary keys, foreign keys, and unique/check constraints in standard relational notation.
2. **ERD (Entity-Relationship Diagram):** Draw a complete ERD using Crow’s Foot notation illustrating entities, cardinalities, primary keys, and foreign keys.  

### Task 2: Data Cleansing
1. Execute `schema.sql` to initialize the database and master tables.
2. Import `customers_raw.csv` into `staging_customers_csv` and `transactions_raw.json` into `staging_transactions_json` using the GUI's native Import/Export tool (and/or external Python script, if needed).
3. Using **SQL DML**, transform the staging data into the core relational tables in `schema.sql`.

#### Mandatory Data Quality and Integration Rules:
- Raw data must not be imported directly into the final table.
- Customer names must be normalized (e.g. trimming whitespace).
- Empty `city` must be given a consistent default value, such as 'Unknown'.
- Transactional duplicates must not be loaded more than once.
- Resolve `store_name` to `store_id` and `customer_code` to `customer_id`.
- Discard or ignore line items that reference invalid/discontinued products not found in the `products` table.

### Task 3: Summary & Aggregate Tables
Create **two summary/aggregate tables**:
1. **`monthly_store_sales_summary`**: Stores pre-aggregated metrics per store and per month
2. **`customer_lifetime_value`**: Stores customer-level aggregate analytical metrics

### Task 4: Mandatory Analytical Queries
* **Q1** Total number of unique customers successfully loaded into `customers`.
* **Q2** Total number of orders loaded into `orders`.
* **Q3** Total number of line items loaded into `order_items`.
* **Q4** Number of customers with `city = 'Unknown'`.
* **Q5** Verify that no duplicate customer names exist in `customers` (must return 0 rows).
* **Q6** Verify that no line items reference non-existent orders or products (must return 0 rows).
* **Q7** Verify that every order's `total_amount` matches the sum of its associated `order_items.subtotal` (must return 0 discrepancies).
* **Q8** Calculate the exact grand total revenue across all processed orders (`SUM(total_amount)`).
* **Q9** Display `monthly_store_sales_summary` ordered by store and `year_month`.
* **Q10** Display the count of customers and total revenue generated per `customer_segment` in `customer_lifetime_value`.
* **Q11** Identify the store generating the highest total revenue.
* **Q12** List all categories, total units sold, total revenue generated, and their percentage share of overall company revenue, ordered descending by revenue.
* **Q13** Top 5 products by total units sold, displaying product name, category name, units sold, and total sales volume.
* **Q14** Aggregate total transaction count, total sales amount, and average order value grouped by `payment_method`.
* **Q15** Identify customers who placed more than 1 order, displaying their name, city, number of orders, and days between their first and most recent order.

## Deliverables
### 1. Final Project Report (PDF, 4-5 pages)
The report must include:
1. **Team Identity:** Student names and IDs.
2. **Relational Architecture:**
   - Logical Schema specification (tables, attributes, data types, PK/FK, constraints).
   - Entity-Relationship Diagram (ERD) using Crow's Foot notation.
3. **Data Cleansing & Transformation Strategy:**
   - Explanation of data cleansing strategy using SQL DML.
   - Explanation of summary table DDL designs (`monthly_store_sales_summary` and `customer_lifetime_value`).
4. **Validation & Analytical Results (Q1–Q15):**
   - A structured summary table containing: Query Code, Output Result, and Insights.
   - Query code and output may be inserted as screenshots and/or text, while insights contain a brief explanation of what         the output may suggest regarding the data.

### 2. SQL Script File
A clean, runnable PostgreSQL script structured into the following sections:
- **Section 1: Data Cleansing & Loading (DML)**
- **Section 2: Summary Tables (DDL & DML)**.
- **Section 3: Mandatory Queries Q1–Q15 (DQL)**.

## 6. Evaluation & Grading Rubric
| Assessment Component | Weight | Criteria |
| :--- | :---: | :--- |
| **Logical Schema & ERD** | 25% | Correct relational mapping, proper normalization (3NF), accurate cardinalities, and primary/foreign key definitions. |
| **Data Cleansing & ETL (DML)** | 15% | Clean execution of string trimming, null replacement, deduplication, JSON unnesting, and referential validation using pure DML. |
| **Summary Table Design (DDL & DML)** | 15% | Well-structured DDL constraints, appropriate data types, and accurate population logic for summary tables. |
| **Analytical DQL & Verification (Q1–Q15)** | 25% | Correctness of SQL syntax, accurate output values, and proper handling of aggregations, joins, and window functions. |
| **Report Presentation & Evidence** | 20% | Professional formatting, clear rationale, complete fullscreen GUI screenshots, and clean SQL script organization. |
| **Total** | **100%** | |
