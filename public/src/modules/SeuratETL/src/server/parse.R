# ROUTE: /seuratETL/parse

suppressMessages(library(reshape))
suppressMessages(library(data.table))

#' readSeuratFile
#' 
#' Reads Seurat formatted assay upload file or the character representation of that file
#'
#' @param pathToSeuratFile character Can be a path to a file (xls, xlsx, or csv) or the text content of a csv file
#' @param file boolean Forces a xlsx or xls file path to be read as a csv
#'
#' @return data.table Seurat assay upload content
#' @export
#'
#' @examples
readSeuratFile <- function(pathToSeuratFile, file = TRUE) {
  
  if(file == TRUE) {
    fileExt <- tolower(file_ext(pathToSeuratFile))
  } else {
    fileExt <- NA
  }
  if(file == TRUE && fileExt %in% c("xlsx", "xls")) {
    library(XLConnect)
    wb <- XLConnect::loadWorkbook(pathToSeuratFile)
    sheetToRead <- which(!unlist(lapply(XLConnect::getSheets(wb), XLConnect::isSheetHidden, object = wb)))[1]
    seuratFileContents <- as.data.table(XLConnect::readWorksheet(wb, sheet = sheetToRead, header = TRUE, dateTimeFormat="%Y-%m-%d", check.names = TRUE))
  } else {
    seuratFileContents <- as.data.table(suppressWarnings(read.csv(pathToSeuratFile, na.strings = c("", "NA"), 
                                colClasses = c("Expt Batch Number" = "character", 
                                               "Assay Protocol" = "character",
                                               "Expt Result Operator" = "character",
                                               "Expt Concentration" = "character",
                                               "Expt Conc Units" = "character",
                                               "Expt Result Desc" = "character"),
                                stringsAsFactors = FALSE,
                                  )))
    setnames(seuratFileContents, make.names(names(seuratFileContents)))
    if("Expt Date" %in% names(seuratFileContents)) {
      seuratFileContents$'Expt Date' <- as.POSIXct(unlist(suppressWarnings(lapply(seuratFileContents$`Expt Date`, validateDate))))
    }
  }
  return(seuratFileContents)
}

#' parseSeuratFileToSELContentJSON
#' 
#' Parse Seurat assay upload content to ACAS SEL formatted content and return JSON representation
#'
#' @param pathToSeuratFile see \code{\link{readSeuratFile}}
#'
#' @return character JSON array with protocolName, experimentName and selContent keys
#' @export
#'
#' @examples
parseSeuratFileToSELContentJSON <- function(pathToSeuratFile) {
  
  library(racas)
  library(jsonlite)
  errorMessages <- list()
  myMessenger <- messenger(racas = TRUE)$reset()
  # use if to check hasErrors in myMessenger
  myMessenger$capture_output({
    seuratFileContent <- readSeuratFile(pathToSeuratFile)
    selContent<- parseSeuratFileContentToSELContentList(seuratFileContent)
  })
  if (!exists("selContent")) { 
    selContent <- NULL
  }
  response <- list(
    commit= FALSE,
    results= selContent,
    hasError= myMessenger$hasErrors(),
    hasWarning = myMessenger$hasWarnings(),
    errorMessages= lapply(myMessenger$errors, function(x) x$message)
  )
  
  return(jsonlite::toJSON(response, auto_unbox=TRUE))
}

#' stopUser
#'
#' Wraps the racas package function for use when racas is not being used
#' 
#' @param message character Value to error
#'
#' @return
#' @export
#'
#' @examples
stopUser <- function(message) {
  
  racasLoaded <- paste("package", "racas", sep = ":") %in% search()
  if(racasLoaded) {
    racas::stopUser(message)
  } else {
    stop(message)
  }
}

