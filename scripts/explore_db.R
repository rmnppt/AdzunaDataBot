library(RMySQL)

con <- dbConnect(RMySQL::MySQL(), 
                 host = "thedatalabdb.cjx6pxwxuzum.eu-west-1.rds.amazonaws.com", 
                 port = 3306,
                 dbname = "adzuna_data",
                 user = "rpopat", 
                 password = "thedatalab")

dbListFields(con, "adzuna_data")
d <- dbReadTable(con, "adzuna_data")
dim(d)

unique(d$date_queried)
table(d$created)

res <- dbSendQuery(con, "SELECT count(*) FROM adzuna_data where date_queried >= '2016-06-21'")
dbFetch(res, n=-1)

### careful i am deleting everything here 
### to start fresh with a new import at midnight
# res <- dbSendQuery(con, "DELETE  FROM adzuna_data")

hist(d$salary_max)

dbDisconnect(con)
