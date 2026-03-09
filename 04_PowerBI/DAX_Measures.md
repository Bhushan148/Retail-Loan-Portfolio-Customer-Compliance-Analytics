# DAX Measures Documentation

This file documents the key DAX measures used in the **Retail Loan Portfolio & Customer Compliance Analytics** Power BI model.

The model includes a dedicated **`dim_date`** table to support time-intelligence calculations such as **MTD, QTD, YTD, MoM, YoY, and rolling period analysis**.

---

## Model Summary

- Total tables in model: **14**
- Total measures: **85**

### Main Reporting Tables

- `fact_loan` — 21 columns, 0 measures
- `dim_loan_product` — 4 columns, 0 measures
- `dim_customer` — 21 columns, 0 measures
- `dim_branch` — 9 columns, 0 measures
- `dim_date` — 27 columns, 0 measures
- `_Measures` — 1 columns, 85 measures

### Notes

- Most business measures are stored in the dedicated **`_Measures`** table.
- The model also includes selector tables used for metric switching and dynamic display behavior.
- Local date tables are present in the model, but the primary reporting calendar is based on **`dim_date`**.

---

## Measure Categories

- **Portfolio & Core Volume** — 15 measures
- **Risk, DPD & NPA** — 18 measures
- **Compliance & Customer** — 10 measures
- **Time Intelligence** — 15 measures
- **Branch, Channel & Product** — 15 measures
- **Advanced / Composite KPIs** — 2 measures
- **Dynamic Labels & Debug** — 10 measures

---

## Portfolio & Core Volume

### Total Loan Amount

- **Measure Table:** `_Measures`
- **Format:** `₹ #,##0`

```DAX
CALCULATE(
    SUM(fact_loan[loan_amount]),
    dim_date[IsFuture] = 0
)
```

### Total Outstanding Amount

- **Measure Table:** `_Measures`
- **Format:** `₹#,##0.00`

```DAX
CALCULATE(
    SUM(fact_loan[outstanding_amount]),
    dim_date[IsFuture] = 0
)
```

### Total Loans

- **Measure Table:** `_Measures`

```DAX
CALCULATE(
    COUNTROWS(fact_loan),
    dim_date[IsFuture] = 0
)
```

### Active Loans

- **Measure Table:** `_Measures`
- **Format:** `0`

```DAX
CALCULATE(
    COUNTROWS(fact_loan),
    fact_loan[active_flag] = 1,
    dim_date[IsFuture] = 0
)
```

### Closed Loans

- **Measure Table:** `_Measures`
- **Format:** `#,##0`

```DAX
CALCULATE(
    COUNTROWS(fact_loan),
    fact_loan[closed_flag] = 1,
    dim_date[IsFuture] = 0
)
```

### Active Portfolio Amount

- **Measure Table:** `_Measures`
- **Format:** `₹#,##0.00`

```DAX
CALCULATE(
    SUM(fact_loan[loan_amount]),
    fact_loan[active_flag] = 1,
    dim_date[IsFuture] = 0
)
```

### Active Outstanding Amount

- **Measure Table:** `_Measures`
- **Format:** `₹ #,##0`

```DAX
CALCULATE(
    SUM(fact_loan[outstanding_amount]),
    fact_loan[active_flag] = 1,
    dim_date[IsFuture] = 0
)
```

### Avg Loan Amount

- **Measure Table:** `_Measures`
- **Format:** `₹#,##0.00`

```DAX
CALCULATE(
    AVERAGEX(
        FILTER(fact_loan, fact_loan[loan_amount] > 0),
        fact_loan[loan_amount]
    ),
    dim_date[IsFuture] = 0
)
```

### Avg Interest Rate

- **Measure Table:** `_Measures`

```DAX
CALCULATE(
    AVERAGE(fact_loan[interest_rate]),
    dim_date[IsFuture] = 0
)
```

### Avg Loan Term (Months)

- **Measure Table:** `_Measures`
- **Format:** `0.0`

```DAX
CALCULATE(
    AVERAGE(fact_loan[loan_term_months]),
    dim_date[IsFuture] = 0
)
```

### Active Rate %

- **Measure Table:** `_Measures`
- **Format:** `0.00%`