#' validateSeuratFileContent
#' 
#' Checks for seurat csv content issues before attempting to parse to sel content
#'
#' @param seuratFileContent data.frame of Seurat assay upload content
#'
#' @return error if validation fails
#' @export
#'
#' @examples
validateSeuratFileContent <- function(seuratFileContent) {
  
  #if the field doesn't exist OR if there are missing cases
  if(is.null(seuratFileContent$Assay.Name) || !all(complete.cases(seuratFileContent$Assay.Name))){
    stopUser("Assay Name not found for some or all results")
  }
  if(is.null(seuratFileContent$Lot.Number) || !all(complete.cases(seuratFileContent$Lot.Number))){
    stopUser("Lot Number not found for some or all results")
  }
  if(is.null(seuratFileContent$Corporate.ID) || !all(complete.cases(seuratFileContent$Corporate.ID))){
    stopUser("Corporate ID not found for some or all results")
  }
  if(is.null(seuratFileContent$Expt.Result.Type) || !all(complete.cases(seuratFileContent$Expt.Result.Type))){
    stopUser("Experiment result type was not specified for some or all results")
  }
  if(is.null(seuratFileContent$Expt.Result.Units) || !all(complete.cases(seuratFileContent$Expt.Result.Units))){
    stopUser("Experiment result unit was not specified for some or all results")
  }
  if(is.null(seuratFileContent$Expt.Result.Value) & is.null(seuratFileContent$Expt.Result.Desc)){
    stopUser("Experiment result value and description are both missing")
  }
  return(seuratFileContent)
}

#' parseSeuratFileContentToSELContentList
#' 
#' Takes Seurat formatted assay upload content and returns an ACAS SEL content data.table
#'
#' @param seuratFileContent data.table Seurat assay upload content
#'
#' @return data.table of sel content with columns protocolName, experimentName, and selContent (csv string)
#' @export
#'
#' @examples
parseSeuratFileContentToSELContentList <- function(seuratFileContent) {
  if(file.exists("validateSeuratFileContent.R")) {
    source("validateSeuratFileContent.R", local = FALSE)
  }
  seuratFileContent <- validateSeuratFileContent(seuratFileContent)
  seuratFileContent[ , c('Assay.Name','Assay.Protocol') := makeExperimentNamesUnique(seuratFileContent[ , c("Assay.Name", "Assay.Protocol"), with = FALSE], by = c("Assay.Name"))]
  seuratFileContent[ , c("value", "type") := makeValueString(.SD, Expt.Result.Type), by=Expt.Result.Type]
  selContent <- seuratFileContent[ , convertSeuratTableToSELContent(.SD), by = c("Assay.Protocol", "Assay.Name"), .SDcols = 1:ncol(seuratFileContent)]
  setnames(selContent, c("experimentName", "protocolName", "selContent"))
  return(selContent)
}

#' file_ext
#'
#' Gets the file extension for a file name
#' 
#' @param x 
#'
#' @return character The files extension
#' @export
#'
#' @examples
file_ext <- function(x) {
  
  pos <- regexpr("\\.([[:alnum:]]+)$", x)
  ifelse(pos > -1L, substring(x, pos + 1L), "")
}

#' makeExperimentNamesUnique
#' 
#' Replaces "Assay.Protocol" columns with a unique experiment name incremented with an "_1" or "_2" depending on how many times the experiment is repeated
#'
#' @param experimentNames data.frame Has "Assay.Protocol" columns as well as columns specified in by
#' @param by character Columns which to make experiments unique by 
#'
#' @return data.table with the same number of columns as experimentNames but with a replaced Assay.Protocol to make it unique
#' @export
#'
#' @examples
makeExperimentNamesUnique <- function(experimentNames, by) {
  
  outNames <- names(experimentNames)
  experimentNames <- copy(experimentNames)
  experimentNames[ , originalOrder := row.names(experimentNames)]
  #setting the key causes the column to sort independently without the rest of the dt
  setkeyv(experimentNames, c("Assay.Protocol", by))
  exptNames <- unique(experimentNames)
  setkey(exptNames,"Assay.Protocol")
  exptNames[, repeatedSequenced := sequence(rle(exptNames$Assay.Protocol)$lengths)-1]
  exptNames[ , 'Assay.Protocol.Old' := get('Assay.Protocol')]
  exptNames[repeatedSequenced > 0, 'Assay.Protocol' := paste0(Assay.Protocol,"_",repeatedSequenced)]
  setkeyv(exptNames, c(by, "Assay.Protocol.Old"))
  setkeyv(experimentNames, c(by, "Assay.Protocol"))
  outData <- exptNames[experimentNames]
  setkey(outData,originalOrder)
  outData[ , outNames, with = FALSE]
}

