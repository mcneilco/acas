performCalculations <- function(resultTable, parameters) {
  # exampleClient
  resultTable <- normalizeData(resultTable, parameters)
  
  # get transformed columns
  transformationList <- vapply(parameters$transformationRuleList, getElement, "", "transformationRule")
  transformationList <- union(transformationList, c("percent efficacy", "sd")) # force "percent efficacy" and "sd" to be included for spotfire
  for (transformation in transformationList) {
    if(transformation != "none") {
      resultTable[ , paste0("transformed_",transformation) := computeTransformedResults(.SD, transformation, parameters)]
    }
  }
  
  # compute Z' and Z' by plate
  resultTable[, zPrime := computeZPrime(positiveControls=resultTable[wellType == "PC" & is.na(flag), ]$normalizedActivity,
                                        negativeControls=resultTable[wellType == "NC" & is.na(flag), ]$normalizedActivity)]
  resultTable[, rawZPrime := computeZPrime(positiveControls=resultTable[wellType == "PC" & is.na(flag), ]$activity,
                                           negativeControls=resultTable[wellType == "NC" & is.na(flag), ]$activity)]
  resultTable[, zPrimeByPlate := computeZPrimeByPlate(.SD),
              by=assayBarcode]
  resultTable[, rawZPrimeByPlate := computeRawZPrimeByPlate(.SD),
              by=assayBarcode]
  
  resultTable[, index:=1:nrow(resultTable)]
  
  #TODO: remove once real data is in place
  #   if (any(is.na(resultTable$batchName))) {
  #     warnUser("Some wells did not have recorded contents in the database- they will not be saved. Make sure all transfers have been loaded.")
  #     # resultTable <- resultTable[!is.na(resultTable$batchName), ]
  #   }
  
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

computeRawZPrimeByPlate <- function(mainData) {
  positiveControls <- mainData[wellType == "PC" & is.na(flag)]$activity
  negativeControls <- mainData[wellType == "NC" & is.na(flag)]$activity
  
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
  } else if (normalization == "plate order & section by 8") {
    getLetterInteger <- function(letter) {
      letter <- gsub("-","",letter)
      letterInteger <- 0
      if(nchar(letter) == 2) {
        firstLetter <- gsub(".{0,1}$","",letter)
        letterInteger <- letterInteger + which(LETTERS == firstLetter) * 26
        letter <- gsub("^.{0,1}","",letter)
      }
      letterInteger <- letterInteger + which(LETTERS == letter)
      return(letterInteger)
    }
    
    getRowSectionNumber <- function(letter, rowsPerSection) {
      letterInteger <- getLetterInteger(letter)
      sectionNumber <- ceiling(letterInteger/rowsPerSection)
      return(sectionNumber)
    }
    
    if (ceiling(max(as.numeric(resultTable$column))/12) == 4) {
      resultTable[ , section := getRowSectionNumber(row, 4), by=row]
    } else if (ceiling(max(as.numeric(resultTable$column))/12) == 2) {
      resultTable[ , section := getRowSectionNumber(row, 2), by=row]
    } else if (ceiling(max(as.numeric(resultTable$column))/12) == 1) {
      # this normalization is the same as the 'plate order and row' normalization
      resultTable[ , section := getRowSectionNumber(row, 1), by=row]
    } else {
      stopUser("Normalization not coded for this plate dimension.")
    }
    resultTable[,normalizedActivity:=computeNormalized(activity,wellType,flag,
                                                       overallMinLevel=overallMinLevel,
                                                       overallMaxLevel=overallMaxLevel, parameters), 
                by= list(assayBarcode,section)]
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
  
  # If the min and max are the same, it causes a divide by zero error
  if ((grpMinLevel - grpMaxLevel) == 0) {
    stopUser(paste0("For at least normalization group, the positive control and the negative ", 
                    "control are the same. Either check your data or change your ", 
                    "normalization rule."))
  }
  
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
    
    # Determine if signal direction is decreasing or increasing
    if (parameters$signalDirectionRule == "increasing") {
      return((as.numeric(mainData$normalizedActivity) - aggregateVehControl)/(stdevVehControl))
    } else if (parameters$signalDirectionRule == "decreasing") {
      return(-(as.numeric(mainData$normalizedActivity) - aggregateVehControl)/(stdevVehControl))
    } else {
      stopUser("Signal Direction (",parameters$signalDirectionRule,")is not defined in the system. Please see your system administrator.")
    }
    
  } else if (transformation == "null" || transformation == "") {
    warnUser("No transformation applied to activity.")
    return(mainData$normalizedActivity)
  } else {
    stopUser("Transformation not defined in system.")
  }  
}