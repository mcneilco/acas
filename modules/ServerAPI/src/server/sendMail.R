# The next line is used by PrepareConfigFiles to include this file as a route in rapache, do not modify unless you intend to modify rapache routes (it can be anywhere in the files though)
# ROUTE: /sendMail

library(racas)
library(mailR)

sendMail <- function(request) {
    request <- jsonlite::fromJSON(request)
    request$send <- TRUE
    request$debug <- TRUE
    do.call(mailR::send.mail, request)
  return(TRUE)
}

postData <- rawToChar(receiveBin(-1))
cat(jsonlite::toJSON(sendMail(postData), auto_unbox = TRUE))
DONE