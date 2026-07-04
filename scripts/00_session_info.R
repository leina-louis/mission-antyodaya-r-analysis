###############################################################
# Session Information and Reproducibility Metadata
#
# Purpose:
# Capture R version, package versions, and system info
# for reproducibility audits and debugging
###############################################################

# Get current session info
session_info <- sessionInfo()

# Create a data frame of package versions
package_versions <- data.frame(
  Package = names(session_info$otherPkgs),
  Version = sapply(session_info$otherPkgs, function(x) x$Version),
  stringsAsFactors = FALSE
)

# Create reproducibility metadata
reproducibility_metadata <- list(
  timestamp = Sys.time(),
  timezone = Sys.timezone(),
  r_version = paste(R.version$major, R.version$minor, sep = "."),
  r_platform = R.version$platform,
  os = Sys.info()[["sysname"]],
  machine = Sys.info()[["machine"]],
  working_directory = getwd(),
  packages = package_versions
)

# Print to console
writeLines("\n=== REPRODUCIBILITY METADATA ===\n")
cat("Analysis Run Date:", format(reproducibility_metadata$timestamp, "%Y-%m-%d %H:%M:%S %Z"), "\n")
cat("R Version:", reproducibility_metadata$r_version, "\n")
cat("Platform:", reproducibility_metadata$r_platform, "\n")
cat("Operating System:", reproducibility_metadata$os, "\n")
cat("Working Directory:", reproducibility_metadata$working_directory, "\n")
cat("\n--- Loaded Packages ---\n")
print(package_versions)

# Optionally save metadata to JSON for archival
metadata_json_path <- here::here("output", "reproducibility_metadata.json")
if (!dir.exists(dirname(metadata_json_path))) {
  dir.create(dirname(metadata_json_path), showWarnings = FALSE, recursive = TRUE)
}

metadata_for_json <- list(
  timestamp = as.character(reproducibility_metadata$timestamp),
  timezone = reproducibility_metadata$timezone,
  r_version = reproducibility_metadata$r_version,
  r_platform = reproducibility_metadata$r_platform,
  os = reproducibility_metadata$os,
  machine = reproducibility_metadata$machine,
  working_directory = reproducibility_metadata$working_directory,
  packages = as.list(package_versions)
)

# Try to save as JSON (jsonlite optional)
tryCatch(
  {
    jsonlite::write_json(metadata_for_json, metadata_json_path, pretty = TRUE)
    cat("\n✓ Reproducibility metadata saved to:", metadata_json_path, "\n")
  },
  error = function(e) {
    cat("\n(JSON output skipped; install jsonlite for metadata export)\n")
  }
)

writeLines("\n=== END METADATA ===\n")