#' makeValueString
#'
#' Helper function to override data type field
#' 
#' @param exptRow data.frame Row of Seurat assay upload csv content
#' @param resultType character The Result type of the row
#'
#' @return
#' @export
#'
#' @examples
makeValueString <- function(exptRow, resultType) {
  
  # Sets the global list of values, the first two are just hard coded
  if (resultType == "Assay Date") type <- "Date"
  else if (resultType == "IC50") type <- "Number"
  else if (all(is.na(exptRow$Expt.Result.Value))) type <- "Text"
  else type <- "Number"
  val <- paste(ifelse(is.na(exptRow$Expt.Result.Operator), "", exptRow$Expt.Result.Operator),
               ifelse(is.na(exptRow$Expt.Result.Value),
                      ifelse(is.na(exptRow$Expt.Result.Desc), "",exptRow$Expt.Result.Desc),
                      exptRow$Expt.Result.Value),
               sep="")
  return(list(val, type))
}

#' getSELFormat
#'
#' Gets the Format of the SEL header block
#' 
#' @param seuratExperiment data.table Seurat assay upload experiment content
#'
#' @return character The format for SEL header block
#' @export
#'
#' @examples
getSELFormat <- function(seuratExperiment){
  
  rawResultColumns <- unlist(getRawResultsColumns(seuratExperiment))
  if (length(rawResultColumns)<1){
    format <- "Generic"
  } else {
    format <- "Dose Response"
  }
  return(format)
}

#' convertSeuratTableToSELContent
#'
#' Converts Seurat experiment to an ACAS SEL character string
#' 
#' @param seuratExperiment data.table Seurat assay upload experiment content
#'
#' @return character csv content of sel file
#' @export
#'
#' @examples
convertSeuratTableToSELContent <- function(seuratExperiment) {
  
  ops <- options()
  on.exit(options(ops))
  options(scipen=99)
  seuratExperiment <- copy(seuratExperiment)
  format <- getSELFormat(seuratExperiment)
  headerBlockLines <- getHeaderLines(seuratExperiment, format)
  if (format == "Dose Response") {
    seuratExperiment <- addCurveDataLines(seuratExperiment)
  }
  calculatedResults <- pivotExperimentCalculatedResults(seuratExperiment)
  columnHeaders <- getColumnHeaders(calculatedResults)
  if (format == "Dose Response") {
    rawResults <- pivotExperimentRawResults(seuratExperiment)
    rawResultsHeaders <- getRawResultsHeaders()
  }
  headerBlockLines <- padHeadColumns(headerBlockLines, length(names(calculatedResults)))
  headerBlockLines <- paste0(headerBlockLines, collapse = '\n')
  if (format == "Dose Response") {
    rawResultsHeaders <- padRawHeadColumns(rawResultsHeaders, length(names(calculatedResults)))
    rawResultsHeaders <- paste0(rawResultsHeaders, collapse = '\n')
  }
  calculatedResultsCSV <- dataframe_to_csvstring(calculatedResults, sep = ",", colNames = FALSE, na = "", quote = TRUE)
  out <- paste0(c(headerBlockLines,columnHeaders,calculatedResultsCSV), collapse = "\n")
  if (format == "Dose Response") {
    rawResultsCSV <- dataframe_to_csvstring(rawResults, sep = ",", colNames = TRUE, na = "", quote = TRUE)
    out <- paste0(c(out, paste(rawResultsHeaders, rawResultsCSV, sep = "\n")), collapse = "")
  }
  return(out)
}

