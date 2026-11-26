# End-to-End E-Commerce Medallion ETL Pipeline (Databricks & Delta Lake)

## Project Overview
An automated, production-style Data Engineering pipeline built on **Databricks** using **PySpark**, **Delta Lake**, **Unity Catalog**, and **SQL**. The pipeline ingests **1,000,123+ raw e-commerce transactional records**, enforces data quality checks, normalizes wide raw files into a Star Schema, performs incremental upserts (`MERGE INTO`), and aggregates business-ready Gold KPIs.

## Architecture (Medallion Design)
```text
[Raw CSV (1,000,123 Rows)] 
       │
       ▼  (01_bronze_ingest)
[Bronze Layer: ecommerce_ops.bronze.transactions_raw] ──► Raw Delta Table + Lineage Metadata
       │
       ▼  (02_silver_transform)
[Silver Layer: Normalized Star Schema + Data Quality]
  ├── customers_cleaned        (Deduplicated Customer Dimension)
  ├── products_cleaned         (Deduplicated Product Dimension)
  ├── orders_cleaned           (Incremental MERGE Upsert Fact Table - 991,930 rows)
  ├── payments_cleaned         (Payment & Fraud Risk Flagging >= 0.75)
  └── quarantine_bad_records   (Dead Letter Queue for Invalid Rows)
       │
       ▼  (03_gold_aggregate)
[Gold Layer: Business Analytics & BI Tables]
  ├── customer_spending        (Customer Lifetime Value & AOV)
  ├── product_performance      (Category & Brand Revenue/Profit)
  └── monthly_sales_summary    (Monthly Trends, Payment Mix & Fraud Counts)
```

## Key Engineering Highlights
- **Data Cleansing & Deduplication:** Removed **8,193 duplicate orders** (`1,000,123` raw -> `991,930` clean orders), standardized text casing/whitespace, and isolated invalid payloads into a quarantine table.
- **Schema Normalization:** Pruned ~32 noisy behavioral attributes and split a 62-column raw dump into normalized Dimension and Fact Delta tables.
- **Incremental Data Loading:** Implemented idempotent upserts using **Delta Lake `MERGE INTO`** on `order_id` to process new batches without full-table rewrites.
- **Workflow Orchestration:** Automated end-to-end execution (`Bronze -> Silver -> Gold`) using **Databricks Workflows** with event-driven file arrival triggers.

## Tech Stack
- **Language & Processing:** Python, PySpark, Spark SQL
- **Platform & Storage:** Databricks, Unity Catalog Volumes, Delta Lake
- **Orchestration:** Databricks Workflows (Jobs & Pipelines)
