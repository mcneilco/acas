performCalculations <- function(resultTable, parameters, experimentCodeName, dryRun, normalizationDataFrame, standardsDataFrame) {
  # Load stats to avoid issues with recognizing 'sd' in Line 13 below
  library(stats)
  
  # Expand the set of arguments and pass normalizationDataFrame as an argument within normalizeData()
  # exampleClient
  resultTable <- normalizeData(resultTable, parameters, normalizationDataFrame)
  
  # get transformed columns
  transformationList <- vapply(parameters$transformationRuleList, getElement, "", "transformationRule")
  transformationList <- union(transformationList, c("percent efficacy", "sd")) # force "percent efficacy" and "sd" to be included for spotfire
  for (transformation in transformationList) {
    if(transformation != "none") {
      resultTable[ , paste0("transformed_",transformation) := computeTransformedResults(.SD, transformation, parameters, experimentCodeName, dryRun, standardsDataFrame)]
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

normalizeData <- function(resultTable, parameters, normalizationDataFrame) {
  normalization <- parameters$normalizationRule
  
  if (nrow(resultTable[(wellType == 'NC' & is.na(flag))]) == 0) {
    # execute the error prompt about lack of NC only if no default value was defined in lieu of a negative control
    if (is.na(normalizationDataFrame$defaultValue[normalizationDataFrame$standardType=="NC"])) {
      stopUser("All of the negative controls were flagged, so normalization cannot proceed.")
    }
  }
  if (nrow(resultTable[(wellType == 'PC' & is.na(flag))]) == 0) {
    # execute the error prompt about lack of PC only if no default value was defined in lieu of a positive control
    if (is.na(normalizationDataFrame$defaultValue[normalizationDataFrame$standardType=="PC"])) {
      stopUser("All of the positive controls were flagged, so normalization cannot proceed.")
    }
  }
  
  #find min of dataset (aggregationMethod of unflagged Negative Controls)
  # otherwise if no NC exists use the default value selected in lieu of NC standard
  if (nrow(resultTable[(wellType == 'NC' & is.na(flag))]) != 0) {
    overallMinLevel <- useAggregationMethod(resultTable[(wellType=='NC' & is.na(flag))]$activity, parameters)
  } else {
    overallMinLevel <- normalizationDataFrame$defaultValue[normalizationDataFrame$standardType=="NC"]
  }
  
  #find max of dataset (aggregationMethod of unflagged Positive Controls)
  # otherwise if no PC exists use the default value selected in lieu of PC standard
  if (nrow(resultTable[(wellType == 'PC' & is.na(flag))]) != 0) {
    overallMaxLevel <- useAggregationMethod(resultTable[(wellType=='PC' & is.na(flag))]$activity, parameters)
  } else {
    overallMaxLevel <- normalizationDataFrame$defaultValue[normalizationDataFrame$standardType=="PC"]
  }
    
    
  if (normalization == "plate order only") {
    resultTable[,normalizedActivity:=computeNormalized(activity,wellType,flag,
                                                       overallMinLevel=overallMinLevel,
                                                       overallMaxLevel=overallMaxLevel, parameters), by= assayBarcode]
  } else if (normalization == "plate order and row") {
    # This now normlizes data by plate, then normalizes the normalized data by row across plates.
    # This matches an earlier system
    resultTable[,plateRow:=gsub("\\d", "",well)]
    resultTable[,normalizedActivity:=computeNormalized(activity, wellType, flag,
                                                       overallMinLevel=overallMinLevel,
                                                       overallMaxLevel=overallMaxLevel, parameters), by= assayBarcode]
    resultTable[,normalizedActivity:=computeNormalized(normalizedActivity, wellType, flag,
                                                       overallMinLevel=overallMinLevel,
                                                       overallMaxLevel=overallMaxLevel, parameters), by= plateRow]
  } else if (normalization == "plate order and tip") {
    stopUser("Normalization not coded for 'plate order and tip'.")
  } else if (normalization == "plate order & section by 8") {
    # This now normlizes data by plate, then normalizes the normalized data by section across plates.
    # This matches an earlier system
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
    resultTable[,normalizedActivity:=computeNormalized(activity, wellType, flag,
                                                       overallMinLevel=overallMinLevel,
                                                       overallMaxLevel=overallMaxLevel, parameters), 
                by= assayBarcode]
    resultTable[,normalizedActivity:=computeNormalized(normalizedActivity, wellType, flag,
                                                       overallMinLevel=overallMinLevel,
                                                       overallMaxLevel=overallMaxLevel, parameters), 
                by= section]
  } else if (normalization == "none") {
    resultTable[, normalizedActivity := resultTable$activity]
  } else {
    warnUser("No normalization applied.")
    resultTable[, normalizedActivity := resultTable$activity]
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

computeTransformedResults <- function(mainData, transformation, parameters, experimentCodeName, dryRun, standardsDataFrame) { 
  #switch on transformation
  # based on transformation (custom code for each), responds with a vector of the new transformation
  # Inputs:
  #   transformation: string
  #   mainData: data.table
  #   parameters: list
  
  # Structure the data frame that holds information about transformation controls, as defined in the GUI
  transformationDataFrame <- as.data.frame(rbind(parameters$transformationRuleList[[1]]$transformationParameters$positiveControl,
                                                parameters$transformationRuleList[[1]]$transformationParameters$negativeControl))
  
  #setnames(transformationDataFrame, c('standardNumber','defaultValue'))
  transformationDataFrame$standardType <- c('PC', 'NC')
  
  # Replace "" by NA to avoid NA coersion warnings when turning the defaultValues of transformationDataFrame to numerical values
  transformationDataFrame$defaultValue[transformationDataFrame$defaultValue==""] <- NA
  transformationDataFrame$defaultValue <- as.numeric(transformationDataFrame$defaultValue)

    
  # For the two transformation options available in the GUI, check if there are any 'unassigned' PC, NC
  if (transformation == "percent efficacy" | transformation == "sd") {
    if (transformationDataFrame$standardNumber[transformationDataFrame$standardType=='PC'] == 'unassigned' |
        transformationDataFrame$standardNumber[transformationDataFrame$standardType=='NC'] == 'unassigned') {
      stopUser("In the transformation section, at least one of the Positive or Negative Controls was not defined.
                Selecting a Standard, or alternatively, setting an Input Value for Positive and Negative Control is required 
                for transformation calculations.")
    }
    
    # If tranformation-related PC OR NC are defined as input value but are missing the numeric value, prompt the user with an error
    if ((transformationDataFrame$standardNumber[transformationDataFrame$standardType=='PC'] == 'input value' &
         is.na(transformationDataFrame$defaultValue[transformationDataFrame$standardType=='PC'])) |
        (transformationDataFrame$standardNumber[transformationDataFrame$standardType=='NC'] == 'input value' &
         is.na(transformationDataFrame$defaultValue[transformationDataFrame$standardType=='NC']))) {
      stopUser("In the transformation section, an Input Value was selected for at least one of the Positive or Negative Controls
                however no actual numeric value was defined. Selecting a Standard, or alternatively setting an Input Value, for
                Positive and Negative Control is required for transformation calculations.")
    }
    
    # If tranformation-related PC OR NC are defined as the exact same standard, prompt the user with an error
    if (transformationDataFrame$standardNumber[transformationDataFrame$standardType=='PC'] != 'unassigned' &
        transformationDataFrame$standardNumber[transformationDataFrame$standardType=='PC'] != 'input value' &
        transformationDataFrame$standardNumber[transformationDataFrame$standardType=='NC'] != 'unassigned' &
        transformationDataFrame$standardNumber[transformationDataFrame$standardType=='NC'] != 'input value') {
      if (identical(transformationDataFrame$standardNumber[transformationDataFrame$standardType=='PC'],
                    transformationDataFrame$standardNumber[transformationDataFrame$standardType=='NC'])) {
        stopUser("The same Standard was defined for both Positive Control and Negative Control in the tranformation section. 
                  Different Standards for Positive and Negative Controls are required for tranformation calculations.")
      }
    }
  }


  if (transformation == "percent efficacy") {
    
    # Use the transformation-related PC to calculate aggregatePosControl in the two possible scenarios below, where a default value has been
    # defined OR a standard is defined
    if (transformationDataFrame$standardNumber[transformationDataFrame$standardType=='PC'] == 'input value') {
      aggregatePosControl <- transformationDataFrame$defaultValue[transformationDataFrame$standardType=='PC']
    } else {
      # Find the standard number for PC from transformationDataFrame
      transfStandardNumberPC <- transformationDataFrame$standardNumber[transformationDataFrame$standardType=='PC']
      # Find the label ("PC", "PC-S2", "NC-S3", etc) that corresponds to the transformation-related PC standard from standardsDataFrame
      enumeratedTransfPC <- standardsDataFrame$standardTypeEnumerated[standardsDataFrame$standardNumber == transfStandardNumberPC]
      # If at least one entry of the transformation-related PC standard exists that is not flagged then calculate aggregatePosControl
      # otherwise prompt the user with an error
      if (nrow(mainData[wellType == enumeratedTransfPC & is.na(flag)]) == 0) {
        stopUser("Either there are no wells with the Positive Control defined in the transformation section or all wells with 
                  that Positive Control are flagged. Please check the data or alternatively select an Input Value for Positive Control
                  in the transformation section.")
      } else {
        aggregatePosControl <- useAggregationMethod(as.numeric(mainData[wellType == enumeratedTransfPC & is.na(flag)]$normalizedActivity), parameters)
      }
    }

    # Use the transformation-related NC to calculate aggregateVehControl in the two possible scenarios below, where a default value has been
    # defined OR a standard is defined
    if (transformationDataFrame$standardNumber[transformationDataFrame$standardType=='NC'] == 'input value') {
      aggregateVehControl <- transformationDataFrame$defaultValue[transformationDataFrame$standardType=='NC']
    } else {
      # Find the standard number for NC from transformationDataFrame
      transfStandardNumberNC <- transformationDataFrame$standardNumber[transformationDataFrame$standardType=='NC']
      # Find the label ("NC", "NC-S2", "PC-S4", "VC-S5", etc) that corresponds to the transformation-related NC standard from standardsDataFrame
      enumeratedTransfNC <- standardsDataFrame$standardTypeEnumerated[standardsDataFrame$standardNumber == transfStandardNumberNC]
      # If at least one entry of the transformation-related NC standard exists that is not flagged then calculate aggregatePosControl
      # otherwise prompt the user with an error
      if (nrow(mainData[wellType == enumeratedTransfNC & is.na(flag)]) == 0) {
        stopUser("Either there are no wells with the Negative Control defined in the transformation section or all wells with 
                  that Negative Control are flagged. Please check the data or alternatively select an Input Value for Negative Control
                  in the transformation section.")
      } else {
        aggregateVehControl <- useAggregationMethod(as.numeric(mainData[wellType == enumeratedTransfNC & is.na(flag)]$normalizedActivity), parameters)
      }
    }
    
    #aggregatePosControl <- useAggregationMethod(as.numeric(mainData[wellType == "PC" & is.na(flag)]$normalizedActivity), parameters)
    ## Use Negative Control if Vehicle Control is not defined
    #if(length(mainData[wellType == "VC"]$normalizedActivity) == 0) {
    #  aggregateVehControl <- useAggregationMethod(as.numeric(mainData[wellType == "NC" & is.na(flag)]$normalizedActivity), parameters)
    #} else {
    #  aggregateVehControl <- useAggregationMethod(as.numeric(mainData[wellType == "VC" & is.na(flag)]$normalizedActivity), parameters)
    #}
    return(
      (1
       - (as.numeric(mainData$normalizedActivity) - aggregatePosControl)
       /(aggregateVehControl-aggregatePosControl)) * 100)
  } else if (transformation == "sd") {
    
    # Note: Transformation-related PC in the case where transformation=="sd" is not used in any calculations!
    
    # Use the transformation-related NC to calculate aggregateVehControl and stdevVehControl in the two possible scenarios below,
    # where a default value has been defined OR a standard is defined
    if (transformationDataFrame$standardNumber[transformationDataFrame$standardType=='NC'] == 'input value') {
      aggregateVehControl <- transformationDataFrame$defaultValue[transformationDataFrame$standardType=='NC']
      stdevVehControl <- 0
    } else {
      # Find the standard number for NC from transformationDataFrame
      transfStandardNumberNC <- transformationDataFrame$standardNumber[transformationDataFrame$standardType=='NC']
      # Find the label ("NC", "NC-S2", "PC-S4", "VC-S5", etc) that corresponds to the transformation-related NC standard from standardsDataFrame
      enumeratedTransfNC <- standardsDataFrame$standardTypeEnumerated[standardsDataFrame$standardNumber == transfStandardNumberNC]
      # If at least one entry of the transformation-related NC standard exists that is not flagged then calculate aggregatePosControl
      # otherwise prompt the user with an error
      if (nrow(mainData[wellType == enumeratedTransfNC & is.na(flag)]) == 0) {
        stopUser("Either there are no wells with the Negative Control defined in the transformation section or all wells with 
                  that Negative Control are flagged. Please check the data or alternatively select an Input Value for Negative Control
                  in the transformation section.")
      } else {
        aggregateVehControl <- useAggregationMethod(as.numeric(mainData[wellType == enumeratedTransfNC & is.na(flag)]$normalizedActivity), parameters)
        stdevVehControl <- sd(as.numeric(mainData[wellType == enumeratedTransfNC & is.na(flag)]$normalizedActivity))
      }
    }
    
    ## Use Negative Control if Vehicle Control is not defined
    #if(length(mainData[wellType == "VC"]$normalizedActivity) == 0) {
    #  aggregateVehControl <- useAggregationMethod(as.numeric(mainData[wellType == "NC" & is.na(flag)]$normalizedActivity), parameters)
    #} else {
    #  aggregateVehControl <- useAggregationMethod(as.numeric(mainData[wellType == "VC" & is.na(flag)]$normalizedActivity), parameters)
    #}
    
    ## Use Negative Control if Vehicle Control is not defined
    #if(length(mainData[wellType == "VC"]$normalizedActivity) == 0) {
    #  stdevVehControl <- sd(as.numeric(mainData[wellType == "NC" & is.na(flag)]$normalizedActivity))
    #} else {
    #  stdevVehControl <- sd(as.numeric(mainData[wellType == "VC" & is.na(flag)]$normalizedActivity))
    #}
    
    # Determine if signal direction is decreasing or increasing
    if (parameters$signalDirectionRule == "increasing") {
      return((as.numeric(mainData$normalizedActivity) - aggregateVehControl)/(stdevVehControl))
    } else if (parameters$signalDirectionRule == "decreasing") {
      return(-(as.numeric(mainData$normalizedActivity) - aggregateVehControl)/(stdevVehControl))
    } else {
      stopUser("Signal Direction (",parameters$signalDirectionRule,")is not defined in the system. Please see your system administrator.")
    }
  } else if (transformation == "noAgonist") {
    return(getNoAgonist(parameters, mainData))
  } else if (transformation == "enhancement") {
    groupBy <- getGroupBy(parameters)
    neededColumns <- c(groupBy, "normalizedActivity", "flag", "transformed_noAgonist")
    if (!("transformed_noAgonist" %in% names(mainData))) {
      mainData[, transformed_noAgonist:=getNoAgonist(parameters, .SD)]
    }
    mainCopy <- mainData[, neededColumns, with=FALSE]
    # users expect this to group by assayBarcode, could look at allowing full groupBy later
    mainCopy[, NCMean := mean(normalizedActivity[wellType == "NC" & is.na(flag)]), by = "assayBarcode"]
    return(mainCopy[, V1 := normalizedActivity - (transformed_noAgonist + NCMean)]$V1)
  } else if (transformation == "enhancementRatio") {
    groupBy <- getGroupBy(parameters)
    neededColumns <- c(groupBy, "normalizedActivity", "flag", "transformed_noAgonist")
    if (!("transformed_noAgonist" %in% names(mainData))) {
      mainData[, transformed_noAgonist:=getNoAgonist(parameters, .SD)]
    }
    mainCopy <- mainData[, neededColumns, with=FALSE]
    # users expect this to group by assayBarcode, could look at allowing full groupBy later
    mainCopy[, NCMean := mean(normalizedActivity[wellType == "NC" & is.na(flag)]), by = "assayBarcode"]
    if (any(na.omit(mainCopy$transformed_noAgonist + mainCopy$NCMean) == 0)) {
      # This is really unlikely as both of these should be positive... they don't use normalization with this
      stopUser("Cannot use enhancementRatio if any of the noAgonist + NCMean = 0")
    }
    return(mainCopy[, V1 := normalizedActivity / (transformed_noAgonist + NCMean)]$V1)
  } else if (transformation == "enhancementGraph") {
    if (!("transformed_noAgonist" %in% names(mainData))) {
      mainData[, transformed_noAgonist:=getNoAgonist(parameters, .SD)]
    }
    if (dryRun) {
      filePath <- paste0("experiments/", experimentCodeName, "/dryRun/images")
    } else {
      filePath <- paste0("experiments/", experimentCodeName, "/images")
    }
    source(file.path(racas::applicationSettings$appHome, "src/r/PrimaryScreen/saveComparisonTraces.R"), local = TRUE)
    saveComparisonTraces(mainData, filePath)
    # Filenames: any rows with wellType other than 'test' are given an entry of NA
    filePaths <- ifelse(
      mainData$wellType == 'test',
      file.path(filePath, paste0(mainData$assayBarcode, "_", mainData$batchCode, ".png")),
      NA_character_)
    return(filePaths)
  } else if (transformation == "null" || transformation == "" || transformation =="none") {
    warnUser("No transformation applied to activity.")
    return(mainData$normalizedActivity)
  } else {
    stopUser("Transformation not defined in system.")
  }  
}

getNoAgonist <- function(parameters, mainData) {
  groupBy <- getGroupBy(parameters)
  neededColumns <- c(groupBy, "agonistConc", "normalizedActivity", "flag")
  mainCopy <- mainData[, neededColumns, with = FALSE]
  meanZero <- function(agonistConc, normalizedActivity, flag) {
    zeroData <- normalizedActivity[agonistConc == 0 & is.na(flag)]
    if (length(zeroData) == 0) {
      return(NA_real_)
    } else {
      return(mean(zeroData))
    }
  }
  return(mainCopy[, V1 := meanZero(agonistConc, normalizedActivity, flag), by = groupBy]$V1)
}
