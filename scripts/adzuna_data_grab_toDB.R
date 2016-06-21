library(jsonlite)
library(adzunar)
library(RMySQL)
source("/home/rpopat/AdzunaDataBot/authentications.R")
Sys.time()
d <- get_country_page(
  "data science", 
  app_id = adzuna_app_id, 
  app_key = adzuna_app_key,
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
d_flat$created <- as.POSIXct(d_flat$created)

cols <- c("id", "created", "contract_time", "contract_type",
          "salary_min", "salary_max", "salary_is_predicted",
          "description", "title", "company.display_name", "company.canonical_name",
          "category.tag",  "category.label", "location.display_name",
          "longitude", "latitude", "date_queried")

d_flat_reduced <- subset(d_flat, select=cols)

con <- dbConnect(RMySQL::MySQL(), 
                 host = "thedatalabdb.cjx6pxwxuzum.eu-west-1.rds.amazonaws.com", 
                 port = 3306,
                 dbname = "adzuna_data",
                 user = AWS_RDS_user, 
                 password = AWS_RDS_password)
dbWriteTable(con, "adzuna_data", d_flat_reduced, append = TRUE)
dbDisconnect(con)

cat("\n\n")

