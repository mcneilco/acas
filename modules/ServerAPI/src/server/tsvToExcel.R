# The next line is used by PrepareConfigFiles to include this file as a route in rapache, do not modify unless you intend to modify rapache routes (it can be anywhere in the files though)
# ROUTE: /tsvToExcel

library(XLConnect)
library(data.table)
myLogger <- logger(logToConsole = FALSE)
myLogger$info("tsv to excel initialized")

request <- list(fileName= "/tmp/blah.xlsx")
request$content <- list(list(sheetName="my sheet 1", tsvContent = "Col1\tCol1\n1\t,n2", orderBy = c(1,2)), list(sheetName="my sheet 2", tsvContent = "Col1\tCol1\n1\t,n2"))

tsvToExcel <- function(request) {
  wb <- loadWorkbook(request$fileName, create = TRUE)
  for(content in request$content) {
    createSheet(wb, content$sheetName)
    if(is.null(content$header) || content$header == TRUE) {
      header = TRUE
    } else {
      header = FALSE
    }
    tsvContent <- fread(content$tsvContent, header = header)
    if(!is.null(content$orderBy) && length(content$orderBy) > 0) {
      setorderv(tsvContent, names(tsvContent)[content$orderBy])
    }
    writeWorksheet(wb, tsvContent, sheet = content$sheetName, header = header)
  }
  saveWorkbook(wb)
  return(list(fileName = request$fileName))
}
postData <- rawToChar(receiveBin())
request <- fromJSON(postData)

output <- tsvToExcel(request)
cat(jsonlite::toJSON(output, auto_unbox = TRUE))