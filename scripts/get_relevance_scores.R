### Function to calculate the relevance scores of each seach result
# This function will be continuously enhanced to add more features to relevance scores
# Final results will be filtered for relevance scores threshold

#For now, relevance scores will be based on conditional statements.
#We could look at improving it by introducing a labeled data set 
#and learning patterns from the data (classification)

get_relevance_scores <- function(x) {
  score = 0 #not relevant
  relevant_categories <- c('accounting-finance-jobs','consultancy-jobs',
                           'engineering-jobs','graduate-jobs','it-jobs',
                           'scientific-qa-jobs', 'teaching-jobs', 'unknown')
  if (x %in% relevant_categories) {
    score = 1
  }
  return (score)
}