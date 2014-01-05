# PrimaryAnalysis.R
#
#
# Sam Meyer
# sam@mcneilco.com
# Copyright 2012 John McNeil & Co. Inc.
#######################################################################################
# Runs the analysis of primary screens, confirmation screens, and dose response screens
#######################################################################################

#TODOs
# Throw an error if files are missing barcodes
# Confirmation and Dose Response
# Done but not saving or plotting: Allow aggregation by plate and across plates (break treatment groups on compound and concentration)
# New Data
# Analyze Dose Response
# Analyze Confirmation screens
# Ask Guy about sd scores (not do for now)
# Do we want a graph of raw data or treatment groups? (for confirmation and dose response) raw data
# What if a compound is fluorescent in one location but not another? third category
# What is a well ID for if we have a well name? nothing
# Done, but not saving or plotting: add normalization by row order and plate order
# Give Guy an ACAS map for everything you save

# Questions
# For Dose Response, there is a read plate name but no barcode...
# What to do when two runs are done on the same barcode?

# runPrimaryAnalysis(request=list(fileToParse="serverOnlyModules/blueimp-file-upload-node/public/files/PrimaryAnalysisFiles.zip",dryRunMode=TRUE,user="smeyer",testMode=FALSE,primaryAnalysisExperimentId=255259))
# runPrimaryAnalysis(request=list(fileToParse="public/src/modules/PrimaryScreen/spec/specFiles",dryRunMode=TRUE,user="smeyer",testMode=FALSE,primaryAnalysisExperimentId=659))
# runMain(folderToParse="public/src/modules/PrimaryScreen/spec/specFiles",dryRun=TRUE,user="smeyer",testMode=FALSE, experimentId=27099)
# newest experimentID: 75191, 9036, 11203
# agonist:"FL0073897-1-1"
# agonistConc: 49.5
# positive: FL0073900-1-1
# negative: FL0073895-1-1

# DryRun
# user  system elapsed 
# 1.847   0.061  37.876

# real
# user  system elapsed 
# 7.904   0.250  45.444 


