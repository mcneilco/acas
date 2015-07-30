# ROUTE: /seuratETL/parse

library(reshape)
library(data.table)
library(jsonlite)
library(racas)


#' Title
#'
#' @param pathToSeuratFile 
#'
#' @return
#' @export
#'
#' @examples 
#' #working example
#' pathToSeuratFileGuy <- "~/Desktop/Seurat-Example-Files/Basic_Assay_Data_Temp_Guy.csv"
#' genericExperiment <- parseSeuratFileToSELContentJSON(pathToSeuratFileGuy)
#' writeLines(jsonlite::fromJSON(genericExperiment)$result$selContent[1], con = "~/Desktop/testGeneric.csv")
#' 
#' #working example
#' selContentJSON <- parseSeuratFileToSELContentJSON("~/Desktop/Seurat-Example-Files/PH-NKM_20140811_KRASG12D-BODIPY_GDP__Dissociation_assay_database-update_with_perInh_xlsx_arr.csv")
#' writeLines(jsonlite::fromJSON(selContentJSON)$results$selContent[1], con = "~/Desktop/testDoseResponse.csv")
#' 
#' #missing values, thows an error
#' pathToSeuratFileMissing <- "~/Desktop/Seurat-Example-Files/PH-NKM_20140811_KRASG12D-BODIPY_GDP__Dissociation_assay_database-update_with_perInh_xlsx_arr missing values.csv"
#' ErrorExperiment <- parseSeuratFileToSELContentJSON(pathToSeuratFileMissing)
#' 
readSeuratFile <- function(pathToSeuratFile, file = TRUE) {
  if(file == TRUE) {
    fileExt <- tolower(file_ext(pathToSeuratFile))
  } else {
    fileExt <- NA
  }
  if(file == TRUE && fileExt %in% c("xlsx", "xls")) {
    wb <- XLConnect::loadWorkbook(pathToSeuratFile)
    sheetToRead <- which(!unlist(lapply(XLConnect::getSheets(wb), XLConnect::isSheetHidden, object = wb)))[1]
    seuratFileContents <- as.data.table(XLConnect::readWorksheet(wb, sheet = sheetToRead, header = TRUE, dateTimeFormat="%Y-%m-%d", check.names = TRUE))
  } else {
    seuratFileContents <- fread(pathToSeuratFile, na.strings = c("", "NA"), 
                                colClasses = c("Expt Batch Number" = "character", 
                                               "Assay Protocol" = "character",
                                               "Expt Result Operator" = "character",
                                               "Expt Concentration" = "character",
                                               "Expt Conc Units" = "character",
                                               "Expt Result Desc" = "character"),
                                stringsAsFactors = FALSE)
    setnames(seuratFileContents, make.names(names(seuratFileContents)))
    if("Expt Date" %in% names(seuratFileContents)) {
      seuratFileContents$'Expt Date' <- as.POSIXct(unlist(suppressWarnings(lapply(seuratFileContents$`Expt Date`, validateDate))))
    }
  }
  return(seuratFileContents)
}

