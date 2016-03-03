# Takes a single JSON object and turns it into an R list
#
# Author: Jennifer Rogers

readJSON <- function(filePath) {
  # Takes the path to a JSON file and reads it out as one
  # long string, with each word separated by spaces only (because
  # JSON is whitespace insensitive)
  
  return(paste(scan(file = filePath, what = character(), quiet = TRUE, quote = ""), collapse = " "))
}

parseJavaScript <- function(filePath) {
  # Takes a file containing a JSON object, which may contain a sequence
  # of JSON objects (see examples under javascripts/spec/TestJSON/)
  #
  # Input:   the file path to a JSON file
  # Returns: a list of the JSON objects found in the file. They can be
  #          accesses by dereferencing the list using the object's name
  #          (e.g., jsonList$objectName)
  
  library(rjson)
  jsonObject <- readJSON(filePath)
  jsonList <- fromJSON(jsonObject)
  return(jsonList)
}
