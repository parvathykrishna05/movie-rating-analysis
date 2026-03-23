options(timeout = 600)
local_lib <- Sys.getenv("R_LIBS_USER")
dir.create(local_lib, recursive = TRUE, showWarnings = FALSE)
.libPaths(c(local_lib, .libPaths()))

packages <- c("shiny", "bslib", "dplyr", "ggplot2", "readr", "stringr", "tidyr", "DT")

for (pkg in packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg, repos = "http://cran.us.r-project.org", lib = local_lib)
  }
}