```DAX
DIVIDE([Active Loans], [Total Loans], 0)
```

### Closure Rate %

- **Measure Table:** `_Measures`
- **Format:** `0.00%`

```DAX
DIVIDE([Closed Loans], [Total Loans], 0)
```

### Avg Days Past Due

- **Measure Table:** `_Measures`
- **Format:** `0.0`

```DAX
CALCULATE(
    AVERAGEX(
        FILTER(fact_loan, fact_loan[days_past_due] > 0 && fact_loan[active_flag] = 1),
        fact_loan[days_past_due]
    ),
    dim_date[IsFuture] = 0
)
```

### Full Compliance %

- **Measure Table:** `_Measures`
- **Format:** `0.00%`

```DAX
DIVIDE(
    CALCULATE(
        DISTINCTCOUNT(fact_loan[customer_key]),
        dim_customer[kyc_verified_flag] = 1,
        dim_customer[pan_verified_flag] = 1,
        dim_date[IsFuture] = 0
    ),
    [Total Unique Customers],
    0
)
```

### Last Refreshed

- **Measure Table:** `_Measures`

```DAX
"Data as of " & FORMAT(NOW(), "DD MMM YYYY, HH:MM")
```

---

## Risk, DPD & NPA

### Total NPA Loans

- **Measure Table:** `_Measures`
- **Format:** `#,##0`

```DAX
CALCULATE(
    COUNTROWS(fact_loan),
    fact_loan[npa_risk_flag] = 1,
    dim_date[IsFuture] = 0
)
```

### NPA Loan Amount

- **Measure Table:** `_Measures`
- **Format:** `₹#,##0.00`

```DAX
CALCULATE(
    SUM(fact_loan[loan_amount]),
    fact_loan[npa_risk_flag] = 1,
    dim_date[IsFuture] = 0
)
```

### NPA Outstanding Amount

- **Measure Table:** `_Measures`
- **Format:** `₹#,##0.00`

```DAX
CALCULATE(
    SUM(fact_loan[outstanding_amount]),
    fact_loan[npa_risk_flag] = 1,
    dim_date[IsFuture] = 0
)
```

### NPA Count %

- **Measure Table:** `_Measures`
- **Format:** `0.00%`

```DAX
DIVIDE(
    [Total NPA Loans],
    [Active Loans],
    0
)
```

### NPA Amount %

- **Measure Table:** `_Measures`
- **Format:** `0.00%`

```DAX
DIVIDE(
    [NPA Outstanding Amount],
    [Active Outstanding Amount],
    0
)
```

### Write-off Loans

- **Measure Table:** `_Measures`
- **Format:** `#,##0`

```DAX
CALCULATE(
    COUNTROWS(fact_loan),
    fact_loan[write_off_flag] = 1,
    dim_date[IsFuture] = 0
)
```

### Write-off Amount

- **Measure Table:** `_Measures`
- **Format:** `₹#,##0.00`

```DAX
CALCULATE(
    SUM(fact_loan[loan_amount]),
    fact_loan[write_off_flag] = 1,
    dim_date[IsFuture] = 0
)
```

### Write-off Rate %

- **Measure Table:** `_Measures`
- **Format:** `0.00%`

```DAX
DIVIDE(
    [Write-off Loans],
    [Total Loans],
    0
)
```

### Loans 30+ DPD

- **Measure Table:** `_Measures`
- **Format:** `#,##0`

```DAX
CALCULATE(
    COUNTROWS(fact_loan),
    fact_loan[days_past_due] >= 30,
    fact_loan[active_flag] = 1,
    dim_date[IsFuture] = 0
)
```

### Loans 60+ DPD

- **Measure Table:** `_Measures`
- **Format:** `#,##0`

```DAX
CALCULATE(
    COUNTROWS(fact_loan),
    fact_loan[days_past_due] >= 60,
    fact_loan[active_flag] = 1,
    dim_date[IsFuture] = 0
)
```

### Loans 90+ DPD

- **Measure Table:** `_Measures`
- **Format:** `#,##0`

