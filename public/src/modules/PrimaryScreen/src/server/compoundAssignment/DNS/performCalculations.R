performCalculations <- function(resultTable, parameters, flaggedWells, flaggingStage, experiment) {
  # DNS
  # Get a table of flags associated with the data. If there was no file name given, then all flags are NA
  flagData <- getWellFlags(flaggedWells, resultTable, flaggingStage, experiment)
  
  # In order to merge with a data.table, the columns have to have the same name
  resultTable <- merge(resultTable, flagData, by = c("assayBarcode", "well"), all.x = TRUE, all.y = FALSE)
  
  checkFlags(resultTable)
  
  resultTable <- normalizeData(resultTable, parameters)
  
  # get transformed columns
  for (trans in 1:length(parameters$transformationRuleList)) {
    transformation <- parameters$transformationRuleList[[trans]]$transformationRule
    if(transformation != "null") {
      resultTable[ , paste0("transformed_",transformation) := computeTransformedResults(resultTable, transformation)]
    }
  }
  
  # compute Z' and Z' by plate
  resultTable[, zPrime := computeZPrime(positiveControls=resultTable[resultTable$wellType == "PC", ]$normalizedActivity,
                                        negativeControls=resultTable[resultTable$wellType == "NC", ]$normalizedActivity)]
  resultTable[, zPrimeByPlate := computeZPrimeByPlate(normalizedActivity, wellType),
              by=assayBarcode]
  
  resultTable[, index:=1:nrow(resultTable)]
  
  #TODO: remove once real data is in place
  if (any(is.na(resultTable$batchName))) {
    warnUser("Some wells did not have recorded contents in the database- they will be skipped. Make sure all transfers have been loaded.")
    resultTable <- resultTable[!is.na(resultTable$batchName), ]
  }
  
  return(resultTable)
}

computeZPrimeByPlate <- function(normalizedActivity, wellType) {
  # creates a vector called
  positiveControls <- normalizedActivity[wellType == "PC"]
  negativeControls <- normalizedActivity[wellType == "NC"]
  
  return(computeZPrime(positiveControls, negativeControls))
}

normalizeData <- function(resultTable, parameters) {
  normalization <- parameters$normalizationRule
  if (normalization == "plate order only") {
    resultTable[,normalizedActivity:=computeNormalized(activity,wellType,flag), by= assayBarcode]
  } else if (normalization == "plate order and row") {
    resultTable[,plateRow:=gsub("\\d", "",well)]
    resultTable[,normalizedActivity:=computeNormalized(activity,wellType,flag), by= list(assayBarcode,plateRow)]
  } else if (normalization == "plate order and tip") {
    stopUser("Normalization not coded for 'plate order and tip'.")
  } else {
    warnUser("No normalization applied.")
    resultTable$normalizedActivity <- resultTable$activity
  }
  
  return(resultTable)
}

computeNormalized  <- function(values, wellType, flag) {
  # Computes normalized version of the given values based on the unflagged positive and 
  # negative controls
  #
  # Args:
  #   values:   A vector of numeric values
  #   wellType: A vector of the same length as values which marks the type of each
  #   flag:     A vector of the same length as values, with text if the well was flagged, and NA otherwise
  # Returns:
  #   A numeric vector of the same length as the inputs that is normalized.
  
  if ((length((values[(wellType == 'NC' & is.na(flag))])) == 0)) {
    stopUser("All of the negative controls in one normalization group (barcode, or barcode and plate row) 
             were flagged, so normalization cannot proceed.")
  }
  if ((length((values[(wellType == 'PC' & is.na(flag))])) == 0)) {
    stopUser("All of the positive controls in one normalization group (barcode, or barcode and plate row) 
             were flagged, so normalization cannot proceed.")
  }
  
  #find min (median of unflagged Negative Controls)
  minLevel <- median(values[(wellType=='NC' & is.na(flag))])
  #find max (median of unflagged Positive Controls)
  maxLevel <- median(values[(wellType=='PC' & is.na(flag))])
  
  return((values - minLevel) / (maxLevel - minLevel))
}

computeTransformedResults <- function(mainData, transformation) {
  #TODO switch on transformation
  if (transformation == "% efficacy") {
    medianPosControl <- median(as.numeric(mainData[mainData$wellType == "PC"]$normalizedActivity))
    
    # Use Negative Control if Vehicle Control is not defined
    if(length(resultTable[resultTable$wellType == "VC"]$normalizedActivity) == 0) {
      medianVehControl <- median(as.numeric(mainData[mainData$wellType == "NC"]$normalizedActivity))
    } else {
      medianVehControl <- median(as.numeric(mainData[mainData$wellType == "VC"]$normalizedActivity))
    }
    return((1-(as.numeric(mainData$normalizedActivity) - medianPosControl)/(medianVehControl-medianPosControl)) * 100)
  } else if (transformation == "sd") {
    
    # Use Negative Control if Vehicle Control is not defined
    if(length(resultTable[resultTable$wellType == "VC"]$normalizedActivity) == 0) {
      medianVehControl <- median(as.numeric(mainData[mainData$wellType == "NC"]$normalizedActivity))
    } else {
      medianVehControl <- median(as.numeric(mainData[mainData$wellType == "VC"]$normalizedActivity))
    }
    
    # Use Negative Control if Vehicle Control is not defined
    if(length(resultTable[resultTable$wellType == "VC"]$normalizedActivity) == 0) {
      stdevVehControl <- sd(as.numeric(mainData[mainData$wellType == "NC"]$normalizedActivity))
    } else {
      stdevVehControl <- sd(as.numeric(mainData[mainData$wellType == "VC"]$normalizedActivity))
    }
    return((as.numeric(mainData$normalizedActivity) - medianVehControl)/(stdevVehControl))
  } else if (transformation == "null") {
    return(mainData$normalizedActivity)
  } else {
    stopUser("Transformation not defined in system.")
  }  
}