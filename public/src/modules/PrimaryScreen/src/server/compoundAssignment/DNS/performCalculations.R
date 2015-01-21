performCalculations <- function(resultTable, parameters) {
  # DNS
  resultTable <- normalizeData(resultTable, parameters)
  
  # get transformed columns
  for (trans in 1:length(parameters$transformationRuleList)) {
    transformation <- parameters$transformationRuleList[[trans]]$transformationRule
    if(transformation != "null") {
      resultTable[ , paste0("transformed_",transformation) := computeTransformedResults(.SD, transformation, parameters)]
    }
  }
  
  # compute Z' and Z' by plate
  resultTable[, zPrime := computeZPrime(positiveControls=resultTable[wellType == "PC" & is.na(flag), ]$normalizedActivity,
                                        negativeControls=resultTable[wellType == "NC" & is.na(flag), ]$normalizedActivity)]
  resultTable[, zPrimeByPlate := computeZPrimeByPlate(.SD),
              by=assayBarcode]
  
  resultTable[, index:=1:nrow(resultTable)]
  
  #TODO: remove once real data is in place
  if (any(is.na(resultTable$batchName))) {
    warnUser("Some wells did not have recorded contents in the database- they will not be saved. Make sure all transfers have been loaded.")
    # resultTable <- resultTable[!is.na(resultTable$batchName), ]
  }
  
  return(resultTable)
}

useAggregationMethod <- function(value, parameters) {
  # Switch to use either mean or median, depending on uer input in GUI
  if (parameters$aggregationMethod == "median") {
    return(median(value))
  } else if (parameters$aggregationMethod == "mean") {
    return(mean(value))
  } else {
    stopUser("Internal error: Aggregation method not defined in system.")
  }
}



computeZPrimeByPlate <- function(mainData) {
  # creates a vector called
  positiveControls <- mainData[wellType == "PC" & is.na(flag)]$normalizedActivity
  negativeControls <- mainData[wellType == "NC" & is.na(flag)]$normalizedActivity
  
  return(computeZPrime(positiveControls, negativeControls))
}

normalizeData <- function(resultTable, parameters) {
  normalization <- parameters$normalizationRule
  
  if ((length((resultTable[(wellType == 'NC' & is.na(flag))])) == 0)) {
    stopUser("All of the negative controls were flagged, so normalization cannot proceed.")
  }
  if ((length((resultTable[(wellType == 'PC' & is.na(flag))])) == 0)) {
    stopUser("All of the positive controls were flagged, so normalization cannot proceed.")
  }
  
  #find min of dataset (aggregationMethod of unflagged Negative Controls)
  overallMinLevel <- useAggregationMethod(resultTable[(wellType=='NC' & is.na(flag))]$activity, parameters)
  #find max of dataset (aggregationMethod of unflagged Positive Controls)
  overallMaxLevel <- useAggregationMethod(resultTable[(wellType=='PC' & is.na(flag))]$activity, parameters)
  
  if (normalization == "plate order only") {
    resultTable[,normalizedActivity:=computeNormalized(activity,wellType,flag,
                                                       overallMinLevel=overallMinLevel,
                                                       overallMaxLevel=overallMaxLevel, parameters), by= assayBarcode]
  } else if (normalization == "plate order and row") {
    resultTable[,plateRow:=gsub("\\d", "",well)]
    resultTable[,normalizedActivity:=computeNormalized(activity,wellType,flag,
                                                       overallMinLevel=overallMinLevel,
                                                       overallMaxLevel=overallMaxLevel, parameters), by= list(assayBarcode,plateRow)]
  } else if (normalization == "plate order and tip") {
    stopUser("Normalization not coded for 'plate order and tip'.")
  } else {
    warnUser("No normalization applied.")
    resultTable$normalizedActivity <- resultTable$activity
  }
  
  return(resultTable)
}

computeNormalized  <- function(values, wellType, flag, overallMinLevel, overallMaxLevel, parameters) {
  # Computes normalized version of the given values based on the unflagged positive and 
  # negative controls
  # Rreference 'data_normalization.pdf'
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
  
  #find min of subgroup (median of unflagged Negative Controls)
  grpMinLevel <- useAggregationMethod(values[(wellType=='NC' & is.na(flag))], parameters)
  #find max of subgroup (median of unflagged Positive Controls)
  grpMaxLevel <- useAggregationMethod(values[(wellType=='PC' & is.na(flag))], parameters)
  
  return(
    ((values - grpMaxLevel) 
    * ((overallMinLevel - overallMaxLevel) / (grpMinLevel - grpMaxLevel)))
    + overallMaxLevel)
}

computeTransformedResults <- function(mainData, transformation, parameters) { 
  #TODO switch on transformation
  if (transformation == "percent efficacy") {
    aggregatePosControl <- useAggregationMethod(as.numeric(mainData[wellType == "PC" & is.na(flag)]$normalizedActivity), parameters)
    
    # Use Negative Control if Vehicle Control is not defined
    if(length(mainData[wellType == "VC"]$normalizedActivity) == 0) {
      aggregateVehControl <- useAggregationMethod(as.numeric(mainData[wellType == "NC" & is.na(flag)]$normalizedActivity), parameters)
    } else {
      aggregateVehControl <- useAggregationMethod(as.numeric(mainData[wellType == "VC" & is.na(flag)]$normalizedActivity), parameters)
    }
    return(
      (1
       - (as.numeric(mainData$normalizedActivity) - aggregatePosControl)
       /(aggregateVehControl-aggregatePosControl)) * 100)
  } else if (transformation == "sd") {
    
    # Use Negative Control if Vehicle Control is not defined
    if(length(mainData[wellType == "VC"]$normalizedActivity) == 0) {
      aggregateVehControl <- useAggregationMethod(as.numeric(mainData[wellType == "NC" & is.na(flag)]$normalizedActivity), parameters)
    } else {
      aggregateVehControl <- useAggregationMethod(as.numeric(mainData[wellType == "VC" & is.na(flag)]$normalizedActivity), parameters)
    }
    
    # Use Negative Control if Vehicle Control is not defined
    if(length(mainData[wellType == "VC"]$normalizedActivity) == 0) {
      stdevVehControl <- sd(as.numeric(mainData[wellType == "NC" & is.na(flag)]$normalizedActivity))
    } else {
      stdevVehControl <- sd(as.numeric(mainData[wellType == "VC" & is.na(flag)]$normalizedActivity))
    }
    return((as.numeric(mainData$normalizedActivity) - aggregateVehControl)/(stdevVehControl))
  } else if (transformation == "null" || transformation == "") {
    warnUser("No transformation applied to activity.")
    return(mainData$normalizedActivity)
  } else {
    stopUser("Transformation not defined in system.")
  }  
}