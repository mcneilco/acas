# ROUTE: /experiment/primaryanalysis
require(data.table)


myMessenger <- Messenger$new()
myMessenger$logger <- logger(logName = "com.acas.reanalysis", logToConsole = FALSE)
myMessenger$logger$debug("primary reanalysis initiated")

write_csv <- function(x, file, rows = 1000L, ...) {
  passes <- NROW(x) %/% rows
  remaining <- NROW(x) %% rows
  k <- 1L
  if(passes > 0) {
    write.table(x[k:rows, ], file, quote = FALSE,row.names = FALSE, ...)
  } else {
    write.table(x, file, quote = FALSE,row.names = FALSE, ...)
    return(invisible())
  }
  k <- k + rows
  for(i in seq_len(passes)[-1]) {
    write.table(x[k:(rows*i), ], file, quote = FALSE,, append = TRUE, row.names =
                  FALSE, col.names = FALSE, ...)
    k <- k + rows
  }
  if(remaining > 0) {
    write.table(x[k:NROW(x), ], file, quote = FALSE, append = TRUE, row.names =
                  FALSE, col.names = FALSE, ...)
  }
}

dataframe_to_csvstring <- function(x, ...) {
  t <- tempfile()
  on.exit(unlink(t))
  write_csv(x,t, sep = "\t", ...)
  csv_string <- readChar(t, file.info(t)$size)
}

normalizeDataOriginal <- function() {
    experimentCode <- POST$experimentCode
    data <- fread(paste0("file://",FILES$file$tmp_name))
    data[, originalOrder:=1:nrow(data)]
    keyColumns <- c("Assay Barcode", "Well")
    setkeyv(data, keyColumns)
    normalizedNames <- c("Efficacy", "SD Score", "Z' By Plate", "Z'", "Activity", "Normalized Activity", "Auto Flag Type", "Auto Flag Observation", "Auto Flag Reason")
    data[ , "Efficacy":=runif(.N, 0, 100)]
    data[ , "SD Score":=runif(.N, -1, 10)]
    data[ , "Z' By Plate":=runif(.N, 0, 1)]
    data[ , "Z'":=runif(.N, 0, 1)]
    data[ , "Activity":=runif(.N, 0, 50000)]
    data[ , "Normalized Activity":= runif(.N, 0, 50000)]
    flags <- list(
        list("Auto Flag Type" = "KO - Well Knocked Out", "Auto Flag Observation" = "Low - Signal too low", "Auto Flag Reason" = "Bad Tip"),
        list("Auto Flag Type" = "KO - Well Knocked Out", "Auto Flag Observation" = "Low - Signal too high", "Auto Flag Reason" = "Pin carryover"),
        list("Auto Flag Type" = "Hit", "Auto Flag Observation" = "Threshold", "Auto Flag Reason" = "Agonist Hit")
        )
    flags <- rbindlist(flags)
    cols <- names(flags)
    data[sample(1:.N,.N/10), get("cols"):=flags[sample(1:nrow(flags),.N, replace = TRUE)]]
    setkey(data,originalOrder)
    keepColumns <- c(keyColumns,normalizedNames)
    data[ , setdiff(colnames(data),keepColumns):=NULL, with = FALSE]
    csv_data <- dataframe_to_csvstring(data, na = "")
    setHeader("Access-Control-Allow-Origin","*")
    setHeader("Content-Length",nchar(csv_data))
    setContentType("text/csv;")
    cat(csv_data)
    DONE
}

normalizeData <- function() {
  setwd(racas::applicationSettings$appHome)
  source("public/src/modules/PrimaryScreen/src/server/PrimaryAnalysis.R")
  experimentCode <- POST$experimentCode
  flagFile <- getUploadedFilePath(FILES$file$name)
  file.copy(FILES$file$tmp_name, flagFile, overwrite = T)
  csvText <- spotfireWrapperFunction(experimentCode, flagFile)
  #myMessenger$capture_output({csvText <- spotfireWrapperFunction(experimentCode, flagFile)})
  #myMessenger$logger$debug(csvText)
  setHeader("Access-Control-Allow-Origin","*")
  setHeader("Content-Length",nchar(csvText))
  setContentType("text/csv;")
  cat(csvText)
  DONE
}

spotfireWrapperFunction <- function(experimentCode, wellFlagFile) {
  #   experimentCode <- "EXPT-00000887"
  #   wellFlagFile <- "Step2_Renormalize_Input_v2 (4).txt"
  
  experiment <- getExperimentByCodeName(experimentCode)
  
  experimentStates <- getStatesByTypeAndKind(experiment, "metadata_experiment metadata")[[1]]
  experimentClobValues <- getValuesByTypeAndKind(experimentStates, "clobValue_data analysis parameters")[[1]]
  experimentFolderPath <- getValuesByTypeAndKind(experimentStates, "fileValue_dryrun source file")[[1]]
  
  # wellFlagFile is passed a location relative from ACAS_HOME, but expects one from privateUploads
  wellFlagFile <- gsub(getUploadedFilePath(""), "", wellFlagFile)
  
  request <- list()
  request$inputParameters <- experimentClobValues$clobValue
  request$primaryAnalysisExperimentId <- experiment$id
  # This loses filename input, maybe add it back later, or just don't save over the old input file
  newPath <- tempfile("spotfireInput", getUploadedFilePath(""), ".zip")
  fileInfo <- fromJSON(getURLcheckStatus(paste0(getAcasFileLink(experimentFolderPath$fileValue), "/metadata.json")))
  file.copy(fileInfo[[1]]$dnsFile$path, newPath)
  #download.file(getAcasFileLink(experimentFolderPath$fileValue), newPath)
  request$fileToParse <- basename(newPath)
  request$user <- experiment$recordedBy
  request$reportFile <- wellFlagFile
  request$flaggedFile <- wellFlagFile
  request$testMode <- FALSE
  
  #   request$testMode <- "false"
  request$dryRunMode <- "true"
  
  #   names(request): 
  #   √ "fileToParse": "Archive.zip"
  #   √ "reportFile": "Step2_Renormalize_Input_v2 (1).txt"
  #     "imagesFile": ""
  #     "dryRunMode": "true"           
  #   √ "user": "bob"
  #   √ "inputParameters": lots of stuff (parameters)
  #   √ "primaryAnalysisExperimentId": "1111764" 
  #     "testMode": "false"              
  #   √ "flaggedFile": "Step2_Renormalize_Input_v2 (1).txt"
  
  analysisResult <- runPrimaryAnalysis(request) # need request
  # do we need to return something different if we're not in dry run?
  # no - we will never run this in !dryRun
  outputText <- analysisResult$results$jsonSummary$dryRunReports$spotfireFile$fileText
  
  #   spotfireFileLocation <- paste0("curl --form experimentCode=",
  #                                  experimentCode,
  #                                  "  --form file=@",
  #                                  wellFlagFile,
  #                                  " http://acas-d.dart.corp/r-services-api/experiment/primaryanalysis/")
  
  #   fileValue <- savedInDatabaseSomewhere /jazz hands
  return(outputText)
}

normalizeData()
