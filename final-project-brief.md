generated, and their percentage share of overall company revenue, ordered descending by revenue.
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
