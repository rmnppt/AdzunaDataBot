words_to_exclude <- c(
  'strong', 
  'data', 
  'science', 
  'will', 
  'work', 
  'working'
)

BagOfWords <- function(
  v,    # should be a character vector
  to_exclude = words_to_exclude
) {
  bow <- Corpus(VectorSource(v))
  bow <- tm_map(bow, content_transformer(tolower))
  myStopwords <- c(stopwords('english'), to_exclude)
  bow <- tm_map(bow, removeWords, myStopwords)
  bow <- tm_map(bow, removePunctuation)
  dtm <- DocumentTermMatrix(bow)
  dtm <- as.data.frame(inspect(dtm))
  word_count <- data.frame(word = colnames(dtm), 
                           count = colSums(dtm))
  word_count$word <- reorder(word_count$word, -word_count$count)
  return(list(dtm = dtm, word_count = word_count))
}