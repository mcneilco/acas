performCalculationsStat1Stat2Seq <- function(resultTable, parameters, instrumentData=instrumentData) {
  resultTable[ , activity := computeActivity(resultTable, parameters$transformationRule)]
  
  # This assumes that there is only one normalization rule passed through the GUI
  resultTable <- normalizeData(resultTable, parameters$normalizationRule)
  
  flaglessResults <- resultTable[is.na(flag)]
  meanValue <- mean(flaglessResults$normalizedActivity[flaglessResults$wellType == "test"])
  sdValue <- sd(flaglessResults$normalizedActivity[flaglessResults$wellType == "test"])
  resultTable$transformed_sd <- computeSDScore(resultTable[is.na(flag)]$normalizedActivity, meanValue, sdValue)
  
  transformationList <- vapply(parameters$transformationRuleList, getElement, "", "transformationRule")
  transformationList <- union(transformationList, c("percent efficacy", "sd")) # force "percent efficacy" and "sd" to be included for spotfire
  for (transformation in transformationList) {
    if(transformation != "none") {
      resultTable[ , paste0("transformed_",transformation) := computeTransformedResults(.SD, transformation, parameters)]
    }
  }
  
  #maxTime is the point used by the stat1/2 files, overallMaxTime includes points outside of that range
  resultTable[, index:=1:nrow(resultTable)]

  # resultTable[, maxTime:=as.numeric(unlist(strsplit(instrumentData$assayData$timePoints, "\t"))[which.max(as.numeric(unlist(strsplit(instrumentData$assayData$sequence, "\t")))[instrumentData$assayData$startReadMax[1]:instrumentData$assayData$endReadMax[1]]) + as.integer(instrumentData$assayData$startReadMax[1]) - 1L]), by = index]
  # resultTable[, overallMaxTime:=as.numeric(unlist(strsplit(instrumentData$assayData$timePoints, "\t"))[which.max(as.numeric(unlist(strsplit(instrumentData$assayData$sequence, "\t"))))]), by = index]
  # resultTable[, fluorescent := instrumentData$assayData$fluorescent]
  resultTable[, zPrime := computeZPrime(positiveControls=resultTable[wellType == "PC" & is.na(flag), ]$normalizedActivity,
                                        negativeControls=resultTable[wellType == "NC" & is.na(flag), ]$normalizedActivity)]
  resultTable[, rawZPrime := computeZPrime(positiveControls=resultTable[wellType == "PC" & is.na(flag), ]$activity,
                                           negativeControls=resultTable[wellType == "NC" & is.na(flag), ]$activity)]
  resultTable[, zPrimeByPlate := computeZPrimeByPlate(.SD),
              by=assayBarcode]
  resultTable[, rawZPrimeByPlate := computeRawZPrimeByPlate(.SD),
              by=assayBarcode]
  
  #TODO: remove once real data is in place
#   if (any(is.na(resultTable$batchName))) {
#     warnUser("Some wells did not have recorded contents in the database- they will be skipped. Make sure all transfers have been loaded.")
#     resultTable <- resultTable[!is.na(resultTable$batchName), ]
#   }
  
#   hitSelection <- parameters$thresholdType #Other choice is "efficacyThreshold"
#   if (is.logical(hitSelection=="sd") & length(hitSelection=="sd")==0) {
#     efficacyThreshold <- parameters$hitEfficacyThreshold
#   } else if (hitSelection == "sd") {
#     efficacyThreshold <- meanValue + sdValue * parameters$hitSDThreshold
#   } else {
#     efficacyThreshold <- parameters$hitEfficacyThreshold
#   }
  
#   if (is.null(efficacyThreshold)){
#     # Get the late peak points
#     # resultTable$latePeak <- (resultTable$overallMaxTime > parameters$latePeakTime) & !resultTable$fluorescent
#     # Get individual points that are greater than the threshold
#     # resultTable$threshold <-  resultTable$fluorescent==F & resultTable$wellType=="test" & resultTable$latePeak==F
#   } else {
#     # Get the late peak points
#     # resultTable$latePeak <- (resultTable$overallMaxTime > parameters$latePeakTime) & 
#       # (resultTable$normalizedActivity > efficacyThreshold) & !resultTable$fluorescent  #also, efficacyThreshold is NULL
#     # Get individual points that are greater than the threshold
#     # resultTable$threshold <- (resultTable$normalizedActivity > efficacyThreshold) & resultTable$fluorescent==F & 
#       # resultTable$wellType=="test" & resultTable$latePeak==F
#   }

  return(resultTable)
}