parseSeuratFileToSELContentJSON <- function(pathToSeuratFile) {
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

validateSeuratFileContent <- function(seuratFileContent) {
  #if the field doesn't exist OR if there are missing cases
  if(is.null(seuratFileContent$Assay.Name) || !all(complete.cases(seuratFileContent$Assay.Name))){
    stopUser("Assay Name not found")
  }
  if(is.null(seuratFileContent$Lot.Number) || !all(complete.cases(seuratFileContent$Lot.Number))){
    stopUser("Lot Number not found")
  }
  if(is.null(seuratFileContent$Corporate.ID) || !all(complete.cases(seuratFileContent$Corporate.ID))){
    stopUser("Corporate Batch ID not found")
  }
  if(is.null(seuratFileContent$Expt.Result.Type) || !all(complete.cases(seuratFileContent$Expt.Result.Type))){
    stopUser("Experiment result type was not specified")
  }
  if(is.null(seuratFileContent$Expt.Result.Units) || !all(complete.cases(seuratFileContent$Expt.Result.Units))){
    stopUser("Experiment result unit was not specified")
  }
  if(is.null(seuratFileContent$Expt.Result.Value) || is.null(seuratFileContent$Expt.Result.Desc) || 
     !Reduce('&', Reduce('|', list(complete.cases(seuratFileContent$Expt.Result.Value), complete.cases(seuratFileContent$Expt.Result.Desc))))){
    stopUser("Experiment result value and/or description is missing.")
  }
}

parseSeuratFileContentToSELContentList <- function(seuratFileContent) {
  validateSeuratFileContent(seuratFileContent)
  seuratFileContent[ , c('Assay.Name','Assay.Protocol') := makeExperimentNamesUnique(seuratFileContent[ , c("Assay.Name", "Assay.Protocol"), with = FALSE], by = c("Assay.Name"))]
  seuratFileContent[ , c("value", "type") := makeValueString(.SD, Expt.Result.Type), by=Expt.Result.Type]
  selContent <- seuratFileContent[ , convertSeuratTableToSELContent(.SD), by = c("Assay.Protocol", "Assay.Name"), .SDcols = 1:ncol(seuratFileContent)]
  setnames(selContent, c("experimentName", "protocolName", "selContent"))
  #selContentJSON <- jsonlite::toJSON(selContent)
  return(selContent)
}

file_ext <- function(x) {
  pos <- regexpr("\\.([[:alnum:]]+)$", x)
  ifelse(pos > -1L, substring(x, pos + 1L), "")
}

makeExperimentNamesUnique <- function(experimentNames, by) {
  outNames <- names(experimentNames)
  experimentNames <- copy(experimentNames)
  experimentNames[ , originalOrder := row.names(experimentNames)]
  #setting the key causes the column to sort independently without the rest of the dt
  setkeyv(experimentNames, c("Assay.Protocol", by))
  exptNames <- unique(experimentNames)
  setkey(exptNames,"Assay.Protocol")
  #experimentNames[repeatedSequenced > 1]
  exptNames[, repeatedSequenced := sequence(rle(exptNames$Assay.Protocol)$lengths)-1]
  exptNames[ , 'Assay.Protocol.Old' := get('Assay.Protocol')]
  exptNames[repeatedSequenced > 0, 'Assay.Protocol' := paste0(Assay.Protocol,"_",repeatedSequenced)]
  setkeyv(exptNames, c(by, "Assay.Protocol.Old"))
  setkeyv(experimentNames, c(by, "Assay.Protocol"))
  outData <- exptNames[experimentNames]
  setkey(outData,originalOrder)
  outData[ , outNames, with = FALSE]
}
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

getSELFormat <- function(seuratExperiment){
  rawResultColumns <- unlist(getRawResultsColumns(seuratExperiment))
  if (length(rawResultColumns)<1){
    format <- "Generic"
  } else {
    format <- "Dose Response"
  }
  return(format)
}

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

pivotExperimentRawResults <- function(seuratExperiment) {
  rawResultColumns <- getRawResultsColumns(seuratExperiment)
#   rawData <- reshape(seuratExperiment[ seuratExperiment$Expt.Result.Type == "curve id",], idvar = "Expt.Result.Desc", varying = c(rawResultColumns), v.names = c("MP.Conc.","MP.Result.","MP.Flag."), direction = "long")
  concData <- reshape(seuratExperiment[ seuratExperiment$Expt.Result.Type == "curve id",], idvar = "Expt.Result.Desc", varying = c(rawResultColumns$concColumnIndexes), v.names = c("MP.Conc."), direction = "long")
  resultData <- reshape(seuratExperiment[ seuratExperiment$Expt.Result.Type == "curve id",], idvar = "Expt.Result.Desc", varying = c(rawResultColumns$resultColumnIndexes), v.names = c("MP.Result."), direction = "long")
  setkey(concData, value, time)
  setkey(resultData, value, time)
  rawData <- concData[resultData]
  rawData <- rawData[ !is.na(MP.Conc.) & !is.na(MP.Result.) ]
  doseColName <- paste0("Dose (", seuratExperiment$Expt.Result.Units[[1]],")")
  responseColName <- paste0("Response (", rawData$MP.Result.Type[[1]],")")
#   flagColName <- "Flag"
  setnames(rawData, "MP.Conc.", doseColName)
  setnames(rawData, "MP.Result.", responseColName)
#   setnames(rawData, "MP.Flag.", flagColName)
  setnames(rawData, "value", "curve id")
#   rawData <- rawData[,c("curve id",doseColName, responseColName, flagColName), with = FALSE]
  rawData <- rawData[,c("curve id",doseColName, responseColName), with = FALSE]
  rawData[ , flag := as.character(NA)]
  setkey(rawData)
  return(rawData)
}

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
    logger$error("SEURAT_BUG_DUPLICATE_ENTRIES")
    return("SEURAT_BUG_DUPLICATE_ENTRIES")
  }
}
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
getRawResultsHeaders <- function(ic50colname) {
  # create RawResults headers
  rawResultsHeaders <- I(",,,")
  rawResultsHeaders[2] <- "Raw Results,,,"
  rawResultsHeaders[3] <- "temp id,x,y,flag"
  return(rawResultsHeaders)
}
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

dataframe_to_csvstring <- function(x, ...) {
  t <- tempfile()
  on.exit(unlink(t))
  write_csv(x,t, ...)
  csv_string <- readChar(t, file.info(t)$size)
}
getRawResultsColumns <- function(seuratExperiment){
  
  #rawResultColumnIndexes <- grep("^MP.Conc.[0-9]|^MP.Result.[0-9]|^MP.Flag.[0-9]", names(seuratExperiment))
  concColumnIndexes <- grep("^MP.Conc.[0-9]", names(seuratExperiment))
  resultColumnIndexes <- grep("^MP.Result.[0-9]", names(seuratExperiment))
  return(list(concColumnIndexes = concColumnIndexes, resultColumnIndexes = resultColumnIndexes))
}

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
runMain <- function() {
  
  if(exists("GET")) {
    # Test if we are in rApache Or not
    csv_data <- rawToChar(receiveBin(-1))
    # FREAD function in data.table only reads as a string if it has atleast one "\n" character
    selContent <- parseSeuratFileToSELContentJSON(paste0(csv_data,"\n"))
    cat(selContent)
  }
}
runMain()
