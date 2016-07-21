library(racas)
generateSummaryStatisticsSuccess <- tryCatch({
  generateSummaryStatistics()
}, error = function(e){
  stop(e)
  return(list())
})
if(length(generateSummaryStatisticsSuccess) > 0) {
  cat("generate summary statistics successful\n")
  cat("files created:\n")
  cat(toJSON(generateSummaryStatisticsSuccess))
}

