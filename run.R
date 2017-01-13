rmarkdown::run(
  file = normalizePath("./app/dashboard.Rmd", winslash = "/"),
  default_file = "dashboard.Rmd",
  shiny_args = list(launch.browser = TRUE))