```DAX
CALCULATE(
    COUNTROWS(fact_loan),
    fact_loan[days_past_due] >= 90,
    fact_loan[active_flag] = 1,
    dim_date[IsFuture] = 0
)
```

### DPD 30+ %

- **Measure Table:** `_Measures`
- **Format:** `0.00%`

```DAX
DIVIDE(
    [Loans 30+ DPD],
    [Active Loans],
    0
)
```

### DPD 90+ %

- **Measure Table:** `_Measures`
- **Format:** `0.00%`

```DAX
DIVIDE(
    [Loans 90+ DPD],
    [Active Loans],
    0
)
```

### Portfolio at Risk %

- **Measure Table:** `_Measures`
- **Format:** `0.00%`

```DAX
DIVIDE(
    CALCULATE(
        SUM(fact_loan[outstanding_amount]),
        fact_loan[days_past_due] >= 30,
        fact_loan[active_flag] = 1,
        dim_date[IsFuture] = 0
    ),
    [Active Outstanding Amount],
    0
)
```

### Avg Outstanding-to-Principal Ratio

- **Measure Table:** `_Measures`
- **Format:** `0.00%`

```DAX
CALCULATE(
    AVERAGE(fact_loan[outstanding_to_principal_ratio]),
    fact_loan[active_flag] = 1,
    dim_date[IsFuture] = 0
)
```

### NPA Risk Score

- **Measure Table:** `_Measures`
- **Format:** `0.00%`

```DAX
VAR _npa_pct = [NPA Amount %]
VAR _dpd90 = [DPD 90+ %]
VAR _writeoff = [Write-off Rate %]
VAR _par30 = [Portfolio at Risk %]
RETURN
    ROUND(
        (_npa_pct * 0.35) + (_dpd90 * 0.25) + (_writeoff * 0.20) + (_par30 * 0.20),
        4
    )
```

### NPA Provisioning Estimate

- **Measure Table:** `_Measures`
- **Format:** `₹#,##0.00`

```DAX
VAR _substandard = CALCULATE(
    SUM(fact_loan[outstanding_amount]),
    fact_loan[npa_risk_flag] = 1,
    fact_loan[days_past_due] < 180,
    dim_date[IsFuture] = 0
)
VAR _doubtful = CALCULATE(
    SUM(fact_loan[outstanding_amount]),
    fact_loan[npa_risk_flag] = 1,
    fact_loan[days_past_due] >= 180,
    fact_loan[days_past_due] < 360,
    dim_date[IsFuture] = 0
)
VAR _loss = CALCULATE(
    SUM(fact_loan[outstanding_amount]),
    fact_loan[npa_risk_flag] = 1,
    fact_loan[days_past_due] >= 360,
    dim_date[IsFuture] = 0
)
RETURN
    (_substandard * 0.15) + (_doubtful * 0.40) + (_loss * 1.00)
```

### Credit Concentration Risk %

- **Measure Table:** `_Measures`
- **Format:** `0.00%`

```DAX
VAR _top_product_amount =
    MAXX(
        VALUES(dim_loan_product[loan_type]),
        CALCULATE([Total Loan Amount])
    )
RETURN
    DIVIDE(_top_product_amount, [Total Loan Amount], 0)
```

---

## Compliance & Customer

### Total Unique Customers

- **Measure Table:** `_Measures`
- **Format:** `#,##0`

```DAX
CALCULATE(
    DISTINCTCOUNT(fact_loan[customer_key]),
    dim_date[IsFuture] = 0
)
```

### KYC Verified Customers

- **Measure Table:** `_Measures`
- **Format:** `#,##0`

```DAX
CALCULATE(
    DISTINCTCOUNT(fact_loan[customer_key]),
    dim_customer[kyc_verified_flag] = 1,
    dim_date[IsFuture] = 0
)
```

### KYC Compliance %

- **Measure Table:** `_Measures`
- **Format:** `0.00%`

```DAX
DIVIDE(
    [KYC Verified Customers],
    [Total Unique Customers],
    0
)
```

### KYC Non-Compliant Customers

- **Measure Table:** `_Measures`
- **Format:** `#,##0`

```DAX
CALCULATE(
    DISTINCTCOUNT(fact_loan[customer_key]),
    dim_customer[kyc_verified_flag] = 0,
    dim_date[IsFuture] = 0
)
```

