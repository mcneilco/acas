performCalculations <- function(resultTable, parameters, flaggedWells, flaggingStage, experiment) {
  # IFF
  resultTable$activity <- computeActivity(resultTable, parameters$transformationRule)
  
  # Get a table of flags associated with the data. If there was no file name given, then all flags are NA
  flagData <- getWellFlags(flaggedWells, resultTable, flaggingStage, experiment)
  
  # In order to merge with a data.table, the columns have to have the same name
  resultTable <- merge(resultTable, flagData, by = c("assayBarcode", "well"), all.x = TRUE, all.y = FALSE)
  
  flagCheck(resultTable)
  
  resultTable <- normalizeData(resultTable, parameters$normalizationRule)
  
  flaglessResults <- resultTable[is.na(flag)]
  meanValue <- mean(flaglessResults$normalizedActivity[flaglessResults$wellType == "test"])
  sdValue <- sd(flaglessResults$normalizedActivity[flaglessResults$wellType == "test"])
  resultTable$transformed_sd <- computeSDScore(resultTable$normalizedActivity, meanValue, sdValue)
  
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
    return( (mainData$Maximum-mainData$Minimum)/mainData$Minimum )
  } else {
    return ( (mainData$Maximum-mainData$Minimum)/mainData$Minimum )
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