#' getHeaderLines
#'  
#' Gets the header lines for the SEL content from a Seurat experiment
#'
#' @param seuratExperiment data.table Seurat assay upload experiment content
#' @param format character Format of sel file (Generic, Dose Response...etc)
#'
#' @return character string of csv content
#' @export
#'
#' @examples
getHeaderLines <- function(seuratExperiment, format) {
  
  hl <- "Experiment Meta Data"
  hl[[2]] <- paste0("Format,", format)
  protocolName <- seuratExperiment$Assay.Name[[1]]
  hl[[3]] <- paste("Protocol Name",protocolName, sep=",")
  experimentName <- seuratExperiment$Assay.Protocol[[1]]
  hl[[4]] <- paste("Experiment Name,",experimentName,"CREATETHISEXPERIMENT", sep="")
  eSci <- unique(seuratExperiment$Experiment.Scientist)
  if (length(eSci) > 1) "problem with experiment results, more than one scientist"
  if (length(eSci) == 0) {eSci[[1]] <- "bob"}
  hl[[5]] <- paste("Scientist",eSci[[1]], sep=",")
  eNBooks <- unique(seuratExperiment$Expt.Notebook)
  if (length(eNBooks) > 1) "problem with experiment results, more than one notebook"
  hl[[6]] <- paste("Notebook",eNBooks[[1]], sep=",")
  ePage <- unique(seuratExperiment$Expt.Nb.Page)
  if (length(ePage) > 1) "problem with experiment results, more than one notebook page"
  hl[[7]] <- paste("Page",ePage[[1]], sep=",")
  eDate <- unique(seuratExperiment$Expt.Date)
  if (length(eDate) > 1) "problem with experiment results, more than one experiment date"
  assayDate <- as.character(eDate)[[1]]
  hl[[8]] <- paste("Assay Date", assayDate, sep=",")
  hl[[9]] <- ","
  hl[[10]] <- "Calculated Results,"
  return(hl)
}

#' pivotExperimentRawResults
#'
#' Finds and pivots seurat sel MP.Result and MP.Conc columns into an SEL raw results data.table
#' 
#' @param seuratExperiment data.table Seurat assay upload experiment content
#'
#' @return data.table SEL formatted raw results
#' @export
#'
#' @examples
pivotExperimentRawResults <- function(seuratExperiment) {
  
  rawResultColumns <- getRawResultsColumns(seuratExperiment)
  concData <- reshape(seuratExperiment[ seuratExperiment$Expt.Result.Type == "curve id",], idvar = "Expt.Result.Desc", varying = c(rawResultColumns$concColumnIndexes), v.names = c("MP.Conc."), direction = "long")
  resultData <- reshape(seuratExperiment[ seuratExperiment$Expt.Result.Type == "curve id",], idvar = "Expt.Result.Desc", varying = c(rawResultColumns$resultColumnIndexes), v.names = c("MP.Result."), direction = "long")
  setkey(concData, value, time)
  setkey(resultData, value, time)
  rawData <- concData[resultData]
  rawData <- rawData[ !is.na(MP.Conc.) & !is.na(MP.Result.) ]
  doseColName <- paste0("Dose (", seuratExperiment$Expt.Result.Units[[1]],")")
  responseColName <- paste0("Response (", rawData$MP.Result.Type[[1]],")")
  setnames(rawData, "MP.Conc.", doseColName)
  setnames(rawData, "MP.Result.", responseColName)
  setnames(rawData, "value", "curve id")
  rawData <- rawData[,c("curve id",doseColName, responseColName), with = FALSE]
  rawData[ , flag := as.character(NA)]
  setkey(rawData)
  return(rawData)
}

