performCalculations <- function(resultTable, parameters, flaggedWells, flaggingStage, experiment) {
  # DNS
  # Get a table of flags associated with the data. If there was no file name given, then all flags are NA
  flagData <- getWellFlags(flaggedWells, resultTable, flaggingStage, experiment)
  
  # In order to merge with a data.table, the columns have to have the same name
  resultTable <- merge(resultTable, flagData, by = c("barcode", "well"), all.x = TRUE, all.y = FALSE)
  
  flagCheck(resultTable)
  
  resultTable <- normalizeData(resultTable, parameters)
  
  for (trans in 1:length(parameters$transformationRuleList)) {
    transformation <- parameters$transformationRuleList[[trans]]$transformationRule
    if(transformation != "null") {
      resultTable[ , paste0("transformed_",transformation) := computeTransformedResults(resultTable, transformation)]
    }
  }
  
  resultTable[, index:=1:nrow(resultTable)]
  
  #TODO: remove once real data is in place
  if (any(is.na(resultTable$batchName))) {
    warnUser("Some wells did not have recorded contents in the database- they will be skipped. Make sure all transfers have been loaded.")
    resultTable <- resultTable[!is.na(resultTable$batchName), ]
  }
  
  return(resultTable)
}

normalizeData <- function(resultTable, parameters) {
  normalization <- parameters$normalizationRule
  if (normalization == "plate order only") {
    resultTable[,normalizedActivity:=computeNormalized(activity,wellType,flag), by= barcode]
  } else if (normalization == "plate order and row") {
    resultTable[,plateRow:=gsub("\\d", "",well)]
    resultTable[,normalizedActivity:=computeNormalized(activity,wellType,flag), by= list(barcode,plateRow)]
  } else if (normalization == "plate order and tip") {
    stopUser("Normalization not coded for 'plate order and tip'.")
  } else {
    warnUser("No normalization applied.")
    resultTable$normalizedActivity <- resultTable$activity
  }
  
  return(resultTable)
}

computeTransformedResults <- function(mainData, transformation) {
  #TODO switch on transformation
  if (transformation == "% efficacy") {
    meanPosControl <- mean(as.numeric(mainData$normalizedActivity[mainData$wellType == "PC"]))
    
    # Use Negative Control if Vehicle Control is not defined
    if(length(resultTable$normalizedActivity[resultTable$wellType == "VC"]) == 0) {
      meanVehControl <- mean(as.numeric(mainData$normalizedActivity[mainData$wellType == "NC"]))
    } else {
      meanVehControl <- mean(as.numeric(mainData$normalizedActivity[mainData$wellType == "VC"]))
    }
    return((1-(as.numeric(mainData$normalizedActivity) - meanPosControl)/(meanVehControl-meanPosControl)) * 100)
  } else if (transformation == "sd") {
    
    # Use Negative Control if Vehicle Control is not defined
    if(length(resultTable$normalizedActivity[resultTable$wellType == "VC"]) == 0) {
      meanVehControl <- mean(as.numeric(mainData$normalizedActivity[mainData$wellType == "NC"]))
    } else {
      meanVehControl <- mean(as.numeric(mainData$normalizedActivity[mainData$wellType == "VC"]))
    }
    
    # Use Negative Control if Vehicle Control is not defined
    if(length(resultTable$normalizedActivity[resultTable$wellType == "VC"]) == 0) {
      stdevVehControl <- sd(as.numeric(mainData$normalizedActivity[mainData$wellType == "NC"]))
    } else {
      stdevVehControl <- sd(as.numeric(mainData$normalizedActivity[mainData$wellType == "VC"]))
    }
    return((as.numeric(mainData$normalizedActivity) - meanVehControl)/(stdevVehControl))
  } else if (transformation == "null") {
    return(mainData$normalizedActivity)
  } else {
    stopUser("Transformation not defined in system.")
  }  
}