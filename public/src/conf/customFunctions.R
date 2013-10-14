calculateTreatmemtGroupID <- function(results, inputFormat, stateGroups, resultTypes) {
  # Returns a column that will be added to results that separates treatmentGroups
  
  # insert formats with custom code in "if" statements
  if(inputFormat == "") {

  } else {
    # Standard code
    treatmentGrouping <- which(lapply(stateGroups, getElement, "stateKind") == "treatment")
    groupingColumns <- stateGroups[[treatmentGrouping]]$valueKinds
    groupingColumns <- resultTypes$DataColumn[resultTypes$Type %in% groupingColumns]
    if(stateGroups[[treatmentGrouping]]$includesCorpName) {
      groupingColumns <- c(groupingColumns, "Corporate Batch ID")
    }
    a <- do.call(paste,results[,groupingColumns])
    return(as.numeric(factor(a)))
  }
}


createRawOnlyTreatmentGroupData <- function(subjectData, sigFigs, inputFormat) {
  # Calculates the treatment group data when averaging subject level data
  if(inputFormat == "") {
    
  } else {
    # Standard code
    isGreaterThan <- any(subjectData$valueOperator==">", na.rm=TRUE)
    isLessThan <- any(subjectData$valueOperator=="<", na.rm=TRUE)
    if(isGreaterThan && isLessThan) {
      resultOperator <- "<>"
      resultValue <- NA
    } else if (isGreaterThan) {
      resultOperator <- ">"
      resultValue <- max(subjectData$numericValue, na.rm = TRUE)
    } else if (isLessThan) {
      resultOperator <- "<"
      resultValue <- min(subjectData$numericValue, na.rm = TRUE)
    } else {
      resultOperator <- NA
      resultValue <- mean(subjectData$numericValue, na.rm = TRUE)
    }
    if (!is.null(sigFigs)) { 
      resultValue <- signif(resultValue, sigFigs)
    }
    return(data.frame(
      "batchCode" = subjectData$batchCode[1],
      "valueKind" = subjectData$valueKind[1],
      "valueUnit" = subjectData$valueUnit[1],
      "numericValue" = if(is.nan(resultValue)) NA else resultValue,
      "stringValue" = if (length(unique(subjectData$stringValue)) == 1) {subjectData$stringValue[1]}
      else if (is.nan(resultValue)) {'NA'}
      else NA,
      "valueOperator" = resultOperator,
      "dateValue" = if (length(unique(subjectData$dateValue)) == 1) subjectData$dateValue[1] else NA,
      "publicData" = subjectData$publicData[1],
      treatmentGroupID = subjectData$treatmentGroupID[1],
      stateGroupIndex = subjectData$stateGroupIndex[1],
      stateID = subjectData$stateID[1],
      stateVersion = subjectData$stateVersion[1],
      valueType = subjectData$valueType[1],
      numberOfReplicates = sum(!is.na(subjectData$numericValue)),
      uncertaintyType = if(!is.na(resultValue)) "standard deviation" else NA,
      uncertainty = if(sum(!is.na(subjectData$numericValue)) > 2) {sd(subjectData$numericValue, na.rm=TRUE)} else NA,
      stringsAsFactors=FALSE))
  }
}