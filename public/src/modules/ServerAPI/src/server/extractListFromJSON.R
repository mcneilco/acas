# Takes a single JSON object and turns it into an R list
#
# Author: Jennifer Rogers

readJSON <- function(filePath) {
  # Takes the path to a JSON file and reads it out as one
  # long string, with each word separated by spaces only (because
  # JSON is whitespace insensitive)
  
  return(paste(scan(file = filePath, what = character(), quiet = TRUE, quote = ""), collapse = " "))
}

parseJavaScript <- function(filePath, objectName) {
  # Takes a file containing *only* a JSON object and turns it into a list
  #
  # Input:   the file path to a JSON file
  #          the name of the JSON variable
  # Returns: a one-element list whose name is the JSON object's name,
  #          and whose contents are the JSON object (as a list)
  
  library(rjson)
  jsonObject <- readJSON(filePath)
  jsonList <- fromJSON(jsonObject)
  namedJsonList <- list(jsonList)
  names(namedJsonList) <- objectName
  return(namedJsonList)
}
