library(racas)
library(rjson)
if(as.logical(racas::applicationSettings$server.support.smtp.auth)) {
  library(mailR)
} else {
  library(sendmailR)
}
globalMessenger <- messenger()
globalMessenger$reset()
globalMessenger$logger <- logger(logName = "com.acas.BulkLoadSampleTransfers.BulkLoadSampleTransfersEmail", reset=TRUE)
globalMessenger$logger$debug("bulk load transfer save started")
source(file.path(racas::applicationSettings$appHome, "public/src/modules/BulkLoadSampleTransfers/src/server/BulkLoadSampleTransfers.R"), local=T)
setwd(racas::applicationSettings$appHome)
runBulkLoadAndEmail <- function(request) {
  fileName <- request$fileName
  dryRun <- request$dryRun
  testMode <- request$testMode
  developmentMode <- request$developmentMode
  recordedBy <- request$recordedBy
  loadResult <- tryCatchLog(runBulkLoadSampleMult(fileName,dryRun, testMode, developmentMode, recordedBy))
  
  globalMessenger$logger$debug(toJSON(loadResult))
  
  if (length(loadResult$errorList) > 0) { # Errors from runner of other code
    allTextErrors <- getErrorText(loadResult$errorList)
    warningList <- getWarningText(loadResult$warningList)
  } else { # Errors within run code
    allTextErrors <- loadResult$value$allTextErrors
    warningList <- loadResult$value$allTextWarnings
  }
  summaryInfo <- list(info=loadResult$value$info)
  
  # Organize the error outputs
  hasError <- length(allTextErrors) > 0
  hasWarning <- length(warningList) > 0
  
  errorMessages <- list()
  
  # This is code that could put the error and warning messages into a format that is displayed at the bottom of the screen
  errorMessages <- c(errorMessages, lapply(allTextErrors, function(x) {list(errorLevel="error", message=x)}))
  errorMessages <- c(errorMessages, lapply(warningList, function(x) {list(errorLevel="warning", message=x)}))
  
  htmlSummary <- createHtmlSummary(hasError,allTextErrors,hasWarning,warningList,summaryInfo=summaryInfo,dryRun)
  
  # look up email for user
  userObject <- fromJSON(getURLcheckStatus(
    paste0(racas::applicationSettings$client.service.persistence.fullpath, 
           "authors?find=ByUserName&userName=", URLencode(recordedBy, reserved = TRUE)), requireJSON = TRUE))
  
  userEmail <- userObject$emailAddress
  from <- sprintf("<ACAS@%s>", Sys.info()[4]) #nodename 
  to <- paste0(gsub(" ", "", recordedBy)," <", userEmail ,">")
  
  subject <- paste0("Sample transfer notification")
  body <- htmlSummary
  globalMessenger$logger$debug(paste0("body: ", body))
  globalMessenger$logger$debug(paste0("subject: ", subject))
  globalMessenger$logger$debug(paste0("from: ", from))
  globalMessenger$logger$debug(paste0("to: ", to))
  # Send with appropriate package
  if(racas::applicationSettings$server.support.smtp.auth) {
    tryCatchLog(send.mail(from = from,
              to = to,
              subject = subject,
              body = body,
              html = TRUE,
              smtp = list(host.name = racas::applicationSettings$server.support.smtp.host, 
                          port = racas::applicationSettings$server.support.smtp.port, 
                          user.name = racas::applicationSettings$server.support.smtp.username, 
                          passwd = racas::applicationSettings$server.support.smtp.password, 
                          ssl = as.logical(racas::applicationSettings$server.support.smtp.ssl)),
              authenticate = racas::applicationSettings$server.support.smtp.auth,
              send = TRUE))
  } else {
    msg <- mime_part(body)
    msg[["headers"]][["Content-Type"]] <- "text/html"
    tryCatchLog(sendmail(from, 
             to, 
             subject, 
             msg = msg))
  }
}
