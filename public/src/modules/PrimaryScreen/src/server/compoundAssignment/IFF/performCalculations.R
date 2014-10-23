performCalculations <- function(resultTable, parameters) {
  # IFF
  resultTable[ , activity := computeActivity(resultTable, parameters$transformationRule)]
  
  # This assumes that there is only one normalization rule passed through the GUI
  resultTable <- normalizeData(resultTable, parameters$normalizationRule)
  
  flaglessResults <- resultTable[is.na(flag)]
  meanValue <- mean(flaglessResults$normalizedActivity[flaglessResults$wellType == "test"])
  sdValue <- sd(flaglessResults$normalizedActivity[flaglessResults$wellType == "test"])
  resultTable$transformed_sd <- computeSDScore(resultTable[is.na(flag)]$normalizedActivity, meanValue, sdValue)
  
  #maxTime is the point used by the stat1/2 files, overallMaxTime includes points outside of that range
  resultTable[, index:=1:nrow(resultTable)]
  
  resultTable[, maxTime:=as.numeric(unlist(strsplit(timePoints, "\t"))[which.max(as.numeric(unlist(strsplit(sequence, "\t")))[startReadMax:endReadMax]) + as.integer(startReadMax) - 1L]), by = index]
  resultTable[, overallMaxTime:=as.numeric(unlist(strsplit(timePoints, "\t"))[which.max(as.numeric(unlist(strsplit(sequence, "\t"))))]), by = index]
  
  #TODO: remove once real data is in place
  if (any(is.na(resultTable$batchName))) {
    warnUser("Some wells did not have recorded contents in the database- they will be skipped. Make sure all transfers have been loaded.")
    resultTable <- resultTable[!is.na(resultTable$batchName), ]
  }
  
  hitSelection <- parameters$thresholdType #Other choice is "efficacyThreshold"
  if (hitSelection == "sd") {
    efficacyThreshold <- meanValue + sdValue * parameters$hitSDThreshold
  } else {
    efficacyThreshold <- parameters$hitEfficacyThreshold
  }
  
  # Get the late peak points
  resultTable$latePeak <- (resultTable$overallMaxTime > parameters$latePeakTime) & 
    (resultTable$normalizedActivity > efficacyThreshold) & !resultTable$fluorescent
  # Get individual points that are greater than the threshold
  resultTable$threshold <- (resultTable$normalizedActivity > efficacyThreshold) & !resultTable$fluorescent & 
    resultTable$wellType=="test" & !resultTable$latePeak
  
  return(resultTable)
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
    return ( (mainData[is.na(flag)]$Maximum-mainData[is.na(flag)]$Minimum)/mainData[is.na(flag)]$Minimum )
  }	
}

normalizeData <- function(resultTable, normalization) {
  if (normalization=="plate order") {
    resultTable[,normalizedActivity:=computeNormalized(activity,wellType,flag), by= assayBarcode]
  } else if (normalizedActivity=="row order") {
    resultTable[,plateRow:=gsub("\\d", "",well)]
    resultTable[,normalizedActivity:=computeNormalized(activity,wellType,flag), by= list(assayBarcode,plateRow)]
  } else {
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
  
  #find min (mean of unflagged Negative Controls)
  minLevel <- mean(values[(wellType=='NC' & is.na(flag))])
  #find max (mean of unflagged Positive Controls)
  maxLevel <- mean(values[(wellType=='PC' & is.na(flag))])
  
  return((values - minLevel) / (maxLevel - minLevel))
}

computeRobustZPrime <- function(positiveControls, negativeControls) {
  # Computes robust Z'
  #
  # Args:
  #   positiveControls:   A vector of the values of the positive controls
  #   negativeControls:   A vector of the values of the negative controls
  # Returns:
  #   A numeric value between 0 and 1
  
  madPositiveControl <- mad(positiveControls)
  madNegativeControl <- mad(negativeControls)
  medianPositiveControl <- median(positiveControls)
  medianNegativeControl <- median(negativeControls)
  return (1 - 3*(madPositiveControl+madNegativeControl)/abs(medianPositiveControl-medianNegativeControl))
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