### PAN Verified Customers

- **Measure Table:** `_Measures`
- **Format:** `#,##0`

```DAX
CALCULATE(
    DISTINCTCOUNT(fact_loan[customer_key]),
    dim_customer[pan_verified_flag] = 1,
    dim_date[IsFuture] = 0
)
```

### PAN Compliance %

- **Measure Table:** `_Measures`
- **Format:** `0.00%`

```DAX
DIVIDE(
    [PAN Verified Customers],
    [Total Unique Customers],
    0
)
```

### Avg Annual Income

- **Measure Table:** `_Measures`
- **Format:** `₹#,##0`

```DAX
CALCULATE(
    AVERAGEX(
        VALUES(dim_customer[customer_key]),
        CALCULATE(AVERAGE(dim_customer[annual_income]))
    ),
    dim_date[IsFuture] = 0
)
```

### Avg Customer Age

- **Measure Table:** `_Measures`
- **Format:** `0.0`

```DAX
CALCULATE(
    AVERAGEX(
        VALUES(dim_customer[customer_key]),
        CALCULATE(AVERAGE(dim_customer[customer_age_years]))
    ),
    dim_date[IsFuture] = 0
)
```

### Avg Loans per Customer

- **Measure Table:** `_Measures`
- **Format:** `0.00`

```DAX
DIVIDE(
    [Total Loans],
    [Total Unique Customers],
    0
)
```

### Avg Loan Amount per Customer

- **Measure Table:** `_Measures`
- **Format:** `₹#,##0.00`

```DAX
DIVIDE(
    [Total Loan Amount],
    [Total Unique Customers],
    0
)
```

---

## Time Intelligence

### PAN Present %

- **Measure Table:** `_Measures`
- **Format:** `0.00%`

```DAX
DIVIDE(
    CALCULATE(
        DISTINCTCOUNT(fact_loan[customer_key]),
        dim_customer[pan_present_flag] = 1,
        dim_date[IsFuture] = 0
    ),
    [Total Unique Customers],
    0
)
```

### Disbursements MTD

- **Measure Table:** `_Measures`
- **Format:** `₹#,##0.00`

```DAX
CALCULATE(
    [Total Loan Amount],
    DATESMTD(dim_date[Date])
)
```

### Disbursements QTD

- **Measure Table:** `_Measures`
- **Format:** `₹#,##0.00`

```DAX
CALCULATE(
    [Total Loan Amount],
    DATESQTD(dim_date[Date])
)
```

### Disbursements YTD

- **Measure Table:** `_Measures`
- **Format:** `₹#,##0.00`

```DAX
CALCULATE(
    [Total Loan Amount],
    DATESYTD(dim_date[Date])
)
```

### Disbursements PM

- **Measure Table:** `_Measures`
- **Format:** `₹#,##0.00`

```DAX
CALCULATE(
    [Total Loan Amount],
    DATEADD(dim_date[Date], -1, MONTH)
)
```

### Disbursements PY

- **Measure Table:** `_Measures`
- **Format:** `₹#,##0.00`

```DAX
CALCULATE(
    [Total Loan Amount],
    DATEADD(dim_date[Date], -1, YEAR)
)
```

### Disbursements LYTD

- **Measure Table:** `_Measures`
- **Format:** `₹#,##0.00`

```DAX
CALCULATE(
    [Total Loan Amount],
    DATESYTD(DATEADD(dim_date[Date], -1, YEAR))
)
```

### MoM Growth %

- **Measure Table:** `_Measures`
- **Format:** `+0.00%;-0.00%;0.00%`

