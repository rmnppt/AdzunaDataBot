library(jsonlite)
library(adzunar)
library(RMySQL)
date()
d <- get_country_page(
  "data science", 
  app_id = "134859f2", 
  app_key = "1d215eccbc34d37430ce8693d575c51b",
  max_age = 1000,
  n_results = 1e4
)
d_flat <- flatten(d, recursive = TRUE) 

these_are_lists <- logical(ncol(d_flat))
for(i in 1:ncol(d_flat)) {
  these_are_lists[i] <- is.list(d_flat[,i])
}

d_flat <- d_flat[,-which(these_are_lists)]
d_flat$date_queried <- Sys.time()
d_flat$created <- as.Date(d_flat$created, "%Y-%m-%dT%H:%M:%S)")

cols <- c("id", "created","contract_time", "contract_type",
          "salary_min","salary_max","salary_is_predicted",
          "description", "title","company.display_name","company.canonical_name",
          "category.tag",  "category.label", "location.display_name",
          "longitude", "latitude", "date_queried"
          )

d_flat_reduced <- subset(d_flat, select=cols)

con <- dbConnect(RMySQL::MySQL(), 
                 host = "thedatalabdb.cjx6pxwxuzum.eu-west-1.rds.amazonaws.com", 
                 port = 3306,
                 dbname = "adzuna_data",
                 user = "rpopat", 
                 password = "thedatalab")
dbWriteTable(con, "adzuna_data", d_flat_reduced, append = TRUE)
dbDisconnect(con)
