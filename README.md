# Mission Antyodaya Maharashtra Student–Teacher Ratio Analysis

A reproducible R workflow analysing village-level Mission Antyodaya data to examine how educational infrastructure, health facilities, public services, and socio-economic indicators relate to student–teacher ratios (STR) in rural Maharashtra.

<img width="2400" height="2100" alt="district_mean_str" src="https://github.com/user-attachments/assets/d536e864-3dc6-460f-a659-52be5cd76539" />

---

## Problem Statement

This analysis determines **district-level factors influencing Student–Teacher Ratio (STR)** in Maharashtra's primary schools. STR is defined as total primary school students divided by total primary school teachers. The project examines 33 Maharashtra districts across four developmental themes: **Education, Health, Facilities, and Socio-economic Welfare**.

---

## Data & Methodology

**Data Source:**  
Mission Antyodaya Village Facilities Survey (2020), Ministry of Rural Development, accessed via SHRUG.

**Districts Analyzed:**  
All 33 Maharashtra districts (excluding Mumbai Suburban due to NA values): Ahmednagar, Akola, Amravati, Aurangabad, Bid, Bhandara, Buldana, Chandrapur, Dhule, Gadchiroli, Gondiya, Hingoli, Jalgaon, Jalna, Kolhapur, Latur, Nagpur, Nanded, Nandurbar, Nashik, Osmanabad, Parbhani, Pune, Raigah, Ratnagiri, Sangli, Satara, Sindhudurg, Solapur, Thane, Wardha, Washim, Yavatmal.

**Variable Selection:**  
48 variables (12 per theme) chosen to prevent bias and balance predictor weight:
- **Education (12):** School availability, enrollment barriers, vocational training, libraries
- **Health (12):** Maternal/child health indicators, health facility access
- **Facilities (12):** Infrastructure (water, electricity, transport, broadband, banking, sanitation)
- **Socio-economic (12):** Welfare schemes, agricultural support, microfinance access

**Data Preparation:**  
- STR retained only if meaningful (0–200, non-NA)
- Train/test split: 70% training / 30% test per district (seed=2 for reproducibility)
- Missing values and outliers handled district-wise

---

## Key Findings

### District STR Ranges

- **Highest STR (most stressed):** Hingoli, Dhule, Nashik (26–30 students per teacher)
- **Lowest STR (best staffing):** Sindhudurg, Ratnagiri, Raigah (10–14 students per teacher)

Lower STR in coastal districts correlates with lower population density and better development. Higher STR in interior/tribal districts reflects teacher shortages and higher poverty-driven enrollment.

### Simple Linear Regression: Most Frequent Significant Variables

| Theme | Variable | Frequency | Avg Effect | Avg R² |
|-------|----------|-----------|-----------|--------|
| **Education** | availability_of_high_school | 31/33 | +5.59 | 0.040 |
| | availability_of_middle_school | 30/33 | +4.97 | 0.044 |
| | availability_of_ssc_school | 28/33 | +5.56 | 0.025 |
| **Facilities** | total_hhd_having_piped_water_con | 30/33 | +0.012 | 0.047 |
| | is_bank_available | 29/33 | +6.19 | 0.031 |
| | is_atm_available | 27/33 | +6.44 | 0.022 |
| **Health** | total_no_of_women_delivered_babi | 31/33 | +0.230 | 0.043 |
| | total_no_of_newly_born_children | 30/33 | +0.117 | 0.043 |
| | total_no_of_lactating_mothers | 28/33 | +0.137 | 0.040 |
| **Others** | total_hhd_availing_pmjdy_bank_ac | 32/33 | +0.015 | 0.049 |
| | total_hhd_having_bpl_cards | 32/33 | +0.017 | 0.054 |
| | gp_total_hhd_receiving_food_grai | 31/33 | +0.011 | 0.034 |

**Interpretation:**  
School availability and poverty proxy variables (BPL cards, bank accounts) most consistently predict higher STR. Health indicators (births, maternal outcomes) also show strong positive associations, likely reflecting population growth pressure.

---

## Simple vs. Stepwise Regression

### The Multicollinearity Problem

**Simple regression** isolates each variable's effect, but ignores confounders. Variables that appear "important" alone often lose significance once other correlated variables are included.

**Stepwise regression** (using AIC) selects a minimal, competing subset of predictors. Because education, health, and facilities indicators move together in real development patterns, stepwise models reveal:
- **Sign flipping:** Variables positive in simple regression become negative in stepwise
- **Magnitude changes:** Coefficients shrink or explode
- **Simpson's Paradox:** A pattern present in districts disappears at state level or vice versa

**Example:** Availability of vocational education centres has different meanings across districts:
- In **Gadchiroli** (tribal): signals population concentration → higher STR
- In **Thane** (urban): reflects dense labor-oriented settlements with lagging teacher recruitment → higher STR

---

## State-Level Stepwise Model (All Districts Combined)

### Theme-wise Effects

**Health:** Pregnant women (+0.72) and newly born children (+0.42) predict higher STR, indicating enrollment pressure from population growth.

**Education/Infrastructure:** 
- Middle schools (+0.89) and high schools (+0.46) increase STR (attract students from wider area)
- Government degree colleges (−0.22) decrease STR (better developed areas, more teacher availability)

**Socio-economic:**
- BPL households (+0.39): poverty drives higher government school enrollment
- PMJDY bank accounts (+0.47): weak households dependent on state schools
- Foodgrain support (−0.21): slight negative effect (possible data quality issue)

### Geographic District Effects (Relative to Baseline)

**Lowest STR (best teachers):**  
Sindhudurg (−10.15), Ratnagiri (−8.20), Wardha (−5.12)

