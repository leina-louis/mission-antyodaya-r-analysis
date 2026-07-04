# Raw Data Access

This directory should contain the raw datasets used in the Mission Antyodaya analysis. The datasets are **not included in this repository** for licensing and distribution reasons.

## Primary Data Source

The primary dataset used in this project is the **Mission Antyodaya Village Facilities (2020)** dataset, accessed through the **SHRUG (Socioeconomic High-resolution Rural-Urban Geographic Platform)**.

### How to Obtain the Data

1. Visit the SHRUG data portal: https://www.devdatalab.org/shrug
2. Navigate to the **Mission Antyodaya Village Facilities (2020)** dataset
3. Download the Maharashtra-level data or the full India dataset
4. Place the raw files in this directory (`data/raw/`)

### SHRUG Metadata and Documentation

Full metadata for the Mission Antyodaya dataset:
https://docs.devdatalab.org/SHRUG-Metadata/Mission%20Antyodaya%20Village%20Facilities%20%282020%29/Tables/antyodaya-metadata/

### Data Format

The analysis expects the raw data in the following structure:
- CSV or other tabular format supported by `readr::read_csv()`
- Village-level observations
- Variables including student–teacher ratios and rural development indicators
- Maharashtra state data

## Directory Structure

Once downloaded, place your files here:

```
data/raw/
├── README.md (this file)
└── [your raw dataset files here]
```

## Citation

If you use this dataset in your own research, please cite:

**SHRUG (Socioeconomic High-resolution Rural-Urban Geographic Platform)**
- Development Data Lab
- https://www.devdatalab.org/shrug

**Mission Antyodaya Village Facilities (2020)** dataset

## Notes

- Raw data files are excluded from version control (see `.gitignore`)
- The analysis pipeline (`scripts/02_data_import_cleaning.R`) automatically reads files from this directory
- Processed datasets are generated in `data/processed/` after running the analysis
