# library(feather)
# library(RMySQL)
# 
# con <- dbConnect(RMySQL::MySQL(), 
#                  host = "thedatalabdb.cjx6pxwxuzum.eu-west-1.rds.amazonaws.com", 
#                  port = 3306,
#                  dbname = "adzuna_data",
#                  user = "rpopat", 
#                  password = "thedatalab")
# 
# these_files <- list.files("data", full.names = TRUE, pattern = ".feather")
# n_files <- length(these_files)
# 
# for(i in 1:n_files) {
#   d <- read_feather(these_files[i])
#   dbWriteTable(con, "adzuna_data", d, append = TRUE)
#   cat("done ", i, "\n")
# }
# 
# dbDisconnect(con)
