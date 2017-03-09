library(jsonlite)
library(adzunar)
library(RMySQL)
library(dplyr)

source("/home/rstudio/AdzunaDataBot/authentications.R")
Sys.time()

search_terms <- c("data+science", "analytics", "machine+learning", 
                  "data+engineering", "data+analyst")

d <- lapply(search_terms, 
            function(string) {
              dat <- get_country_page(string,
                                      app_id = adzuna_app_id, 
                                      app_key = adzuna_app_key,
                                      max_age = 1000,
                                      n_results = 1e4)
              dat$search_term <- string
              return(dat)
            })

# some of the collumns are lists (hierarchical/nested locations)
# getting rid of these
removeLists <- function(dat) {
  these_are_lists <- lapply(dat, is.list) %>% unlist
  dat[,-which(these_are_lists)]
}

# only retaining some collumns
# recording the time

d_flat <- d %>% 
  lapply(flatten, recursive = TRUE) %>%
  lapply(removeLists) %>%
  do.call(rbind, .) %>% 
  select(-contains("CLASS")) %>%
  mutate(date_queried = Sys.time()) %>%
  mutate(created = as.POSIXct(created))

### Removing duplicate ads posted twice with different IDs
# Job Title, trimmed and cleaned company name, and first 20 chars of description
# will be used to determine the duplicates
# the company name will be sanitized to remove the following generic titles, 
# to identify the underlying company

exc_words = "ltd.|ltd|limited|limited.|recruitment|solutions|solution|plc|plc."
trim <- function (x) gsub("^\\s+|\\s+$", "", x)
cutout <- function (x) gsub(exc_words, "", x)

d_flat$company.display_name_lower <- trim(cutout(tolower(d_flat$company.display_name)))
d_flat$desc_short  <- tolower(substring(d_flat$description, 0, 20))

duplicate_ads <- which(duplicated(
  d_flat[,c('title','company.display_name_lower', 'desc_short')]
  ,fromLast=TRUE)
)

d_small <- d_flat[-duplicate_ads, ]
saveRDS(d_small, "/home/rstudio/AdzunaDataBot/dashboard/data/d_small.rds")

# write to db
con <- dbConnect(RMySQL::MySQL(), 
                 host = "adzunadata.crerwlnt3utz.us-west-2.rds.amazonaws.com", 
                 port = 3306,
                 dbname = "AdzunaData",
                 user = AWS_RDS_user, 
                 password = AWS_RDS_password)
dbWriteTable(con, "adzuna_data", d_small, append = TRUE)
dbDisconnect(con)

cat("\n\n")

