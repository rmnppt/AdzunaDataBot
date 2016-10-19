library(lubridate)
library(tm)

source("/home/rpopat/AdzunaDataBot/authentications.R")
source("/home/rpopat/AdzunaDataBot/scripts/bow_functions.R")
source("/home/rpopat/AdzunaDataBot/scripts/get_sql_data.R")
source("/home/rpopat/AdzunaDataBot/scripts/get_relevance_scores.R")

d$day_created <- date(d$created)

### STILL AVAILABLE
# from our historical DB, which ads are still live
today <- max(d$date_queried)
available_today_id <- d$id[d$date_queried == today]
d$available_today <- d$id %in% available_today_id
d$location_coords <- paste(d$longitude, d$latitude)

saveRDS(d, "/home/rpopat/AdzunaDataBot/dashboard/data/d.rds")


### REMOVE DUPLICATES
# present because succesive daily queries return some identical results
duplicate_ads <- which(duplicated(d$id, fromLast = TRUE))
d_small <- d[-duplicate_ads, ]
d_small$mean_salary_thou <- ((d_small$salary_max + d_small$salary_min) / 2)/1000

### Removing duplicate ads posted twice with different IDs
# Job Title, trimmed and cleaned company name, and first 20 chars of description
# will be used to determine the duplicates
# the company name will be sanitized to remove the following generic titles, 
# to identify the underlying company

exc_words = "ltd.|ltd|limited|limited.|recruitment|solutions|solution|plc|plc."
trim <- function (x) gsub("^\\s+|\\s+$", "", x)
cutout <- function (x) gsub(exc_words, "", x)
d_small$company.display_name_lower <- trim(cutout(tolower(d_small$company.display_name)))
d_small$desc_short  <- tolower(substring(d_small$description, 0, 20))
duplicate_ads <- which(duplicated(
                  d_small[,c('title','company.display_name_lower', 'desc_short')]
                  ,fromLast=TRUE)
                  )
d_small <- d_small[-duplicate_ads, ]
saveRDS(d_small, "/home/rpopat/AdzunaDataBot/dashboard/data/d_small.rds")

### Calculate relevance scores
# And filter results not deemed relevant (score == 0)

d_small$relevance_score <- sapply(d_small$category.tag, get_relevance_scores)
d_small <- d_small[d_small$relevance_score !=0,]
saveRDS(d_small, "/home/rpopat/AdzunaDataBot/dashboard/data/d_small.rds")

### DATASET FOR MAPPING
# need to handle repeat locations and missing locations
job_points <- data.frame(
  lng = d_small$longitude, 
  lat = d_small$latitude
)
gaps <- which(apply(job_points, 1, function(x) any(is.na(x))))
dups <- which(duplicated(job_points))
to_remove <- unique(c(gaps, dups))
d_map <- d_small[-to_remove,]
job_points <- job_points[-to_remove,]

### COLLECT MAP POPUP LABELS
popup_labels <- character(nrow(d_map))
still_available <- character(nrow(d_map))
still_available[1:nrow(d_map)] <- "red"
for(i in 1:nrow(d_map)) {
  these_rows <- d_small[d_small$location_coords == d_map$location_coords[i],]
  these_rows$pred_true <- ifelse(these_rows$salary_is_predicted == "1", "**Predicted salary (c) Adzuna", "")
  if(sum(these_rows$available_today, na.rm = TRUE) > 0) { still_available[i] <- "darkgreen" }
  for(j in 1:nrow(these_rows)){
    popup_labels[i] <- paste0(popup_labels[i],
                           paste0(
                             these_rows$company.display_name[j], "<br>",
                             these_rows$title[j], "<br>",
                             "£", these_rows$salary_min[j], " - ", these_rows$salary_max[j], "<br>",
                             these_rows$pred_true[j], "<br><br>"
                             )
                           )
  }
}
d_map$labels <- popup_labels
d_map$still_available <- still_available

saveRDS(d_map, "/home/rpopat/AdzunaDataBot/dashboard/data/d_map.rds")

### DATASETs FOR WORDS
words <- BagOfWords(d_small$description)

wrd <- paste0(" ", words$word_count$word, " ")
skills_index <- c(
  grep(" c ", wrd),
  grep(" r ", wrd),
  grep(" spss ", wrd),
  grep(" python ", wrd), 
  grep(" scala ", wrd), 
  grep(" java ", wrd), 
  grep(" hadoop ", wrd), 
  grep(" spark ", wrd), 
  grep(" pig ", wrd), 
  grep(" hive ", wrd), 
  grep(" maths ", wrd), 
  grep(" statistics ", wrd), 
  grep(" visualisation ", wrd)
)
skills_count <- colSums(words$dtm)[skills_index]
skills_count <- skills_count[order(skills_count)]
skills_count <- data.frame(
  skill = names(skills_count), 
  count = skills_count
)
saveRDS(skills_count, "/home/rpopat/AdzunaDataBot/dashboard/data/skills_count.rds")

top_words <- words$word_count[order(words$word_count$count, decreasing = TRUE), ]
saveRDS(top_words, "/home/rpopat/AdzunaDataBot/dashboard/data/top_words.rds")

cat(paste("\nscript ran successfully on:", Sys.time()))
