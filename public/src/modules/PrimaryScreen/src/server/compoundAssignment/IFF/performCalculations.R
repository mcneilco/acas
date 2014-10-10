performCalculations <- function(resultTable, parameters, flaggedWells, flaggingStage, experiment) {
  # IFF
  resultTable$transformed <- computeTransformedResults(resultTable, parameters$transformationRule)
  
  # Get a table of flags associated with the data. If there was no file name given, then all flags are NA
  flagData <- getWellFlags(flaggedWells, resultTable, flaggingStage, experiment)
  
  # In order to merge with a data.table, the columns have to have the same name
  resultTable <- merge(resultTable, flagData, by = c("barcode", "well"), all.x = TRUE, all.y = FALSE)
  
  flagCheck(resultTable)
  
  resultTable <- normalizeData(resultTable, parameters$normalizationRule)
  
  return(resultTable)
}

computeTransformedResults <- function(mainData, transformation) {
  #TODO switch on transformation
  if (transformation == "(maximum-minimum)/minimum") {
    return( (mainData$Maximum-mainData$Minimum)/mainData$Minimum )
  } else {
    return ( (mainData$Maximum-mainData$Minimum)/mainData$Minimum )
  }	
}

normalizeData <- function(resultTable, normalization) {
  if (normalization=="plate order") {
    resultTable[,normalized:=computeNormalized(transformed,wellType,flag), by= barcode]
  } else if (normalization=="row order") {
    resultTable[,plateRow:=gsub("\\d", "",well)]
    resultTable[,normalized:=computeNormalized(transformed,wellType,flag), by= list(barcode,plateRow)]
  } else {
    resultTable$normalized <- resultTable$transformed
  }
  
  return(resultTable)
}