#' pivotExperimentCalculatedResults
#'
#' Pivots (transposes) the content of a seurat formatted experiment to calulated results section of an ACAS SEL file
#' 
#' @param seuratExperiment data.table Seurat assay upload experiment content
#'
#' @return data.table SEL format calculated results
#' @export
#'
#' @examples
pivotExperimentCalculatedResults <- function(seuratExperiment) {
  
  seuratExperiment <- copy(seuratExperiment)
  seuratExperiment[ ,corp_batch_name := paste0(Corporate.ID, "-",Lot.Number)]
  #Sometimes Expt_Batch_Number is not set correctly, 
  #We can't have 2 repeats of the same Corporate Batch ID, Expt Batch Number, and Expt Result Type combination
  #So here we are finding those and seperating them

  #First find repeated combinations of corporate_batch_name, Expt_Batch_Number, and Expt_Result_Type
  #This code creates a marks any duplicates by creating a sequence along the combination of corporate_batch_name, Expt_Batch_Number, and Expt_Result_Type
  seuratExperiment[ ,artificialExptBatchNumber := as.character(paste0(corp_batch_name,"-",Expt.Batch.Number,"-",Expt.Result.Type,"-", Expt.Concentration,"-",Expt.Conc.Units))]
  seuratExperiment <- seuratExperiment[order(artificialExptBatchNumber)]
  seuratExperiment[, repeatedSequenced := sequence(rle(seuratExperiment$artificialExptBatchNumber)$lengths)]
  
  #Any "artificialExptBatchNumber" with a value above 1 means that it was a repeat and cannot be matched to any other result properly
  #So for anything like this, we create a unique new (and unique) Expt_Batch_Number
  seuratExperiment[, newExpt.Batch.Number := as.character(Expt.Batch.Number)]
  createUniqueExptBatchNumber <- seuratExperiment$artificialExptBatchNumber %in% unique(seuratExperiment[repeatedSequenced > 1]$artificialExptBatchNumber)
  seuratExperiment[ createUniqueExptBatchNumber, newExpt.Batch.Number := as.character(1:length(createUniqueExptBatchNumber[createUniqueExptBatchNumber]))]
  
  #castExpt <- cast(expt, corp_batch_name + newExpt_Batch_Number ~ Expt_Result_Type + Expt_Result_Units + Expt_Concentration + Expt_Conc_Units,
  #throws warning for generic data if add.missing is TRUE
  castExpt <- cast(as.data.frame(seuratExperiment), corp_batch_name + newExpt.Batch.Number + Expt.Batch.Number ~ Expt.Result.Type + Expt.Result.Units + Expt.Concentration + Expt.Conc.Units + type,
                   add.missing=FALSE, fill="NA", fun.aggregate=aggregateValues)
  
  #   castExpt <- cast(expt, corp_batch_name + Expt_Batch_Number ~ Expt_Result_Type + Expt_Result_Units + Expt_Concentration + Expt_Conc_Units,
  #                    add.missing=FALSE, fill="NA", fun.aggregate=aggregateValues)
  
  #   castExpt <- cast(as.data.frame(expt), corp_batch_name + Expt_Batch_Number ~ Expt_Result_Type + Expt_Result_Units + Expt_Concentration + Expt_Conc_Units,
  #                    add.missing=FALSE, fill="NA", fun.aggregate=aggregateValues)
  if("Expt.Result.Std.Dev" %in% names(seuratExperiment)) {
    if(any(!is.na(seuratExperiment$"Expt.Result.Std.Dev"))) {
      stdDevs <- cast(as.data.frame(seuratExperiment), corp_batch_name + newExpt.Batch.Number ~ Expt.Result.Type + Expt.Result.Units + Expt.Concentration + Expt.Conc.Units + type,
                      add.missing=FALSE, fill="NA", value = "Expt.Result.Std.Dev", fun.aggregate=aggregateValues)
      castExpt <- merge(castExpt,stdDevs, by = c("corp_batch_name", "newExpt.Batch.Number"), suffixes = c("", "_(UNCERTAINTY)"))
    }
  }
  if("Expt.Result.Comment" %in% names(seuratExperiment)) {
    if(any(!is.na(seuratExperiment$"Expt.Result.Comment"))) {
      comments <- cast(seuratExperiment, corp_batch_name + newExpt.Batch.Number ~ Expt.Result.Type + Expt.Result.Units + Expt.Concentration + Expt.Conc.Units + type,
                     add.missing=FALSE, fill="NA", value = "Expt.Result.Comment", fun.aggregate=aggregateValues)
       castExpt <- merge(castExpt,comments, by = c("corp_batch_name", "newExpt.Batch.Number"), suffixes = c("", "_(COMMENTS)"))
    }
  }

  castExpt <- castExpt[,colSums(is.na(castExpt))<nrow(castExpt)]
  
  i <- sapply(castExpt, is.factor)
  castExpt[i] <- lapply(castExpt[i], as.character)
  castExpt[castExpt=="NA"] <- ""
  drops <- c("Expt.Batch.Number","newExpt.Batch.Number")
  for ( name in names(castExpt)) {
    if (is.na(all(castExpt[ ,name]=="")) | all(castExpt[ ,name]=="NA" | all(castExpt[ ,name]=="")) ) drops <- c(drops, name)
  }
  castExpt <- castExpt[ , !(names(castExpt) %in% drops)]
  return(castExpt)
}

