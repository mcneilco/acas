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
# Done but not saving or plotting: Allow aggregation by plate and across plates (break treatment groups on compound and concentration)
# New Data
# Analyze Dose Response
# Do we want a graph of raw data or treatment groups? (for confirmation and dose response) raw data
# Throw a warning when repeat run done on same barcode (this might be hard)

# How to run a test
# Confirmation - Check that createWellTable is getting correct csv in testMode
# file.copy("public/src/modules/PrimaryScreen/spec/ConfirmationRegression.zip", "privateUploads/", overwrite=T)
# library(rjson)
# request = fromJSON('{\"fileToParse\":\"ConfirmationRegression.zip\",\"reportFile\":\"\",\"dryRunMode\":\"true\",\"user\":\"bob\",\"inputParameters\":\"{\\\"positiveControl\\\":{\\\"batchCode\\\":\\\"RD36882\\\",\\\"concentration\\\":2,\\\"concentrationUnits\\\":\\\"uM\\\",\\\"includeAgonist\\\":\\\"true\\\"},\\\"negativeControl\\\":{\\\"batchCode\\\":\\\"DMSO\\\",\\\"concentration\\\":null,\\\"concentrationUnits\\\":\\\"uM\\\",\\\"includeAgonist\\\":\\\"true\\\"},\\\"agonistControl\\\":{\\\"batchCode\\\":\\\"SUGAR\\\",\\\"concentration\\\":20,\\\"concentrationUnits\\\":\\\"uM\\\"},\\\"vehicleControl\\\":{\\\"batchCode\\\":\\\"PBS\\\",\\\"concentration\\\":null,\\\"concentrationUnits\\\":null},\\\"transformationRule\\\":\\\"(maximum-minimum)/minimum\\\",\\\"normalizationRule\\\":\\\"plate order\\\",\\\"hitEfficacyThreshold\\\":0.8,\\\"hitSDThreshold\\\":5,\\\"thresholdType\\\":\\\"efficacy\\\",\\\"aggregateReplicates\\\":\\\"within plates\\\",\\\"dilutionRatio\\\":1}\",\"primaryAnalysisExperimentId\":\"6507\",\"testMode\":\"true\"}')
# runPrimaryAnalysis(request)
# request$dryRunMode <- FALSE
# runPrimaryAnalysis(request)


