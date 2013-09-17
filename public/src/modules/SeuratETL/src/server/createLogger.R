library(logging)
createLogger <- function(logName = "default.logger", logFileName = "output.log", logDir = getwd(), logLevel = "INFO") {
  basicConfig(level = logLevel)
  if(is.na(logDir)) {
    logDir <-  getwd()
  }
  logPath <- paste0(logDir,"/",logFileName)
  getLogger(logName)$addHandler(writeToFile, file=logPath, level = logLevel)
  logger <- getLogger(logName)
  setLevel(logLevel, logger)
  
  return(logger)
}