```DAX
VAR HasAnyDateFilter =
    ISCROSSFILTERED('dim_date') ||
    ISFILTERED('dim_date'[Date]) ||
    ISFILTERED('dim_date'[Month]) ||
    ISFILTERED('dim_date'[Year])

/* IMPORTANT: Use latest date from FACT data (not dim_date) */
VAR LatestDate =
    CALCULATE(
        MAX(fact_loan[disbursement_date]),
        REMOVEFILTERS('dim_date')
    )

VAR CurrStart = DATE(YEAR(LatestDate), MONTH(LatestDate), 1)
VAR CurrEnd   = EOMONTH(LatestDate, 0)

VAR PrevStart = EOMONTH(LatestDate, -2) + 1
VAR PrevEnd   = EOMONTH(LatestDate, -1)

VAR _current =
    IF(
        HasAnyDateFilter,
        [Total Loan Amount],
        CALCULATE(
            [Total Loan Amount],
            REMOVEFILTERS('dim_date'),
            DATESBETWEEN('dim_date'[Date], CurrStart, CurrEnd)
        )
    )

VAR _previous =
    IF(
        HasAnyDateFilter,
        [Disbursements PM],
        CALCULATE(
            [Total Loan Amount],
            REMOVEFILTERS('dim_date'),
            DATESBETWEEN('dim_date'[Date], PrevStart, PrevEnd)
        )
    )

RETURN
DIVIDE(_current - _previous, _previous, BLANK())
```

### YoY Growth %

- **Measure Table:** `_Measures`
- **Format:** `+0.00%;-0.00%;0.00%`

```DAX
VAR HasAnyDateFilter =
    ISCROSSFILTERED('dim_date') ||
    ISFILTERED('dim_date'[Date]) ||
    ISFILTERED('dim_date'[Month]) ||
    ISFILTERED('dim_date'[Year])

/* Latest date from FACT, but NOT beyond today (prevents future-dated rows) */
VAR LatestDate =
    CALCULATE(
        MAX(fact_loan[disbursement_date]),
        REMOVEFILTERS('dim_date'),
        fact_loan[disbursement_date] <= TODAY()
    )

-- Current Year based on LatestDate (not calendar future)
VAR CurrStart = DATE(YEAR(LatestDate), 1, 1)
VAR CurrEnd   = DATE(YEAR(LatestDate), 12, 31)

-- Previous Year
VAR PrevStart = DATE(YEAR(LatestDate) - 1, 1, 1)
VAR PrevEnd   = DATE(YEAR(LatestDate) - 1, 12, 31)

VAR _current =
    IF(
        HasAnyDateFilter,
        [Total Loan Amount],
        CALCULATE(
            [Total Loan Amount],
            REMOVEFILTERS('dim_date'),
            DATESBETWEEN('dim_date'[Date], CurrStart, CurrEnd)
        )
    )

VAR _previous =
    IF(
        HasAnyDateFilter,
        [Disbursements PY],
        CALCULATE(
            [Total Loan Amount],
            REMOVEFILTERS('dim_date'),
            DATESBETWEEN('dim_date'[Date], PrevStart, PrevEnd)
        )
    )

RETURN
DIVIDE(_current - _previous, _previous, BLANK())
```

### Loan Count MTD

- **Measure Table:** `_Measures`
- **Format:** `#,##0`

```DAX
CALCULATE(
    [Total Loans],
    DATESMTD(dim_date[Date])
)
```

### Loan Count YTD

- **Measure Table:** `_Measures`
- **Format:** `#,##0`

```DAX
CALCULATE(
    [Total Loans],
    DATESYTD(dim_date[Date])
)
```

### Rolling 3M Disbursements

- **Measure Table:** `_Measures`
- **Format:** `₹#,##0.00`

```DAX
CALCULATE(
    [Total Loan Amount],
    DATESINPERIOD(
        dim_date[Date],
        LASTDATE(dim_date[Date]),
        -3,
        MONTH
    )
)
```

### Rolling 12M Disbursements

- **Measure Table:** `_Measures`
- **Format:** `₹#,##0.00`

```DAX
CALCULATE(
    [Total Loan Amount],
    DATESINPERIOD(
        dim_date[Date],
        LASTDATE(dim_date[Date]),
        -12,
        MONTH
    )
)
```

### MoM Growth (Present)

- **Measure Table:** `_Measures`

```DAX
VAR v = [MoM Growth %]
RETURN
SWITCH(
    TRUE(),
    ISBLANK(v), BLANK(),
    v = 0, FORMAT(v, "0.00%"),
    v > 0, FORMAT(v, "0.00%") & " " & UNICHAR(9650),   -- ▲
    v < 0, FORMAT(v, "0.00%") & " " & UNICHAR(9660)    -- ▼
)
```

