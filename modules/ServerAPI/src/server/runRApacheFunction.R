# The next line is used by PrepareConfigFiles to include this file as a route in rapache, do not modify unless you intend to modify rapache routes (it can be anywhere in the files though)
# ROUTE: /runfunction

myMessenger <- Messenger$new()
myMessenger$logger <- createLogger(logName = "com.acas.runrfunction", logToConsole = FALSE)
myMessenger$logger$debug("runrfunction initiated")

runFunction <- function() {
  tryCatch({
    out <- capture.output(
      {
        setwd(racas::applicationSettings$appHome)
        myMessenger$logger$debug(paste0("working directory: ", getwd()))
        postData <- rawToChar(receiveBin())
        postedRequest <- fromJSON(postData)
        rScript <- postedRequest$rScript
        rFunction <- postedRequest$rFunction
        request <- fromJSON(postedRequest$request)
        myMessenger$logger$debug(paste0("running: source(\"",rScript,"\", local = TRUE)"))
        myMessenger$capture_output(source(rScript, local = TRUE), continueOnError = FALSE)
        myMessenger$logger$debug(paste0("running: returnValues <- ",rFunction,"(",paste0(capture.output(dput(request)),collapse = ""),")", collapse = ""))
        myMessenger$capture_output(returnValues <- eval(parse(text = paste0(rFunction,"(request)"))), stopOnError = TRUE)
      })
    cat(rjson::toJSON(returnValues))
  },error = function(ex) {
    cat(paste0('{"RExecutionError":"',ex$message,'"}'))
    myMessenger$logger$error(ex$message)
  })
}
runFunction()
