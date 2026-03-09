# Retail Loan Portfolio & Customer Compliance Analytics

This is a personal end-to-end analytics project that I built using **Python, PostgreSQL, SQL, and Power BI** to analyze retail loan portfolio performance and customer compliance. The project starts from raw CSV files, moves through SQL-based data transformation in PostgreSQL, and ends with a Power BI report published to Power BI Service with gateway connectivity, incremental refresh, and scheduled refresh.

The solution demonstrates a complete analytics workflow that combines **data ingestion, layered SQL transformation, compliance validation, dimensional modeling, semantic modeling, and cloud-based reporting** in a single project.

---

## Live Power BI Report

You can explore the interactive report here:

[Power BI Dashboard](https://app.powerbi.com/view?r=eyJrIjoiNjI5Nzg5ZTMtNTYxNC00MzQ2LTlhZTgtYjk0YTNmMDhkNTNmIiwidCI6IjI1Y2UwMjYxLWJiZDYtNDljZC1hMWUyLTU0MjYwODg2ZDE1OSJ9)

---

## Project Overview

In this project, I created a complete reporting pipeline for a retail loan portfolio use case. The main purpose of this project was to build a structured data model and reporting solution that can monitor loan performance, customer compliance, KYC quality, delinquency trends, and portfolio risk in a single Power BI report.

The project includes:

- Python-based raw data loading into PostgreSQL
- SQL-based raw, staging, and business-layer transformations
- PAN validation and KYC status correction logic
- business-ready dimension and fact tables for reporting
- Power BI semantic model creation
- Power BI date table creation for time intelligence analysis
- DAX measures and KPI reporting
- vertical Power BI report layout
- drill-through, field parameters, bookmarks, slicers, and interactive visuals
- On-Premises Data Gateway setup
- incremental refresh
- scheduled refresh in Power BI Service

---

## Project Context

Retail lending businesses need a structured way to monitor portfolio exposure, delinquency, branch and channel performance, and customer compliance. In many practical scenarios, raw data exists in flat files or source extracts, but decision-makers need a governed reporting layer that can answer business questions quickly and consistently.

The goal of this project was to build a full reporting pipeline that could:

- ingest raw loan portfolio data from CSV files
- transform and standardize the data in PostgreSQL
- validate KYC and PAN quality
- create analytics-ready fact and dimension tables
- support a Power BI semantic model and interactive dashboard
- publish the report to Power BI Service
- refresh automatically using an On-Premises Data Gateway, incremental refresh, and scheduled refresh

The final output is a complete portfolio and compliance analytics solution that provides a structured, business-ready reporting experience across loan performance, KYC quality, delinquency, geography, branch contribution, and portfolio risk.

---

## Project Objective

The objective of this project was to build a reporting solution that can answer important business questions such as:

- What is the total loan portfolio size?
- How much of the portfolio is still active?
- How much outstanding balance is currently exposed?
- Which branches, regions, and channels contribute the most to the portfolio?
- Which loans are entering higher DPD buckets?
- What percentage of customers are KYC compliant?
- Which customer records have missing or invalid PAN information?
- How can the report be refreshed automatically in Power BI Service even when the database is hosted locally?

---

## End-to-End Project Flow

The complete flow of this project is:

```text
Raw CSV Files
    ↓
Python Load Notebook
    ↓
PostgreSQL Raw Layer
    ↓
SQL Staging Layer
    ↓
KYC / PAN Validation & Deduplication
    ↓
PostgreSQL Business Layer
    ↓
Power BI Semantic Model
    ↓
DAX Measures and Report Visuals
    ↓
Power BI Report
    ↓
Power BI Service
    ↓
Gateway + Incremental Refresh + Scheduled Refresh
```

---

## Project Architecture

### 1. Source Layer
The project starts with CSV files stored locally. These files act as the raw source data.

### 2. Python Load Layer
I used a Python notebook to read all CSV files from the source folder and load them into PostgreSQL raw tables. The notebook automatically creates tables and bulk loads the data using PostgreSQL `COPY`.

### 3. Raw Layer
The raw schema stores source data as loaded from the CSV files. This layer is used as the base for SQL transformations.

### 4. Staging Layer
In the staging layer, I cleaned and standardized the data by:
- trimming text values
- converting IDs to uppercase
- converting date columns into proper date format
- converting numeric fields
- standardizing descriptive text
- normalizing flags such as yes/no fields

### 5. KYC / PAN Validation Layer
I added PAN validation logic on the KYC staging table to identify valid, invalid, and missing PAN values. I also updated KYC status where invalid or missing PAN details conflicted with a verified status.

### 6. Business Layer
In the business layer, I created final reporting tables in dimension and fact structure so that Power BI could directly consume analytics-ready data.

### 7. Power BI Layer
I connected Power BI to the PostgreSQL business layer, created the semantic model, built a dedicated **date table in Power BI** for time-based analysis, developed DAX measures, and designed the report pages.

### 8. Power BI Service Layer
After publishing the report, I configured the dataset in Power BI Service, connected it through the On-Premises Data Gateway, enabled incremental refresh, and scheduled a daily refresh.

---

## Repository Structure

```text
├── README.md
├── requirements.txt
├── 01_Data/
│   ├── sample_data/
│   └── data_dictionary/
│       └── Data_Dictionary.xlsx
├── 02_Python_Load/
│   └── 00_Python_Raw_Data_Load.ipynb
├── 03_SQL/
│   ├── 01_Schema_Setup.sql
│   ├── 02_Verify_Python_Loaded_Raw_Data.sql
│   ├── 03_Staging_Layer_Transformations.sql
│   ├── 04_KYC_PAN_Validation_And_Dedup.sql
│   └── 05_Business_Layer_Transformations.sql
├── 04_PowerBI/
│   ├── Retail_Loan_Portfolio_Analytics.pbix
│   ├── Retail Loan Portfolio & Customer Compliance Analytics.pdf
│   └── dax_measures/
│       └── DAX_Measures.md
└── 06_Assets/
    ├── architecture_diagram.png
    ├── schema_diagram.png
    └── report_banner.png
```

---

## Data Layer Details

### Raw Tables
The raw layer tables used in this project are:

- `raw.dim_branch`
- `raw.dim_customer`
- `raw.dim_geography`
- `raw.dim_kyc`
- `raw.dim_loan_product`
- `raw.fact_loan`

### Staging Tables
From the raw layer, I created these staging tables:

- `staging.stg_dim_branch`
- `staging.stg_dim_customer`
- `staging.stg_dim_geography`
- `staging.stg_dim_kyc`
- `staging.stg_dim_loan_product`
- `staging.stg_fact_loan`

### Business Tables
For Power BI reporting, I created these final business tables:

- `business.dim_branch`
- `business.dim_customer`
- `business.dim_loan_product`
- `business.fact_loan`

---

## Python Load Process

The notebook `00_Python_Raw_Data_Load.ipynb` is used to load all CSV files into PostgreSQL.

In this notebook, I:

- connected to PostgreSQL
- created the raw schema
- identified all CSV files from the local folder
- created raw tables dynamically
- truncated old data before reload
- loaded the data using PostgreSQL `COPY`
- verified the raw tables after load

This notebook acts as the starting point of the project pipeline.

---

## SQL Workflow

I organized the SQL part of the project into 5 files.

### 1. `01_Schema_Setup.sql`
This file creates the required schemas:
- `raw`
- `staging`
- `business`

It also sets the default search path.

### 2. `02_Verify_Python_Loaded_Raw_Data.sql`
This file verifies the raw data after Python load. It checks:
- whether raw tables exist
- row counts
- null or blank key values
- duplicate keys
- sample previews

### 3. `03_Staging_Layer_Transformations.sql`
This file creates all staging tables from the raw source tables.

The transformations include:
- trimming values
- uppercase formatting for IDs
- date conversion
- numeric conversion
- text standardization
- flag normalization

### 4. `04_KYC_PAN_Validation_And_Dedup.sql`
This file contains the PAN validation logic.

In this step, I:
- added PAN validation helper functions
- created PAN status logic
- identified valid, invalid, and missing PAN records
- updated KYC status to `Requires Reverification` where required
- removed duplicate KYC rows based on `customer_id`

### 5. `05_Business_Layer_Transformations.sql`
This file creates the final business layer for reporting.

The output includes:
- `dim_branch`
- `dim_customer`
- `dim_loan_product`
- `fact_loan`

These tables are directly used in Power BI.

---

## KYC and PAN Validation Logic

One important part of this project is the KYC and PAN validation use case.

In the KYC staging table, I implemented PAN validation logic using SQL rules such as:

- PAN must follow the standard pattern of 5 letters, 4 digits, and 1 letter
- sequential character patterns are treated as invalid
- adjacent repeated character patterns are treated as invalid
- missing PAN values are handled separately

I also updated the KYC status logic so that:

- if PAN is invalid and KYC status is `Verified`, it becomes `Requires Reverification`
- if PAN is missing and KYC status is `Verified`, it becomes `Requires Reverification`

This part of the project adds a practical compliance check to the data pipeline.

---

## Business Layer Design

The business layer is designed specifically for reporting and analysis.

### `business.dim_branch`
This table contains branch information along with denormalized geography attributes such as state, city, region, zone, and tier category.

### `business.dim_customer`
This table contains customer demographics and compliance information such as:
- PAN number
- KYC status
- PAN validation status
- income
- customer age
- customer tenure
- income band

### `business.dim_loan_product`
This table contains loan product attributes such as:
- loan type
- loan category
- interest type

### `business.fact_loan`
This table contains loan-level facts such as:
- loan amount
- EMI amount
- outstanding amount
- interest rate
- loan term
- days past due
- loan status
- write-off flag
- active flag
- closed flag
- DPD bucket
- NPA risk flag
- outstanding-to-principal ratio

---

## Data Model Design

The reporting layer follows a **dimensional model** centered around the loan fact table.

### Fact Table
- `business.fact_loan`

### Dimension Tables
- `business.dim_branch`
- `business.dim_customer`
- `business.dim_loan_product`

### Grain
- **One row in `fact_loan` represents one loan account**

This model helps Power BI perform fast aggregations and supports branch-wise, customer-wise, product-wise, channel-wise, and delinquency-wise analysis.

---

## Power BI Report Development

After creating the business layer in PostgreSQL, I connected Power BI to the final business tables and built the report.

The Power BI report is based on:

- PostgreSQL business tables
- semantic model relationships
- a dedicated Power BI date table for calendar-based analysis
- DAX measures
- KPI cards
- slicers and filtering
- multi-page navigation
- business-focused visual storytelling

---

## Power BI Features Implemented

In this report, I implemented the following Power BI features:

- semantic model / dataset
- relationships
- Power BI date table
- time intelligence support
- DAX measures
- KPI cards
- slicers
- matrix
- bar charts
- donut charts
- maps
- tooltips
- cross-filtering
- cross-highlighting
- bookmarks
- drill-through
- field parameters
- interactive navigation
- lineage view validation
- incremental refresh
- scheduled refresh

---

## Report Layout

The Power BI report is designed in a **vertical layout**.

### Canvas Size
- **1080 × 4800**

I used this layout to create a scrolling analytical report experience so that the user can move through the report in a structured top-to-bottom flow.

This layout helped me present:
- summary KPIs
- trend visuals
- geography analysis
- compliance analysis
- branch and channel breakdowns
- detailed performance sections

in a single long-form reporting style.

---

## Report Pages

### 1. Cover Page
This page contains:
- project title
- reporting period
- author information
- entry point for the report

### 2. Loan Portfolio Analysis
This page focuses on the portfolio side of the report and includes:
- total loans
- total loan amount
- active loans
- active outstanding amount
- NPA amount %
- KYC compliance %
- regional distribution
- state-wise active accounts
- loan status analysis
- DPD bucket analysis
- active loan trends
- MoM and YoY growth indicators

### 3. Customer, Compliance & Branch Performance
This page focuses on customer and compliance-related analysis and includes:
- KYC status breakdown
- income band distribution
- occupation-based analysis
- channel contribution
- branch type contribution
- average loan per customer
- compliance-related breakdowns

---

## Key Metrics Used in the Report

Some of the main KPIs and measures used in the report include:

The Power BI model also includes a **dedicated date table** to support time-based slicing, period comparisons, and trend reporting across the portfolio.

- Total Loans
- Total Loan Amount
- Active Loans
- Active Outstanding Amount
- NPA Amount %
- KYC Compliance %
- Active Rate
- Portfolio at Risk
- Write-off Rate
- Average Loan Size
- Average Loan per Customer
- Total Portfolio by Channel
- Total Portfolio by Branch Type
- DPD Bucket Analysis
- MoM Growth
- YoY Growth

---

## Power BI Service Deployment

After building the report in Power BI Desktop, I published it to Power BI Service.

### Deployment setup
- Data Source: PostgreSQL
- Server: `localhost`
- Port: `5432`
- Gateway: `Bhushan Gateway`
- Machine: `LENOVO_IDEAPAD`

### Service architecture

```text
PostgreSQL Database
       │
       │
On-Premises Data Gateway
       │
       │
Power BI Service Dataset (Semantic Model)
       │
       │
Power BI Report
```

Because the PostgreSQL database is hosted locally, I used an **On-Premises Data Gateway** to connect the local database to Power BI Service.

---

## Incremental Refresh and Scheduled Refresh

In Power BI Service, I configured:

### Incremental Refresh
I used incremental refresh so that the dataset does not need to reload all historical records every time. This makes the refresh process more efficient and closer to real-world reporting deployment.

### Scheduled Refresh
I configured daily scheduled refresh so that the published report stays updated automatically through the gateway connection.

This part of the project demonstrates the full reporting pipeline from local database to Power BI cloud refresh.

---

## SSL and Connection Configuration

One of the important technical parts of this project was handling PostgreSQL encrypted connection requirements for Power BI and the gateway setup.

For this, I worked on:
- SSL enablement
- certificate generation
- PostgreSQL configuration updates
- service restart
- connection validation
- gateway credential mapping
- dataset refresh troubleshooting

This was an important part of making the complete deployment work successfully.

---

## Issues I Handled During the Project

While building and deploying this project, I also handled several real setup issues such as:

- PostgreSQL service issues
- authentication and connection issues
- encrypted connection error
- SSL configuration errors
- certificate validation issue
- gateway credential failure
- dataset mapping issue
- scheduled refresh disablement
- refresh troubleshooting in Power BI Service

These were part of the actual deployment and refresh setup process.

---

## Step-by-Step Execution Order

### Step 1
Prepare the source CSV files in the local project data folder.

### Step 2
Run the Python notebook:

- `02_Python_Load/00_Python_Raw_Data_Load.ipynb`

### Step 3
Run the SQL files in this order:

1. `03_SQL/01_Schema_Setup.sql`
2. `03_SQL/02_Verify_Python_Loaded_Raw_Data.sql`
3. `03_SQL/03_Staging_Layer_Transformations.sql`
4. `03_SQL/04_KYC_PAN_Validation_And_Dedup.sql`
5. `03_SQL/05_Business_Layer_Transformations.sql`

### Step 4
Open Power BI Desktop and connect to the PostgreSQL business tables.

### Step 5
Create the semantic model, build the Power BI date table, define relationships, develop DAX measures, and design the report visuals.

### Step 6
Design the report using the vertical layout of **1080 × 4800**.

### Step 7
Publish the report to Power BI Service.

### Step 8
Configure the dataset through the On-Premises Data Gateway.

### Step 9
Enable incremental refresh.

### Step 10
Enable scheduled refresh.

### Step 11
Validate the refresh pipeline, gateway mapping, credentials, and report availability in Power BI Service.

---

## Files Included in This Repository

### Data
- sample data folder
- data dictionary file

### Python
- raw data load notebook

### SQL
- schema setup
- raw data verification
- staging transformations
- KYC PAN validation
- business layer transformations

### Power BI
- PBIX report file
- report PDF
- DAX measures documentation

### Assets
- architecture diagram
- schema diagram
- banner and supporting visuals


---

## Author

**Bhushan Gawali**
