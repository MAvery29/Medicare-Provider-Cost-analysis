# Medicare Provider Cost Analysis

## Overview
An end-to-end data analysis project exploring 9.7 million 
Medicare provider records to identify billing patterns, 
cost variations, and high-value outliers across the 
United States.

## Tools Used
- **MySQL** — data cleaning, staging, and advanced SQL analysis
- **Python** (pandas, matplotlib, seaborn) — exploratory 
  data analysis and visualization
- **GitHub** — version control and portfolio documentation

## ETL Process

### Extract
- Downloaded raw dataset from CMS (Centers for Medicare 
  & Medicaid Services)
- Loaded 9.7M+ rows into MySQL using LOAD DATA INFILE

### Transform (SQL)
- Removed 363,367 duplicate records using CTE + ROW_NUMBER()
- Flagged provider locations as Domestic, Military, or Foreign
- Renamed 28 columns to readable format
- Applied advanced SQL techniques:
  - Window Functions (RANK, ROW_NUMBER)
  - Multi-CTE queries
  - National average comparisons
  - Top provider rankings by state

### Load
- Exported aggregated summary tables to CSV
- Loaded into Python for visualization

## Key Findings
- Ambulatory Surgical Centers dominate Medicare billing 
  — averaging $1,301 per procedure vs $180 for the 
  next highest specialty (Radiation Oncology)
- California leads all states with $80M in total 
  Medicare payments
- Coppel Surgical Solutions (NV) bills $19,865 above 
  the national average — the highest outlier in the dataset
- Ambulatory Surgical Centers appear in the top 5 
  highest billing providers in nearly every US state
- 363,367 duplicate records (3.7%) were identified 
  and removed during cleaning

## How to Run
1. Clone this repository
2. Download raw data from CMS:
   [Medicare Provider Data](https://data.cms.gov)
3. Run `cleaning.sql` in MySQL Workbench
4. Export aggregated tables to CSV
5. Open `analysis.ipynb` in Jupyter Notebook
6. Run all cells

## Data Source
Raw dataset from the Centers for Medicare & Medicaid 
Services (CMS):
[Medicare Physician & Other Practitioners Dataset]
(https://data.cms.gov/provider-summary-by-type-of-service/
medicare-physician-other-practitioners/
medicare-physician-other-practitioners-by-provider-and-service)