### YoY Growth (Present)

- **Measure Table:** `_Measures`

```DAX
VAR v = [YoY Growth %]
RETURN
SWITCH(
    TRUE(),
    ISBLANK(v), BLANK(),
    v = 0, FORMAT(v, "0.00%"),
    v > 0, FORMAT(v, "0.00%") & " " & UNICHAR(9650),   -- ▲
    v < 0, FORMAT(v, "0.00%") & " " & UNICHAR(9660)    -- ▼
)
```

---

## Branch, Channel & Product

### Total EMI Amount

- **Measure Table:** `_Measures`
- **Format:** `₹#,##0.00`

```DAX
CALCULATE(
    SUM(fact_loan[emi_amount]),
    dim_date[IsFuture] = 0
)
```

### Branch Count

- **Measure Table:** `_Measures`
- **Format:** `0`

```DAX
DISTINCTCOUNT(fact_loan[branch_key])
```

### Avg Loan Amount per Branch

- **Measure Table:** `_Measures`
- **Format:** `₹#,##0.00`

```DAX
DIVIDE(
    [Total Loan Amount],
    [Branch Count],
    0
)
```

### Digital Channel Loans

- **Measure Table:** `_Measures`
- **Format:** `#,##0`

```DAX
CALCULATE(
    [Total Loans],
    fact_loan[disbursement_channel] = "Digital",
    dim_date[IsFuture] = 0
)
```

### Branch Channel Loans

- **Measure Table:** `_Measures`
- **Format:** `#,##0`

```DAX
CALCULATE(
    [Total Loans],
    fact_loan[disbursement_channel] = "Branch",
    dim_date[IsFuture] = 0
)
```

### Digital Channel %

- **Measure Table:** `_Measures`
- **Format:** `0.00%`

```DAX
DIVIDE(
    [Digital Channel Loans],
    [Total Loans],
    0
)
```

### Avg EMI Amount

- **Measure Table:** `_Measures`
- **Format:** `₹#,##0.00`

```DAX
CALCULATE(
    AVERAGE(fact_loan[emi_amount]),
    fact_loan[active_flag] = 1,
    dim_date[IsFuture] = 0
)
```

### Top Branch Disbursement

- **Measure Table:** `_Measures`
- **Format:** `₹#,##0.00`

```DAX
MAXX(
    VALUES(dim_branch[branch_name]),
    CALCULATE([Total Loan Amount])
)
```

### Loan Product Count

- **Measure Table:** `_Measures`
- **Format:** `#,##0`

```DAX
DISTINCTCOUNT(fact_loan[loan_product_key])
```

### Fixed Rate Loans

- **Measure Table:** `_Measures`
- **Format:** `#,##0`

```DAX
CALCULATE(
    [Total Loans],
    dim_loan_product[interest_type] = "Fixed",
    dim_date[IsFuture] = 0
)
```

### Floating Rate Loans

- **Measure Table:** `_Measures`
- **Format:** `#,##0`

```DAX
CALCULATE(
    [Total Loans],
    dim_loan_product[interest_type] = "Floating",
    dim_date[IsFuture] = 0
)
```

### Fixed Rate %

- **Measure Table:** `_Measures`
- **Format:** `0.00%`

```DAX
DIVIDE(
    [Fixed Rate Loans],
    [Total Loans],
    0
)
```

### Outstanding Collection Efficiency %

- **Measure Table:** `_Measures`
- **Format:** `0.00%`

```DAX
DIVIDE(
    [Active Portfolio Amount] - [Active Outstanding Amount],
    [Active Portfolio Amount],
    0
)
```

### Interest Income Estimate

- **Measure Table:** `_Measures`
- **Format:** `₹#,##0.00`

```DAX
SUMX(
    FILTER(fact_loan, fact_loan[active_flag] = 1),
    DIVIDE(
        fact_loan[outstanding_amount] * fact_loan[interest_rate],
        12,
        0
    )
)
```

### Annual Interest Income Estimate

- **Measure Table:** `_Measures`
- **Format:** `₹#,##0.00`

