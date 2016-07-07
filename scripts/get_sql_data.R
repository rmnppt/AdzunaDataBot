library(RMySQL)
library(lubridate)
this_period <- Sys.time() - days(60)
con <- dbConnect(RMySQL::MySQL(), 
                 host = "thedatalabdb.cjx6pxwxuzum.eu-west-1.rds.amazonaws.com", 
                 port = 3306,
                 dbname = "adzuna_data",
                 user = AWS_RDS_user, 
                 password = AWS_RDS_password)
sql_query <- paste0("SELECT * FROM adzuna_data 
                    where created >= '", this_period, "'")
results <- dbSendQuery(con, sql_query)
d <- dbFetch(results, n=-1)
dbDisconnect(con)