**Highest STR (most stressed):**  
Hingoli (+10.84), Dhule (+5.17), Nashik (+4.73)

**Model Performance:** R² = 0.14 (explains 14% of STR variation); heteroscedasticity present in residuals.

---

## LASSO Regression Results

LASSO addresses multicollinearity by selecting 18 from 47 variables and shrinking unstable coefficients:

| Variable | LASSO Coefficient |
|----------|-------------------|
| **(Intercept)** | **16.58** |
| **availability_of_high_school** | **+1.86** |
| **availability_of_middle_school** | **+1.01** |
| **availability_of_govt_degree_coll** | **−1.55** |
| phc | +0.51 |
| public_transport | +0.50 |
| no_electricity | +0.49 |
| sub_centre | +0.15 |
| availability_of_public_library | +0.16 |
| *18 others* | ≤±0.02 |

**Key Insights:**
- **Reduces from 47 → 18 variables** eliminates noise and multicollinearity
- **Stable coefficients** compared to stepwise regression
- **Negative associations:** Degree colleges (−1.55), adult education centres (−0.43), anemic adolescent girls (−0.0016)
- **Residual heteroscedasticity remains:** Model more reliable for higher STR predictions, unreliable for lower values

---

## Current Policy Context

**Sancha-Manyata Rule (2024):**  
Maharashtra introduced a new staffing norm allowing government primary schools with ≤60 students to deploy just **one teacher** (vs. two mandated by Right to Education Act). For secondary, one teacher per 60 students across multiple subjects.

**Controversy:**  
- Violates RTE guidelines
- Reduces total teacher posts across state
- Educators warn of quality degradation and further parent exodus to private schools
- Teachers' unions demand reversal to RTE-compliant norms

**Relevance to Analysis:**  
Current STR disparities (Hingoli 26–30, Sindhudurg 10–14) will worsen under Sancha-Manyata unless targeted recruitment occurs in high-STR districts.

---

## Model Fit & Limitations

### What the Residuals Tell Us

**Good fit districts:** Ahmednagar, Akola, Aurangabad, Chandrapur, Gondiya, Nagpur, Pune, Satara, Sindhudurg, Yavatmal — residuals randomly scattered around zero, similar spread across fitted values.

**Poor fit districts:** Parbhani (massive outlier), Osmānabad (high noise), Sangli (data quality issues).

### Challenges

1. **Heteroscedasticity:** Residuals funnel-shaped; model errors larger for lower STR. Indicates non-constant variance and unreliable standard errors.

2. **Overfitting risk:** 48 predictors vs. limited observations per district; stepwise AIC masks true relationships.

3. **Multicollinearity:** Variables flip signs across districts; state-level aggregation hides local context and triggers Simpson's Paradox.

4. **Data quality:** Missing values, extreme outliers (e.g., Parbhani STR outlier), truncated distributions (zero-inflated poverty variables).

5. **Generalization limits:** Tribal Vidarbha, coastal Konkan, and urban Thane follow different patterns; state-level model averages away critical heterogeneity.

6. **Limited secondary validation:** Few district-level reports available to cross-check findings.

---

## Repository structure

```
mission-antyodaya-r-analysis
│
├── run_analysis.R                 Main entry point
│
├── scripts/
│   ├── 00_utils.R                 Compatibility wrapper
│   ├── 01_setup.R                 Dependencies, helpers, themes
│   ├── 02_data_import_cleaning.R  Ingest & prepare data
│   ├── 03_simple_regressions.R    Single-predictor models per district
│   ├── 04_stepwise_models.R       AIC-based variable selection per district
│   ├── 05_state_model.R           All-Maharashtra model with district effects
│   └── 06_lasso_model.R           Regularized regression, 18 variables selected
│
├── data/
│   ├── raw/                       Mission Antyodaya datasets (externally sourced)
│   └── processed/                 Cleaned datasets after analysis
│
├── output/
│   ├── figures/                   Publication-ready plots
│   └── tables/                    Regression summaries, coefficients
│
├── .gitignore 
├── LICENSE
└── README.md
```

---

## How to run it

1. **Install R 4.2+** and required packages:
   ```r
   install.packages(c("boot", "broom", "dplyr", "ggplot2", "glmnet", "here", "MASS", "patchwork", "purrr", "readr", "stringr", "tibble", "tidyr"))
   ```

2. **Obtain data:** Download Maharashtra Mission Antyodaya Village Facilities (2020) from [SHRUG](https://www.devdatalab.org/shrug), place CSV files in `data/raw/`

3. **Run analysis:**
   ```r
   source("run_analysis.R")
   ```

Outputs automatically written to `output/tables/`, `output/figures/`, and `data/processed/maharashtra_cleaned.csv`.

---

## Requirements

- **R:** 4.2 or newer
- **Packages:** boot, broom, dplyr, ggplot2, glmnet, here, MASS, patchwork, purrr, readr, stringr, tibble, tidyr

---

## Author

**Leina Louis, Aman, Adrita, Prem**

Undergraduate research project in applied statistics and rural development for *Statistical Principles through Computation* course.

---

## References

- Development Data Lab. (2020). SHRUG: Socioeconomic High-resolution Rural-Urban Geographic Platform. https://www.devdatalab.org/shrug
- Hindustan Times. (2023). Teacher shortages in tribal districts; recruitment drives needed.
- Maharashtra Human Development Report. (2012). District-level HDI rankings and literacy/income patterns.
- Annual Survey of Education Report (ASER). (2023). Teacher deployment and facility gaps in Nandurbar and Dhule.
