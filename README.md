# Mission Antyodaya Maharashtra Student–Teacher Ratio Analysis

A reproducible R workflow analysing village-level Mission Antyodaya data to examine the relationship between student–teacher ratios and rural development indicators across Maharashtra.

This project applies simple linear regression, district-level stepwise regression, state-level linear modelling, and LASSO regression to identify infrastructure and socio-economic variables associated with primary school student–teacher ratios.

<img width="2400" height="2100" alt="district_mean_str" src="https://github.com/user-attachments/assets/d536e864-3dc6-460f-a659-52be5cd76539" />

---

## Repository structure

```
mission-antyodaya-r-analysis
│
├── run_analysis.R
│
├── scripts/
│   ├── 00_utils.R
│   ├── 01_setup.R
│   ├── 02_data_import_cleaning.R
│   ├── 03_simple_regressions.R
│   ├── 04_stepwise_models.R
│   ├── 05_state_model.R
│   └── 06_lasso_model.R
│
├── data/
│   ├── raw/
│   └── processed/
│
├── output/
│   ├── figures/
│   └── tables/
│
├── .gitignore 
├── LICENSE
└── README.md
```

---

## Project overview

The analysis investigates how educational infrastructure, health facilities, public services, and welfare indicators relate to village-level student–teacher ratios (STR) in Maharashtra using Mission Antyodaya data.

The workflow consists of:

- Data cleaning and preprocessing
- Simple linear regressions for individual predictors
- District-wise stepwise regression models
- State-level multiple linear regression
- LASSO regression for robust variable selection
- Diagnostic plots and model evaluation
- Automatic export of publication-ready figures and summary tables

---

## Methods

The repository contains implementations of:

- Simple linear regression
- Stepwise model selection (AIC)
- State-level multiple linear regression
- LASSO regression using glmnet
- Bootstrap confidence intervals
- Residual diagnostics
- Train/test validation
- Data standardisation and preprocessing

---

## LASSO Results & Interpretation

### Why LASSO?

LASSO regression addresses key limitations from stepwise regression:

1. **Prevents overfitting**: Automatically selected 18 variables from the original 47, reducing noise.
2. **Handles multicollinearity**: When variables are highly correlated, stepwise regression produces unstable estimates with flipping signs. LASSO shrinks unreliable coefficients to zero for cleaner interpretation.
3. **Robust regularization**: Minimizes beta values and protects against outliers.

### Selected Variables (18 total)

| Variable | Coefficient | Interpretation |
|----------|-------------|-----------------|
| **(Intercept)** | **16.58** | Base student–teacher ratio when all predictors are zero |
| **availability_of_high_school** | **+1.86** | Villages with high schools have 1.86 higher primary STR |
| **availability_of_middle_school** | **+1.01** | Villages with middle schools have 1.01 higher primary STR |
| **availability_of_govt_degree_coll** | **−1.55** | Degree colleges associate with 1.55 *lower* primary STR (more teachers available) |
| **phc** | **+0.51** | Primary health centres associate with higher STR |
| **sub_centre** | **+0.15** | Health sub-centres show weak positive association |
| **public_transport** | **+0.50** | Public transport availability associates with higher STR |
| **no_electricity** | **+0.49** | Lack of electricity correlates with higher STR (possible poor teacher retention) |
| **availability_of_adult_edu_centre** | **−0.43** | Adult education centres associate with lower primary STR |
| **availability_of_public_library** | **+0.16** | Public libraries show weak positive association |
| *Other variables* | negligible | Welfare scheme beneficiaries, health indicators (very small effects < 0.01) |

### Key Findings

**Positive associations** (higher STR):
- Educational infrastructure concentration (high schools, middle schools) correlates with more students per teacher in primary schools—suggesting differential resource distribution across school tiers.
- Better access to health facilities and public transport associates with slightly elevated primary STRs.
- **Lack of electricity** surprisingly shows positive correlation, possibly indicating teacher retention issues in remote villages despite high enrollment in government schools.

**Negative associations** (lower STR):
- **Degree colleges**: Villages with higher education institutions have lower primary STRs, suggesting these areas generate local teaching talent.
- **Adult education centres**: Associated with lower primary STRs.
- Most welfare scheme variables and individual health metrics have negligible effects after regularization.

### Model Diagnostics

The residuals vs. fitted plot reveals **heteroscedasticity**—errors are funnel-shaped and concentrated around fitted values 15–25, indicating:
- More prediction error for lower STR values
- More reliable predictions for higher STR values
- Some outliers remain, but substantially improved over stepwise regression

### Limitations & Next Steps

While LASSO provides stable, interpretable results and addresses multicollinearity, underlying data quality issues persist:
- Residual heteroscedasticity suggests unequal variance in the outcome
- Outliers remain in rural regions with extreme STRs
- Model is suitable for exploratory analysis but requires data refinement, weighted estimation, or additional diagnostics before informing policy recommendations

---

## Repository outputs

Running the project generates:

- Cleaned datasets
- Regression summary tables
- Significant predictor tables
- Model performance statistics
- Bootstrap confidence intervals
- District comparison plots
- Residual diagnostic plots
- LASSO coefficient summaries

All outputs are written automatically to the appropriate folders.

---

## Requirements

R (version 4.2 or newer recommended)

Packages used include:

- boot
- broom
- dplyr
- ggplot2
- glmnet
- here
- MASS
- patchwork
- purrr
- readr
- stringr
- tibble
- tidyr

---

## Running the analysis

Clone the repository and place the original Mission Antyodaya datasets inside

```
data/raw/
```

Then run

```r
source("run_analysis.R")
```

The workflow automatically:

- imports raw data
- cleans and prepares datasets
- fits all statistical models
- generates figures
- exports summary tables

---

## Example outputs

<img width="2700" height="1800" alt="state_level_coefficients_scaled" src="https://github.com/user-attachments/assets/3eb58e8e-23d2-495e-84d1-baeafe311c50" />

<img width="2700" height="1800" alt="state_level_district_effects" src="https://github.com/user-attachments/assets/7a08d1e3-e0f9-42fd-919b-e93da7537113" />

<img width="3000" height="3000" alt="simple_vs_stepwise_aurangabad" src="https://github.com/user-attachments/assets/417fbd3d-29c8-42f1-b877-6f3495591b20" />

<img width="2400" height="1500" alt="state_level_residuals_vs_fitted" src="https://github.com/user-attachments/assets/cd06cdf8-a834-465a-8c1c-c8a77edc6662" />

<img width="2400" height="1500" alt="lasso_residuals_vs_fitted" src="https://github.com/user-attachments/assets/42869fa7-d2ca-4b89-a0c4-22511d86c610" />

Examples include:

- State-level coefficient estimates
- District effects
- Residual diagnostics
- LASSO residual plot

---

## Author

**Leina Louis**

Undergraduate research project in applied statistics and rural development for Statistical Principles through Computation course.