#' aggregateValues
#'
#' @param vals usually a unique set of values
#'
#' @return
#' @export
#'
#' @examples
aggregateValues <- function (vals) {
  
  firstVal = vals[[1]]
  allMatch = TRUE
  for (val in vals) {
    if (!identical(firstVal,val)) 
      allMatch = FALSE
  }
  if (allMatch) 
    return(firstVal)
  else {
    stop("SEURAT_BUG_DUPLICATE_ENTRIES")
  }
}

#' getColumnHeaders
#' 
#' This function takes pivoted ACAS SEL content and determines the correct column headers for the calculated results
#'
#' @param castExpt calculated results section of an ACAS SEL file after it has been pivoted from seurat results
#'
#' @return
#' @export
#'
#' @examples
getColumnHeaders <- function(castExpt) {
  
  headers <- c()
  dataTypes <- c()
  dataTypeDesc <- NULL
  for (name in names(castExpt)) {
    # units and conc are split by _, but those might be in result type as well
    if (name == "Rendering Hint_NA_NA_NA_Text") {
      dataTypes <- c(dataTypes, "Text (hidden)")
      headers <- c(headers, "Rendering Hint")
    } else if (name == "curve id_NA_NA_NA_Text") {
      dataTypes <- c(dataTypes, "Text (hidden)")
      headers <- c(headers, "curve id")
    } else if (name!="corp_batch_name") {
      if(grepl(".*_\\((UNCERTAINTY|COMMENTS)\\)$", name)) {
        dataTypeDesc <- sub(".*_\\(", "\\(", name)
        name <- sub("_\\((UNCERTAINTY|COMMENTS)\\)$","",name)
      }
      nameParts <- strsplit(name, "_")
      nameParts <- nameParts[[1]]
      len <- length(nameParts)
      units <- nameParts[[len-3]]
      concentration <- nameParts[[len-2]]
      concentrationUnits <- nameParts[[len-1]]
      if (units=="NA" | units=="") {
        nameParts[[len-3]] = "()" 
      } else {
        nameParts[[len-3]] = paste(" (", units, ")", sep="" )
      }
      if (concentration=="NA") {
        nameParts[[len-2]] = ""
      } else {
        nameParts[[len-2]] = paste(" [", concentration, " ",concentrationUnits,"]", sep="" )
      }
      nameParts[[len-1]] = ""
      types <- paste(nameParts[-((len-3):len)], collapse="_")
      theRest <- paste(nameParts[(len-3):(len-1)], collapse = "")
      headers <- c(headers, (paste0(types, theRest, collapse="")))
      if (!is.null(dataTypeDesc)) {
        if (dataTypeDesc == "(UNCERTAINTY)") {
          dataTypes <- c(dataTypes, "Standard Deviation")
        } else if (dataTypeDesc == "(COMMENTS)") {
          dataTypes <- c(dataTypes, "Comments")
        } else {
          stop("dataTypeDesc case not defined.")
        }
        dataTypeDesc <- NULL
      } else {
        
        dataTypes <- c(dataTypes, nameParts[[len]])
      }
    } else {
      headers <- c(headers, "Corporate Batch ID")
      dataTypes <- c(dataTypes, "Datatype")
    }
  }
  hLines = I(paste(dataTypes, collapse=","))
  hLines[[2]] <- paste(headers, collapse=",")
  return(hLines)
}

