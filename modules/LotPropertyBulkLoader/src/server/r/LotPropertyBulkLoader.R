# Brian Bolt
# 2018
# brian.bolt@boltengineered.com
library(RCurl)
library(data.table)
library(xtable)


validateNumeric <- function(inputValue) {
  value <- suppressWarnings(as.numeric(gsub(",", "", as.character(inputValue))))
  isNumeric <- !is.na(value)
  return(list(value, isNumeric))
}
areNumbersEqual <- function(val1, val2) {
  if(is.na(val1) & is.na(val2)) {
    return(TRUE)
  }
  if((is.na(val1) & !is.na(val2)) || (!is.na(val1) & is.na(val1))) {
    return(FALSE)
  }
  identical(val1, val2)
}

validateFileInput <- function(fileData, headerMap, errorEnv) {
  expectedHeaders <- "Lot Corporate Name"

  fileHeaders <- as.character(fileData[1,])
  missingNames <- expectedHeaders[!expectedHeaders %in% fileHeaders]
  if(length(missingNames) > 0) {
    stopUser(paste0("Missing columns in file: ",paste0("'",paste(missingNames, collapse = "','"), "'")))
  }
  optionalHeaders <- fileHeaders[ !fileHeaders %in% expectedHeaders]
  if(length(optionalHeaders) == 0) {
    stopUser(paste0("You must provide atleast one property to load: ",paste0("'",paste(headerMap$fileHeader, collapse = "','"), "'")))
  }
  unusedColumns <- optionalHeaders[!optionalHeaders %in% headerMap$fileHeader]
  if(length(unusedColumns) > 0) {
    racasMessenger$addWarning(paste0("The following columns are unused: ",paste0("'",paste(unusedColumns, collapse = "','"), "'")))
  }
  usedHeaders <- optionalHeaders[ !optionalHeaders %in% unusedColumns]
  if(length(usedHeaders) == 0) {
    stopUser(paste0("You must provide atleast one property to load: ",paste0("'",paste(headerMap$fileHeader, collapse = "','"), "'")))
  }
  validatedFileData <- fileData[2:nrow(fileData),fileHeaders %in% c(expectedHeaders, usedHeaders)]
  names(validatedFileData) <- c(expectedHeaders, usedHeaders)
  
  mainCode <- "Corporate Batch ID"
  newBatchIds <- as.data.table(getPreferredId2(validatedFileData$`Lot Corporate Name`, displayName = mainCode))
  newBatchIds[ , c("error", "warning", "Issues") := {
    issues <- NA_character_
    error <- FALSE
    warning <- FALSE
    if (is.null(Reference.Code) || is.na(Reference.Code) || Reference.Code == "") {
      error <- TRUE
      issues <- paste0(mainCode, " '", Requested.Name,
                      "' has not been registered in the system. Contact your system administrator for help.")
    } else if (as.character(Requested.Name) != as.character(Reference.Code)) {
        warning <- TRUE
        issues <- paste0("A ", mainCode, " that you entered, '", Requested.Name,
                        "', was replaced by preferred ", mainCode, " '", Reference.Code,
                        "'. If this is not what you intended, replace the ", mainCode, " with the correct ID.")
        
    }
    list(error, warning, issues)
  }, by = "Requested.Name"]
 
  validatedFileDataDT <- as.data.table(validatedFileData)
  newBatchIds <- as.data.table(newBatchIds)
  setkey(newBatchIds, 'Requested.Name' )
  setkey(validatedFileDataDT, 'Lot Corporate Name' )
  validatedFileDataDT[newBatchIds, c('Lot Corporate Name','error','warning','Issues') := list(Reference.Code, error, warning, Issues)]
  return(validatedFileDataDT)
}
requestHandler <- function(request) {
  racasMessenger <- messenger()
  racasMessenger$reset()
  racasMessenger$logger <- logger(logName = "com.mcneilco.acas.LotPropertyBulkLoader", reset=TRUE)
  
  fileData <- readExcelOrCsv(getUploadedFilePath(request$fileToParse))
  errorEnv <- globalenv()

  headerMap <- data.frame(fileHeader = c("Purity","Observed Mass #1","Observed Mass #2"), 
                          ## These settings should come from the bulk load configuration but remove "Lot" from the name as this is already the context
                          mappedProperty = c("purity", "observedMassOne", "observedMassTwo"),
                          type = c("numeric", "numeric", "numeric")
                          , stringsAsFactors = FALSE)

  validatedData <- validateFileInput(fileData, headerMap, errorEnv)

  metaLotBaseURL <- paste0(applicationSettings$client.service.cmpdReg.persistence.basepath,"/metalots")
  metaLotCorpNameURL <- paste0(metaLotBaseURL,"/corpName")
  getPropertyNames <- names(validatedData)[ !names(validatedData) %in% c('Lot Corporate Name', 'error','warning', 'Issues')]
  getProperties <- headerMap[match(getPropertyNames, headerMap$fileHeader),]
  overwriteExisting <- as.logical(request$inputParameters$overwriteExisting)
  validatedData[ error == FALSE, c(paste0(c("Current ", "New "), rep(getProperties$fileHeader, each = 2)),"error","warning","Issues") := {
    metaLotBaseURL <- paste0(applicationSettings$client.service.cmpdReg.persistence.basepath,"/metalots")
    metaLotCorpNameURL <- paste0(metaLotBaseURL,"/corpName")
    metaLot <- fromJSON(getURL(paste0(metaLotCorpNameURL, "/",`Lot Corporate Name`)), )
    properties <- metaLot$lot[getProperties$mappedProperty]
    values <- list()
    issues <- Issues
    for(i in 1:nrow(getProperties)) {
      type <- getProperties$type[[i]]
      if(is.null(properties[[i]])) {
        currentProperty <- switch(type,
               numeric = NA_real_,
               character = NA_character_
          )
      } else {
        currentProperty <- properties[[i]]
      }
  
      inputProperty <- get(getProperties$fileHeader[[i]])
      validatedInputProperty <- switch(type,
             numeric = validateNumeric(inputProperty),
             character = validateCharacter(inputProperty))
      
      if(!is.na(inputProperty) && validatedInputProperty[[2]] == FALSE) {
        error <- TRUE
        issues <- c(issues,"Input value not numeric")
      } else {
        numbersEqual <- areNumbersEqual(currentProperty, validatedInputProperty[[1]])
        if(!numbersEqual & !is.na(currentProperty)) {
          if(overwriteExisting) {
            warning <- TRUE
          } else {
            error <- TRUE
          }
          issues <- c(issues, paste0(getProperties$fileHeader[[i]]," overwrite"))
        }
      }
      if(!error)  {
        print(error)
        if(is.na(validatedInputProperty[[1]])) {
          metaLot$lot[getProperties$mappedProperty[[i]]] <- NULL
        } else {
          metaLot$lot[getProperties$mappedProperty[[i]]] <- validatedInputProperty[[1]]
        }
      }
      values <- c(values,list(currentProperty, validatedInputProperty[[1]]))
    }
    issues <- stats::na.omit(issues)
    if(length(issues) > 0) {
      issues <- paste0(issues, collapse = ", ")
    } else {
      issues <- NA_character_
    }
    if(!as.logical(request$dryRunMode)) {
      if(!error) {
        metaLotJson <- toJSON(metaLot)
        postJSONURL(metaLotBaseURL, metaLotJson)
      }
    }
    c(values, list(error, warning, unique(issues)))
  }, by = 'Lot Corporate Name', with = FALSE]
  
  validatedData[ , getProperties$fileHeader := NULL, with = FALSE]
  
	hasError <- FALSE
	if(any(validatedData$error) | length(racasMessenger$errors) > 0) {
	  hasError <- TRUE
	}
	hasWarning <- FALSE
	if(any(validatedData$warning) | length(racasMessenger$warnings) > 0) {
	  hasWarning <- TRUE
	}
	errorList <- lapply(racasMessenger$errors, function(x) {x$message})
	warningList <- lapply(racasMessenger$warnings, function(x) {x$message})
	errorMessages <- list()
	errorMessages <- c(errorMessages, lapply(errorList, function(x) {list(errorLevel="error", message=x)}))
	errorMessages <- c(errorMessages, lapply(warningList, function(x) {list(errorLevel="warning", message=x)}))
	transactionId = NULL
	fileName <- request[[1]]
	dryRun <- request[[2]]
	addToRow <- NULL

	if(!as.logical(request$dryRun)) {
	  validatedData[ , names(validatedData)[grepl("Current", names(validatedData))] := NULL, with = FALSE]
	  validatedData[ , "Issues" := NULL, with = FALSE]
	} else {
	  errorRows <- which(validatedData$error)-1
	  warningRows <- which(validatedData$warning & !validatedData$error)-1
	  addToRows <- c(errorRows, warningRows)
	  if(length(errorRows) > 0) {
	    errorList <- c(errorList, list("See table for additional errors"))
	  }
	  if(length(warningRows) > 0) {
	    warningList <- c(warningList, list("See table for additional warnings"))
	  }
	  if(length(addToRows) > 0) {
	    command <- c(rep("error", times = length(errorRows)), rep("warning", times = length(warningRows)))
	    addToRow <- list(pos = as.list(addToRows), command = command)
	  }
	}

	table <- print.xtable(
	  xtable(validatedData[ , c("error", "warning") := NULL]), "html",hline.after=c(-1,0, 1:nrow(validatedData)),
	  include.rownames=FALSE, caption.placement='top',
	  html.table.attributes='align="left"', print.rules = FALSE, size = "small",
	  add.to.row = addToRow
	)

	table <- paste('<style>
    table {
        border-collapse: collapse;
        width: 100%;
    }
    div.bv_htmlSummary.well {
        width: 1050px;
    }
    .warning {
        background-color: yellow !important;
    }
    .error {
        background-color: #ff8080 !important;
    }
    td, th {
        border: 1px solid #dddddd;
    	               text-align: left;
    }
    tr:nth-child(even) {
      background-color: #dddddd;
    }
</style>',table)
	table <- gsub("<table>",'<table style="font-family:arial;font-size:80%" border=1 frame=hsides rules=rows>', table)
	table <- gsub("warning <tr>", '<tr class="warning">', table)
	table <- gsub("error <tr>", '<tr class="error">', table)
	
	htmlSummary <- createHtmlSummary(hasError, errorList, hasWarning, warningList, 
	                                 summaryInfo=NULL, as.logical(request$dryRun))
	
	htmlSummary <- paste0(htmlSummary,"<br>",table)
	
	racasMessenger
	response <- list(
		commit= FALSE,
		transactionId= transactionId,
		results= list(
			path= getwd(),
			fileToParse= fileName,
			dryRun= dryRun,
			htmlSummary= htmlSummary
		),
		hasError= hasError,
		hasWarning = hasWarning,
		errorMessages= errorMessages
	)
	return( response)

}