computeZPrime <- function(positiveControls, negativeControls) {
  # Computes Z'
  #
  # Args:
  #   positiveControls:   A vector of the values of the positive controls
  #   negativeControls:   A vector of the values of the negative controls
  # Returns:
  #   A numeric value between 0 and 1
  
  sdPositiveControl <- sd(positiveControls)
  sdNegativeControl <- sd(negativeControls)
  meanPositiveControl <- mean(positiveControls)
  meanNegativeControl <- mean(negativeControls)
  return (1 - 3*(sdPositiveControl+sdNegativeControl)/abs(meanPositiveControl-meanNegativeControl))
}

computeSDScore <- function(dataVector, meanValue, sdValue) {
  # TODO: check math, what should be included?
  # Computes an SD Score
  
  return ((dataVector - meanValue)/sdValue)
}

computeActivity <- function(mainData, transformation) {
  #TODO switch on transformation
  
  if (transformation == "(maximum-minimum)/minimum") {
    return( (mainData[is.na(flag)]$Maximum-mainData[is.na(flag)]$Minimum)/mainData[is.na(flag)]$Minimum )
  } else {
    return(mainData$activity)
  }	
}

normalizeData <- function(resultTable, normalization) {
  if (normalization=="plate order") {
    resultTable[,normalizedActivity:=computeNormalized(activity,wellType,flag), by= assayBarcode]
  } else if (normalization=="row order") {
    resultTable[,plateRow:=gsub("\\d", "",well)]
    resultTable[,normalizedActivity:=computeNormalized(activity,wellType,flag), by= list(assayBarcode,plateRow)]
  } else {
    resultTable[,normalizedActivity:=resultTable$activity]
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
  
  #find min (mean of unflagged Negative Controls)
  minLevel <- mean(values[(wellType=='NC' & is.na(flag))])
  #find max (mean of unflagged Positive Controls)
  maxLevel <- mean(values[(wellType=='PC' & is.na(flag))])
  
  return((values - minLevel) / (maxLevel - minLevel))
}

computeZ <- function(positiveControls, testCompounds) {
  # Computes Z (by using the Z Prime function, but with test compounds as negative controls)
  #
  # Args:
  #   positiveControls:   A vector of the values of the positive controls
  #   testCompounds:      A vector of the values of the test compounds
  # Returns:
  #   A numeric value between 0 and 1
  
  return(computeZPrime(positiveControls, testCompounds))
}
computeRobustZ <- function(positiveControls, testCompounds) {
  # Computes Robust Z (by using the Robust Z Prime function, but with test compounds as negative controls)
  #
  # Args:
  #   positiveControls:   A vector of the values of the positive controls
  #   testCompounds:      A vector of the values of the test compounds
  # Returns:
  #   A numeric value between 0 and 1
  
  return(computeRobustZPrime(positiveControls, testCompounds))
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

computeTransformedResults <- function(mainData, transformation, parameters) { 
  # mainData is a data.table, columns include wellType, normalizedActivity, ...
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
    
  } else if (transformation == "null" || transformation == "" || transformation =="none") {
    warnUser("No transformation applied to activity.")
    return(mainData$normalizedActivity)
  } else {
    stopUser("Transformation not defined in system.")
  }  
}