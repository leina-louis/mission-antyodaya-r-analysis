.PHONY: help install data analyze clean validate all

help:
	@echo "Mission Antyodaya R Analysis - Build Targets"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  install      - Install all R dependencies (via renv or CRAN)"
	@echo "  data         - Download and prepare data"
	@echo "  analyze      - Run full analysis pipeline"
	@echo "  validate     - Check outputs are sensible"
	@echo "  clean        - Remove generated files (keeps data)"
	@echo "  clean-all    - Remove all generated files and data"
	@echo "  all          - install + data + analyze"
	@echo ""

install:
	@echo "Installing R dependencies..."
	@Rscript -e "if (!requireNamespace('renv', quietly=TRUE)) { install.packages('renv'); renv::restore() } else { renv::restore() }"

data:
	@echo "Data must be obtained manually from SHRUG (https://www.devdatalab.org/shrug)"
	@echo "Place raw CSV files in data/raw/ and re-run 'make analyze'"

analyze:
	@echo "Running analysis pipeline..."
	@Rscript run_analysis.R

validate:
	@echo "Validating outputs..."
	@Rscript tests/validate_output.R

clean:
	@echo "Removing analysis outputs..."
	@rm -rf output/tables/* output/figures/*
	@rm -rf data/processed/*
	@rm -f .Rhistory .RData

clean-all: clean
	@echo "Removing raw data..."
	@rm -rf data/raw/*.csv

all: install analyze validate
	@echo "All done!"
