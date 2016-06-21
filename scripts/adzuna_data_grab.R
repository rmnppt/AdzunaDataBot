library(jsonlite)
library(adzunar)
library(feather)
d <- get_country_page(
  "data science", 
  app_id = "134859f2", 
  app_key = "1d215eccbc34d37430ce8693d575c51b",
  max_age = 1,
  n_results = 1e4
)
d_flat <- flatten(d, recursive = TRUE) 
d_flat <- d_flat[,-23]
date_in_name <- gsub(" ", "_", date())
write_feather(
  d_flat, 
  paste0("/home/rpopat/AdzunaDataCollection/data/datascience_", date_in_name, ".feather")
)