#' getRawResultsHeaders
#' 
#' returns a string to be inserted as raw results headers
#'
#' @return
#' @export
#'
#' @examples
getRawResultsHeaders <- function() {
  
  # create RawResults headers
  rawResultsHeaders <- I(",,,")
  rawResultsHeaders[2] <- "Raw Results,,,"
  rawResultsHeaders[3] <- "temp id,x,y,flag"
  return(rawResultsHeaders)
}

#' padHeadColumns
#' 
#' pads csv calculated results header string content with extra commas
#' 
#' @param headLines csv string content
#' @param cols number of desired columns in csv
#'
#' @return character of padded columns
#' @export
#'
#' @examples
padHeadColumns <- function(headLines, cols) {
  
  if (cols <=2) return(headLines)
  tStr = ""
  for (c in 3:cols) {
    tStr = paste(tStr,",", sep="")
  }
  for (l in 1:length(headLines)) {
    headLines[[l]] = paste(headLines[[l]], tStr, sep="")
  }
  return(headLines)
}

#' padRawHeadColumns
#' 
#' pads csv raw header string content with extra commas
#' 
#' @param headLines csv string content
#' @param cols number of desired columns in csv
#'
#' @return character of padded columns
#' @export
#'
#' @examples
padRawHeadColumns <- function(headLines, cols) {
  
  if (cols <=4) return(headLines)
  tStr = ""
  for (c in 5:cols) {
    tStr = paste(tStr,",", sep="")
  }
  for (l in 1:length(headLines)) {
    headLines[[l]] = paste(headLines[[l]], tStr, sep="")
  }
  return(headLines)
}

#' write_csv
#'
#' Faster version of write.csv
#' 
#' @param x object To write to csv
#' @param file character Rile to write to
#' @param rows numeric Rows to write at a time
#' @param colNames logical Should it write the column headers or not
#' @param ... 
#'
#' @return
#' @export
#'
#' @examples
write_csv <- function(x, file, rows = 1000L, colNames = TRUE, ...) {
  
  if(colNames) {
    col.names = TRUE
  } else {
    col.names = FALSE
  }
  passes <- NROW(x) %/% rows
  remaining <- NROW(x) %% rows
  k <- 1L
  if(passes > 0) {
    write.table(x[k:rows, ], file, row.names = FALSE, col.names = col.names, ...)
  } else {
    write.table(x, file,row.names = FALSE, col.names = col.names, ...)
    return(invisible())
  }
  k <- k + rows
  for(i in seq_len(passes)[-1]) {
    write.table(x[k:(rows*i), ], file, append = TRUE, row.names = FALSE, col.names = FALSE, ...)
    k <- k + rows
  }
  if(remaining > 0) {
    write.table(x[k:NROW(x), ], file, append = TRUE, row.names = FALSE, col.names = FALSE, ...)
  }
}

#' dataframe_to_csvstring
#' 
#' Convert a data.frame to csv string
#'
#' @param x data.frame To write to string
#' @param ... Addtitional parameters to pass to write_csv
#'
#' @return character csv string representation of x
#' @export
#'
#' @examples
dataframe_to_csvstring <- function(x, ...) {
  
  t <- tempfile()
  on.exit(unlink(t))
  write_csv(x,t, ...)
  csv_string <- readChar(t, file.info(t)$size)
}


