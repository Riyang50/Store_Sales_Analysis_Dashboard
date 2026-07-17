# 📊 Store Sales Analysis Dashboard

![Python](https://img.shields.io/badge/Python-3.12-blue?logo=python)
![MySQL](https://img.shields.io/badge/MySQL-8.0-orange?logo=mysql)
![Excel](https://img.shields.io/badge/Excel-Data%20Cleaning-green?logo=microsoftexcel)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-yellow?logo=powerbi)
![License](https://img.shields.io/badge/License-MIT-lightgrey)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

An end-to-end data analytics portfolio project analyzing retail store sales data — from raw,
messy source data through cleaning, database modeling, exploratory analysis, and an
interactive Power BI dashboard — following the same workflow used in real analytics teams.

---

## 📌 Project Overview

This project simulates a full data analyst workflow at a retail company: sales data arrives
messy (missing values, duplicates, inconsistent formatting, mixed data types), and the job is
to clean it, model it, analyze it, and turn it into a decision-ready dashboard with clear
business recommendations.

## 🎯 Problem Statement

Retail leadership wants to understand: which regions, products, and customer segments drive
revenue and profit, where discounting is hurting margins, and how sales trends have moved over
time — without digging through raw spreadsheets themselves.

## 🎯 Objectives

- Clean and standardize a messy 15,000+ record retail sales export
- Model the data in a relational MySQL database with proper constraints and indexing
- Explore the data with Python (Pandas/NumPy/Matplotlib/Seaborn) to surface trends and outliers
- Write 30+ SQL queries covering joins, subqueries, CTEs, window functions, views, and stored procedures
- Design an interactive Power BI dashboard with KPIs, drill-through, bookmarks, and time intelligence
- Summarize findings into clear, actionable business insights

## 🛠️ Tools Used

| Tool | Purpose |
|---|---|
| **Microsoft Excel** | Initial cleaning formulas (IF, INDEX/MATCH, TEXT, ROUND, SUMIF/SUMIFS, COUNTIF), pivot-style summaries and charts |
| **Python** (Pandas, NumPy, Matplotlib, Seaborn) | Full-dataset cleaning, feature engineering, outlier detection, EDA with 20 visualizations |
| **MySQL** | Relational schema, constraints, indexing, 30+ analytical queries, views, stored procedures |
| **Power BI** | Interactive dashboard — KPIs, time intelligence, drill-through, bookmarks |

## 🔄 Workflow / Project Architecture

```
Raw Data (messy CSV/Excel export)
        │
        ▼
Excel — first-pass cleaning & pivot exploration
        │
        ▼
Python — full cleaning, feature engineering, outlier flagging, EDA
        │
        ▼
MySQL — relational modeling, indexing, 30+ SQL analyses, views, stored procedures
        │
        ▼
Power BI — interactive dashboard, DAX measures, business-ready visuals
        │
        ▼
Business Insights & Recommendations
```

## 📁 Folder Structure

```
Store-Sales-Analysis-Dashboard/
│
├── Dataset/
│   ├── Raw_Data.xlsx           # Original messy export
│   ├── Cleaned_Data.xlsx       # Final cleaned dataset (Excel)
│   ├── Cleaned_Data.csv        # Final cleaned dataset (CSV, used by SQL/Power BI)
│   └── sales.csv               # Raw export in CSV form
│
├── Excel/
│   ├── Data Cleaning.xlsx      # Formula-driven cleaning demo (IF, INDEX/MATCH, TEXT, ROUND...)
│   └── Pivot Tables.xlsx       # SUMIF/SUMIFS/COUNTIF pivot-style summaries + charts
│
├── Python/
│   ├── data_cleaning.py        # Full cleaning + feature engineering pipeline
│   ├── eda.ipynb               # Exploratory data analysis, 20 visualizations
│   ├── eda_images/             # Exported chart images from the notebook
│   └── requirements.txt
│
├── MySQL/
│   ├── database.sql            # Schema, constraints, indexes
│   └── sql_queries.sql         # 30+ queries: joins, CTEs, window functions, views, procedures
│
├── PowerBI/
│   ├── DAX_Measures_and_Build_Guide.md   # Full DAX + dashboard build spec
│   └── Dashboard Images/                 # Layout mockups
│
├── Business_Insights.md        # 25 data-driven business insights
├── Project_Report.md           # Full written project report
├── README.md
├── LICENSE
├── .gitignore
└── requirements.txt
```

## 🧹 Dataset Information

- **~15,200 cleaned records** (from a 15,504-row raw export) across 19 original fields plus
  9 engineered features (year/month/quarter, shipping days, profit margin, discount band,
  order value tier, outlier flag).
- Raw export deliberately contains missing values, ~2% duplicate rows, inconsistent text
  casing/whitespace, mixed date formats, and numeric fields stored as text — mirroring a
  real-world messy source system.

## 🧼 Data Cleaning

- **Excel:** trims/proper-cases text, converts currency-formatted text to numbers, fills
  blanks with `IF`, looks up missing customer names with `INDEX`/`MATCH`, and summarizes with
  `SUMIF`/`SUMIFS`/`COUNTIF` (see `Excel/Data Cleaning.xlsx`).
- **Python:** full-dataset equivalent at scale — see `Python/data_cleaning.py` for text
  normalization, numeric/date type coercion, missing-value imputation rules (median by group,
  mode, cross-referenced lookups), duplicate removal, IQR-based outlier flagging, and feature
  engineering.

## 🗄️ SQL Analysis

`MySQL/database.sql` creates `store_sales_db` with a `customers` dimension and `sales` fact
table (primary keys, foreign key, `CHECK` constraints, and indexes on date/region/category/
customer). `MySQL/sql_queries.sql` contains 30+ queries organized into: basic retrieval,
aggregates & `GROUP BY`/`HAVING`, joins (`INNER`/`LEFT`/`RIGHT`), subqueries & CTEs, window
functions (`RANK`, `LAG`, running totals), views, stored procedures, and business-insight
queries (CLV, revenue concentration, discount impact on profit).

## 🐍 Python Analysis

`Python/eda.ipynb` runs a full exploratory analysis on the cleaned dataset: summary statistics,
correlation heatmap, distribution/boxplots, monthly and yearly trends, category/sub-category
performance, discount-vs-profit relationships, regional and segment breakdowns, top/worst
products, and shipping-time analysis — 20 saved chart images in `Python/eda_images/`.

## 📈 Power BI Dashboard

See `PowerBI/DAX_Measures_and_Build_Guide.md` for the full data model, every DAX measure
(core KPIs, time intelligence, rank/contribution, discount-impact measures), and a
page-by-page visual/slicer/interactivity spec (drill-through, tooltips, bookmarks,
navigation buttons). `PowerBI/Dashboard Images/` contains layout mockups.

> The `.pbix` binary isn't included since it must be built in Power BI Desktop on a live
> machine — the guide above reproduces it in under 90 minutes.

## 💡 Business Insights

25 data-driven findings are documented in `Business_Insights.md`, covering revenue/growth,
category & product performance, discount impact on profitability, regional performance,
customer concentration, and operational (shipping) patterns.

## 🖼️ Project Screenshots

| EDA — Correlation Heatmap | EDA — Monthly Sales Trend | Dashboard Mockup |
|---|---|---|
| `Python/eda_images/01_correlation_heatmap.png` | `Python/eda_images/04_monthly_sales_trend.png` | `PowerBI/Dashboard Images/page1_executive_overview_MOCKUP.png` |

## 🧠 Key Learnings

- Handling real-world messiness (mixed date formats, currency-as-text, blank cascade rules)
  is most of the actual work in a data analytics pipeline — the analysis itself is often
  the smaller step once the data is trustworthy.
- Designing the SQL schema with the reporting layer (Power BI) in mind up front — sensible
  keys, indexes, and pre-built views — saves significant rework later.
- Discount depth turned out to be a far stronger driver of profit than category or region,
  which only became visible after building the EDA correlation analysis.

## 🚀 Future Improvements

- Add a returns/refunds table and rebuild profit metrics net of returns.
- Automate the Excel → Python → MySQL → Power BI refresh with a scheduled pipeline (e.g., Airflow).
- Add a customer-churn model to flag at-risk high-value accounts.
- Extend the Power BI model with a forecasting visual (built-in Analytics pane).

## ⚙️ Installation Steps

```bash
git clone https://github.com/Riyang50/Store-Sales-Analysis-Dashboard.git
cd Store-Sales-Analysis-Dashboard/Python
pip install -r requirements.txt
```

## ▶️ How to Run

1. **Python cleaning:** `cd Python && python data_cleaning.py` — regenerates `Dataset/Cleaned_Data.csv/.xlsx`.
2. **EDA:** open `Python/eda.ipynb` in Jupyter and run all cells.
3. **MySQL:** run `MySQL/database.sql` in MySQL Workbench/CLI, load `Cleaned_Data.csv` into the
   `sales` table (see the `LOAD DATA` command at the top of the script), then run
   `MySQL/sql_queries.sql`.
4. **Power BI:** open Power BI Desktop and follow `PowerBI/DAX_Measures_and_Build_Guide.md`.

## 🧑‍💻 Skills Demonstrated

Data cleaning & validation · Excel formulas & pivot analysis · Python (Pandas/NumPy/
Matplotlib/Seaborn) · relational database design · advanced SQL (joins, CTEs, window
functions, views, stored procedures) · DAX & Power BI dashboard design · business
storytelling and insight generation.

## 📄 License
