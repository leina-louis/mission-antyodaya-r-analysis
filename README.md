# Mission Antyodaya Maharashtra Student–Teacher Ratio Analysis

A reproducible R workflow for analysing village-level educational and development indicators from the Mission Antyodaya Survey to investigate factors associated with primary school student–teacher ratios (STR) across Maharashtra.

---
<img width="2400" height="2100" alt="district_mean_str" src="https://github.com/user-attachments/assets/092c996f-d4ba-44c5-9e9c-47b9d93d3415" />

## Overview

This project investigates how village-level development indicators are associated with the **Student–Teacher Ratio (STR)** in Maharashtra's primary schools using data from the **2020 Mission Antyodaya Village Facilities Survey**.

Student–Teacher Ratio (STR), calculated as the number of primary school students divided by the number of primary school teachers, is used as a proxy for educational capacity. The project examines whether educational infrastructure, health facilities, public services, and socio-economic characteristics help explain variation in STR across districts.

The analysis was originally developed as part of a university statistics project and has since been refactored into a reproducible research workflow.

---

## Research Questions

This project addresses the following questions:

* Which village-level characteristics are associated with higher or lower primary school student–teacher ratios?
* Do these relationships vary across districts in Maharashtra?
* Which predictors remain important after accounting for multicollinearity?
* How well do different regression approaches explain variation in student–teacher ratios?

---

## Data

The analysis uses the **Mission Antyodaya Village Facilities Survey (2020)**, administered by the Ministry of Rural Development and accessed through the SHRUG database.

The cleaned dataset includes villages from **33 districts of Maharashtra**, with Mumbai Suburban excluded because the available observations contained only missing values.

Student–Teacher Ratio was calculated as:

> STR = Total Primary School Students / Total Primary School Teachers

Only observations with valid STR values between 1 and 200 were retained.

---

## Methodology

The project follows a reproducible statistical workflow:

1. Data cleaning and validation
2. Feature engineering and calculation of Student–Teacher Ratio
3. Exploratory analysis of district-level variation
4. Simple linear regression for individual predictors
5. District-wise stepwise regression models
6. Train/test split for out-of-sample evaluation
7. State-level regression modelling
8. Bootstrap confidence intervals
9. LASSO regression for variable selection
10. Model diagnostics using residual analysis

The workflow generates publication-ready figures and summary tables automatically.

---

## Development Themes

Predictor variables were grouped into four broad themes:

* **Education**

  * School availability
  * Public libraries
  * Vocational education
  * Adult education
  * School facilities

* **Health**

  * Primary Health Centres (PHCs)
  * Sub-centres
  * Maternal and child health
  * Nutrition indicators

* **Infrastructure**

  * Water supply
  * Electricity
  * Public transport
  * Banking services
  * Internet connectivity

* **Socio-economic Indicators**

  * BPL households
  * Welfare programme participation
  * Self-help groups
  * Agricultural support schemes

---

## Key Findings

<img width="2700" height="1800" alt="state_level_coefficients_scaled" src="https://github.com/user-attachments/assets/1f62fe52-f56a-468f-a918-db45b41e19b5" />

Across multiple modelling approaches, several consistent patterns emerged.

* Villages with higher enrolment pressure tended to exhibit higher student–teacher ratios.
* Educational and health infrastructure frequently appeared as important predictors of STR.
* Better-developed villages generally showed lower student–teacher ratios, while poorer or more densely populated villages often exhibited higher STR values.
* LASSO substantially reduced the number of predictors, producing a more stable and interpretable model than stepwise regression by removing redundant variables.
* Model diagnostics suggested that heteroscedasticity and influential observations remained present, indicating that results should be interpreted as exploratory rather than causal.

<img width="2700" height="1800" alt="state_level_district_effects" src="https://github.com/user-attachments/assets/59ee2994-b926-444f-89bd-39541842b5d3" />

---

## Repository Structure

```text
mission-antyodaya-r-analysis
│
├── .git/
├── .gitignore
├── LICENSE
├── README.md
├── run_analysis.R
│
├── data/
│   ├── raw/
│   └── processed/
│
├── scripts/
│   ├── 01_setup.R
│   ├── 02_data_import_cleaning.R
│   ├── 03_simple_regressions.R
│   ├── 04_stepwise_models.R
│   ├── 05_state_model.R
│   ├── 06_lasso_model.R
│   └── analysis_pipeline.R
│
├── outputs/
│   ├── tables/
│
└── figures/
```

---

## Reproducing the Analysis

1. Clone this repository.
2. Download the required Mission Antyodaya datasets.
3. Place the raw CSV files inside `data/raw/`.
4. Install the required R packages.
5. Run the analysis script.

The workflow automatically:

* cleans the data,
* produces regression models,
* evaluates model performance,
* generates diagnostic plots,
* exports figures,
* writes summary tables to the `outputs/` directory.

---

## Software

This project was developed in **R** using packages including:

* dplyr
* ggplot2
* glmnet
* broom
* MASS
* boot
* patchwork
* tidyr
* readr
* purrr

---

## Limitations

This project is intended as an exploratory statistical analysis.

Several limitations should be considered:

* Student–Teacher Ratio is only one proxy for educational development.
* The analysis identifies statistical associations rather than causal relationships.
* Missing values and outliers required extensive cleaning.
* Heteroscedasticity remained present in several models.
* Stepwise regression showed sensitivity to multicollinearity, motivating the use of LASSO for variable selection.

Future work could incorporate population-weighted measures, spatial modelling, and longitudinal data to improve inference.

---

## License

This project is released under the MIT License.