# file.copy("public/src/modules/PrimaryScreen/spec/SinglePointRegression.zip", "privateUploads/", overwrite=T)
# request = fromJSON('{\"fileToParse\":\"SinglePointRegression.zip\",\"reportFile\":\"\",\"dryRunMode\":\"true\",\"user\":\"bob\",\"inputParameters\":\"{\\\"positiveControl\\\":{\\\"batchCode\\\":\\\"CMPD-0000006-1\\\",\\\"concentration\\\":2,\\\"concentrationUnits\\\":\\\"uM\\\"},\\\"negativeControl\\\":{\\\"batchCode\\\":\\\"CMPD-0000001-1\\\",\\\"concentration\\\":null,\\\"concentrationUnits\\\":\\\"uM\\\"},\\\"agonistControl\\\":{\\\"batchCode\\\":\\\"CMPD-0000002-1\\\",\\\"concentration\\\":20,\\\"concentrationUnits\\\":\\\"uM\\\"},\\\"vehicleControl\\\":{\\\"batchCode\\\":\\\"CMPD-00000001-01\\\",\\\"concentration\\\":null,\\\"concentrationUnits\\\":null},\\\"transformationRule\\\":\\\"(maximum-minimum)/minimum\\\",\\\"normalizationRule\\\":\\\"plate order\\\",\\\"hitEfficacyThreshold\\\":42,\\\"hitSDThreshold\\\":5,\\\"thresholdType\\\":\\\"sd\\\",\\\"dilutionRatio\\\":1}\",\"primaryAnalysisExperimentId\":\"7582\",\"testMode\":\"true\"}')
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
getBatchNamesAndConcentrations <- function(barcode, well, wellTable) {
  # Matches result rows up with batch names and concentrations
  #
  # Args:
  #   barcode:        A vector of the barcodes
  #   well:           A vector of the wells
  #   wellTabe:       A data.frame with columns of BARCODE, WELL_NAME, BATCH_CODE,CONCENTRATION,CONCENTRATION_UNIT
  # Returns:
  #   A data.frame with batchName,concentration, and concUnit that matches the order of the input barcodes and wells
  
  wellUniqueId <- paste(barcode, well)
  wellTableUniqueId <- paste(wellTable$BARCODE, wellTable$WELL_NAME)
  outputFrame <- wellTable[match(wellUniqueId,wellTableUniqueId),c("BATCH_CODE","CONCENTRATION","CONCENTRATION_UNIT", "hasAgonist")]
  names(outputFrame) <- c("batchName","concentration","concUnit", "hasAgonist")
  return(outputFrame)
}
getAgonist <- function(agonist, wellTable) {
  # TODO: does not deal with multiple compounds in one well
  if((length(agonist) > 0) && !(agonist$batchCode %in% wellTable$BATCH_CODE)) {
    stop("The agonist was not found in the plates. Have all transfers been loaded?")
  }
  
  agonistRows <- wellTable$BATCH_CODE == agonist$batchCode & 
    wellTable$CONCENTRATION <= agonist$concentration & wellTable$CONCENTRATION_UNIT == agonist$concentrationUnits
  agonistTable <- wellTable[agonistRows, c("BARCODE", "WELL_NAME")]
  agonistLocations <- paste(agonistTable$BARCODE, agonistTable$WELL_NAME, sep=":")
  wellTable$tableAndWell <- paste(wellTable$BARCODE, wellTable$WELL_NAME, sep=":")
  wellTable$hasAgonist <- wellTable$tableAndWell %in% agonistLocations
  
  wellTable <- wellTable[!agonistRows, ]
  
  return(wellTable)
}
getFlags <- function(flaggedWells, resultTable) {
  # Reads the flagged wells from an input csv or Excel file
  # Input: flaggedWells, the name of a file in privateUploads that contains well-flagging information
  #        resultTable, a data.table that must contain all of the barcodes and wells for the data set
  # Returns: a data.table with each barcode, well, and associated flag. All column names are lowercase.
  
  # If we don't have a file, make all flags NA
  if(is.null(flaggedWells) || flaggedWells == "") {
    flaggedWells <- data.table(barcode = resultTable$barcode, well = resultTable$well, flag = c(NA_character_))
  } else {
    flaggedWells <- racas::getUploadedFilePath(flaggedWells)
    flagData <- readExcelOrCsv(flaggedWells, header = FALSE)
    
    # We want to accept two formats: the file we output, which the user has edited, and a file
    # that contains just the barcode, well, and flag information
    flagData <- tryCatch({
      flagData <- racas::getSection(flagData, lookFor = "Calculated Results")
      # Remove "Editable" Row
      flagData <- flagData[1:nrow(flagData)>1,]
      # Get the headers in the appropriate place
      names(flagData) <- tolower(flagData[1:nrow(flagData)==1,])
      flagData <- flagData[1:nrow(flagData)>1,]
    }, error = function(e) {
      if (any(class(e) == "userStop")) {
        # If we received an error that we defined, it means the section heading wasn't there
        # (or there were too few rows); we assume we just had the basic csv file
        names(flagData) <- tolower(flagData[1:nrow(flagData)==1,])
        flagData <- flagData[1:nrow(flagData)>1,]
        return(flagData)
      } else {
        stopUser("The system encountered an error while reading the flagged wells.")
      }
    })
    # Ensure that the data is in the proper form, and remove unneeded columns
    flagData <- validateFlagData(flagData, resultTable)
    flagData <- data.table(barcode = flagData$barcode, well = flagData$well, flag = flagData$flag)
    
    flagData <- as.data.table(flagData)
    # readExcelOrCsv reads nonexistent entries as empty strings, not NA, so we fix that:
    flagData[flag == ""]$flag <- NA_character_
    
    # If the table is blank, readExcelOrCsv decides all of the column types should be "logical",
    # so we change them to "character"
    if (nrow(flagData) == 0) {
      flagData <- as.data.table(sapply(flagData, as.character))
    }
  }
  return(flagData)
}
removeVehicle <- function(vehicle, wellTable) {
  #Removes rows with a vehicle that are part of another well
  # If the vehicle is the only compound in a well, it is kept
  library(plyr)
  
  vehicleRows <- wellTable$BATCH_CODE == vehicle$batchCode
    #wellTable$CONCENTRATION <= agonist$concentration & wellTable$CONCENTRATION_UNIT == agonist$concentrationUnits
  compoundCount <- ddply(wellTable, "WELL_ID", summarise, count = length(BATCH_CODE))
  hasMoreThanOneCompound <- compoundCount$WELL_ID[compoundCount$count > 1]
  vehicleIds <- wellTable$ID[vehicleRows & wellTable$WELL_ID %in% hasMoreThanOneCompound]
  wellTable <- wellTable[!(wellTable$ID %in% vehicleIds), ]
  return(wellTable)
}
getWellTypes <- function(batchNames, concentrations, concentrationUnits, hasAgonist, positiveControl, negativeControl, testMode=F) {
  # Takes vectors of batchNames, concentrations, and concunits 
  # and compares to named lists of the same for positive and negative controls
  # TODO: get client to send "infinite" as text for the negative control
  
  wellTypes <- rep.int("test", length(batchNames))
  
  if (positiveControl$concentration == "infinite") {
    positiveControl$concentration <- Inf
  }
  if (is.null(negativeControl$concentration) || negativeControl$concentration == "infinite") {
    negativeControl$concentration <- Inf
  }
  #   if(testMode) {
  #     wellTypes[batchNames==positiveControl$batchCode] <- "PC"
  #     wellTypes[batchNames==negativeControl$batchCode] <- "NC"
  #   } else {
  
  wellTypes[batchNames==positiveControl$batchCode & concentrations==positiveControl$concentration & 
              concentrationUnits==positiveControl$concentrationUnits & hasAgonist] <- "PC"
  wellTypes[batchNames==negativeControl$batchCode & concentrations==negativeControl$concentration & 
              concentrationUnits==negativeControl$concentrationUnits & hasAgonist] <- "NC"
  #   }
  
  wellTypes[!hasAgonist] <- "no agonist"

	return(wellTypes)
}
computeTransformedResults <- function(mainData, transformation) {
  #TODO switch on transformation
  if (transformation == "(maximum-minimum)/minimum") {
    return( (mainData$Maximum-mainData$Minimum)/mainData$Minimum )
  } else if (transformation == "unknown") {
    return ( mainData$"R1 {activity_1}") 
  } else {
    return ( list() )
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
    wellTable <- read.csv("public/src/modules/PrimaryScreen/spec/examplePlateContentsConfirmation.csv")
    #wellTable <- read.csv("public/src/modules/PrimaryScreen/spec/examplePlateContents.csv")
#     fakeAPI <- read.csv("public/src/modules/PrimaryScreen/spec/api_container_export.csv")
#     fakeAPI$BARCODE <- gsub("BF00007450", "TL00098001", fakeAPI$BARCODE)
#     fakeAPI$BARCODE <- gsub("BF00007460","TL00098002",fakeAPI$BARCODE)
#     fakeAPI$BARCODE <- gsub("BF00007390","TL00098003",fakeAPI$BARCODE)
#     fakeAPI$BARCODE <- gsub("BF00007395","TL00098004",fakeAPI$BARCODE)
#     wellTable <- fakeAPI[fakeAPI$BARCODE %in% barcodeList, ]
#     wellTable$BATCH_CODE <- gsub("CRA-024169-1", "CRA-000399-1", wellTable$BATCH_CODE)
#     wellTable$BATCH_CODE <- gsub("CRA-024184-1", "CRA-000396-1", wellTable$BATCH_CODE)
#     wellTable$BATCH_CODE <- gsub("CRA-024074-1", "CRA-000399-1", wellTable$BATCH_CODE)
#     wellTable$BATCH_CODE <- gsub("CRA-024087-1", "CRA-000396-1", wellTable$BATCH_CODE)
#     # different test, remove after nextval deploy
#     load("public/src/modules/PrimaryScreen/spec/wellTable.Rda")
#     wellTable <- wellTable[!(wellTable$BATCH_CODE=="FL0073897-1-1" & (wellTable$CONCENTRATION < 0.2 | wellTable$CONCENTRATION>49.6)), ]
  } else {
    wellTable <- query(paste0(
      "SELECT *
    FROM api_container_contents
    WHERE barcode IN ('", barcodeQuery, "')"))
  }
  
  wellTable$CONCENTRATION[wellTable$CONCENTRATION_STRING == "infinite"] <- Inf
  
  return(wellTable)
}

createPDF <- function(resultTable, analysisGroupData, parameters, summaryInfo, threshold, experiment, dryRun=F) {
  require('gplots')
  require('gridExtra')
  require('data.table')
  require('reshape')
  source("public/src/modules/PrimaryScreen/src/server/primaryAnalysisPlots.R")
  
  allResultTable <- resultTable
  resultTable <- resultTable[!resultTable$fluorescent & is.na(resultTable$flag),]
  
  if(dryRun) {
    pdfLocation <- paste0(experiment$codeName, "_SummaryDRAFT.pdf")
    pdfSave <- paste0("privateTempFiles/", pdfLocation)
  } else {
    pdfLocation <- paste0("experiments/",experiment$codeName,"/analysis/",experiment$codeName,"_Summary.pdf")
    pdfSave <- racas::getUploadedFilePath(pdfLocation)
  }
  pdf(file = pdfSave, width = 8.5, height = 11)
  if(dryRun) {
    textplot("Validation DRAFT")
  }
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
  flaggedWells <- allResultTable[!is.na(allResultTable$flag),list(barcode,well,sequence,timePoints,batchName)]
  
  plotFigure <- function(xData,yData, barcode, well, batchCode, title) {
    xData <- as.numeric(unlist(strsplit(xData,"\t", fixed= TRUE)))
    yData <- as.numeric(unlist(strsplit(yData,"\t", fixed= TRUE)))
    type="l"; xlab="Time (sec)"; ylab="Activity (rfu)"
    plot(xData, yData, type=type, xlab=xlab, ylab=ylab)
    title(main=paste0(barcode, " : ", well, "\n", batchCode))
    mtext(title, 3, line=0, adj=0.5, cex=1.2, outer=TRUE)
  }
  
  plotWells <- function(wellType, wellTypeName) {
    # wellType could be fluorescentWells, and then wellTypeName would be "Fluorescent Wells"
    if(nrow(wellType) > 0) {
      par(mfcol=c(4,3), mar=c(4,4,4,4), oma =c(2,2,2,2))
      mapply(plotFigure, wellType$timePoints, wellType$sequence, wellType$barcode, wellType$well, wellType$batchName, wellTypeName)
    }
  }
  
  plotWells(fluorescentWells, "Fluorescent Wells")
  plotWells(latePeakWells, "Late Peak Wells")
  plotWells(hitWells, "Hit Wells")
  plotWells(flaggedWells, "Flagged Wells")
  
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
  
  recordedBy <- user
  
  originalNames <- names(subjectData)
  subjectData <- as.data.frame(subjectData)
  
  # Fix names
  nameChange <- c(
    'well'='well name', 'Maximum'='maximum', 'Minimum'='minimum', 'sequence'='fluorescencePoints', 
    'batchName'='batchCode', 'concentration'='Dose', 'concUnit'='DoseUnit', 'wellType' = 'well type', 
    'transformed'='transformed efficacy','normalized'='normalized efficacy', 'maxTime' = 'max time', 
    'latePeak'='late peak', 'threshold'='over efficacy threshold', 'hasAgonist' = 'has agonist',
    'comparisonTraceFile'='comparison graph')
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
                                          "normalized efficacy", "over efficacy threshold",        #"fluorescencePoints", "timePoints",
                                          "max time", 'late peak', 'has agonist'),
                           includesOthers = FALSE,
                           includesCorpName = FALSE),
                      list(entityKind = "analysis group",
                           stateType = "data",
                           stateKind = "results",
                           valueKinds = c("fluorescent", "normalized efficacy", "transformed efficacy", "transformed efficacy without sweetener", "over efficacy threshold", "normalized efficacy without sweetener", "comparison graph"),
                           includesOthers = FALSE,
                           includesCorpName = TRUE),
                      list(entityKind = "analysis group",
                           stateType = "metadata",
                           stateKind = "plate information",
                           valueKinds = c("well type"),
                           includesOthers = FALSE,
                           includesCorpName = FALSE),
                      list(entityKind = "treatment group",
                           stateType = "data",
                           stateKind = "results",
                           valueKinds = c("fluorescent", "normalized efficacy", "over efficacy threshold", "transformed efficacy"),
                           includesOthers = FALSE,
                           includesCorpName = TRUE),
                      list(entityKind = "treatment group",
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
    DataColumn = c('barcode', 'well name', 'maximum', 'minimum', 'fluorescent',               #'timePoints', 'fluorescencePoints', 
                   'Dose', 'well type', 'transformed efficacy', 'normalized efficacy', 'over efficacy threshold',
                   'max time', 'late peak', 'has agonist', 'comparison graph'),
    Type = c('barcode', 'well name', 'maximum', 'minimum', 'fluorescent',                     #'timePoints', 'fluorescencePoints', 
             'Dose', 'well type', 'transformed efficacy', 'normalized efficacy', 'over efficacy threshold',
             'max time', 'late peak', 'has agonist', 'comparison graph'),
    Units = c(NA, NA, 'rfu', 'rfu', NA, #'sec', 'rfu', 
              subjectData$DoseUnit[1], NA, NA, NA, NA, 'sec', NA, NA, NA),
    valueType = c('codeValue','stringValue', 'numericValue','numericValue','stringValue', #'clobValue', 'clobValue',
                  'numericValue','stringValue','numericValue','numericValue','stringValue',
                  'numericValue','stringValue', 'stringValue', 'inlineFileValue'),
    stringsAsFactors = FALSE)
  
  if(is.null(subjectData$"comparison graph")) {
    resultTypes <- resultTypes[resultTypes$DataColumn != 'comparison graph', ]
  }
  
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
    longResults$comments <- NA
    
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
    
    longResults$fileValue <- as.character(longResults$"UnparsedValue")
    fileValueRows <- longResults$valueType %in% c("fileValue", "inlineFileValue")
    longResults$fileValue[!fileValueRows] <- NA
    longResults$comments[fileValueRows] <- basename(longResults$fileValue[fileValueRows])
    longResults$stringValue[fileValueRows] <- NA
    
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
    
    longResults$stringValue[longResults$stringValue == ""] <- NA
    longResults$valueOperator[longResults$valueOperator == ""] <- NA
    
    return(longResults)
  }
  meltedSubjectData <- makeLongData(subjectData, resultTypes=resultTypes, splitTreatmentGroupsBy=c("Dose","batchCode", "barcode", "well type"))
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
  
  savedSubjectValues <- saveValuesFromLongFormat(subjectDataWithBatchCodeRows, "subject", stateGroups, lsTransaction, recordedBy)

  #
  #####  
  # Treatment Group states =========================================================================
  treatmentGroupIndices <- which(sapply(stateGroups, function(x) {x$entityKind})=="treatment group")
  analysisGroupIndices <- which(sapply(stateGroups, function(x) {x$entityKind})=="analysis group")
  
  treatmentValueKinds <- unlist(lapply(stateGroups[treatmentGroupIndices], getElement, "valueKinds"))
  analysisValueKinds <- unlist(lapply(stateGroups[analysisGroupIndices], getElement, "valueKinds"))
  listedValueKinds <- do.call(c,lapply(stateGroups, getElement, "valueKinds"))
  otherValueKinds <- setdiff(unique(subjectData$valueKind),listedValueKinds)
  resultsDataValueKinds <- stateGroups[sapply(stateGroups, function(x) x$stateKind)=="results"][[1]]$valueKinds
  extraDataValueKinds <- stateGroups[sapply(stateGroups, function(x) x$stateKind)=="plate information"][[1]]$valueKinds
  treatmentDataValueKinds <- c(treatmentValueKinds, otherValueKinds, resultsDataValueKinds, extraDataValueKinds)
  excludedSubjects <- subjectData$subjectID[subjectData$valueKind == "Exclude"]
  treatmentDataStart <- subjectData[subjectData$valueKind %in% c(treatmentDataValueKinds, analysisValueKinds)
                                    & !(subjectData$subjectID %in% excludedSubjects),]
  
  createRawOnlyTreatmentGroupDataDT <- function(subjectData) {
    isGreaterThan <- any(subjectData$valueOperator==">", na.rm=TRUE)
    isLessThan <- any(subjectData$valueOperator=="<", na.rm=TRUE)
    resultValue <- NA
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
      resultOperator <- as.character(NA)
      resultValue <- mean(subjectData$numericValue)
    }
    return(list(
      "stateID" = subjectData$stateID[1],
      "stateVersion" = subjectData$stateVersion[1],
      "numericValue" = resultValue,
      "stringValue" = if (length(unique(subjectData$stringValue)) == 1) {subjectData$stringValue[1]}
      else if (all(subjectData$stringValue %in% c("yes", "no"))) {"sometimes"}
      else if (is.nan(resultValue)) {'NA'}
      else {as.character(NA)},
      "valueOperator" = resultOperator,
      "dateValue" = if (length(unique(subjectData$dateValue)) == 1) subjectData$dateValue[1] else NA,
      "fileValue" = if (length(unique(subjectData$fileValue)) == 1) subjectData$fileValue[1] else as.character(NA),
      "comments" = if (length(unique(subjectData$comments)) == 1) subjectData$comments[1] else as.character(NA),
      "publicData" = subjectData$publicData[1],
      "numberOfReplicates" = nrow(subjectData),
      "uncertaintyType" = if(is.numeric(resultValue)) "standard deviation" else as.character(NA),
      "uncertainty" = sd(subjectData$numericValue)
    ))
  }
  
  treatmentDataStartDT <- as.data.table(treatmentDataStart)
  
  keepValueKinds <- c("maximum", "minimum", "Dose", "transformed efficacy","normalized efficacy","over efficacy threshold","max time","late peak", "has agonist", "comparison graph")
  treatmentGroupDataDT <- treatmentDataStartDT[ valueKind %in% keepValueKinds, createRawOnlyTreatmentGroupDataDT(.SD), by = c("analysisGroupID", "treatmentGroupCodeName", "treatmentGroupID", "resultTypeAndUnit", "stateGroupIndex",
                                                                                                                              "batchCode", "valueKind", "valueUnit", "valueType")]
  #setkey(treatmentGroupDataDT, treatmentGroupID)
  treatmentGroupData <- as.data.frame(treatmentGroupDataDT)
  
  treatmentGroupIndices <- c(treatmentGroupIndices,othersGroupIndex)
  
  treatmentGroupData$stateID <- paste0(treatmentGroupData$treatmentGroupID, "-", treatmentGroupData$stateGroupIndex)
  
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
  # This is a hack to fix issues with batch codes
  treatmentGroupDataWithBatchCodeRows$stateVersion <- 0
  
  savedTreatmentGroupValues <- saveValuesFromLongFormat(entityData = treatmentGroupDataWithBatchCodeRows, 
                                                        entityKind = "treatmentgroup", 
                                                        stateGroups = stateGroups, 
                                                        stateGroupIndices = treatmentGroupIndices, 
                                                        lsTransaction = lsTransaction,
                                                        recordedBy=recordedBy)

  
  if (length(analysisGroupIndices > 0)) {
    analysisGroupData <- treatmentGroupDataWithBatchCodeRows
    
    ###
    # Correction for non-agonist data to put in separate column
    if (any(analysisGroupData$valueKind == "has agonist")) {
      #analysisGroupKeep <- analysisGroupData$analysisGroupID[(analysisGroupData$valueKind == "has agonist" & analysisGroupData$stringValue == "yes")]
      #analysisGroupData <- analysisGroupData[analysisGroupData$analysisGroupID %in% analysisGroupKeep, ]
      
      analysisGroupHasAgonist <- analysisGroupData$analysisGroupID[(analysisGroupData$valueKind == "has agonist" & analysisGroupData$stringValue == "yes")]      
      analysisGroupDataNoAgonist <- analysisGroupData[!(analysisGroupData$analysisGroupID %in% analysisGroupHasAgonist), ]
      analysisGroupDataHasAgonist <- analysisGroupData[(analysisGroupData$analysisGroupID %in% analysisGroupHasAgonist), ]
      
      analysisGroupDataNoAgonist$valueKind[analysisGroupDataNoAgonist$valueKind == "normalized efficacy"] <- "normalized efficacy without sweetener"
      analysisGroupDataNoAgonist$valueKind[analysisGroupDataNoAgonist$valueKind == "transformed efficacy"] <- "transformed efficacy without sweetener"
      analysisGroupDataNoAgonist <- analysisGroupDataNoAgonist[!(analysisGroupDataNoAgonist$valueKind %in% c("over efficacy threshold", "comparison graph")), ]
      analysisGroupData <- rbind.fill(analysisGroupDataNoAgonist, analysisGroupDataHasAgonist)
      # Remove empty comparison graphs (happens for controls across plates)
      analysisGroupDataRemove <- analysisGroupData$valueKind == "comparison graph" & is.na(analysisGroupData$fileValue)
      analysisGroupData <- analysisGroupData[!analysisGroupDataRemove, ]
    }
    
    ###
    analysisGroupData$stateID <- paste0(analysisGroupData$analysisGroupID, "-", analysisGroupData$stateGroupIndex)
    
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
validateFlagData <- function(flagData, resultTable) {
  # Ensures that the flagData is in a reasonable format, so we can throw helpful
  #   errors before the rest of the code generates unhelpful (R) errors
  #
  # flagData:    A data.frame that should contain (at a minimum) the barcode, well, and flag
  #                for flagged wells
  # resultTable: A data.table containing, among other fields, a complete list of barcodes and wells
  # Returns: the input data frame, with accumulated warnings and errors

  columnsIncluded <- c("well", "barcode", "flag") %in% names(flagData)
  if (!all(columnsIncluded)) {
    stopUser(paste0("An important column appears to be missing from the input. ",
                    "Please ensure that the uploaded file contains columns for Well,", 
                    "Barcode, and Flag. If the uploaded file contained calculated ", 
                    "results, please ensure that you only modified the columns marked ",
                    "as editable."))
  }
  
  duplicateIndices <- duplicated(data.frame(flagData$barcode, flagData$well))
  if (any(duplicateIndices)) {
    duplicateTests <- unique(data.frame(flagData$barcode[duplicateIndices], flagData$well[duplicateIndices]))
    stopUser(paste0("The same barcode and well combination was listed multiple times in the flag file. Please remove ",
             "duplicates for ", paste(duplicateTests[[1]], duplicateTests[[2]], collapse = ", "), "."))
  }
  
  results <- data.table(barcode = resultTable$barcode, well = resultTable$well)
  flags <- data.table(barcode = flagData$barcode, well = flagData$well)
  setkey(flags, barcode, well)
  extraTests <- flags[!results]
  if (nrow(extraTests) > 0) {
    warning(paste0("Some of the wells listed in the flag file were not found in the experiment ",
            "data, and will be ignored. Please remove or modify ", 
            paste(extraTests[[1]], extraTests[[2]], collapse = ", "), "."))
  }
  
  return(flagData)
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
saveFileLocations <- function (rawResultsLocation, resultsLocation, pdfLocation, flagLocation, experiment, dryRun, recordedBy, lsTransaction) {
  # Saves the locations of the results, pdf, flags, and raw R resultTable as experiment values
  #
  # Args:
  #   rawResultsLocation:   A string of the file location where the raw R resultTable is located
  #   resultsLocation:      A string of the results csv location
  #   pdfLocation:          A string of the pdf summary report location
  #   flagLocation:         A string of the flagged wells csv location
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
    
    flagLocationValue <- createStateValue(
      lsType = "fileValue",
      lsKind = "flag file",
      fileValue = flagLocation,
      lsState = locationState)
    
    saveExperimentValues(list(rawLocationValue,resultsLocationValue,pdfLocationValue))
  }, error = function(e) {
    stop("Could not save the summary and result locations")
  })
  
  
  
  return(NULL)
}
saveInputParameters <- function(inputParameters, experiment, lsTransaction, recordedBy) {
  # input: inputParameters a string that is JSON
  metadataState <- experiment$lsStates[lapply(experiment$lsStates,getElement,"lsKind")=="experiment metadata"]
  
  if (length(metadataState)> 0) {
    metadataState <- metadataState[[1]]
    
    valueKinds <- lapply(metadataState$lsValues,getElement,"lsKind")
    valuesToDelete <- metadataState$lsValues[valueKinds %in% c("data analysis parameters")]
    lapply(valuesToDelete, deleteExperimentValue)
  } else {
    metadataState <- createExperimentState(
      recordedBy = recordedBy,
      experiment = experiment,
      lsType = "metadata",
      lsKind = "experiment metadata",
      lsTransaction=lsTransaction)
    tryCatch({
      metadataState <- saveExperimentState(metadataState)
    }, error = function(e) {
      stop("Could not save the input parameters")
    })
  }
  
  tryCatch({
    inputParametersValue <- createStateValue(
      lsType = "clobValue",
      lsKind = "data analysis parameters",
      clobValue = inputParameters,
      lsState = metadataState)
    saveExperimentValues(list(inputParametersValue))
  }, error = function(e) {
    stop("Could not save the input parameters")
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
  #     $aggregateReplicates
  
  parameters <- fromJSON(inputParameters)
  
  if (is.null(parameters$aggregateReplicates)) {
    parameters$aggregateReplicates<- "no"
  }
  
  if (is.null(parameters$dilutionRatio)) {
    parameters$dilutionRatio <- 2
  }
  
  return(parameters)
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
    stop("All of the negative controls in one normalization group (barcode, or barcode and plate row) were flagged, so normalization cannot proceed.")
  }
  if ((length((values[(wellType == 'PC' & is.na(flag))])) == 0)) {
    stop("All of the positive controls in one normalization group (barcode, or barcode and plate row) were flagged, so normalization cannot proceed.")
  }
  
  #find min (mean of unflagged Negative Controls)
  minLevel <- mean(values[(wellType=='NC' & is.na(flag))])
  #find max (mean of unflagged Positive Controls)
  maxLevel <- mean(values[(wellType=='PC' & is.na(flag))])
  
  return((values - minLevel) / (maxLevel - minLevel))
}

####### Main function
runMain <- function(folderToParse, user, dryRun, testMode, experimentId, inputParameters, flaggedWells=NULL) {
  # Runs main functions that are inside the tryCatch.W.E
  # flaggedWells: the name of a csv or Excel file that lists each well's barcode, 
  #               well number, and if it's flagged. If NULL, the file did not exist,
  #               and no wells are flagged.
  
  folderToParse <- racas::getUploadedFilePath(folderToParse)
  
  if (!file.exists(folderToParse)) {
    stop("Input file not found")
  }
  
  require("data.table")
  
  if(!testMode) {
    experiment <- getExperimentById(experimentId)
    
    metadataState <- Filter(function(x) x$lsKind == "experiment metadata", 
                            x = experiment$lsStates)[[1]]
    
    # metadataState <- experiment$lsStates[lapply(experiment$lsStates,getElement,"lsKind")=="experiment metadata"][[1]]
    if(!dryRun) {
      setAnalysisStatus(status = "parsing", metadataState)
    }
  } else {
    experiment <- list(id = experimentId, codeName = "test", version = 0)
  }
  
  parameters <- getExperimentParameters(inputParameters)
  # TODO: store this in protocol
  parameters$latePeakTime <- 80
  if(is.null(parameters$useRdap)) {
    useRdap <- FALSE
  } else {
    useRdap <- as.logical(parameters$useRdap)
    rdapTestMode <- as.logical(parameters$rdapTestMode)
  }
  
  dir.create(racas::getUploadedFilePath("experiments"), showWarnings = FALSE)
  dir.create(paste0(racas::getUploadedFilePath("experiments"),"/",experiment$codeName), showWarnings = FALSE)
  
  # If the folderToParse is actually a zip file
  zipFile <- NULL
  if (!file.info(folderToParse)$isdir) {
    if(!grepl("\\.zip$", folderToParse)) {
      stop("The file provided must be a zip file or a directory")
    }
    zipFile <- folderToParse
    filesLocation <- paste0(racas::getUploadedFilePath("experiments"),"/",experiment$codeName, "/rawData")
    
    dir.create(filesLocation, showWarnings = FALSE)
    
    oldFiles <- as.list(paste0(filesLocation,"/",list.files(filesLocation)))
    
    do.call(unlink, list(oldFiles, recursive=T))
    
    unzip(zipfile=folderToParse, exdir=paste0(racas::getUploadedFilePath("experiments"),"/",experiment$codeName, "/rawData"))
    folderToParse <- paste0(racas::getUploadedFilePath("experiments"),"/",experiment$codeName, "/rawData")
  } 
  
  ### START HERE - FLIPR reading function
  
  if(useRdap) {
    
    #   fileNameTable <- validateInputFiles(folderToParse)
    #   
    #   # TODO maybe: http://stackoverflow.com/questions/2209258/merge-several-data-frames-into-one-data-frame-with-a-loop/2209371
    #   
    #   resultList <- apply(fileNameTable,1,combineFiles)
    #   resultTable <- as.data.table(do.call("rbind",resultList))
    #   barcodeList <- levels(resultTable$barcode)
    #   
    #   wellTable <- createWellTable(barcodeList, testMode)
    #   
    #   resultTable <- cbind(resultTable,batchNamesAndConcentrations)
    
    ## TODO: Test Structure
    #       require(rjson)
    #       request <- fromJSON('{\"fileToParse\":\"~/Desktop/1_FLIPR_raw_data/\",\"reportFile\":\"\",\"dryRunMode\":\"true\",\"user\":\"bob\",\"inputParameters\":\"{\\\"positiveControl\\\":{\\\"batchCode\\\":\\\"CMPD-0000006-1\\\",\\\"concentration\\\":2,\\\"concentrationUnits\\\":\\\"uM\\\"},\\\"negativeControl\\\":{\\\"batchCode\\\":\\\"CMPD-0000001-1\\\",\\\"concentration\\\":null,\\\"concentrationUnits\\\":\\\"uM\\\"},\\\"agonistControl\\\":{\\\"batchCode\\\":\\\"CMPD-0000002-1\\\",\\\"concentration\\\":20,\\\"concentrationUnits\\\":\\\"uM\\\"},\\\"vehicleControl\\\":{\\\"batchCode\\\":\\\"CMPD-00000001-01\\\",\\\"concentration\\\":null,\\\"concentrationUnits\\\":null},\\\"transformationRule\\\":\\\"unknown\\\",\\\"normalizationRule\\\":\\\"\\\",\\\"hitEfficacyThreshold\\\":42,\\\"hitSDThreshold\\\":5,\\\"thresholdType\\\":\\\"sd\\\",\\\"useRdap\\\":\\\"true\\\",\\\"rdapTestMode\\\":\\\"true\\\"}\",\"primaryAnalysisExperimentId\":\"1034\",\"testMode\":\"true\"}')
    #       request <- fromJSON('{\"fileToParse\":\"Archive.zip\",\"reportFile\":\"\",\"dryRunMode\":\"true\",\"user\":\"bob\",\"inputParameters\":\"{\\\"positiveControl\\\":{\\\"batchCode\\\":\\\"CMPD-0000006-1\\\",\\\"concentration\\\":2,\\\"concentrationUnits\\\":\\\"uM\\\"},\\\"negativeControl\\\":{\\\"batchCode\\\":\\\"CMPD-0000001-1\\\",\\\"concentration\\\":null,\\\"concentrationUnits\\\":\\\"uM\\\"},\\\"agonistControl\\\":{\\\"batchCode\\\":\\\"CMPD-0000002-1\\\",\\\"concentration\\\":20,\\\"concentrationUnits\\\":\\\"uM\\\"},\\\"vehicleControl\\\":{\\\"batchCode\\\":\\\"CMPD-00000001-01\\\",\\\"concentration\\\":null,\\\"concentrationUnits\\\":null},\\\"transformationRule\\\":\\\"unknown\\\",\\\"normalizationRule\\\":\\\"none\\\",\\\"hitEfficacyThreshold\\\":42,\\\"hitSDThreshold\\\":5,\\\"thresholdType\\\":\\\"\\\",\\\"useRdap\\\":\\\"true\\\",\\\"rdapTestMode\\\":\\\"true\\\"}\",\"primaryAnalysisExperimentId\":\"186149\",\"testMode\":\"false\"}')
    #       parameters <- fromJSON(request$inputParameters)
    #     
    #       folderToParse <- request$fileToParse
    #       rdapTestMode <- TRUE
    ## End Test Structure
    require(rdap)
    rdapList <- catchExecuteDap(request=list(filePath=file.path(getwd(), folderToParse), testMode=rdapTestMode))
    
    ## TODO: Test Structure rdap FIXABLE
    #          currentWD <- getwd()
    #          setwd(file.path(currentWD, folderToParse))
    ## End Test Structure
    
    resultTable <- as.data.table(unique(read.table(file.path(dirname(folderToParse), "output_well_data.srf"),
                                                   header=TRUE, 
                                                   sep="\t", 
                                                   stringsAsFactors=FALSE,
                                                   check.names=FALSE)
                                        [ , c(well="wellReference", 
                                              "assayBarcode", 
                                              "cmpdConc", 
                                              "corp_name", 
                                              "cmpdBatch", 
                                              colnames(rdapList$value$activity))]))
    
    setnames(resultTable, c("wellReference", "assayBarcode", "cmpdConc", "corp_name", "cmpdBatch"), c("well", "barcode", "concentration", "batchName", "batchCode"))
    
    ## TODO: Test Sructure
      resultTable$hasAgonist <- FALSE
      resultTable$concentrationUnit <- "uM"
    #       resultTable$fileName <- folderToParse
    #     
    #       
    #     
    # #       parameters <- fromJSON("{\"positiveControl\":{\"batchCode\":\"CMPD-0000006-1\",\"concentration\":2,\"concentrationUnits\":\"uM\"},\"negativeControl\":{\"batchCode\":\"CMPD-0000001-1\",\"concentration\":null,\"concentrationUnits\":\"uM\"},\"agonistControl\":{\"batchCode\":\"CMPD-0000002-1\",\"concentration\":20,\"concentrationUnits\":\"uM\"},\"vehicleControl\":{\"batchCode\":\"CMPD-00000001-01\",\"concentration\":null,\"concentrationUnits\":null},\"transformationRule\":\"unknown\",\"normalizationRule\":\"plate order\",\"hitEfficacyThreshold\":42,\"hitSDThreshold\":5,\"thresholdType\":\"sd\"}")
    #     
    #       # normalization
    normalization <- ""
    
    ## End Test Structure
  } else {
    fileNameTable <- validateInputFiles(folderToParse)
    
    # TODO maybe: http://stackoverflow.com/questions/2209258/merge-several-data-frames-into-one-data-frame-with-a-loop/2209371
    
    resultList <- apply(fileNameTable,1,combineFiles)
    resultTable <- as.data.table(do.call("rbind",resultList))
    barcodeList <- levels(resultTable$barcode)
    
    wellTable <- createWellTable(barcodeList, testMode)
    
    # apply dilution
    if (!is.null(parameters$dilutionRatio)) {
      wellTable$CONCENTRATION <- wellTable$CONCENTRATION / parameters$dilutionRatio
    }
    
    wellTable <- getAgonist(parameters$agonistControl, wellTable)
    
    wellTable <- removeVehicle(parameters$vehicleControl, wellTable)
    
    if(anyDuplicated(paste(wellTable$BARCODE, wellTable$WELL_NAME, sep=":"))) {
      stop("Multiple test compounds were found in these wells, so it is unclear which is the tested compound: '", 
           paste(wellTable$tableAndWell[duplicated(wellTable$tableAndWell)], collapse = "', '"),
           "'. Please contact your system administrator.")
    }
    
    batchNamesAndConcentrations <- getBatchNamesAndConcentrations(resultTable$barcode, resultTable$well, wellTable)
    resultTable <- cbind(resultTable,batchNamesAndConcentrations)
    
    normalization <- parameters$normalizationRule
    
  }
  ### END FLIPR reading function
  
  resultTable$wellType <- getWellTypes(resultTable$batchName, resultTable$concentration, 
                                       resultTable$concUnit, resultTable$hasAgonist, 
                                       parameters$positiveControl, parameters$negativeControl, testMode)
  
  if (!any(resultTable$wellType == "PC")) {
    stop("The positive control was not found in the plates. Make sure all transfers have been loaded and your postive control is defined correctly.")
  }
  
  if (!any(resultTable$wellType == "NC")) {
    stop("The negative control was not found in the plates. Make sure all transfers have been loaded and your negative control is defined correctly.")
  }
  
  #calculations
  resultTable$transformed <- computeTransformedResults(resultTable, parameters$transformationRule)
  
  # Get a table of flags associated with the data. If there was no file name given, then all flags are NA
  flaggedWells <- getFlags(flaggedWells, resultTable)
  
  # In order to merge with a data.table, the columns have to have the same name
  resultTable <- merge(resultTable, flaggedWells, by = c("barcode", "well"), all.x = TRUE, all.y = FALSE)
  
  # Error handling -- what if there are no unflagged PC's or NC's? 
  if (!any(is.na(resultTable$flag))) { 
    stop("All data points appear to have been flagged, so the data cannot be analyzed")
  }
  if (!any(resultTable$wellType == "NC" & is.na(resultTable$flag))) {
    stop("All negative controls appear to have been flagged, so the data cannot be normalized.")
  }
  if (!any(resultTable$wellType == "PC" & is.na(resultTable$flag))) {
    stop("All positive controls appear to have been flagged, so the data cannot be normalized.")
  }
  
  # normalization
  
  if (normalization=="plate order") {
    resultTable[,normalized:=computeNormalized(transformed,wellType,flag), by= barcode]
  } else if (normalization=="row order") {
    resultTable[,plateRow:=gsub("\\d", "",well)]
    resultTable[,normalized:=computeNormalized(transformed,wellType,flag), by= list(barcode,plateRow)]
  } else {
    resultTable$normalized <- resultTable$transformed
  }
  
  if(!useRdap) {
    flaglessResults <- resultTable[is.na(flag)]
    meanValue <- mean(flaglessResults$normalized[flaglessResults$wellType == "test"])
    sdValue <- sd(flaglessResults$normalized[flaglessResults$wellType == "test"])
    resultTable$sdScore <- computeSDScore(resultTable$normalized, meanValue, sdValue)
  }
  #maxTime is the point used by the stat1/2 files, overallMaxTime includes points outside of that range
  resultTable[, index:=1:nrow(resultTable)]
  
  if(!useRdap) {
    resultTable[, maxTime:=as.numeric(unlist(strsplit(timePoints, "\t"))[which.max(as.numeric(unlist(strsplit(sequence, "\t")))[startReadMax:endReadMax]) + as.integer(startReadMax) - 1L]), by = index]
    resultTable[, overallMaxTime:=as.numeric(unlist(strsplit(timePoints, "\t"))[which.max(as.numeric(unlist(strsplit(sequence, "\t"))))]), by = index]
  }
  #   #TODO: remove once real data is in place
  #   if (any(is.na(resultTable$batchName))) {
  #     warning("Some wells did not have recorded contents in the database- they will be skipped. Make sure all transfers have been loaded.")
  #     resultTable <- resultTable[!is.na(resultTable$batchName), ]
  #   }
  
  #TODO: remove once real data is in place
  if (any(is.na(resultTable$batchName))) {
    warning("Some wells did not have recorded contents in the database- they will be skipped. Make sure all transfers have been loaded.")
    resultTable <- resultTable[!is.na(resultTable$batchName), ]
  }

  hitSelection <- parameters$thresholdType #Other choice is "efficacyThreshold"
  if (hitSelection == "sd") {
    efficacyThreshold <- meanValue + sdValue * parameters$hitSDThreshold
  } else {
    efficacyThreshold <- parameters$hitEfficacyThreshold
  }
  
  if(useRdap) {
    flaglessTable <- resultTable[is.na(flag)]
    batchDataTable <- data.table(values = flaglessTable$normalized, 
                                 batchName = flaglessTable$batchName,
                                 wellType = flaglessTable$wellType,
                                 barcode = flaglessTable$barcode)
  } else {
    # Get the late peak points
    resultTable$latePeak <- (resultTable$overallMaxTime > parameters$latePeakTime) & 
      (resultTable$normalized > efficacyThreshold) & !resultTable$fluorescent
    # Get individual points that are greater than the threshold
    resultTable$threshold <- (resultTable$normalized > efficacyThreshold) & !resultTable$fluorescent & 
      resultTable$wellType=="test" & !resultTable$latePeak
    
    # Omit the flagged results when calculating treatment group data
    flaglessTable <- resultTable[is.na(flag)]
    batchDataTable <- data.table(values = flaglessTable$normalized, 
                                 batchName = flaglessTable$batchName,
                                 fluorescent = flaglessTable$fluorescent,
                                 sdScore = flaglessTable$sdScore,
                                 wellType = flaglessTable$wellType,
                                 barcode = flaglessTable$barcode,
                                 maxTime = flaglessTable$maxTime,
                                 overallMaxTime = flaglessTable$overallMaxTime,
                                 threshold = flaglessTable$threshold,
                                 hasAgonist = flaglessTable$hasAgonist,
                                 latePeak = flaglessTable$latePeak,
                                 concentration = flaglessTable$concentration,
                                 concUnit = flaglessTable$concUnit)
  }

  if(!useRdap) {
    if (parameters$aggregateReplicates == "across plates") {
      treatmentGroupData <- batchDataTable[, list(groupMean = mean(values), 
                                                  stDev = sd(values), n=length(values), 
                                                  sdScore = mean(sdScore), 
                                                  threshold = ifelse(all(threshold), "yes", "no"),
                                                  latePeak = if (all(latePeak)) "yes" else if (!any(latePeak)) "no" else "sometimes"),
                                           by=list(batchName,fluorescent,concUnit,hasAgonist, wellType)]
    } else if (parameters$aggregateReplicates == "within plates") {
      treatmentGroupData <- batchDataTable[, list(groupMean = mean(values), 
                                                  stDev = sd(values), 
                                                  n=length(values),
                                                  sdScore = mean(sdScore),
                                                  threshold = ifelse(all(threshold), "yes", "no"),
                                                  latePeak = if (all(latePeak)) "yes" else if (!any(latePeak)) "no" else "sometimes"),
                                           by=list(batchName,fluorescent,barcode,concUnit,hasAgonist, wellType)]
    } else {
      treatmentGroupData <- batchDataTable[, list(batchName = batchName, 
                                                  fluorescent = fluorescent, 
                                                  wellType = wellType, 
                                                  groupMean = values, 
                                                  stDev = NA, 
                                                  n = 1, 
                                                  sdScore = sdScore,
                                                  maxTime = maxTime,
                                                  overallMaxTime = overallMaxTime,
                                                  threshold = ifelse(threshold, "yes", "no"),
                                                  hasAgonist = hasAgonist)]
    }
    treatmentGroupData$treatmentGroupId <- 1:nrow(treatmentGroupData)
    
    analysisType <- "primary"
    if (analysisType == "primary" || analysisType == "confirmation") {
      analysisGroupData <- treatmentGroupData[hasAgonist == T & wellType=="test"]
      analysisGroupData[, analysisGroupId := treatmentGroupId]
    } else if (analysisType == "dose response") {
      analysisGroupData <- treatmentGroupData
      analysisGroupData$analysisGroupId <- as.numeric(factor(analysisGroupData$batchName))
    }
    
    #analysisGroupData$threshold <- analysisGroupData$sdScore > parameters$hitSDThreshold & !analysisGroupData$fluorescent & analysisGroupData$wellType=="test"
    
    if (parameters$aggregateReplicates == "no") {
    #     analysisGroupData$latePeak <- (analysisGroupData$overallMaxTime > 80) & 
    #       (analysisGroupData$groupMean > efficacyThreshold) & !analysisGroupData$fluorescent
    #     analysisGroupData$threshold <- analysisGroupData$groupMean > efficacyThreshold & !analysisGroupData$fluorescent & 
    #       analysisGroupData$wellType=="test" & !analysisGroupData$latePeak
    } else {
      
    }
  
    
    library(plyr)
    #if (analysisType == "primary") {
    if (TRUE) {
      # May need to return to using analysisGroupData eventually
      outputTable <- ddply(resultTable, c("batchName", "hasAgonist", "barcode", "wellType"), function(idf) {
        data.frame("Flag" = idf$flag,
          "Corporate Batch ID" = as.character(idf$batchName),
          "Barcode" = as.character(idf$barcode),
          "Well" = as.character(idf$well),
          "Well Hit" = ifelse(idf$threshold, "yes", "no"),
          "Hit" = rep(ifelse(all(idf$threshold), "yes", "no"), length.out = nrow(idf)),
          "SD Score" = idf$sdScore,
          "Activity" = idf$transformed,
          "Normalized Activity" = idf$normalized,
          "Fluorescent" = ifelse(idf$fluorescent, "yes", "no"),
          "Max Time (s)" = idf$maxTime,
          "Well Type" = idf$wellType,
          "Late Peak" = ifelse(idf$latePeak, "yes", "no"),
          "Has Agonist" = ifelse(idf$hasAgonist, "yes", "no"),
          check.names = FALSE,
          stringsAsFactors = FALSE)
      })
    }
    
    outputTable$batchName <- NULL
    outputTable$barcode <- NULL
    outputTable$wellType <- NULL
    outputTable$hasAgonist <- NULL
    
    if(parameters$aggregateReplicates == "no") {
      outputTable$"Well Hit" <- NULL
    }
    
    #     outputTable <- data.table("Corporate Batch ID" = resultTable$batchName, "Barcode" = as.character(resultTable$barcode),
    #                               "Well" = as.character(resultTable$well), "Hit" = ifelse(resultTable$threshold, "yes", "no"),
    #                               "SD Score" = resultTable$sdScore, "Normalized Activity" = resultTable$normalized,
    #                               "Activity" = resultTable$transformed, 
    #                               "Fluorescent"= ifelse(resultTable$fluorescent, "yes", "no"),
    #                               "Max Time (s)" = resultTable$maxTime, "Well Type" = resultTable$wellType,
    #                               "Late Peak" = ifelse(resultTable$latePeak, "yes", "no"))
    outputTable <- as.data.table(outputTable)
    outputTable <- outputTable[order(Hit, Fluorescent, decreasing=TRUE)]
  
    summaryInfo <- list(
      info = list(
        "Sweetener" = parameters$agonist$batchCode,
        "Plates analyzed" = paste0(length(unique(resultTable$barcode)), " plates:\n  ", paste(unique(resultTable$barcode), collapse = "\n  ")),
        "Compounds analyzed" = length(unique(resultTable$batchName)),
        "Hits" = sum(analysisGroupData$threshold == "yes"),
        "Threshold" = signif(efficacyThreshold, 3),
        "SD Threshold" = ifelse(hitSelection == "sd", parameters$hitSDThreshold, "NA"),
        "Fluorescent wells" = sum(resultTable$fluorescent),
        "Flagged wells" = sum(!is.na(resultTable$flag)),
        "Z'" = format(computeZPrime(resultTable$transformed[resultTable$wellType=="PC" & is.na(resultTable$flag)], resultTable$transformed[resultTable$wellType=="NC" & is.na(resultTable$flag)]),digits=3,nsmall=3),
        "Robust Z'" = format(computeRobustZPrime(resultTable$transformed[resultTable$wellType=="PC" & is.na(resultTable$flag)], resultTable$transformed[resultTable$wellType=="NC" & is.na(resultTable$flag)]),digits=3,nsmall=3),
        "Z" = format(computeZPrime(resultTable$transformed[resultTable$wellType=="PC" & is.na(resultTable$flag)], resultTable$transformed[resultTable$wellType=="test" & !resultTable$fluorescent & is.na(resultTable$flag)]),digits=3,nsmall=3),
        "Robust Z" = format(computeRobustZPrime(resultTable$transformed[resultTable$wellType=="PC" & is.na(resultTable$flag)], resultTable$transformed[resultTable$wellType=="test"& !resultTable$fluorescent & is.na(resultTable$flag)]),digits=3,nsmall=3),
        "Date analysis run" = format(Sys.time(), "%a %b %d %X %z %Y")
      )
    )
    library('RCurl')
    row.names(outputTable) <- NULL
    outputTableReloadColumns <- as.data.frame(outputTable)[, c("Corporate Batch ID", "Hit")]
    if (parameters$aggregateReplicates == "within plates") {
      uniqueString <- paste(outputTable$"Corporate Batch ID", outputTable$"Barcode", outputTable$"Well Type")
    } else if (parameters$aggregateReplicates == "no") {
      uniqueString <- 1:nrow(outputTableReloadColumns)
    } else {
      uniqueString <- paste(outputTableReloadColumns$"Corporate Batch ID", outputTable$"Well Type")
    }
    outputTableReloadColumns$"Hit"[duplicated(uniqueString)] <- ""
    names(outputTableReloadColumns) <- c("Corporate Batch ID", "User Defined Hit")
    outputTable$"Corporate Batch ID" <- NULL  # Don't want this showing up twice
    protocol <- fromJSON(getURL(paste0(racas::applicationSettings$client.service.persistence.fullpath, "protocols/", experiment$protocol$id)))
    protocolName <- protocol$lsLabels[[1]]$labelText
    metadataState <- experiment$lsStates[lapply(experiment$lsStates, getElement, "lsKind") == "experiment metadata"][[1]]
    completionDateValue <- metadataState$lsValues[lapply(metadataState$lsValues, getElement, "lsKind") == "completion date"][[1]]
    
    dataSection <- cbind(outputTableReloadColumns, outputTable)
    headerRow <- names(dataSection)
    columnNamesSection <- as.data.frame(t(headerRow), stringsAsFactors=F)
    names(columnNamesSection) <- as.character(seq(1, length(columnNamesSection)))
    columnTypeSection <- data.frame(c(NA, "Calculated Results", "Reference"), 
                                    c(NA, NA, "Editable"), 
                                    c(NA, NA, "Editable"),
                                    c(NA, NA, "Reference"),
                                    c(NA, NA, "Reference"),
                                    c(NA, NA, "Reference"),
                                    c(NA, NA, "Reference"),
                                    c(NA, NA, "Reference"),
                                    c(NA, NA, "Reference"),
                                    c(NA, NA, "Reference"),
                                    c(NA, NA, "Reference"),
                                    c(NA, NA, "Reference"),
                                    c(NA, NA, "Reference"),
                                    c(NA, NA, "Reference"),
                                    c(NA, NA, "Reference"),
                                    stringsAsFactors=F)
    names(columnTypeSection) <- as.character(seq(1, length(columnTypeSection)))
    names(dataSection) <- as.character(seq(1, length(dataSection)))
    
    if(!testMode) {
      headerSection <- data.frame(c("Format", "Protocol Name", "Experiment Name", "Scientist", "Notebook", "Page", "Assay Date"),
                                  c("Generic", protocolName, paste(experiment$lsLabels[[1]]$labelText, "user override"), experiment$lsLabels[[1]]$recordedBy, "", "", 
                                    format(as.POSIXct(completionDateValue$dateValue/1000, origin="1970-01-01"), "%Y-%m-%d")))
    } else {
      headerSection <- data.frame(c("Format", "Protocol Name", "Experiment Name", "Scientist", "Notebook", "Page", "Assay Date"),
                                  c("Generic", "FLIPR target A biochemical", paste("test", "user override"), "bob", "", "", 
                                    format(as.POSIXct(1395788334, origin="1970-01-01"), "%Y-%m-%d")))
      protocolName <- "FLIPR target A biochemical"
    }
    names(headerSection) <- as.character(seq(1, length(headerSection)))
    
    library('plyr')
    userOverrideFrame <- rbind.fill(headerSection, columnTypeSection, columnNamesSection, dataSection)
    names(userOverrideFrame) <- c("Experiment Meta Data", rep("", length(userOverrideFrame) - 1))
  } else { #This section is "if(useRdap)"
    
    protocol <- fromJSON(getURL(paste0(racas::applicationSettings$client.service.persistence.fullpath, "protocols/", experiment$protocol$id)))
    protocolName <- protocol$lsLabels[[1]]$labelText
    
    summaryInfo <- list(
      info = list(
        "Sweetener" = parameters$agonist$batchCode,
        "Plates analyzed" = paste0(length(unique(resultTable$barcode)), " plates:\n  ", paste(unique(resultTable$barcode), collapse = "\n  ")),
        "Compounds analyzed" = length(unique(resultTable$batchName)),
        # "Hits" = sum(analysisGroupData$threshold),
        # "Threshold" = signif(efficacyThreshold, 3),
        # "SD Threshold" = ifelse(hitSelection == "sd", parameters$hitSDThreshold, "NA"),
        "Fluorescent wells" = sum(resultTable$fluorescent),
        "Flagged wells" = sum(!is.na(resultTable$flag)),
        # "Z'" = format(computeZPrime(resultTable$transformed[resultTable$wellType=="PC"], resultTable$transformed[resultTable$wellType=="NC"]),digits=3,nsmall=3),
        # "Robust Z'" = format(computeRobustZPrime(resultTable$transformed[resultTable$wellType=="PC"], resultTable$transformed[resultTable$wellType=="NC"]),digits=3,nsmall=3),
        # "Z" = format(computeZPrime(resultTable$transformed[resultTable$wellType=="PC"], resultTable$transformed[resultTable$wellType=="test" & !resultTable$fluorescent]),digits=3,nsmall=3),
        # "Robust Z" = format(computeRobustZPrime(resultTable$transformed[resultTable$wellType=="PC"], resultTable$transformed[resultTable$wellType=="test"& !resultTable$fluorescent]),digits=3,nsmall=3),
        "Date analysis run" = format(Sys.time(), "%a %b %d %X %z %Y")
      )
    )
  }
  
  if (dryRun) {
    lsTransaction <- NULL
    
    if(!useRdap) {
      #save(experiment, file="experiment.Rda")
      pdfLocation <- createPDF(resultTable, analysisGroupData, parameters, summaryInfo, 
                               threshold = efficacyThreshold, experiment, dryRun)
      summaryInfo$info$"Summary" <- paste0('<a href="http://', racas::applicationSettings$client.host, ":", 
                                           racas::applicationSettings$client.port,
                                           "/tempFiles/", 
                                           experiment$codeName,'_SummaryDRAFT.pdf" target="_blank">Summary</a>')
      
      overrideLocation <- paste0("privateTempFiles/", experiment$codeName, "_OverrideDRAFT.csv")
      write.csv(userOverrideFrame, overrideLocation, na = "", row.names=FALSE)
      summaryInfo$info$"QC Entry" <- paste0('<a href="http://', racas::applicationSettings$client.host, ":", 
                                            racas::applicationSettings$client.port,
                                            "/tempFiles/", 
                                            experiment$codeName,'_OverrideDRAFT.csv" target="_blank">QC Entry</a>')
      
      resultsLocation <- paste0("privateTempFiles/", experiment$codeName, "_ResultsDRAFT.csv")
      write.csv(outputTable, resultsLocation, na = "", row.names=FALSE)
      summaryInfo$info$"Results" <- paste0('<a href="http://', racas::applicationSettings$client.host, ":", 
                                           racas::applicationSettings$client.port,
                                           "/tempFiles/", 
                                           experiment$codeName,'_ResultsDRAFT.csv" target="_blank">Results</a>')
      
      flagLocation <- paste0("privateTempFiles/", experiment$codeName, "_flagDRAFT.csv")
      write.csv(flaggedWells, flagLocation, na = "", row.names=FALSE)
      summaryInfo$info$"Flags" <- paste0('<a href="http://', racas::applicationSettings$client.host, ":", 
                                           racas::applicationSettings$client.port,
                                           "/tempFiles/", 
                                           experiment$codeName,'_flagDRAFT.csv" target="_blank">Flags</a>')
    }
  } else { #This section is "If not dry run"
    if (!is.null(zipFile)) {
      file.rename(zipFile, 
                  paste0(racas::getUploadedFilePath("experiments"),"/",experiment$codeName,"/rawData/", 
                         basename(zipFile)))
    }
    
    
    lsTransaction <- createLsTransaction()$id
    dir.create(paste0(racas::getUploadedFilePath("experiments"),"/",experiment$codeName,"/analysis"), showWarnings = FALSE)
    #experiment <<- experiment
    deleteExperimentAnalysisGroups <- function(experiment, lsServerURL = racas::applicationSettings$client.service.persistence.fullpath) {
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
    if (!useRdap) {
      rawResultsLocation <- paste0("experiments/",experiment$codeName,"/analysis/rawResults.Rda")
      save(resultTable,parameters,file=paste0(racas::getUploadedFilePath(rawResultsLocation)))
      
      resultsLocation <- paste0("experiments/", experiment$codeName,"/analysis/",experiment$codeName, "_Results.csv")
  
      write.csv(outputTable, paste0(racas::getUploadedFilePath(resultsLocation)), na = "", row.names=FALSE)
      
      pdfLocation <- createPDF(resultTable, analysisGroupData, parameters, summaryInfo, 
                               threshold = efficacyThreshold, experiment)
      if (parameters$aggregateReplicates != "no") {
        source("public/src/modules/PrimaryScreen/src/server/saveComparisonTraces.R")
        # They should be factors for saveComparisonTraces
        resultTable$barcode <- as.factor(resultTable$barcode)
        resultTable$batchName <- as.factor(resultTable$batchName)
        resultTable <- saveComparisonTraces(resultTable, paste0("experiments/", experiment$codeName, "/images"))
    }
    
    flagLocation <- paste0("experiments/", experiment$codeName,"/analysis/",experiment$codeName, "_Flags.csv")
    write.csv(flaggedWells, paste0(racas::getUploadedFilePath(flagLocation)), na = "", row.names=FALSE)
    
    #save(resultTable, treatmentGroupData, analysisGroupData, file = "test2.Rda")
    
    lsTransaction <- saveData(subjectData = resultTable, treatmentGroupData, analysisGroupData, user, experimentId)
    } else { # We are using Rdap
      
      meltStuff <- function(resultTable, resultTypes) {
        ## this could be done as a data table. Check out http://stackoverflow.com/questions/6902087/proper-fastest-way-to-reshape-a-data-table
        resultTable <- as.data.frame(resultTable)
           
        longResults <- reshape(resultTable, idvar = c("id"), ids = row.names(resultTable), 
                               v.names = "UnparsedValue", 
                               timevar = "valueKind", varying=list(resultTypes$columnName),
                               direction = "long", times=resultTypes$valueKind, drop="fileName")
        
        longResults <- merge(longResults, resultTypes)
        
        for (value in unique(longResults$valueType)) {
          if(value == 'numericValue') {
            longResults[[value]] <- NA
            longResults[[value]][longResults$valueType==value] <- as.numeric(longResults$UnparsedValue[longResults$valueType==value])
          } else {
            longResults[[value]] <- NA
            longResults[[value]][longResults$valueType==value] <- longResults$UnparsedValue[longResults$valueType==value]
          }
          
        }
        
        return(longResults)  
      }
      
      # transformed and normalized should be included if they are not null
      # resultKinds should include activityColumns, numericValue, data, results
      resultTypes <- data.frame(valueKind=c("barcode", "well name", "well type", "transformed efficacy"), valueType=c("codeValue", "stringValue", "stringValue", "numericValue"), 
                                columnName=c("barcode", "well", "wellType", "transformed"), 
                                stateType=c("metadata","metadata","metadata","data"), stateKind=c("plate information", "plate information", "plate information", "results"), 
                                stringsAsFactors=FALSE) 
      
      analysisGroupData <- meltStuff(resultTable, resultTypes)
      
      # Removes rows that have no compound data
      analysisGroupData <- analysisGroupData[ analysisGroupData$batchCode != "NA::NA", ]
      
      analysisGroupData$analysisGroupID <- analysisGroupData$index
      
      ## TODO Fix racas bugs, then remove
      # analysisGroupData$stateGroupIndex <- 1 #meltBatchcodes
      # analysisGroupData$publicData <- TRUE #meltBatchCodes
      # analysisGroupData$time <- NA #meltTimes
      # meltConcentrations fix to do other than treatmentGroup
      # add in acasEntityHierarchySpace
      # acasEntityHierarchySpace <- c("protocol", "experiment", "analysis group", "treatment group", "subject")
      ## End fix racas
      
      analysisGroupData$experimentID <- experimentId
      
      lsTransaction <- uploadData(analysisGroupData=analysisGroupData, recordedBy=user, lsTransaction=lsTransaction)
      
      analysisGroupData$experimentID <- experiment$id
      analysisGroupData$experimentVersion <- experiment$version
      
    }
    
    
    saveInputParameters(inputParameters, experiment, lsTransaction, user)
    
    if (!useRdap) {
      saveFileLocations(rawResultsLocation, resultsLocation, pdfLocation, flagLocation, experiment, dryRun, user, lsTransaction)
      
      #TODO: allow saving in an external file service
      summaryInfo$info$"Summary" <- paste0('<a href="http://', racas::applicationSettings$client.host, ":", 
                                           racas::applicationSettings$client.port,
                                           '/dataFiles/experiments/', experiment$codeName, "/analysis/", 
                                           experiment$codeName,'_Summary.pdf" target="_blank">Summary</a>')
      
      overrideLocation <- paste0(experiment$codeName, "_Override.csv")
      write.csv(userOverrideFrame, paste0(racas::getUploadedFilePath(overrideLocation)), 
                na = "", row.names=FALSE)
      summaryInfo$info$"QC Entry" <- paste0('<a href="http://', racas::applicationSettings$client.host, ":", 
                                            racas::applicationSettings$client.port,
                                            '/dataFiles/experiments/', experiment$codeName, "/analysis/", 
                                            experiment$codeName,'_Override.csv" target="_blank">QC Entry</a>')
      
      summaryInfo$info$"Results" <- paste0('<a href="http://', racas::applicationSettings$client.host, ":", 
                                           racas::applicationSettings$client.port,
                                           '/dataFiles/experiments/', experiment$codeName,"/analysis/", 
                                           experiment$codeName,'_Results.csv" target="_blank">Results</a>')
      
      flagLocation <- paste0(experiment$codeName, "_flag.csv")
      write.csv(flaggedWells, paste0(racas::getUploadedFilePath(flagLocation)), na = "",row.names=FALSE)
      summaryInfo$info$"Flags" <- paste0('<a href="http://', racas::applicationSettings$client.host, ":", 
                                         racas::applicationSettings$client.port,
                                         '/dataFiles/experiments/', experiment$codeName, "/analysis/", 
                                         experiment$codeName,'_Flags.csv" target="_blank">Flags</a>')
    }
    
    if (racas::applicationSettings$client.service.result.viewer.experimentNameColumn == "EXPERIMENT_NAME") {
      experimentName <- paste0(experiment$codeName, "::", experiment$lsLabels[[1]]$labelText)
    } else {
      experimentName <- experiment$lsLabels[[1]]$labelText
    }
    viewerLink <- paste0(racas::applicationSettings$client.service.result.viewer.protocolPrefix, 
                         URLencode(protocolName, reserved=TRUE), 
                         racas::applicationSettings$client.service.result.viewer.experimentPrefix,
                         URLencode(experimentName, reserved=TRUE))
    summaryInfo$viewerLink <- viewerLink
  }
  
  summaryInfo$lsTransactionId <- lsTransaction
  summaryInfo$experiment <- experiment
  
  return(summaryInfo)
}

getExperimentById <- function(experimentId, include="", errorEnv=NULL, lsServerURL = racas::applicationSettings$client.service.persistence.fullpath) {
  require('RCurl')
  experiment <- NULL
  tryCatch({
    if(include=="") {
      experiment <- getURL(paste0(lsServerURL, "experiments/", experimentId))
    } else {
      experiment <- getURL(paste0(lsServerURL, "experiments/", experimentId, "?with=", include))  
    }
    experiment <- fromJSON(experiment)
  }, error = function(e) {
    addError(paste0("Could not get experiment ", experimentId, " from the server"), errorEnv)
  })
  return(experiment)
}

saveFullEntityData <- function(entityData, entityKind) {
  
  ### local names
  # entityData[[paste0(entityKind, "ID")]] must be numeric
  acasEntity <- changeEntityMode(entityKind, "camel", "lowercase")
  entityID <- paste0(entityKind, "ID")
  tempIds <- c()
  
  ### Error checking
  if (!(entityID %in% names(entityData))) {
    stop(paste0("Internal Error: Column ", entityID, " is not a missing from entityData"))
  }
  
  ### main code
  thingTypeAndKind <- paste0("document_", changeEntityMode(entityKind, "camel", "space"))
  entityCodeNameList <- unlist(getAutoLabels(thingTypeAndKind=thingTypeAndKind, 
                                             labelTypeAndKind="id_codeName", 
                                             numberOfLabels=max(entityData[[entityID]], na.rm=TRUE)),
                               use.names=FALSE)
  
  entityData$analysisGroupCodeName <- entityCodeNameList[entityData[[entityID]]]
  
  createEntity <- function(codeName, lsType, lsKind, recordedBy, lsTransaction) {
    return(list(
      codeName=codeName,
      lsType=lsType,
      lsKind=lsKind,
      recordedBy=recordedBy,
      lsTransaction=lsTransaction))
  }
  
  createEntityFromDF <- function(dfData, currentEntity) {
    entity <- createEntity(
      lsType = "default",
      lsKind = "default",
      codeName=dfData[[paste0(currentEntity, "CodeName")]][1],
      recordedBy=dfData$recordedBy[1],
      lsTransaction=dfData$lsTransaction[1])
    upperAcasEntity <- acasEntityHierarchyCamel[which(currentEntity == acasEntityHierarchyCamel) - 1]
    if (is.null(dfData[[paste0(upperAcasEntity, "ID")]][1])) {
      stop("Internal Error: No ", paste0(upperAcasEntity, "ID"), " found in data")
    }
    if (is.null(dfData[[paste0(upperAcasEntity, "ID")]][1])) {
      stop("Internal Error: No ", paste0(upperAcasEntity, "Version"), " found in data")
    }
    entity[[upperAcasEntity]] <- list(id=dfData[[paste0(upperAcasEntity, "ID")]][1],
                                      version=dfData[[paste0(upperAcasEntity, "Version")]][1])
    return(entity)
  }
  
  entities <- dlply(.data=entityData, .variables = paste0(entityKind, "ID"), createEntityFromDF, currentEntity=entityKind)
  tempIds <- as.numeric(names(entities))
  
  names(entities) <- NULL
  savedEntities <- saveAcasEntities(entities, paste0(acasEntity, "s"))
  
  if (length(savedEntities) != length(entities)) {
    stop(paste0("Internal Error: roo server did not respond with the same number of ", acasEntity, "s after a post"))
  }
  
  entityIds <- sapply(savedEntities, getElement, "id")
  entityVersions <- sapply(savedEntities, getElement, "version")
  
  entityData[[entityID]] <- entityIds[match(entityData[[entityID]], tempIds)]
  
  ###### entity States #######
  
  stateAndVersion <- saveStatesFromExplicitFormat(entityData, entityKind)
  entityData$stateID <- stateAndVersion$entityStateId
  entityData$stateVersion <- stateAndVersion$entityStateVersion
  
  ### entity Values ======================================================================= 
  
  savedEntityValues <- saveValuesFromExplicitFormat(entityData, entityKind)
  #
  
  return(data.frame(tempID = tempIds, entityID = entityIds, entityVersion = entityVersions))
}

saveStatesFromExplicitFormat <- function(entityData, entityKind, testMode=FALSE) {
  #TODO: should allow containers or interactions
  idColumn = "stateID"
  entityID = paste0(entityKind, "ID")
  entityVersion = paste0(entityKind, "Version")
  
  acasServerEntity <- changeEntityMode(entityKind, "camel", "lowercase")
  
  
  # If no version given, assume version 0
  if (!(entityVersion %in% names(entityData))) {
    entityData[[entityVersion]] <- 0
  }
  
  if (!(idColumn %in% names(entityData))) {
    stop(paste0("Internal Error: ", idColumn, " must be a column in entityData"))
  }
  
  if (!(entityKind %in% racas::acasEntityHierarchyCamel)) {
    stop("Internal Error: entityKind must be in racas::acasEntityHierarchyCamel")
  }
  
  if (!(entityID %in% names(entityData))) {
    stop("Internal Error: ", entityID, " must be included in entityData")
  }
  
  createExplicitLsState <- function(entityData, entityKind) {
    # TODO: add stateType and StateKind to meltBatchCodes
    lsType <- entityData$stateType[1]
    lsKind <- entityData$stateKind[1]
    lsState <- list(lsType = entityData$stateType[1],
                    lsKind = entityData$stateKind[1],
                    recordedBy = entityData$recordedBy[1],
                    lsTransaction = entityData$lsTransaction[1])
    # e.g. lsState$analysisGroup <- list(id=entityData$analysisGroupID[1], version=0)
    lsState[[entityKind]] <- list(id = entityData[[entityID]][1], version = entityData[[entityVersion]][1])
    return(lsState)
  }
  
  lsStates <- dlply(.data=entityData, .variables=idColumn, .fun=createExplicitLsState, entityKind=entityKind)
  originalStateIds <- names(lsStates)
  names(lsStates) <- NULL
  if (testMode) {
    lsStates <- lapply(lsStates, function(x) {x$recordedDate <- 1381939115000; return (x)})
    return(toJSON(lsStates))
  } else {
    savedLsStates <- saveAcasEntities(lsStates, paste0(acasServerEntity, "states"))
  }
  
  lsStateIds <- sapply(savedLsStates, getElement, "id")
  lsStateVersions <- sapply(savedLsStates, getElement, "version")
  entityStateTranslation <- data.frame(entityStateId = lsStateIds, 
                                       originalStateId = originalStateIds, 
                                       entityStateVersion = lsStateVersions)
  stateIdAndVersion <- entityStateTranslation[match(entityData[[idColumn]], 
                                                    entityStateTranslation$originalStateId),
                                              c("entityStateId", "entityStateVersion")]
  return(stateIdAndVersion)
}

saveValuesFromExplicitFormat <- function(entityData, entityKind, testMode=FALSE) {
  ### static variables
  #TODO: should allow containers or interactions
  idColumn = "stateID"
  acasServerEntity <- changeEntityMode(entityKind, "camel", "lowercase")
  
  #create a uniqueID to split on
  entityData$uniqueID <- 1:(nrow(entityData))
  
  optionalColumns <- c("fileValue", "urlValue", "codeValue", "numericValue", "dateValue",
                       "valueOperator", "valueUnit", "clobValue", "blobValue", "numberOfReplicates",
                       "uncertainty", "uncertaintyType", "comments")
  missingOptionalColumns <- Filter(function(x) !(x %in% names(entityData)),
                                   optionalColumns)
  entityData[missingOptionalColumns] <- NA
  
  ### Error Checking
  requiredColumns <- c("valueType", "valueKind", "publicData", "stateVersion", "stateID")
  if (any(!(requiredColumns %in% names(entityData)))) {
    stop("Internal Error: Missing input columns in entityData, must have ", paste(requiredColumns, collapse = ", "))
  }
  
  # Turns factors to character
  factorColumns <- vapply(entityData, is.factor, c(TRUE))
  entityData[factorColumns] <- lapply(entityData[factorColumns], as.character)
  
  if (is.character(entityData$dateValue)) {
    entityData$dateValue[entityData$dateValue == ""] <- NA
    entityData$dateValue <- as.numeric(format(as.Date(entityData$dateValue,origin="1970-01-01"), "%s"))*1000
  } else if (is.numeric(entityData$dateValue)) {
    # No change
  } else if (is.null(entityData$dateValue) || all(is.na(entityData$dateValue))) {
    entityData$dateValue <- as.character(NA)
  } else {
    stop("Internal Error: unrecognized class of entityData$dateValue: ", class(entityData$dateValue))
  }
  
  
  
  ### Helper function
  createLocalStateValue <- function(valueData) {
    stateValue <- with(valueData, {
      createStateValue(
        lsState = list(id = stateID, version = stateVersion),
        lsType = if (valueType %in% c("stringValue", "fileValue", "urlValue", "dateValue", "clobValue", "blobValue", "numericValue", "codeValue")) {
          valueType
        } else {"numericValue"},
        lsKind = valueKind,
        stringValue = if (is.character(stringValue) && !is.na(stringValue)) {stringValue} else {NULL},
        dateValue = if(is.numeric(stringValue)) {dateValue} else {NULL},
        clobValue = if(is.character(clobValue) && !is.na(clobValue)) {clobValue} else {NULL},
        blobValue = if(!is.null(blobValue) && !is.na(blobValue)) {blobValue} else {NULL},
        codeValue = if(is.character(codeValue) && !is.na(codeValue)) {codeValue} else {NULL},
        fileValue = if(is.character(fileValue) && !is.na(fileValue)) {fileValue} else {NULL},
        urlValue = if(is.character(urlValue) && !is.na(urlValue)) {urlValue} else {NULL},
        valueOperator = if(is.character(valueOperator) && !is.na(valueOperator)) {valueOperator} else {NULL},
        operatorType = if(is.character(operatorType) && !is.na(operatorType)) {operatorType} else {NULL},
        numericValue = if(is.numeric(numericValue) && !is.na(numericValue)) {numericValue} else {NULL},
        valueUnit = if(is.character(valueUnit) && !is.na(valueUnit)) {valueUnit} else {NULL},
        unitType = if(is.character(unitType) && !is.na(unitType)) {unitType} else {NULL},
        publicData = publicData,
        lsTransaction = lsTransaction,
        numberOfReplicates = if(is.numeric(numberOfReplicates) && !is.na(numberOfReplicates)) {numberOfReplicates} else {NULL},
        uncertainty = if(is.numeric(uncertainty) && !is.na(uncertainty)) {uncertainty} else {NULL},
        uncertaintyType = if(is.character(uncertaintyType) && !is.na(uncertaintyType)) {uncertaintyType} else {NULL},
        recordedBy = recordedBy,
        comments = if(is.character(comments) && !is.na(comments)) {comments} else {NULL}
      )
    })
    return(stateValue)
  }
  entityValues <- plyr::dlply(.data = entityData, 
                              .variables = .(uniqueID), 
                              .fun = createLocalStateValue)
  
  names(entityValues) <- NULL
  
  if (testMode) {
    entityValues <- lapply(entityValues, function(x) {x$recordedDate <- 42; return (x)})
    return(toJSON(entityValues))
  } else {
    savedEntityValues <- saveAcasEntities(entityValues, paste0(acasServerEntity, "values"))
    return(savedEntityValues)
  }
}

# saveAcasEntities <- function(entities, acasCategory, lsServerURL = racas::applicationSettings$client.service.persistence.fullpath) {
#   binSize <- 1000
#   if (length(entities) > binSize) {
#     numberOfSplits <- ceiling(length(entities)/binSize)
#     remainderEntities <- length(entities) %% binSize
#     allSaves <- list()
#     i <- 1
#     for (i in 1:numberOfSplits){
#       output <- NULL
#       if (i == 1){
#         entityStart <- 1
#         entityEnd <- binSize
#       } else {
#         entityStart <- (i * binSize) + 1
#         entityEnd <- (i+1) * binSize
#         if (entityEnd > length(entities)){
#           entityEnd <- length(entities) 
#         }
#       }
#             print(i) #7 7
#       ## start debug 
#              entityStart <- 1
#              entityEnd <- 2
#              if (entityEnd > length(entities)){
#                entityEnd <- length(entities) 
#              }
#       ## end debug
#       output <- saveAcasEntitiesInternal(entities[entityStart:entityEnd], acasCategory, lsServerURL)
#       allSaves[[i]] <- output
#     }
#     #     output <- saveAcasEntitiesInternal(entities[1:1000], acasCategory, lsServerURL)
#     #     otherSaves <- saveAcasEntities(entities[1001:2000], acasCategory, lsServerURL)
#     #     otherSaves <- saveAcasEntities(entities[1001:length(entities)], acasCategory, lsServerURL)
#     #     return(c(output, otherSaves))
#     return(allSaves)
#   } else {
#     return(saveAcasEntitiesInternal(entities, acasCategory, lsServerURL))
#   }
# }
# 
# saveAcasEntitiesInternal <- function(entities, acasCategory, lsServerURL = racas::applicationSettings$client.service.persistence.fullpath) {
#   # If you have trouble, make sure the acasCategory is all lowercase, has no spaces, and is plural
#   logName = "com.acas.racas.saveAcasEntitiesInternal"
#   logFileName = file.path(racas::applicationSettings$server.log.path, "racas.log")
# 
#   h = basicTextGatherer()
#   
#   message <- toJSON(entities)
#   response <- getURL(
#     paste0(lsServerURL, acasCategory, "/jsonArray"),
#     customrequest='POST',
#     httpheader=c('Content-Type'='application/json'),
#     postfields=message,
#     headerfunction = h$update)
#   responseHeader <- as.list(parseHTTPHeader(h$value()))
#   statusCode <- as.numeric(responseHeader$status)
#   if (statusCode >= 400) {
#     myLogger <- createLogger(logName = logName, logFileName = logFileName)
#     errorMessage <- paste0("Request to ", lsServerURL, acasCategory, "/jsonArray with method 'POST' failed with status '",
#                            statusCode, " ", responseHeader$statusMessage, "' when sent the following JSON: \n", 
#                            message, "\nHeader was \n", h$value())
#     myLogger$error(errorMessage)
#     stop (paste0("Internal Error: The loader was unable to save your ", acasCategory, ". Check the log ", 
#                  logFileName, " at ", Sys.time()))
#   } else if (grepl("^<",response)) {
#     myLogger <- createLogger(logName = logName, logFileName = logFileName)
#     myLogger$error(response)
#     stop (paste0("Internal Error: The loader was unable to save your ", acasCategory, ". Check the logs at ", Sys.time()))
#   } else if (grepl("^\\s*$", response)) {
#     return(list())
#   }
#   response <- fromJSON(response)
#   return(response)
# }

changeEntityMode <- function(entityKind, currentMode, desiredMode) {
  entityKindIndex <- switch(
    currentMode,
    lowercase = which(entityKind == acasEntityHierarchy),
    camel = which(entityKind == acasEntityHierarchyCamel),
    space = which(entityKind == acasEntityHierarchySpace),
    stop(paste0("Internal error: ", currentMode, " is not a valid mode")))
  
  return(switch(
    desiredMode,
    lowercase = acasEntityHierarchy[entityKindIndex],
    camel = acasEntityHierarchyCamel[entityKindIndex],
    space = acasEntityHierarchySpace[entityKindIndex],
    stop(paste0("Internal error: ", desiredMode, " is not a valid mode"))))
}

uploadData <- function(lsTransaction=NULL,analysisGroupData,treatmentGroupData=NULL,subjectData=NULL,
                       recordedBy) {
  # Uploads all the data to the server
  # 
  # Args:
  #   metaData:               A data frame of the meta data
  #   lsTransaction:          An id of the transaction
  #   calculatedResults:      A data frame of the calculated results (analysis group data)
  #   treatmentGroupData:     A data frame of the treatment group data
  #   rawResults:             A data frame of the raw results (subject group data)
  #   xLabel:                 A string with the name of the variable that is in the 'x' column
  #   yLabel:                 A string with the name of the variable that is in the 'y' column
  #   tempIdLabel:            A string with the name of the variable that is in the 'temp id' column
  #   testOutputLocation:     A string with the file location to output a JSON file to when dryRun is TRUE
  #   developmentMode:        A boolean that marks if the JSON request should be saved to a file
  #
  #   Returns:
  #     lsTransaction
  
  library('plyr')
  
  if(is.null(lsTransaction)) {
    lsTransaction <- createLsTransaction()$id
  }
    
  ### Analysis Group Data
  # Not all of these will be filled
  analysisGroupData$stateID <- paste0(analysisGroupData$analysisGroupID, "-", analysisGroupData$stateGroupIndex, "-", 
                                      analysisGroupData$concentration, "-", analysisGroupData$concentrationUnit, "-",
                                      analysisGroupData$time, "-", analysisGroupData$timeUnit, "-", analysisGroupData$stateKind)
  
  if(is.null(analysisGroupData$publicData) && nrow(analysisGroupData) > 0) {
    analysisGroupData$publicData <- TRUE
  }
  if(is.null(analysisGroupData$stateGroupIndex) && nrow(analysisGroupData) > 0) {
    analysisGroupData$stateGroupIndex <- 1
  }
  
  analysisGroupData <- rbind.fill(analysisGroupData, meltConcentrations(analysisGroupData))
  analysisGroupData <- rbind.fill(analysisGroupData, meltTimes(analysisGroupData))
  analysisGroupData <- rbind.fill(analysisGroupData, meltBatchCodes(analysisGroupData, 0, optionalColumns = "analysisGroupID"))
  
  analysisGroupData$lsTransaction <- lsTransaction
  analysisGroupData$recordedBy <- recordedBy
  
  analysisGroupIDandVersion <- saveFullEntityData(analysisGroupData, "analysisGroup")
  
  if(!is.null(treatmentGroupData)) {
    ### TreatmentGroup Data
    treatmentGroupData$lsTransaction <- lsTransaction
    treatmentGroupData$recordedBy <- recordedBy
    
    matchingID <- match(treatmentGroupData$analysisGroupID, analysisGroupIDandVersion$tempID)
    treatmentGroupData$analysisGroupID <- analysisGroupIDandVersion$entityID[matchingID]
    treatmentGroupData$analysisGroupVersion <- analysisGroupIDandVersion$entityVersion[matchingID]
    
    treatmentGroupData$stateID <- paste0(treatmentGroupData$treatmentGroupID, "-", treatmentGroupData$stateGroupIndex, "-", 
                                         treatmentGroupData$concentration, "-", treatmentGroupData$concentrationUnit, "-",
                                         treatmentGroupData$time, "-", treatmentGroupData$timeUnit, "-", treatmentGroupData$stateKind)
    
    treatmentGroupData <- rbind.fill(treatmentGroupData, meltConcentrations(treatmentGroupData))
    treatmentGroupData <- rbind.fill(treatmentGroupData, meltTimes(treatmentGroupData))
    treatmentGroupData <- rbind.fill(treatmentGroupData, meltBatchCodes(treatmentGroupData, 0, optionalColumns = "treatmentGroupID"))
    
    treatmentGroupIDandVersion <- saveFullEntityData(treatmentGroupData, "treatmentGroup")
    
    ### subject Data
    subjectData$lsTransaction <- lsTransaction
    subjectData$recordedBy <- recordedBy
    
    matchingID <- match(subjectData$treatmentGroupID, treatmentGroupIDandVersion$tempID)
    subjectData$treatmentGroupID <- treatmentGroupIDandVersion$entityID[matchingID]
    subjectData$treatmentGroupVersion <- treatmentGroupIDandVersion$entityVersion[matchingID]
    
    subjectData$stateID <- paste0(subjectData$subjectID, "-", subjectData$stateGroupIndex, "-", 
                                  subjectData$concentration, "-", subjectData$concentrationUnit, "-",
                                  subjectData$time, "-", subjectData$timeUnit, "-", subjectData$stateKind)
    
    subjectData <- rbind.fill(subjectData, meltConcentrations(subjectData))
    subjectData <- rbind.fill(subjectData, meltTimes(subjectData))
    subjectData <- rbind.fill(subjectData, meltBatchCodes(subjectData, 0, optionalColumns = "subjectID"))
    
    subjectIDandVersion <- saveFullEntityData(subjectData, "subject")
  }
  
  return (lsTransaction)
}

runPrimaryAnalysis <- function(request) {
  # Highest level function, runs everything else
  library('racas')
  options("scipen"=15)
  save(request, file="request.Rda")
  request <- as.list(request)
  experimentId <- request$primaryAnalysisExperimentId
  folderToParse <- request$fileToParse
  dryRun <- request$dryRunMode
  user <- request$user
  testMode <- request$testMode
  inputParameters <- request$inputParameters
  flaggedWells <- request$flaggedWells
  # Fix capitalization mismatch between R and javascript
  dryRun <- interpretJSONBoolean(dryRun)
  testMode <- interpretJSONBoolean(testMode)
  # Set up the error handling for non-fatal errors, and add it to the search path (almost like a global variable)
  errorHandlingBox <- list(errorList = list())
  attach(errorHandlingBox)
  # If there is a global defined by another R code, this will overwrite it
  errorList <<- list()
  
  loadResult <- tryCatch.W.E(runMain(folderToParse, 
                                     user, 
                                     dryRun, 
                                     testMode, 
                                     experimentId, 
                                     inputParameters,
                                     flaggedWells))
  
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