```DAX
SUMX(
    FILTER(fact_loan, fact_loan[active_flag] = 1),
    fact_loan[outstanding_amount] * fact_loan[interest_rate]
)
```

---

## Advanced / Composite KPIs

### Portfolio Health Index

- **Measure Table:** `_Measures`
- **Format:** `0.00%`

```DAX
VAR _compliance = [Full Compliance %]
VAR _collection = [Outstanding Collection Efficiency %]
VAR _active = [Active Rate %]
VAR _non_npa = 1 - [NPA Amount %]
RETURN
    ROUND(
        (_compliance * 0.25) + (_collection * 0.35) + (_active * 0.20) + (_non_npa * 0.20),
        4
    )
```

### Disbursement Acceleration

- **Measure Table:** `_Measures`
- **Format:** `+0.00%;-0.00%;0.00%`

```DAX
VAR _mom = [MoM Growth %]
VAR _prev_mom = CALCULATE(
    [MoM Growth %],
    DATEADD(dim_date[Date], -1, MONTH)
)
RETURN
    _mom - _prev_mom
```

---

## Dynamic Labels & Debug

### Selected Period Label

- **Measure Table:** `_Measures`

```DAX
VAR _min = MINX(VALUES(dim_date[Date]), dim_date[Date])
VAR _max = MAXX(VALUES(dim_date[Date]), dim_date[Date])
RETURN
    IF(
        HASONEVALUE(dim_date[Year]),
        FORMAT(_min, "YYYY"),
        FORMAT(_min, "MMM YYYY") & " – " & FORMAT(TODAY(), "MMM YYYY")
    )
```

### Formatted INR Label

- **Measure Table:** `_Measures`

```DAX
VAR v = [Total Loan Amount]                -- change if your base measure name differ
VAR av = ABS(v)
VAR sign = IF(v < 0, "-", "")
RETURN
SWITCH(
    TRUE(),
    ISBLANK(v), BLANK(),
    av >= 1000000000, sign & "₹ " & FORMAT(av / 1000000000, "0.00") & " Bn",
    av >= 10000000,   sign & "₹ " & FORMAT(av / 10000000,   "0.00") & " Cr",
    av >= 100000,     sign & "₹ " & FORMAT(av / 100000,     "0.00") & " L",
    av >= 1000,       sign & "₹ " & FORMAT(av / 1000,       "0.00") & " K",
    v = 0,            "₹ 0.00",
                      sign & "₹ " & FORMAT(av, "N0")
)
```

### Data Label Format (INR Smart)

- **Measure Table:** `_Measures`

```DAX
VAR MetricName =
    SELECTEDVALUE('Portfolio Metric Selector'[Portfolio Metric Selector], "")
RETURN
IF(
    MetricName IN { "Active Loans", "Total Loan" },     -- counts (no ₹)
    "#,##0",
    "₹ #,##0"                                           -- currency (₹)
)
```

### Debug Format Code

- **Measure Table:** `_Measures`

```DAX
VAR MetricName =
    SELECTEDVALUE('Portfolio Metric Selector'[Portfolio Metric Selector], "")
RETURN
IF(MetricName IN {"Active Loans","Total Loan"}, "#,##0", "₹ #,##0")
```

### Data Label Format (Smart)

- **Measure Table:** `_Measures`

```DAX
VAR MetricName =
    SELECTEDVALUE('Portfolio Metric Selector'[Portfolio Metric Selector], "")
RETURN
IF(
    MetricName IN { "Active Loans", "Total Loan" },
    "#,##0",        -- counts
    "#,##0.00"      -- amounts (currency symbol comes from the measure format)
)
```

### Test Metric Name

- **Measure Table:** `_Measures`

```DAX
SELECTEDVALUE('Portfolio Metric Selector'[Portfolio Metric Selector])
```

### Portfolio Metric Display

- **Measure Table:** `_Measures`