#' getRawResultsColumns
#' 
#' Function to get the column indexes of raw results
#'
#' @param seuratExperiment data.table Seurat assay upload experiment content
#'
#' @return list With concColumnIndexes and resultColumnIndexes
#' @export
#'
#' @examples
getRawResultsColumns <- function(seuratExperiment){
  
  #rawResultColumnIndexes <- grep("^MP.Conc.[0-9]|^MP.Result.[0-9]|^MP.Flag.[0-9]", names(seuratExperiment))
  concColumnIndexes <- grep("^MP.Conc.[0-9]", names(seuratExperiment))
  resultColumnIndexes <- grep("^MP.Result.[0-9]", names(seuratExperiment))
  return(list(concColumnIndexes = concColumnIndexes, resultColumnIndexes = resultColumnIndexes))
}

#' addCurveDataLines
#' 
#' Function to add curve data lines to a seurat experiment
#'
#' @param seuratExperiment data.frame of seurat experiment csv content  
#'
#' @return
#' @export
#'
#' @examples
addCurveDataLines <-function(seuratExperiment) {
  
  rawResultColumns <- unlist(getRawResultsColumns(seuratExperiment))
  isCurveIDRow <- rowSums(seuratExperiment[,rawResultColumns,with=FALSE],na.rm = TRUE) != 0
  isCurveIDRow[is.na(isCurveIDRow)] <- FALSE
  curveIDRows <- seuratExperiment[ isCurveIDRow, ]
  seuratExperiment[ isCurveIDRow ,rawResultColumns := NA,with=FALSE]
  curveIDRows[ , c("Expt.Result.Type", "Expt.Result.Desc", "Expt.Result.Value", "Expt.Result.Units", "Expt.Concentration", "Expt.Conc.Units", "Expt.Result.Comment","Expt.Result.Std.Dev","type", "value") := list("curve id", row.names(curveIDRows), NA, NA, NA, NA, NA, as.numeric(NA), "Text", row.names(curveIDRows))]
  renderingHintRows <- copy(curveIDRows)
  renderingHintRows[ , c("Expt.Result.Type", "Expt.Result.Desc", "value") := list("Rendering Hint", "4 parameter D-R","4 paramter D-R")]
  seuratExperiment <- rbind(seuratExperiment, curveIDRows, renderingHintRows, fill = TRUE)
  return(seuratExperiment)
}

#' print_usage
#' 
#' Function to print usage
#'
#' @return 
#' @export
#'
#' @examples
print_usage <- function() {
  
  cat("Usage:  Rscript /path/to/seurat_upload_format.csv /path/to/script/output/folder\n")
}
#' runMain
#' 
#' Wrapper function that changes output depending on the environment (Rapache or if command args were passed in)
#'
#' @return If "GET" is present (RApache) then return the sel content as a string.  If command args are present, then create a folder and output sel csv files
#' @export
#'
#' @examples
runMain <- function() {
  
# Test if we are in rApache or not
  if(exists("GET")) {
    csv_data <- rawToChar(receiveBin(-1))
    # FREAD function in data.table only reads as a string if it has atleast one "\n" character
    selContent <- parseSeuratFileToSELContentJSON(paste0(csv_data,"\n"))
    cat(selContent)
    
  } else {
    args <- commandArgs(TRUE)
    if(length(args) == 2) {
      file <- args[[1]]
      outFolder <- args[[2]]
      seuratFileContent <- readSeuratFile(file)
      selContent <- parseSeuratFileContentToSELContentList(seuratFileContent)
      dir.create(path = outFolder, showWarnings = FALSE)
      setkey(selContent)
      out <- selContent[ , {
          outProtocolFolder <- file.path(outFolder,protocolName)
          dir.create(path = outProtocolFolder, showWarnings = FALSE)
          outExperiment <- file.path(outProtocolFolder, paste0(experimentName,".csv"))
          cat(paste0("writing file ", outExperiment, "\n"))
          writeLines(selContent, con = outExperiment)
        }, by = key(selContent)]
    } else {
      print_usage()
    }
  }
}
options(warn=1)
runMain()
