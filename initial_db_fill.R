# library(jsonlite)
# library(adzunar)
# library(RMySQL)
# d <- get_country_page(
#   "data science", 
#   app_id = "134859f2", 
#   app_key = "1d215eccbc34d37430ce8693d575c51b",
#   max_age = 1000,
#   n_results = 1e5
# )
# d_flat <- flatten(d, recursive = TRUE) 
# these_are_lists <- logical(ncol(d_flat))
# for(i in 1:ncol(d_flat)) {
#   these_are_lists[i] <- is.list(d_flat[,i])
# }
# d_flat <- d_flat[,-which(these_are_lists)]
# d_flat$date_queried <- gsub(" ", "_", date())
# 
# con <- dbConnect(RMySQL::MySQL(), 
#                  host = "thedatalabdb.cjx6pxwxuzum.eu-west-1.rds.amazonaws.com", 
#                  port = 3306,
#                  dbname = "adzuna_data",
#                  user = "rpopat", 
#                  password = "thedatalab")
# dbWriteTable(con, "adzuna_data", d_flat, overwrite = TRUE)
# dbDisconnect(con)
