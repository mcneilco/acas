calculateTreatmemtGroupID <- function(results, inputFormat, stateGroups, resultTypes) {
  # Returns a column that will be added to results that separates treatmentGroups
  
  # insert formats with custom code in "if" statements
  if(inputFormat == "DNS Locomotor") {
    neededColumns <- c("Bin", "Dose (mg/kg)", "Vehicle", "Administration route","Treatment Time (min)", "subjectID")
    if (any(!(neededColumns %in% names(results)))) {
      stop("Missing columns needed for Locomotor data. Needs 'Bin', 'Dose (mg/kg)', 'Vehicle', 'Administration route','Treatment Time (min)'")
    }
    treatmentFrame <- results[, c("Bin", "Dose (mg/kg)", "Vehicle", "Administration route","Treatment Time (min)", "subjectID")]
    treatmentFrame <- treatmentFrame[with(treatmentFrame, order(Bin)),]
    
    createTreatmentGroupUnique <- function(df) {
      return(data.frame(subjectID=df$subjectID, treatmentGroupID=paste(df[c("Dose (mg/kg)", "Vehicle", "Administration route","Treatment Time (min)")],collapse="-")))
    }
    treatmentMatching <- ddply(treatmentFrame, .(subjectID), createTreatmentGroupUnique)
    treatmentMatching$treatmentGroupID <- as.numeric(as.factor(treatmentMatching$treatmentGroupID))
    return(treatmentMatching$treatmentGroupID[match(results$subjectID, treatmentMatching$subjectID)])
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