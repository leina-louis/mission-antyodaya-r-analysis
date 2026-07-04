# Data Dictionary: Mission Antyodaya Village-Level Data

This document describes the key variables used in the student–teacher ratio analysis. Full dataset metadata is available from [SHRUG](https://docs.devdatalab.org/SHRUG-Metadata/Mission%20Antyodaya%20Village%20Facilities%20%282020%29/Tables/antyodaya-metadata/).

## Core Outcome Variable

| Variable Name | Type | Range | Description |
|---------------|------|-------|-------------|
| `str` | Numeric | 0–200 | **Student–Teacher Ratio**: Total primary school students ÷ total primary school teachers. Aggregated to district level. Retains only meaningful values (non-NA, within realistic range). |

## Geographic Variables

| Variable Name | Type | Example | Description |
|---------------|------|---------|-------------|
| `district` | Character | "Ahmednagar", "Hingoli" | Maharashtra district name (33 districts analyzed; Mumbai Suburban excluded due to NA values). |
| `village` | Character | "village_001" | Unique village identifier from Mission Antyodaya dataset. |

---

## Predictor Variables (48 total; 12 per theme)

### Education (12 variables)

All binary (0/1) or count indicators at village level.

| Variable Name | Description | Type |
|---------------|-------------|------|
| `availability_of_high_school` | Primary school present in village | Binary (0/1) |
| `availability_of_middle_school` | Middle school present in village | Binary (0/1) |
| `availability_of_ssc_school` | SSC (secondary) school present | Binary (0/1) |
| `availability_of_govt_degree_coll` | Government degree college present | Binary (0/1) |
| `availability_of_pvt_degree_coll` | Private degree college present | Binary (0/1) |
| `availability_of_icds` | ICDS (Integrated Child Development Services) center present | Binary (0/1) |
| `has_vocational_training_center` | Vocational training center present | Binary (0/1) |
| `has_public_library` | Public library present | Binary (0/1) |
| `adult_education_center` | Adult education center present | Binary (0/1) |
| `availability_of_primary_school` | Primary school present in village | Binary (0/1) |
| `school_meal_program` | School meal program (MDM) available | Binary (0/1) |
| `literacy_rate_percent` | Percentage literate population | Numeric (0–100) |

**Interpretation**: Positive coefficients suggest that school availability attracts wider enrollment, increasing STR. Negative coefficients (e.g., degree colleges) may indicate better-developed areas with more teacher availability.

---

### Health (12 variables)

Counts at village level; reflect population health outcomes and service access.

| Variable Name | Description | Type |
|---------------|-------------|------|
| `total_no_of_women_delivered_babi` | Number of women who delivered in facility | Count |
| `total_no_of_newly_born_children` | Newly born children (births indicator) | Count |
| `total_no_of_lactating_mothers` | Lactating mothers (maternal health indicator) | Count |
| `total_no_of_anemic_adolescent_girls` | Anemic adolescent girls | Count |
| `phc` | Primary Health Center present | Binary (0/1) |
| `sub_centre` | Sub-center (auxiliary midwifery center) present | Binary (0/1) |
| `is_govt_health_centre` | Government health center present | Binary (0/1) |
| `is_govt_hospital` | Government hospital present | Binary (0/1) |
| `malaria_program` | Active malaria control program | Binary (0/1) |
| `immunization_coverage_percent` | Percentage children immunized | Numeric (0–100) |
| `maternal_mortality_ratio` | Maternal mortality ratio (deaths per 100K births) | Numeric |
| `child_mortality_rate` | Child mortality rate (per 1000 live births) | Numeric |

**Interpretation**: Positive health indicators (births, lactating mothers) correlate with higher STR, suggesting enrollment pressure from population growth. Negative coefficients (anemic girls) may reflect better health infrastructure areas with fewer enrollment pressures.

---

### Facilities (12 variables)

Infrastructure and service availability at village level.

| Variable Name | Description | Type |
|---------------|-------------|------|
| `total_hhd_having_piped_water_con` | Households with piped water connection | Count |
| `is_electricity_available` | Electricity available in village | Binary (0/1) |
| `no_electricity` | No electricity in village | Binary (0/1) |
| `public_transport` | Public transport (bus/auto) available | Binary (0/1) |
| `is_bank_available` | Bank present in village | Binary (0/1) |
| `is_atm_available` | ATM present in village | Binary (0/1) |
| `is_post_office_available` | Post office present | Binary (0/1) |
| `is_police_station_available` | Police station present | Binary (0/1) |
| `internet_cafe_available` | Internet cafe present | Binary (0/1) |
| `broadband_available` | Broadband internet available | Binary (0/1) |
| `sanitation_coverage_percent` | % households with toilets | Numeric (0–100) |
| `waste_management_program` | Active waste management program | Binary (0/1) |

**Interpretation**: Infrastructure presence (water, banking, transport) positively correlates with STR—likely a proxy for urbanization and population concentration. Better facilities attract more families, increasing school enrollment.

---

### Socio-Economic (12 variables)

Welfare, financial access, and poverty indicators at village level.

| Variable Name | Description | Type |
|---------------|-------------|------|
| `total_hhd_availing_pmjdy_bank_ac` | Households with PMJDY bank accounts (financial inclusion proxy) | Count |
| `total_hhd_having_bpl_cards` | Households holding BPL (Below Poverty Line) ration cards | Count |
| `gp_total_hhd_receiving_food_grai` | Households receiving food grains subsidy | Count |
| `has_pds` | Public Distribution System (PDS) operational | Binary (0/1) |
| `has_mgnrega_program` | MGNREGA employment guarantee scheme active | Binary (0/1) |
| `old_age_pension_available` | Old age pension scheme operational | Binary (0/1) |
| `widow_pension_available` | Widow pension scheme operational | Binary (0/1) |
| `disability_pension_available` | Disability pension scheme operational | Binary (0/1) |
| `agricultural_input_subsidy` | Agricultural input subsidy available | Binary (0/1) |
| `microfinance_access` | Access to microfinance institutions | Binary (0/1) |
| `agricultural_training_program` | Agricultural training programs available | Binary (0/1) |
| `income_per_capita` | Per capita income (Rs) | Numeric |

**Interpretation**: Poverty indicators (BPL cards, PMJDY accounts) strongly predict higher STR—families in economically weaker areas depend more on government schools. Welfare programs indicate socio-economic stress zones with higher school enrollment pressure.

---

## Data Preparation Notes

1. **Train/Test Split**: 70% training / 30% test per district (seed=2 for reproducibility)
2. **Missing Values**: Handled district-wise; variables with >80% missingness excluded
3. **Outliers**: Identified via IQR method; extreme values (e.g., STR > 50 without contextual justification) flagged for review
4. **Aggregation**: Village-level predictors aggregated to district means for regression modeling

---

## References

Full metadata: https://docs.devdatalab.org/SHRUG-Metadata/Mission%20Antyodaya%20Village%20Facilities%20%282020%29/Tables/antyodaya-metadata/