makeDataFrameOfWellsGrid <- function(allData, barcode, valueName) {
  # Takes data and forms it into a data frame
  #
  # Args:
  #   allData:    A matrix or data.frame of data, row.names are wells
  #   barcode:    The barcode for this data
  #   valueName:  a label for the values inside the wells
  # Returns:
  #   A data.frame with three columns:
  #     "barcode":    barcode of source plate
  #     "well":       well names of source
  #     valueName:    the values for each well
  
	wellNames <- c()
	values <- c()
	for (i in 1:length(row.names(allData))) {
		for (j in 1:length(names(allData))) {
      if (j<10) {
        wellName = (paste(sep='0',row.names(allData)[[i]], j))
      } else {
        wellName = (paste(sep='',row.names(allData)[[i]], j))
      }	
			wellNames <- c(wellNames, wellName)
			values <- c(values, allData[i,j])
		}
	}
	out <- data.frame(barcode=barcode, well=wellNames)
	out[valueName] <- values
	return(out)
	
}
getParamByKey <- function(params, key) {
	line <- params[[grep(key, params)]] 
	components <- strsplit(line, " = ")
	return( components[[1]][[2]])
}
getBatchNamesAndConcentrations <- function(barcode, well, wellTable, ignore=list()) {
  # Matches result rows up with batch names and concentrations
  #
  # Args:
  #   barcode:        A vector of the barcodes
  #   well:           A vector of the wells
  #   wellTabe:       A data.frame with columns of BARCODE, WELL_NAME, BATCH_CODE,CONCENTRATION,CONCENTRATION_UNIT
  #   ignore:         A list with names: batchCode, concentration, concentrationUnits
  # Returns:
  #   A data.frame with batchName,concentration, and concUnit that matches the order of the input barcodes and wells
  
  # TODO: does not deal with multiple compounds in one well
  # Remove agonist compounds (TODO: needs to be modified to include concentration for fructose)
  if((length(ignore) > 0) && !(ignore$batchCode %in% wellTable$BATCH_CODE)){
    stop("The agonist was not found in the plates. Have all transfers been loaded?")
  }
  # TODO: Figure out if the <= is correct for the concentration
#   ignoredRows <- wellTable$BATCH_CODE == ignore$batchCode & 
#     wellTable$CONCENTRATION == ignore$concentration
  ignoredRows <- wellTable$BATCH_CODE == ignore$batchCode & 
    wellTable$CONCENTRATION <= ignore$concentration & wellTable$CONCENTRATION_UNIT == ignore$concentrationUnits
  wellTable <- wellTable[!(ignoredRows), ]
  
  wellUniqueId <- paste(barcode, well)
  wellTableUniqueId <- paste(wellTable$BARCODE, wellTable$WELL_NAME)
  outputFrame <- wellTable[match(wellUniqueId,wellTableUniqueId),c("BATCH_CODE","CONCENTRATION","CONCENTRATION_UNIT")]
  names(outputFrame) <- c("batchName","concentration","concUnit")
  return(outputFrame)
}
getWellTypes <- function(batchNames, concentrations, concentrationUnits, positiveControl, negativeControl) {
  # Takes vectors of batchNames, concentrations, and concunits 
  # and compares to named lists of the same for positive and negative controls
  
  wellTypes <- rep.int("test",length(batchNames))
  
  if (positiveControl$concentration == "infinite"){
    positiveControl$concentration <- Inf
  }
  if (negativeControl$concentration == "infinite"){
    negativeControl$concentration <- Inf
  }
  
  wellTypes[batchName==positiveControl$batchCode & concentrations==positiveControl$concentration & 
              concentrationUnits==positiveControl$concentrationUnits] <- "PC"
  wellTypes[batchName==negativeControl$batchCode & concentrations==negativeControl$concentration & 
              concentrationUnits==negativeControl$concentrationUnits] <- "NC"
  
	return(wellTypes)
}
computeTransformedResults <- function(mainData, transformation) {
	#TODO switch on transformation
	if (transformation == "(maximum-minimum)/minimum") {
	  return( (mainData$Maximum-mainData$Minimum)/mainData$Minimum )
	} else {
    return ( (mainData$Maximum-mainData$Minimum)/mainData$Minimum )
	}	
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
computeSDScore <- function(dataVector, meanValue, sdValue) {
  # TODO: check math, what should be included?
  # Computes an SD Score

  return ((dataVector - meanValue)/sdValue)
}
createWellTable <- function(barcodeList, testMode) {
  # Creates a table of wells and corporate batch id's
  #
  # Args:
  #   barcodeList:    A list of plate barcodes used in the experiment
  #   testMode:       A boolean of the testMode
  # Returns:
  #   A table of wells and corporate batch id's
  
  barcodeQuery <- paste(barcodeList,collapse="','")
  
  if (testMode) {
    fakeAPI <- read.csv("public/src/modules/PrimaryScreen/spec/api_container_export.csv")
    fakeAPI$BARCODE <- gsub("BF00007450", "TL00098001", fakeAPI$BARCODE)
    fakeAPI$BARCODE <- gsub("BF00007460","TL00098002",fakeAPI$BARCODE)
    fakeAPI$BARCODE <- gsub("BF00007390","TL00098003",fakeAPI$BARCODE)
    fakeAPI$BARCODE <- gsub("BF00007395","TL00098004",fakeAPI$BARCODE)
    wellTable <- fakeAPI[fakeAPI$BARCODE %in% barcodeList, ]
    wellTable$BATCH_CODE <- gsub("CRA-024169-1", "CRA-000399-1", wellTable$BATCH_CODE)
    wellTable$BATCH_CODE <- gsub("CRA-024184-1", "CRA-000396-1", wellTable$BATCH_CODE)
    wellTable$BATCH_CODE <- gsub("CRA-024074-1", "CRA-000399-1", wellTable$BATCH_CODE)
    wellTable$BATCH_CODE <- gsub("CRA-024087-1", "CRA-000396-1", wellTable$BATCH_CODE)
    # different test, remove after nextval deploy
    load("public/src/modules/PrimaryScreen/spec/wellTable.Rda")
    wellTable <- wellTable[!(wellTable$BATCH_CODE=="FL0073897-1-1" & (wellTable$CONCENTRATION < 0.2 | wellTable$CONCENTRATION>49.6)), ]
  } else {
    wellTable <- query(paste0(
      "SELECT *
    FROM api_container_contents
    WHERE barcode IN ('", barcodeQuery, "')"))
  }
  
  wellTable$CONCENTRATION[wellTable$CONCENTRATION_STRING] <- Inf
  
  return(wellTable)
}

createPDF <- function(resultTable, analysisGroupData, parameters, summaryInfo, threshold, experiment) {
  require('gplots')
  require('gridExtra')
  require('data.table')
  require('reshape')
  source("public/src/modules/PrimaryScreen/src/server/primaryAnalysisPlots.R")
  
  allResultTable <- resultTable
  resultTable <- resultTable[!resultTable$fluorescent,]
  
  pdfLocation <- paste0("experiments/",experiment$codeName,"/analysis/",experiment$codeName,"_Summary.pdf")
  pdf(file=paste0("serverOnlyModules/blueimp-file-upload-node/public/files/", pdfLocation), width=8.5, height=11)
  
  textToShow <- paste0("------------------------------------------------------------------------------------------------\n",
                      paste(paste0(names(summaryInfo$info),": ",summaryInfo$info),collapse="\n"))
  textplot(textToShow, halign="left",valign="top")
  title("Primary Screen")
  
  createDensityPlot(resultTable$normalized, resultTable$wellType, threshold = threshold, margins = c(25,4,4,8))
  
  print(createGGComparison(graphTitle = "Plate Comparison", xColumn=resultTable$barcode,
                           wellType = resultTable$wellType, dataRow = resultTable$transformed, xLabel = "Plate", 
                           margins = c(4,2,20,4), rotateXLabel = TRUE, test = FALSE, colourPalette = c("blue","green")))
  
  plateDataTable <- data.table(transformedValues = resultTable$transformed, 
                               well = resultTable$well)
  plateData <- plateDataTable[,list(transformedValues = mean(transformedValues)), by=well]
  print(createGGHeatmap("Heatmap of the Average of All Plates", plateData, margins=c(0,0,20,0)))
  
  rowVector <- gsub("\\d", "", resultTable$well)
  columnVector <- gsub("\\D", "", resultTable$well)
  for (barcode in levels(resultTable$barcode)) {
    plateData <- data.frame(transformedValues = resultTable$normalized[resultTable$barcode==barcode], 
                            well = resultTable$well[resultTable$barcode==barcode], hits=resultTable$threshold[resultTable$barcode==barcode])
    g1 <- createGGHeatmap(paste("Heatmap ",barcode), plateData)
#     g2 <- createGGComparison(graphTitle = paste("Row Comparison ",barcode), 
#                            yLimits = c(-1,2), 
#                            xColumn = rowVector[resultTable$barcode==barcode],
#                            wellType = resultTable$wellType[resultTable$barcode == barcode],
#                            dataRow = plateData$transformedValues,
#                              hits = plateData$hits,
#                            xLabel = "Row",
#                            colourPalette = c("red","green","black"))
    g3 <- createGGComparison(graphTitle = paste("Column Comparison ", barcode),
                             xColumn = columnVector[resultTable$barcode==barcode],
                             wellType = resultTable$wellType[resultTable$barcode == barcode],
                             dataRow = plateData$transformedValues,
                             hits = plateData$hits,
                             xLabel = "Column",
                             yLabel = "Normalized Activity (rfu)",
                             colourPalette = c("blue", "green", "red", "black"),
                             threshold = threshold)
#     resultTable$well <- factor(resultTable$well, levels = levels(resultTable$well)[order(gsub("\\D", "", levels(resultTable$well)))])
#     resultTable <- resultTable[order(gsub("\\D", "", resultTable$well)),]
    plateData <- data.frame(transformedValues = resultTable$transformed[resultTable$barcode==barcode], 
                            well = resultTable$well[resultTable$barcode==barcode], hits=resultTable$threshold[resultTable$barcode==barcode])
#     g4 <- createGGComparison(graphTitle = paste("Well Comparison ",barcode), 
#                              yLimits = c(-1,2), 
#                              xColumn = resultTable$well[resultTable$barcode==barcode],
#                              wellType = resultTable$wellType[resultTable$barcode == barcode],
#                              dataRow = resultTable$transformed[resultTable$barcode==barcode],
#                              hits = resultTable$efficacyThreshold[resultTable$barcode==barcode],
#                              xLabel = "Column",
#                              colourPalette = c("red","green","black"))
    
    print(grid.arrange(g1, g3))
    
  }
  
  fluorescentWells <- allResultTable[allResultTable$fluorescent,list(barcode,well,sequence,timePoints,batchName)]
  hitWells <- allResultTable[allResultTable$threshold,list(barcode,well,sequence,timePoints,batchName)]
  latePeakWells <- allResultTable[allResultTable$latePeak,list(barcode,well,sequence,timePoints,batchName)]
  
  plotFigure <- function(xData,yData, barcode, well, batchCode, title) {
    xData <- as.numeric(unlist(strsplit(xData,"\t", fixed= TRUE)))
    yData <- as.numeric(unlist(strsplit(yData,"\t", fixed= TRUE)))
    type="l"; xlab="Time (sec)"; ylab="Activity (rfu)"
    plot(xData, yData, type=type, xlab=xlab, ylab=ylab)
    title(main=paste0(barcode, " : ", well, "\n", batchCode))
    mtext(title, 3, line=0, adj=0.5, cex=1.2, outer=TRUE)
  }
  
  if(nrow(fluorescentWells) > 0) {
    par(mfcol=c(4,3), mar=c(4,4,4,4), oma =c(2,2,2,2))
    mapply(plotFigure, fluorescentWells$timePoints, fluorescentWells$sequence, fluorescentWells$barcode, fluorescentWells$well, fluorescentWells$batchName, "Fluorescent Wells")
  }
  if(nrow(latePeakWells) > 0) {
    par(mfcol=c(4,3), mar=c(4,4,4,4), oma =c(2,2,2,2))
    mapply(plotFigure, latePeakWells$timePoints, latePeakWells$sequence, latePeakWells$barcode, latePeakWells$well, latePeakWells$batchName, "Late Peak Wells")
  }
  if(nrow(hitWells) > 0) {
    par(mfcol=c(4,3), mar=c(4,4,4,4), oma =c(2,2,2,2))
    mapply(plotFigure, hitWells$timePoints, hitWells$sequence, hitWells$barcode, hitWells$well, hitWells$batchName, "Hit Wells")
  }

  dev.off()
  

  return(pdfLocation)
}
createPlots <- function(resultTable){
  source("primaryAnalysisPlots.R")
  require('tools')
  
  #don't lose old parameters
  oldpar <- par(col=4, lty = 2)
  
  #TODO go learn hmisc.axis() to make this look better
  dir.create(file.path("./","results"), showWarnings = FALSE)
  dir.create(file.path("./results","plots"), showWarnings = FALSE)
  png(file="./results/plots/NormalizedPlateCompareisonNoOutliers.png")
  createComparison(title = "Normalized Plate Comparison w/o Outliers", norm = TRUE, ylim = c(-1,2), resultTableCopy = resultTable,
                   resultColumn = resultTable$barcode, organizeBy = "Plate")
  par(oldpar)
  dev.off()
  
  png(file="./results/plots/NormalizedPlateCompareisonWithOutliers.png")
  createComparison(title = "Normalized Plate Comparison w/ Outliers", norm = TRUE, resultTableCopy = resultTable,
                   resultColumn = resultTable$barcode, organizeBy = "Plate")
  par(oldpar)
  dev.off()
  
  png(file="./results/plots/PlateComparisonWithOutliers.png")
  createComparison(title = "Plate Comparison w/ Outliers",resultTableCopy = resultTable,
                   resultColumn = resultTable$barcode, organizeBy = "Plate")
  dev.off()
  par(oldpar)
  
  png(file="./results/plots/PlateComparisonNoOutliers.png")
  createComparison(title = "Plate Comparison w/o Outliers", ylim = c(-1,2), resultTableCopy = resultTable,
                   resultColumn = resultTable$barcode, organizeBy = "Plate")
  dev.off()
  par(oldpar)
  
  #create plot of comparison by row
  png(file="./results/plots/RowComparison.png")
  rowColumn <- gsub("\\d", "", resultTable$well)
  createComparison(title = "Row Comparison", resultTableCopy = resultTable,
                   resultColumn = rowColumn, norm = TRUE, organizeBy = "Row")
  dev.off()
  par(oldpar)
  
  #create view of plate by column
  png(file="./results/plots/ColumnComparison.png")
  numberColumn <- gsub("\\D", "", resultTable$well)
  createComparison(title = "Column Comparison", resultColumn = numberColumn, resultTableCopy = resultTable,
                   norm = TRUE, organizeBy = "Column")
  dev.off()
  par(oldpar)
  
  #create plot of comparison by plate order and well
  png(file="./results/plots/PlateOrderWellComparison.png")
  plateOrderWell <- paste(resultTable$barcode, resultTable$well, sep = ":")
  createComparison(title = "Plate Order and Well", resultColumn = plateOrderWell, resultTableCopy = resultTable,
                   norm = TRUE, organizeBy = "Plate Order: Well")
  dev.off()
  par(oldpar)
  
  #create plot of comparison by corporate batch
  png(file="./results/plots/CorporateBatchComparison.png")
  createComparison(title = "Corporate Batch Comparison", resultColumn = resultTable$batchName, resultTableCopy = resultTable,
                   norm = TRUE, organizeBy = "Corporate Batch")
  dev.off()
  par(oldpar)
  
  #density plot
  png(file="./results/plots/Density.png")
  createDensityPlot(resultTable,threshold=parameters$activeEfficacyThreshold)
  dev.off()
  par(oldpar)
  
  #create heatmap for each plate
  for (barcode in levels(resultTable$barcode)) {
    plateData <- data.frame(values = resultTable$normalized[resultTable$barcode==barcode], 
                            well = resultTable$well[resultTable$barcode==barcode])
    createHeatMap(paste("Heatmap ",barcode), plateData)
  }
  #create heatmap for average of set
  plateDataTable <- data.table(values = resultTable$normalized, 
                               well = resultTable$well)
  plateData <- plateDataTable[,list(values = mean(values)), by=well]
  createHeatMap("All Plates", plateData)

}
saveData <- function(subjectData, treatmentGroupData, analysisGroupData, user, experimentId){
  #save(subjectData, experimentId, file="test.Rda")
  originalNames <- names(subjectData)
  subjectData <- as.data.frame(subjectData)
  
  # Fix names
  nameChange <- c(
    'well'='well name', 'Maximum'='maximum', 'Minimum'='minimum', 'sequence'='fluorescencePoints', 
    'batchName'='batchCode', 'concentration'='Dose', 'concUnit'='DoseUnit', 'wellType' = 'well type', 
    'transformed'='transformed efficacy','normalized'='normalized efficacy', 'maxTime' = 'max time', 
    'latePeak'='late peak', 'threshold'='over efficacy threshold')
  names(subjectData)[names(subjectData) %in% names(nameChange)] <- nameChange[names(subjectData)[names(subjectData) %in% names(nameChange)]]
  
  stateGroups <- list(list(entityKind = "subject",
                           stateType = "data", 
                           stateKind = "test compound treatment", 
                           valueKinds = c("Dose"),
                           includesOthers = FALSE,
                           includesCorpName = TRUE),
                      list(entityKind = "subject",
                           stateType = "metadata",
                           stateKind = "plate information",
                           valueKinds = c("well type","barcode","well name"),
                           includesOthers = FALSE,
                           includesCorpName = FALSE),
                      list(entityKind = "subject",
                           stateType = "data",
                           stateKind = "results",
                           valueKinds = c("maximum","minimum", "fluorescent", "transformed efficacy", 
                                          "normalized efficacy", "over efficacy threshold", "fluorescencePoints",
                                          "timePoints","max time", 'late peak'),
                           includesOthers = FALSE,
                           includesCorpName = FALSE),
                      list(entityKind = "analysis group",
                           stateType = "data",
                           stateKind = "results",
                           valueKinds = c("fluorescent", "normalized efficacy", "over efficacy threshold"),
                           includesOthers = FALSE,
                           includesCorpName = TRUE),
                      list(entityKind = "analysis group",
                           stateType = "metadata",
                           stateKind = "plate information",
                           valueKinds = c("well type"),
                           includesOthers = FALSE,
                           includesCorpName = FALSE)
                      )
  
  # Turn logicals into "yes" and "no"
  columnClasses <- lapply(subjectData, class)
  
  for (i in 1:length(columnClasses)) {
    if (columnClasses[[i]]=="logical") {
      subjectData[[names(columnClasses)[i]]] <- ifelse(subjectData[[names(columnClasses)[i]]],"yes","no")
    }
  }
  
  # Turn all others into character
  subjectData <- as.data.frame(lapply(subjectData, as.character), stringsAsFactors=FALSE, optional=TRUE)
  
  # TODO: check that all dose units are same
  resultTypes <- data.frame(
    DataColumn = c('barcode', 'well name', 'maximum', 'minimum', 'fluorescent', 'timePoints', 'fluorescencePoints', 
                   'Dose', 'well type', 'transformed efficacy', 'normalized efficacy', 'over efficacy threshold',
                   'max time', 'late peak'),
    Type = c('barcode', 'well name', 'maximum', 'minimum', 'fluorescent', 'timePoints', 'fluorescencePoints', 
             'Dose', 'well type', 'transformed efficacy', 'normalized efficacy', 'over efficacy threshold',
             'max time', 'late peak'),
    Units = c(NA, NA, 'rfu', 'rfu', NA, 'sec', 'rfu', subjectData$DoseUnit[1], NA, NA, NA, NA, 'sec', NA),
    valueType = c('codeValue','stringValue', 'numericValue','numericValue','stringValue','clobValue',
                  'clobValue','numericValue','stringValue','numericValue','numericValue','stringValue',
                  'numericValue','stringValue'),
    stringsAsFactors = FALSE)
  
  subjectData$DoseUnit <- NULL
  subjectData$fileName <- NULL
  
  makeLongData <- function(entityData, resultTypes, splitTreatmentGroupsBy) {
    library('reshape')
    library('gdata')
    
    entityData$entityID <- seq(1,nrow(entityData))
    entityData$treatmentGroupID <- do.call(paste,entityData[,splitTreatmentGroupsBy])
    entityData$treatmentGroupID <- as.numeric(factor(entityData$treatmentGroupID))
    blankSpaces <- lapply(as.list(entityData), function(x) return (x != ""))
    emptyColumns <- unlist(lapply(blankSpaces, sum) == 0)
    resultTypes <- resultTypes[!(resultTypes$DataColumn %in% names(entityData)[emptyColumns]),]
    
    longResults <- reshape(entityData, idvar=c("id"), ids=row.names(entityData), v.names="UnparsedValue",
                           times=resultTypes$DataColumn, timevar="resultTypeAndUnit",
                           varying=list(resultTypes$DataColumn), direction="long", drop = names(entityData)[emptyColumns])
    
    # Add the extract result types information to the long format
    longResults$valueUnit <- resultTypes$Units[match(longResults$"resultTypeAndUnit",resultTypes$DataColumn)]
    longResults$concentration <- resultTypes$Conc[match(longResults$"resultTypeAndUnit",resultTypes$DataColumn)]
    longResults$concentrationUnit <- resultTypes$concUnits[match(longResults$"resultTypeAndUnit",resultTypes$DataColumn)]
    longResults$valueType <- resultTypes$valueType[match(longResults$"resultTypeAndUnit",resultTypes$DataColumn)]
    longResults$valueKind <- resultTypes$Type[match(longResults$"resultTypeAndUnit",resultTypes$DataColumn)]
    
    longResults$UnparsedValue <- trim(as.character(longResults$"UnparsedValue"))
    
    # Parse numeric data from the unparsed values
    matches <- is.na(suppressWarnings(as.numeric(gsub("^(>|<)(.*)", "\\2", gsub(",","",longResults$"UnparsedValue")))))
    longResults$numericValue <- longResults$"UnparsedValue"
    longResults$numericValue[matches] <- ""
    
    # Parse string values from the unparsed values
    longResults$stringValue <- as.character(longResults$"UnparsedValue")
    longResults$stringValue[!matches & longResults$valueType != "stringValue"] <- ""
    
    longResults$clobValue <- as.character(longResults$"UnparsedValue")
    longResults$clobValue[!longResults$valueType=="clobValue"] <- NA
    longResults$stringValue[longResults$valueType=="clobValue"] <- NA
    
    longResults$codeValue <- as.character(longResults$"UnparsedValue")
    longResults$codeValue[!longResults$valueType=="codeValue"] <- NA
    longResults$stringValue[longResults$valueType=="codeValue"] <- NA
    
    # Parse Operators from the unparsed value
    matchExpression <- ">|<"
    longResults$valueOperator <- longResults$numericValue
    matches <- gregexpr(matchExpression,longResults$numericValue)
    regmatches(longResults$valueOperator,matches, invert = TRUE) <- ""
    
    # Turn result values to numeric values
    longResults$numericValue <-  as.numeric(gsub(",","",gsub(matchExpression,"",longResults$numericValue)))
    
    # For the results marked as "stringValue":
    #   Set the Result Desc to the original value
    #   Clear the other categories
    longResults$numericValue[which(longResults$valueType=="stringValue")] <- rep(NA, sum(longResults$valueType=="stringValue"))
    longResults$valueOperator[which(longResults$valueType=="stringValue")] <- rep(NA, sum(longResults$valueType=="stringValue"))
    
    
    # For the results marked as "dateValue":
    #   Apply the function validateDate to each entry
    longResults$dateValue <- rep(NA, length(longResults$entityID))
    if (length(which(longResults$valueType=="dateValue")) > 0) {
      longResults$dateValue[which(longResults$valueType=="dateValue")] <- sapply(longResults$UnparsedValue[which(longResults$valueType=="dateValue")], FUN=validateDate)
    }
    longResults$numericValue[which(longResults$valueType=="dateValue")] <- rep(NA, sum(longResults$valueType=="dateValue"))
    longResults$valueOperator[which(longResults$valueType=="dateValue")] <- rep(NA, sum(longResults$valueType=="dateValue"))
    longResults$stringValue[which(longResults$valueType=="dateValue")] <- rep(NA, sum(longResults$valueType=="dateValue"))
    
    return(longResults)
  }
  meltedSubjectData <- makeLongData(subjectData, resultTypes=resultTypes, splitTreatmentGroupsBy=c("Dose","batchCode"))
  experiment <- fromJSON(getURL(paste0(racas::applicationSettings$client.service.persistence.fullpath,"experiments/",experimentId)))
  
  subjectData <- meltedSubjectData
  subjectData$subjectID <- subjectData$entityID
  subjectData$publicData <- TRUE
  
  subjectData$analysisGroupID <- subjectData$treatmentGroupID
  
  lsTransaction <- createLsTransaction(comments="Primary Analysis load")$id
  
  # Get a list of codes
  analysisGroupCodeNameList <- unlist(getAutoLabels(thingTypeAndKind="document_analysis group", 
                                             labelTypeAndKind="id_codeName",
                                             numberOfLabels=length(unique(subjectData$analysisGroupID))),
                                      use.names=FALSE)
                                             #numberOfLabels=length(analysisGroupData$batchName))
                                             #numberOfLabels=length(unique(analysisGroupData$batchName))) 
  
  subjectCodeNameList <- unlist(getAutoLabels(thingTypeAndKind="document_subject", 
                                       labelTypeAndKind="id_codeName", 
                                       numberOfLabels=length(unique(subjectData$entityID))),
                                use.names=FALSE)
  
  treatmentGroupCodeNameList <- unlist(getAutoLabels(thingTypeAndKind="document_treatment group", 
                                              labelTypeAndKind="id_codeName", 
                                              numberOfLabels=length(unique(subjectData$treatmentGroupID))),
                                       use.names=FALSE)
                                              #numberOfLabels=length(treatmentGroupData$batchName))
                                              #numberOfLabels=length(unique(treatmentGroupData$batchName)))
  
  recordedBy <- user
  experiment$lsStates <- NULL
  experiment$analysisGroups <- NULL
  analysisGroups <- lapply(FUN= createAnalysisGroup, X= analysisGroupCodeNameList,
                            recordedBy=recordedBy, lsTransaction=lsTransaction, experiment=experiment)
  
  savedAnalysisGroups <- saveAcasEntities(analysisGroups, "analysisgroups")
  
  analysisGroupIds <- sapply(savedAnalysisGroups, getElement, "id")
  
  subjectData$analysisGroupID <- analysisGroupIds[match(subjectData$analysisGroupID,1:length(analysisGroupIds))]
  
  subjectData$treatmentGroupCodeName <- treatmentGroupCodeNameList[subjectData$treatmentGroupID]
  
  createLocalTreatmentGroup <- function(subjectData) {
    return(createTreatmentGroup(
      analysisGroup=list(id=subjectData$analysisGroupID[1], version=0),
      codeName=subjectData$treatmentGroupCodeName[1],
      recordedBy=recordedBy,
      lsTransaction=lsTransaction))
  }
  
  treatmentGroups <- dlply(.data= subjectData, .variables= .(treatmentGroupID), .fun= createLocalTreatmentGroup)
  names(treatmentGroups) <- NULL
  
  savedTreatmentGroups <- saveAcasEntities(treatmentGroups, "treatmentgroups")
  
  treatmentGroupIds <- sapply(savedTreatmentGroups, getElement, "id")
  
  subjectData$treatmentGroupID <- treatmentGroupIds[subjectData$treatmentGroupID]
  
  # Subjects
  subjectData$subjectCodeName <- subjectCodeNameList[subjectData$subjectID]
  
  createRawOnlySubject <- function(subjectData) {
    return(createSubject(
      treatmentGroup=list(id=subjectData$treatmentGroupID[1],version=0),
      codeName=subjectData$subjectCodeName[1],
      recordedBy=recordedBy,
      lsTransaction=lsTransaction))
  }
  
  subjects <- dlply(.data= subjectData, .variables= .(subjectID), .fun= createRawOnlySubject)
  names(subjects) <- NULL
  
  savedSubjects <- saveAcasEntities(subjects, "subjects")
  
  subjectIds <- sapply(savedSubjects, getElement, "id")
  
  subjectData$subjectID <- subjectIds[subjectData$subjectID]
  
  ### Subject States ===============================================
  #######  
  
  stateGroupIndex <- 1
  subjectData$stateGroupIndex <- NA
  for (stateGroup in stateGroups) {
    includedRows <- subjectData$valueKind %in% stateGroup$valueKinds
    newRows <- subjectData[includedRows & !is.na(subjectData$stateGroupIndex), ]
    subjectData$stateGroupIndex[includedRows & is.na(subjectData$stateGroupIndex)] <- stateGroupIndex
    if (nrow(newRows)>0) newRows$stateGroupIndex <- stateGroupIndex
    subjectData <- rbind.fill(subjectData,newRows)
    stateGroupIndex <- stateGroupIndex + 1
  }
  
  othersGroupIndex <- which(sapply(stateGroups, FUN=getElement, "includesOthers"))
  if (length(othersGroupIndex) > 0) {  
    subjectData$stateGroupIndex[is.na(subjectData$stateGroupIndex)] <- othersGroupIndex
  }
  
  subjectData$stateID <- paste0(subjectData$subjectID, "-", subjectData$stateGroupIndex)
  
  stateAndVersion <- saveStatesFromLongFormat(subjectData, "subject", stateGroups, "stateID", recordedBy, lsTransaction)
  subjectData$stateID <- stateAndVersion$entityStateId
  subjectData$stateVersion <- stateAndVersion$entityStateVersion
  
  ### Subject Values ======================================================================= 
  batchCodeStateIndices <- which(sapply(stateGroups, getElement, "includesCorpName"))
  if (is.null(subjectData$stateVersion)) subjectData$stateVersion <- 0
  subjectDataWithBatchCodeRows <- rbind.fill(subjectData, meltBatchCodes(subjectData, batchCodeStateIndices))
  
  #
  #####  
  # Treatment Group states =========================================================================
  treatmentGroupIndex <- grep("treatment", sapply(stateGroups, getElement, "stateKind"))
  treatmentValueKinds <- stateGroups[[treatmentGroupIndex]]$valueKinds
  listedValueKinds <- do.call(c,lapply(stateGroups, getElement, "valueKinds"))
  otherValueKinds <- setdiff(unique(subjectData$valueKind),listedValueKinds)
  resultsDataValueKinds <- stateGroups[sapply(stateGroups, function(x) x$stateKind)=="results"][[1]]$valueKinds
  extraDataValueKinds <- stateGroups[sapply(stateGroups, function(x) x$stateKind)=="plate information"][[1]]$valueKinds
  treatmentDataValueKinds <- c(treatmentValueKinds, otherValueKinds, resultsDataValueKinds, extraDataValueKinds)
  excludedSubjects <- subjectData$subjectID[subjectData$valueKind == "Exclude"]
  treatmentDataStart <- subjectData[subjectData$valueKind %in% treatmentDataValueKinds 
                                    & !(subjectData$subjectID %in% excludedSubjects),]
  
  createRawOnlyTreatmentGroupData <- function(subjectData) {
    isGreaterThan <- any(subjectData$valueOperator==">", na.rm=TRUE)
    isLessThan <- any(subjectData$valueOperator=="<", na.rm=TRUE)
    if(isGreaterThan && isLessThan) {
      resultOperator <- "<>"
      resultValue <- NA
    } else if (isGreaterThan) {
      resultOperator <- ">"
      resultValue <- max(subjectData$numericValue)
    } else if (isLessThan) {
      resultOperator <- "<"
      resultValue <- min(subjectData$numericValue)
    } else {
      resultOperator <- NA
      resultValue <- mean(subjectData$numericValue)
    }
    return(data.frame(
      "batchCode" = subjectData$batchCode[1],
      "valueKind" = subjectData$valueKind[1],
      "valueUnit" = subjectData$valueUnit[1],
      "numericValue" = resultValue,
      "stringValue" = if (length(unique(subjectData$stringValue)) == 1) {subjectData$stringValue[1]}
      else if (all(subjectData$stringValue %in% c("yes", "no"))) {"sometimes"}
      else if (is.nan(resultValue)) {'NA'}
      else {NA},
      "valueOperator" = resultOperator,
      "dateValue" = if (length(unique(subjectData$dateValue)) == 1) subjectData$dateValue[1] else NA,
      "publicData" = subjectData$publicData[1],
      treatmentGroupID = subjectData$treatmentGroupID[1],
      analysisGroupID = subjectData$analysisGroupID[1],
      stateGroupIndex = subjectData$stateGroupIndex[1],
      stateID = subjectData$stateID[1],
      stateVersion = subjectData$stateVersion[1],
      valueType = subjectData$valueType[1],
      numberOfReplicates = nrow(subjectData),
      uncertaintyType = if(is.numeric(resultValue)) "standard deviation" else NA,
      uncertainty = sd(subjectData$numericValue),
      stringsAsFactors=FALSE))
  }
  
  treatmentGroupData <- ddply(.data = treatmentDataStart, .variables = c("treatmentGroupID", "resultTypeAndUnit", "stateGroupIndex"), .fun = createRawOnlyTreatmentGroupData)
  
  treatmentGroupIndices <- c(treatmentGroupIndex,othersGroupIndex)
  
  stateAndVersion <- saveStatesFromLongFormat(entityData = treatmentGroupData, 
                                              entityKind = "treatmentgroup", 
                                              stateGroups = stateGroups,
                                              stateGroupIndices = treatmentGroupIndices,
                                              idColumn = "stateID",
                                              recordedBy = recordedBy,
                                              lsTransaction = lsTransaction)
  
  treatmentGroupData$stateID <- stateAndVersion$entityStateId
  treatmentGroupData$stateVersion <- stateAndVersion$entityStateVersion
  
  treatmentGroupData$treatmentGroupStateID <- treatmentGroupData$stateID
  
  #### Treatment Group Values =====================================================================
  batchCodeStateIndices <- which(sapply(stateGroups, function(x) return(x$includesCorpName)))
  if (is.null(treatmentGroupData$stateVersion)) treatmentGroupData$stateVersion <- 0
  
  treatmentGroupDataWithBatchCodeRows <- rbind.fill(treatmentGroupData, meltBatchCodes(treatmentGroupData, batchCodeStateIndices))
  
  savedTreatmentGroupValues <- saveValuesFromLongFormat(entityData = treatmentGroupDataWithBatchCodeRows, 
                                                        entityKind = "treatmentgroup", 
                                                        stateGroups = stateGroups, 
                                                        stateGroupIndices = treatmentGroupIndices, 
                                                        lsTransaction = lsTransaction,
                                                        recordedBy=recordedBy)

  analysisGroupIndices <- which(sapply(stateGroups, function(x) {x$entityKind})=="analysis group")
  if (length(analysisGroupIndices > 0)) {
    analysisGroupData <- treatmentGroupDataWithBatchCodeRows
    analysisGroupData$stateID <- paste0(analysisGroupData$analysisGroupID, "-", analysisGroupData$stateGroupIndex)
    
    #TODO: missing batch codes
    stateAndVersion <- saveStatesFromLongFormat(entityData = analysisGroupData, 
                                                entityKind = "analysisgroup", 
                                                stateGroups = stateGroups,
                                                stateGroupIndices = analysisGroupIndices,
                                                idColumn = "stateID",
                                                recordedBy = recordedBy,
                                                lsTransaction = lsTransaction)
    
    analysisGroupData$stateID <- stateAndVersion$entityStateId
    analysisGroupData$stateVersion <- stateAndVersion$entityStateVersion
    
    analysisGroupData$analysisGroupStateID <- analysisGroupData$stateID
    
    #### Analysis Group Values =====================================================================
    savedAnalysisGroupValues <- saveValuesFromLongFormat(entityData = analysisGroupData, 
                                                         entityKind = "analysisgroup", 
                                                         stateGroups = stateGroups, 
                                                         stateGroupIndices = analysisGroupIndices,
                                                         lsTransaction = lsTransaction,
                                                         recordedBy = recordedBy)
  }
  
  return(lsTransaction)
}
validateBarcode <- function(barcode, filePath) {
  # Checks that the barcode inside the file matches the one in the file path
  # Returns the barcode inside the file name
  fileNameBarcode <- gsub(".+_([^/]+)_[^/]+$", "\\1", filePath)
  if (fileNameBarcode == filePath) {
    fileName <- gsub(".+/([^/]+)+$", "\\1", filePath)
    warning("No barcode could be found between underscores in ", fileName, ", so the barcode inside the file will be used")
    return (barcode)
  }
  if (fileNameBarcode != barcode) {
    fileName <- gsub(".+/([^/]+)+$", "\\1", filePath)
    warning(paste0("The barcode '", barcode, "' inside the file ", fileName, 
                   " was replaced by the barcode '", fileNameBarcode, "'"))
  }
  return(fileNameBarcode)
}
validateInputFiles <- function(dataDirectory) {
  # Validates and organizes the names of the input files
  #
  # Args:
  #   dataDirectory:      A string that is a path to a folder full of files
  # Returns:
  #   A data.frame with one column for each type of file: stat1, stat2, seq
  #     Files are organized alphabetically in rows
  
  
  #possible errors:
  #lack of protocol
  #no files
  #uneven files (no match or different lengths)
  #save(dataDirectory, file="dataDirectory.Rda")
  #collect the names of files
  fileList <- list.files(path = dataDirectory, pattern = "\\.stat[^\\.]*", full.names = TRUE)
  seqFileList <- list.files(path = dataDirectory, pattern = "\\.seq\\d$", full.names = TRUE)
  
  # the program exits when there are no files
  if (length(fileList) == 0) {
    stop("No files found")
  }
  
  stat1List <- grep("\\.stat1$", fileList, value="TRUE")
  stat2List <- grep("\\.stat2$", fileList, value="TRUE")
  
  if (length(stat1List) != length(stat2List) | length(stat1List) != length(seqFileList)) {
    stop("Number of Maximum and Minimum and sequence files do not match")
  }
  
  fileNameTable <- data.frame(stat1= sort(stat1List),
                              stat2= sort(stat2List),
                              seq= sort(seqFileList))

  checkSameName <- function(x) {
    # This function is used below, it checks that all columns have the same name
    firstName <- gsub(pattern="\\.stat1$",replacement="",x[1])
    return(gsub("\\.stat2$","",x[2])==firstName && gsub("\\.seq1$","",x[2])==firstName)
  }
  
  # TODO: tell user which ones
  if (any(apply(fileNameTable,1,checkSameName))) {
    stop("File names do not match")
  }
  
  return(fileNameTable)
}
findFluorescents <- function(seqData) {
  # Finds fluorescent compounds by initial slope
  #
  # Args:
  #   sequenceFile: a path to a sequence file
  # Returns:
  #   A character vector of well names
  
  fluorescentRows <- (seqData[13, ] - seqData[9, ]) > 100
  
  fluorescentRowNums <- which(fluorescentRows)
  
  fluorescentRowCoordinates <- names(seqData)[fluorescentRowNums]
  
  return(fluorescentRowCoordinates)
}
combineFiles <- function(fileSet) {
  # Takes a set of stat1, stat2, and seq files and merges them
  #
  # Args:
  #   fileSet: a list of files which inclues stat1, stat2, and seq files
  # Returns:
  #   A data.frame with columns stat1, stat2, and seq files in sorted columns
  
  stat1Frame <- parseStatFile(as.character(fileSet[1]))
  stat2Frame <- parseStatFile(as.character(fileSet[2]))
  seqData <- parseSeqFile(as.character(fileSet[3]))
  
  fluorescentList <- findFluorescents(seqData)
  allStatFrame <- merge(stat1Frame,stat2Frame)
  allStatFrame$fluorescent <- allStatFrame$well %in% fluorescentList
  
  timeValues <- gsub("X","", row.names(seqData))
  allStatFrame$timePoints <- paste(timeValues, collapse = "\t")
  allStatFrame$sequence <- unlist(lapply(seqData[,as.character(allStatFrame$well)], paste, collapse="\t"),use.names=FALSE)
  return(allStatFrame)
}
parseStatFile <- function(fileName) {
  # Parses a stat file
  #
  # Args:
  #   fileName:   the path to a file
  #
  # Returns:
  #   A data.frame with four columns:
  #     "barcode":    barcode of source plate
  #     "well":       well names of source
  #     Statistic:    the values for each well (name taken from the parameters of the stat file)
  #     "fileName":  the path the to source file without the extension
  
  rawLines <- readLines(fileName)
  
  # The first line of the plate grid are the column headers and starts with  \t1
  columnsHeaderLine <- grep("^\t1", rawLines)
  
  # The first line of the user requested paramters
  userParamsLine <- grep("*User Requested Parameters*", rawLines)
  
  # Now collect all non-data lines
  paramLines <- c(rawLines[1:(columnsHeaderLine-1)], rawLines[(userParamsLine+1):length(rawLines)])
  paramLines <- unlist(strsplit(paramLines, "\t"))
  # Find last data array line
  #TODO, make this more robust
  lastLineOfData <- userParamsLine-2
  
  # Get the data
  mainData <- read.table(
    fileName,
    sep="\t",
    skip=columnsHeaderLine-1,
    nrows=lastLineOfData-columnsHeaderLine,
    header=TRUE,
    row.names=1
  )
  # all the rows end in \t, so I need to kill the last column
  
  mainData <- mainData[,!(names(mainData) %in% "X.1")]
  
  barcode <- getParamByKey(paramLines, "Source Plate 2 Barcode")
  readName <- getParamByKey(paramLines, "Statistic")
  startRead <- getParamByKey(paramLines, "Start Sample")
  endRead <- getParamByKey(paramLines, "End Sample")
  
  barcode <- validateBarcode(barcode, fileName)
  
  statData <- makeDataFrameOfWellsGrid(mainData, barcode, readName)
  statData$fileName <- gsub("(.*)\\.stat.$","\\1",fileName)
  if (readName == "Maximum") {
    statData$startReadMax <- startRead
    statData$endReadMax <- endRead
  } else if (readName == "Minimum") {
    statData$startReadMin <- startRead
    statData$endReadMin <- endRead
  } else {
    stop (paste("Unknown Statistic in ", fileName))
  }
  
  return(statData)
}
parseSeqFile <- function(fileName) {
  # Parses a seq file
  #
  # Args:
  #   fileName:   the path to a file
  #
  # Returns:
  #   A data.frame with a column for each well
  
  inputData <- read.delim(file=fileName, as.is=TRUE)
  intermediateMatrix <- t(inputData[5:75])
  outputData <- as.data.frame(intermediateMatrix[1:nrow(intermediateMatrix)>1,], stringsAsFactors = FALSE)
  names(outputData) <- normalizeWellNames(intermediateMatrix[1,])
  outputData[] <- lapply(outputData, as.numeric)
  
  return(outputData)
}
normalizeWellNames <- function(wellName) {
  # Turns A1 into A01
  #
  # Args:
  #   wellName:     a charcter vector
  # Returns:
  #   a character vector
  
  return(gsub("(\\D)(\\d)$","\\10\\2",wellName))
}
getContainers <- function() {
  # Currently not used, may be removed
  #TODO: this should take in the barcodes of the containers and output a list of containers
  containerList <- list(fromJSON(getURL("http://suse.labsynch.com:8080/acas/containers/2796")),
                        fromJSON(getURL("http://suse.labsynch.com:8080/acas/containers/2797")))
  return(containerList)
}
saveFileLocations <- function (rawResultsLocation, resultsLocation, pdfLocation, experiment, dryRun, recordedBy, lsTransaction) {
  # Saves the locations of the results, pdf, and raw R resultTable as experiment values
  #
  # Args:
  #   rawResultsLocation:   A string of the file location where the raw R resultTable is located
  #   resultsLocation:      A string of the results csv location
  #   pdfLocation:          A string of the pdf summary report location
  #   experiment:       A list that is an experiment
  #
  # Returns:
  #   NULL
  
  locationState <- experiment$lsStates[lapply(experiment$lsStates,getElement,"lsKind")=="report locations"]
  
  if (length(locationState)> 0) {
    locationState <- locationState[[1]]
     
    valueKinds <- lapply(locationState$lsValues,getElement,"lsKind")
    
    valuesToDelete <- locationState$lsValues[valueKinds %in% c("raw r results location","summary location","data results location")]
    
    lapply(valuesToDelete, deleteExperimentValue)
  } else {
    locationState <- createExperimentState(
      recordedBy = recordedBy,
      experiment = experiment,
      lsType = "metadata",
      lsKind = "report locations",
      lsTransaction=lsTransaction)
    
    locationState <- saveExperimentState(locationState)
  }
    
  tryCatch({
    
    rawLocationValue <- createStateValue(
      lsType = "fileValue",
      lsKind = "raw r results location",
      fileValue = rawResultsLocation,
      lsState = locationState)
    
    resultsLocationValue <- createStateValue(
      lsType = "fileValue",
      lsKind = "data results location",
      fileValue = resultsLocation,
      lsState = locationState)
    
    pdfLocationValue <- createStateValue(
      lsType = "fileValue",
      lsKind = "summary location",
      fileValue = pdfLocation,
      lsState = locationState)
    
    saveExperimentValues(list(rawLocationValue,resultsLocationValue,pdfLocationValue))
  }, error = function(e) {
    stop("Could not save the summary and result locations")
  })


  
  return(NULL)
}
getExperimentParameters <- function(inputParameters) {
  # Gets experiment parameters
  #
  # Args:
  #   inputParameters:       A json string that has the experiment parameters
  # Returns:
  #   a list with 
  #     $positiveControl
  #     $positiveControl$batchCode
  #     $positiveControl$concentration
  #     $positiveControl$conentrationUnits
  #     $negativeControl
  #     $negativeControl$batchCode
  #     $negativeControl$concentration
  #     $negativeControl$concentrationUnits
  #     $agonistControl
  #     $agonistControl$batchCode
  #     $agonistControl$concentration
  #     $agonistControl$concentrationUnits
  #     $vehicleControl
  #     $vehicleControl$batchCode
  #     $vehicleControl$concentration
  #     $vehicleControl$concentrationUnits
  #     $transformationRule
  #     $normalizationRule
  #     $hitEfficacyThreshold
  #     $hitSDThreshold
  #     $thresholdType
  
  parameters <- fromJSON(inputParameters)
  
  return(parameters)
}
getExperimentById <- function(experimentId) {
  # Gets experiment given an id
  #
  # Args:
  #   experimentId:     An integer of the experiment Id
  # Returns:
  #   a list that is an experiment
  
  require('RCurl')
  require('rjson')
  
  experiment <- NULL
  tryCatch({
    experiment <- getURL(paste0(racas::applicationSettings$client.service.persistence.fullpath,"experiments/", experimentId))
    experiment <- fromJSON(experiment)
  }, error = function(e) {
    stop("Could not get experiment ", experimentId, " from the server")
  })
  return(experiment)
}
setAnalysisStatus <- function(status, metadataState) {
  # Sets the analysis status
  #
  # Args:
  #   status:         A string to set the analysis status
  #   metadataState:  A list that is a state that has a value of type "analysis status"
  # Returns:
  #   NULL
  
  valueKinds <- lapply(metadataState$lsValues,getElement,"lsKind")
  
  valuesToDelete <- metadataState$lsValues[valueKinds == "analysis status"]
  
  tryCatch({
    lapply(valuesToDelete, deleteExperimentValue)
    
    statusValue <- createStateValue(
      lsType = "stringValue",
      lsKind = "analysis status",
      stringValue = status,
      lsState = metadataState)
    
    saveExperimentValues(list(statusValue))
  }, error = function(e) {
    stop("Could not save the experiment status")
  })
  return(NULL)
}
computeNormalized  <- function(values, wellType) {
  # Computes normalized version of the given values based on the positive and negative controls included
  #
  # Args:
  #   values:   A vector of numeric values
  #   wellType: A vector of the same length as values which marks the type of each
  # Returns:
  #   A numeric vector of the same length as the inputs that is normalized
  
  #find min (mean of Negative Controls)
  minLevel <- mean(values[(wellType=='NC')])
  #find max (mean of Positive Controls)
  maxLevel <- mean(values[(wellType=='PC')])
  
  return((values - minLevel) / (maxLevel - minLevel))
}

####### Main function
runMain <- function(folderToParse, user, dryRun, testMode, experimentId, inputParameters) {
  # Runs main functions that are inside the tryCatch.W.E
  
  require("data.table")
  
  experiment <- getExperimentById(experimentId)
  
  metadataState <- experiment$lsStates[lapply(experiment$lsStates,getElement,"lsKind")=="experiment metadata"][[1]]
  
  if(!dryRun) {
    setAnalysisStatus(status="parsing", metadataState)
  }
  
  parameters <- getExperimentParameters(inputParameters)
  
  dir.create("serverOnlyModules/blueimp-file-upload-node/public/files/experiments", showWarnings = FALSE)
  dir.create(paste0("serverOnlyModules/blueimp-file-upload-node/public/files/experiments/",experiment$codeName), showWarnings = FALSE)
  
  # If the folderToParse is actually a zip file
  if (!file.info(folderToParse)$isdir) {
    if(!grepl("\\.zip$", folderToParse)) {
      stop("The file provided must be a zip file or a directory")
    }
    filesLocation <- paste0("serverOnlyModules/blueimp-file-upload-node/public/files/experiments/",experiment$codeName, "/rawData")
    
    dir.create(filesLocation, showWarnings = FALSE)
    
    oldFiles <- as.list(paste0(filesLocation,"/",list.files(filesLocation)))
    
    do.call(unlink, list(oldFiles, recursive=T))
    
    unzip(zipfile=folderToParse, exdir=paste0("serverOnlyModules/blueimp-file-upload-node/public/files/experiments/",experiment$codeName, "/rawData"))
    folderToParse <- paste0("serverOnlyModules/blueimp-file-upload-node/public/files/experiments/",experiment$codeName, "/rawData")
  } 
 
  fileNameTable <- validateInputFiles(folderToParse)
  
  # TODO maybe: http://stackoverflow.com/questions/2209258/merge-several-data-frames-into-one-data-frame-with-a-loop/2209371
  
  resultList <- apply(fileNameTable,1,combineFiles)
  resultTable <- as.data.table(do.call("rbind",resultList))
  barcodeList <- levels(resultTable$barcode)
  
  wellTable <- createWellTable(barcodeList, testMode)
  
  batchNamesAndConcentrations <- getBatchNamesAndConcentrations(resultTable$barcode, resultTable$well, wellTable, parameters$agonistControl)
  resultTable <- cbind(resultTable,batchNamesAndConcentrations)
  
  resultTable$wellType <- getWellTypes(resultTable$batchName, resultTable$concentration, resultTable$concUnit, parameters$positiveControl, parameters$negativeControl)
  
  #calculations
  resultTable$transformed <- computeTransformedResults(resultTable, parameters$transformation)
  
  # normalization
  normalization <- "plate order"
  if (normalization=="plate order") {
    resultTable[,normalized:=computeNormalized(transformed,wellType), by= barcode]
  } else if (normalization=="row order") {
    resultTable[,plateRow:=gsub("\\d", "",well)]
    resultTable[,normalized:=computeNormalized(transformed,wellType), by= list(barcode,plateRow)]
  } else {
    resultTable$normalized <- resultTable$transformed
  }
  
  meanValue <- mean(resultTable$normalized[resultTable$wellType == "test"])
  sdValue <- sd(resultTable$normalized[resultTable$wellType == "test"])
  resultTable$sdScore <- computeSDScore(resultTable$normalized, meanValue, sdValue)
  
  #maxTime is the point used by the stat1/2 files, overallMaxTime includes points outside of that range
  resultTable[, index:=1:nrow(resultTable)]
  resultTable[, maxTime:=as.numeric(unlist(strsplit(timePoints, "\t"))[which.max(as.numeric(unlist(strsplit(sequence, "\t")))[startReadMax:endReadMax]) + as.integer(startReadMax) - 1L]), by = index]
  resultTable[, overallMaxTime:=as.numeric(unlist(strsplit(timePoints, "\t"))[which.max(as.numeric(unlist(strsplit(sequence, "\t"))))]), by = index]
  
  #TODO: remove once real data is in place
  if (any(is.na(resultTable$batchName))) {
    warning("Some wells did not have recorded contents in the database- they will be skipped. Make sure all transfers have been loaded.")
    resultTable <- resultTable[!is.na(resultTable$batchName), ]
  }
  
  batchDataTable <- data.table(values = resultTable$normalized, 
                               batchName = resultTable$batchName,
                               fluorescent = resultTable$fluorescent,
                               sdScore = resultTable$sdScore,
                               wellType = resultTable$wellType,
                               barcode = resultTable$barcode,
                               maxTime = resultTable$maxTime,
                               overallMaxTime = resultTable$overallMaxTime)
  
  aggregateReplicates <- "no"
  if (aggregateReplicates == "across plates") {
    treatmentGroupData <- batchDataTable[, list(groupMean = mean(values), 
                                                stDev = sd(values), n=length(values), 
                                                sdScore = mean(sdScore)),
                                         by=list(batchName,fluorescent,concentration,concUnit)]
  } else if (aggregateReplicates == "within plates") {
    treatmentGroupData <- batchDataTable[, list(groupMean = mean(values), 
                                                stDev = sd(values), 
                                                n=length(values),
                                                sdScore = mean(sdScore)),  
                                         by=list(batchName,fluorescent,barcode,concentration,concUnit)]
  } else {
    treatmentGroupData <- batchDataTable[, list(batchName = batchName, 
                                                fluorescent = fluorescent, 
                                                wellType = wellType, 
                                                groupMean = values, 
                                                stDev = NA, 
                                                n = 1, 
                                                sdScore = sdScore,
                                                maxTime = maxTime,
                                                overallMaxTime = overallMaxTime)]
  }
  treatmentGroupData$treatmentGroupId <- 1:nrow(treatmentGroupData)
  
  analysisType <- "primary"
  if (analysisType == "primary") {
    analysisGroupData <- treatmentGroupData
    analysisGroupData$analysisGroupId <- treatmentGroupData$treatmentGroupId
  } else if (analysisType == "confirmation" || analysisType == "dose response") {
    analysisGroupData <- treatmentGroupData
    analysisGroupData$analysisGroupId <- as.numeric(factor(analysisGroupData$batchName))
  }
  
  hitSelection <- parameters$thresholdType #Other choice is "efficacyThreshold"
  if (hitSelection == "sd") {
    efficacyThreshold <- meanValue + sdValue * parameters$hitSDThreshold
  } else {
    efficacyThreshold <- parameters$hitEfficacyThreshold
  }
  #analysisGroupData$threshold <- analysisGroupData$sdScore > parameters$hitSDThreshold & !analysisGroupData$fluorescent & analysisGroupData$wellType=="test"
  analysisGroupData$latePeak <- (analysisGroupData$overallMaxTime > 80) & 
    (analysisGroupData$groupMean > efficacyThreshold) & !analysisGroupData$fluorescent
  analysisGroupData$threshold <- analysisGroupData$groupMean > efficacyThreshold & !analysisGroupData$fluorescent & 
    analysisGroupData$wellType=="test" & !analysisGroupData$latePeak
  
  summaryInfo <- list(
    info = list(
      "Sweetener" = parameters$agonist$batchCode,
      "Plates analyzed" = paste0(length(unique(resultTable$barcode)), " plates:\n  ", paste(unique(resultTable$barcode), collapse = "\n  ")),
      "Compounds analyzed" = length(unique(resultTable$batchName)),
      "Hits" = sum(analysisGroupData$threshold),
      "Threshold" = signif(efficacyThreshold, 3),
      "SD Threshold" = ifelse(hitSelection == "sd", parameters$hitSDThreshold, "NA"),
      "Fluorescent compounds" = sum(resultTable$fluorescent),
      "Z'" = format(computeZPrime(resultTable$transformed[resultTable$wellType=="PC"], resultTable$transformed[resultTable$wellType=="NC"]),digits=3,nsmall=3),
      "Robust Z'" = format(computeRobustZPrime(resultTable$transformed[resultTable$wellType=="PC"], resultTable$transformed[resultTable$wellType=="NC"]),digits=3,nsmall=3),
      "Z" = format(computeZPrime(resultTable$transformed[resultTable$wellType=="PC"], resultTable$transformed[resultTable$wellType=="test" & !resultTable$fluorescent]),digits=3,nsmall=3),
      "Robust Z" = format(computeRobustZPrime(resultTable$transformed[resultTable$wellType=="PC"], resultTable$transformed[resultTable$wellType=="test"& !resultTable$fluorescent]),digits=3,nsmall=3),
      "Date analysis run" = format(Sys.time(), "%a %b %d %X %z %Y")
    )
  )
  
  lsTransaction <- NULL
  
  if (dryRun) {
    save(experiment, file="experiment.Rda")
  } else {
    lsTransaction <- createLsTransaction()$id
    dir.create(paste0("serverOnlyModules/blueimp-file-upload-node/public/files/experiments/",experiment$codeName,"/analysis"), showWarnings = FALSE)
    
    deleteExperimentAnalysisGroups <- function(experiment, lsServerURL = racas::applicationSettings$client.service.persistence.fullpath){
      response <- getURL(
        paste0(lsServerURL, "experiments/",experiment$id, "?with=analysisgroups"),
        customrequest='DELETE',
        httpheader=c('Content-Type'='application/json'),
        postfields=toJSON(experiment))
      if(response!="") {
        stop (paste("The loader was unable to delete the old experiment's analysis groups."))
      }
      return(response)
    }
    
    deleteExperimentAnalysisGroups(experiment)
    
    # Get the late peak points
    resultTable$latePeak <- (resultTable$overallMaxTime > 80) & 
      (resultTable$normalized > efficacyThreshold) & !resultTable$fluorescent
    # Get individual points that are greater than the threshold
    resultTable$threshold <- (resultTable$normalized > efficacyThreshold) & !resultTable$fluorescent & 
      resultTable$wellType=="test" & !resultTable$latePeak
    
    rawResultsLocation <- paste0("experiments/",experiment$codeName,"/analysis/rawResults.Rda")
    save(resultTable,parameters,file=paste0("serverOnlyModules/blueimp-file-upload-node/public/files/",rawResultsLocation))
    
    resultsLocation <- paste0("experiments/", experiment$codeName,"/analysis/",experiment$codeName, "_Results.csv")
    if (analysisType == "primary") {
      # May need to return to using analysisGroupData eventually
      outputTable <- data.table("Corporate Batch ID" = resultTable$batchName, "Barcode" = resultTable$barcode,
                                "Well" = resultTable$well, "Hit" = ifelse(resultTable$threshold, "yes", "no"),
                                "SD Score" = resultTable$sdScore, "Normalized Activity" = resultTable$normalized,
                                "Activity" = resultTable$transformed, 
                                "Fluorescent"= ifelse(resultTable$fluorescent, "yes", "no"),
                                "Max Time (s)" = resultTable$maxTime, "Well Type" = resultTable$wellType,
                                "Late Peak" = ifelse(resultTable$latePeak, "yes", "no"))
    }
    outputTable <- outputTable[order(Hit,Fluorescent,decreasing=TRUE)]
    write.csv(outputTable, paste0("serverOnlyModules/blueimp-file-upload-node/public/files/", resultsLocation), row.names=FALSE)
    
    pdfLocation <- createPDF(resultTable, analysisGroupData, parameters, summaryInfo, 
                             threshold = efficacyThreshold, experiment)
    
    #save(resultTable, treatmentGroupData, analysisGroupData, file = "test2.Rda")
    
    lsTransaction <- saveData(subjectData = resultTable, treatmentGroupData, analysisGroupData, user, experimentId)
    
    saveFileLocations(rawResultsLocation, resultsLocation, pdfLocation, experiment, dryRun, user, lsTransaction)
    
    #TODO: allow saving in an external file service
    summaryInfo$info$"Summary" <- paste0('<a href="', racas::applicationSettings$client.host, 
                                         ":", racas::applicationSettings$client.service.file.port,
                                         '/files/experiments/', experiment$codeName,"/analysis/", 
                                         experiment$codeName,'_Summary.pdf" target="_blank">Summary</a>')
                                         
    summaryInfo$info$"Results" <- paste0('<a href="', racas::applicationSettings$client.host, 
                                         ":", racas::applicationSettings$client.service.file.port,
                                         '/files/experiments/', experiment$codeName,"/analysis/", 
                                         experiment$codeName,'_Results.csv" target="_blank">Results</a>')
  }
  
  summaryInfo$lsTransactionId <- lsTransaction
  summaryInfo$experiment <- experiment
  
  return(summaryInfo)
}
runPrimaryAnalysis <- function(request) {
  # Highest level function, runs everything else
  save(request, file = "request.Rda")
  require('racas')
  
  request <- as.list(request)
  experimentId <- request$primaryAnalysisExperimentId
  folderToParse <- request$fileToParse
  dryRun <- request$dryRunMode
  user <- request$user
  testMode <- request$testMode
  inputParameters <- request$inputParameters
  # Fix capitalization mismatch between R and javascript
  dryRun <- interpretJSONBoolean(dryRun)
  #testMode <- interpretJSONBoolean(testMode)
  
  # Set up the error handling for non-fatal errors, and add it to the search path (almost like a global variable)
  errorHandlingBox <- list(errorList = list())
  attach(errorHandlingBox)
  # If there is a global defined by another R code, this will overwrite it
  errorList <<- list()
  
  loadResult <- tryCatch.W.E(runMain(folderToParse, user, dryRun, testMode, experimentId, inputParameters))
  
  # If the output has class simpleError or is not a list, save it as an error
  if(class(loadResult$value)[1]=="simpleError") {
    errorList <- c(errorList,list(loadResult$value$message))
    loadResult$value <- NULL
  } else if (sum(class(loadResult$value)=="SQLException")>0) {
    errorList <- c(errorList,list(paste0("There was an error in connecting to the SQL server ", 
                                         racas::applicationSettings$erver.database.url, ":", 
                                         as.character(loadResult$value), ". Please contact your system administrator.")))
    loadResult$value <- NULL
  } else if (sum(class(loadResult$value)=="error")>0 || class(loadResult$value)!="list") {
    errorList <- c(errorList,list(as.character(loadResult$value)))
    loadResult$value <- NULL
  }
  
  # Save warning messages but not the function call, which is only useful while programming
  loadResult$warningList <- lapply(loadResult$warningList, getElement, "message")
  if (length(loadResult$warningList)>0) {
    loadResult$warningList <- strsplit(unlist(loadResult$warningList),"\n")
  }
  
  # Organize the error outputs
  loadResult$errorList <- errorList
  hasError <- length(errorList) > 0
  hasWarning <- length(loadResult$warningList) > 0
  
  errorMessages <- list()
  
  # This is code that could put the error and warning messages into a format that is displayed at the bottom of the screen
  for (singleError in errorList) {
    errorMessages <- c(errorMessages, list(list(errorLevel="error", message=singleError)))
  }
  
  for (singleWarning in loadResult$warningList) {
    errorMessages <- c(errorMessages, list(list(errorLevel="warning", message=singleWarning)))
  }
  #   
  #   errorMessages <- c(errorMessages, list(list(errorLevel="info", message=countInfo)))
  #   
  
  # Create the HTML to display
  htmlSummary <- createHtmlSummary(hasError,errorList,hasWarning,loadResult$warningList,summaryInfo=loadResult$value,dryRun)
  
  # Detach the box for error handling
  detach(errorHandlingBox)
  
  tryCatch({
    if(is.null(loadResult$value$experiment)) {
      experiment <- fromJSON(getURL(paste0(racas::applicationSettings$client.service.persistence.fullpath,"experiments/",experimentId)))
    } else {
      experiment <- loadResult$value$experiment
    }
    if(!dryRun) {
      htmlSummary <- saveAnalysisResults(experiment, hasError, htmlSummary)
    }
  }, error= function(e) {
    htmlSummary <- paste(htmlSummary, "<p>Could not get the experiment</p>")  
  })
  
  # Return the output structure
  response <- list(
    commit= (!dryRun & !hasError),
    transactionId = loadResult$value$lsTransactionId,
    results= list(
      path= getwd(),
      folderToParse= folderToParse,
      dryRun= dryRun,
      htmlSummary= htmlSummary
    ),
    hasError= hasError,
    hasWarning= hasWarning,
    errorMessages= errorMessages)
  return(response)
}
  
  
  
# Next up:
# make three more (four total) stat1 and stat2 files, new barcodes, change numbers slightly (done)
# make fake multi-plate data
# normalize by plate (done)
# calculate SD score (done)
# calculate Z' (done)
# threshold by efficacy (done)
# threshold by SD (done)
# save results
# send results to requestor
# Finish other TODO items