```DAX
VAR MetricName =
    SELECTEDVALUE('Portfolio Metric Selector'[Portfolio Metric Selector], "Total Loan Amount")

VAR v =
    SWITCH(
        MetricName,
        "Total Loan Amount", [Total Loan Amount],
        "Active Loans", [Active Loans],
        "Active Outstanding Amount", [Active Outstanding Amount],
        "Avg Loan Amount", [Avg Loan Amount],
        "Total Loan", [Total Loans]
    )

VAR IsCount =
    MetricName IN { "Active Loans", "Total Loan" }

VAR av = ABS(v)

RETURN
IF(
    IsCount,
    v,  -- counts unchanged
    SWITCH(
        TRUE(),
        av >= 10000000, v / 10000000,   -- Crore
        av >= 100000,   v / 100000,     -- Lakh
        av >= 1000,     v / 1000,       -- Thousand
        v
    )
)
```

### Portfolio Metric Label

- **Measure Table:** `_Measures`

```DAX
VAR MetricName =
    SELECTEDVALUE('Portfolio Metric Selector'[Portfolio Metric Selector], "Total Loan Amount")

VAR IsCount =
    MetricName IN { "Active Loans", "Total Loan" }

RETURN
IF(
    IsCount,
    MetricName,
    MetricName & " (₹ Cr / L / K)"
)
```

### Debug - Selected Metric Name

- **Measure Table:** `_Measures`

```DAX
SELECTEDVALUE('Portfolio Metric Selector'[Portfolio Metric Selector], "No single selection")
```

### Debug - Display Value

- **Measure Table:** `_Measures`

```DAX
[Portfolio Metric Display]
```

---

## Measure List (Quick Reference)

- `Total Loan Amount`
- `Total Outstanding Amount`
- `Total EMI Amount`
- `Total Loans`
- `Active Loans`
- `Closed Loans`
- `Active Portfolio Amount`
- `Active Outstanding Amount`
- `Avg Loan Amount`
- `Avg Interest Rate`
- `Avg Loan Term (Months)`
- `Active Rate %`
- `Closure Rate %`
- `Total NPA Loans`
- `NPA Loan Amount`
- `NPA Outstanding Amount`
- `NPA Count %`
- `NPA Amount %`
- `Write-off Loans`
- `Write-off Amount`
- `Write-off Rate %`
- `Loans 30+ DPD`
- `Loans 60+ DPD`
- `Loans 90+ DPD`
- `DPD 30+ %`
- `DPD 90+ %`
- `Portfolio at Risk %`
- `Avg Days Past Due`
- `Avg Outstanding-to-Principal Ratio`
- `Total Unique Customers`
- `KYC Verified Customers`
- `KYC Compliance %`
- `KYC Non-Compliant Customers`
- `PAN Verified Customers`
- `PAN Compliance %`
- `PAN Present %`
- `Full Compliance %`
- `Avg Annual Income`
- `Avg Customer Age`
- `Avg Loans per Customer`
- `Avg Loan Amount per Customer`
- `Disbursements MTD`
- `Disbursements QTD`
- `Disbursements YTD`
- `Disbursements PM`
- `Disbursements PY`
- `Disbursements LYTD`
- `MoM Growth %`
- `YoY Growth %`
- `Loan Count MTD`
- `Loan Count YTD`
- `Rolling 3M Disbursements`
- `Rolling 12M Disbursements`
- `Branch Count`
- `Avg Loan Amount per Branch`
- `Digital Channel Loans`
- `Branch Channel Loans`
- `Digital Channel %`
- `Avg EMI Amount`
- `Top Branch Disbursement`
- `Loan Product Count`
- `Fixed Rate Loans`
- `Floating Rate Loans`
- `Fixed Rate %`
- `Outstanding Collection Efficiency %`
- `NPA Risk Score`
- `Portfolio Health Index`
- `Interest Income Estimate`
- `Annual Interest Income Estimate`
- `NPA Provisioning Estimate`
- `Credit Concentration Risk %`
- `Disbursement Acceleration`
- `Selected Period Label`
- `Last Refreshed`
- `MoM Growth (Present)`
- `YoY Growth (Present)`
- `Formatted INR Label`
- `Data Label Format (INR Smart)`
- `Debug Format Code`
- `Data Label Format (Smart)`
- `Test Metric Name`
- `Portfolio Metric Display`
- `Portfolio Metric Label`
- `Debug - Selected Metric Name`
- `Debug - Display Value`
