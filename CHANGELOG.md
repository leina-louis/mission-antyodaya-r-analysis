# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-07-04

### Added
- Initial reproducible analysis workflow for Mission Antyodaya Maharashtra student–teacher ratio analysis
- Complete data pipeline: import, cleaning, exploratory analysis
- Four regression modeling approaches:
  - Simple linear regression (single predictors per district)
  - Stepwise regression (AIC-based variable selection per district)
  - State-level model with district fixed effects
  - LASSO regression (regularized, multicollinearity-robust)
- Publication-ready figures and regression summary tables
- Comprehensive README with problem statement, findings, and limitations
- R project file and dependency management infrastructure
- Contributing guidelines and citation metadata
- Makefile for standardized workflow execution

### Documentation
- District-level STR ranges and policy implications
- Detailed interpretation of multicollinearity challenges
- Residual diagnostics and model fit assessment
- Discussion of Sancha-Manyata Rule (2024) policy impact

---

