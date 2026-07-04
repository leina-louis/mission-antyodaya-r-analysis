# Contributing to Mission Antyodaya R Analysis

Thank you for your interest in this project! This guide will help you understand how to contribute.

## Project Overview

This is a reproducible R analysis workflow examining student–teacher ratios across Maharashtra's districts using Mission Antyodaya village-level data. The project includes data cleaning, exploratory analysis, and multiple regression models (simple, stepwise, and LASSO).

## Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/leina-louis/mission-antyodaya-r-analysis.git
   cd mission-antyodaya-r-analysis
   ```

2. **Open the R project**
   - Open `mission-antyodaya-r-analysis.Rproj` in RStudio

3. **Install dependencies**
   ```r
   renv::restore()  # Or install packages from README if renv not available
   ```

4. **Obtain data**
   - Download Mission Antyodaya Village Facilities (2020) from [SHRUG](https://www.devdatalab.org/shrug)
   - Place raw CSV files in `data/raw/`

5. **Run the analysis**
   ```r
   source("run_analysis.R")
   ```

## Code Style

- Use `snake_case` for variable names
- Use 2-space indentation (enforced by `.editorconfig`)
- Comment complex logic; aim for clarity over brevity
- Follow [tidyverse style guide](https://style.tidyverse.org/syntax.html)

## Workflow Structure

Scripts run sequentially via `run_analysis.R`:

| Script | Purpose |
|--------|---------|
| `01_setup.R` | Load packages, set themes, define helpers |
| `02_data_import_cleaning.R` | Ingest and prepare Maharashtra data |
| `03_simple_regressions.R` | Single-predictor models per district |
| `04_stepwise_models.R` | AIC-based variable selection per district |
| `05_state_model.R` | All-Maharashtra model with district fixed effects |
| `06_lasso_model.R` | Regularized regression (L1 penalty) |

## Making Changes

1. **Create a branch** for your work
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make changes** and test locally
   ```r
   source("run_analysis.R")  # Ensure full pipeline still works
   ```

3. **Validate output** (when available)
   ```r
   source("tests/validate_output.R")
   ```

4. **Commit with clear messages**
   ```bash
   git commit -m "Add description of what changed and why"
   ```

5. **Push and open a pull request**
   ```bash
   git push origin feature/your-feature-name
   ```

## Types of Contributions

### Bug Reports
- Describe what you expected vs. what happened
- Include the error message and your environment (R version, OS)
- Attach reproducible example if possible

### Improvements
- Performance optimizations (e.g., vectorized code, faster I/O)
- Better documentation or comments
- Additional diagnostic plots or summary statistics
- Test coverage

### Feature Requests
- Suggest new regression models or robustness checks
- Propose additional analyses (e.g., sensitivity analysis, interactions)
- Recommend alternative data sources or validation strategies

## Testing

Before opening a pull request, ensure:

1. All scripts run without errors
2. Output tables and figures are generated
3. No console warnings or deprecated function calls
4. Existing results are not unexpectedly changed (document any intentional changes)

## Questions or Discussion?

Open a [GitHub Issue](https://github.com/leina-louis/mission-antyodaya-r-analysis/issues) to discuss ideas before diving into code.

## License

All contributions are licensed under the MIT License. By submitting a pull request, you agree to license your work under the same terms.

---

**Thank you for contributing!** 🙏
