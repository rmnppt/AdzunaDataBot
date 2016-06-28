library(ggplot2)
library(lubridate)
library(tm)

source("/home/rpopat/AdzunaDataBot/authentications.R")
source("/home/rpopat/AdzunaDataBot/scripts/bow_functions.R")
source("/home/rpopat/AdzunaDataBot/scripts/get_sql_data.R")

### STILL AVAILABLE
# from our historical DB, which ads are still live
today <- max(d$date_queried)
available_today_id <- d$id[d$date_queried == today]
d$available_today <- d$id %in% available_today_id
d$location_coords <- paste(d$longitude, d$latitude)

### REMOVE DUPLICATES
# present because succesive daily queries return some identical results
duplicate_ads <- which(duplicated(d$id, fromLast = TRUE))
d_small <- d[-duplicate_ads, ]
d_small$day_created <- date(d_small$created)
d_small$mean_salary_thou <- ((d_small$salary_max + d_small$salary_min) / 2)/1000
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
  if(sum(these_rows$available_today, na.rm = TRUE) > 0) { still_available[i] <- "darkgreen" }
  for(j in 1:nrow(these_rows)){
    popup_labels[i] <- paste0(popup_labels[i],
                           paste0(
                             these_rows$company.display_name[j], "<br>",
                             these_rows$title[j], "<br>",
                             "£", these_rows$salary_min[j], " - ", these_rows$salary_max[j], "<br><br>"
                             )
                           )
  }
}
d_map$labels <- popup_labels
d_map$still_available <- still_available

saveRDS(d_map, "/home/rpopat/AdzunaDataBot/dashboard/data/d_map.rds")

### DATASET FOR WORDS
words <- BagOfWords(d_small$description)$word_count
top_words <- words[order(words$count, decreasing = TRUE), ]

saveRDS(top_words, "/home/rpopat/AdzunaDataBot/dashboard/data/top_words.rds")

cat(paste("\nscript ran successfully on:", Sys.time()))
