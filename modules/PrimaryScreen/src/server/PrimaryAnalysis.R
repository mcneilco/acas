# PrimaryAnalysis.R
#
#
# Sam Meyer
# sam@mcneilco.com
# Copyright 2012-2014 John McNeil & Co. Inc.
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
# request <- fromJSON("{\"primaryAnalysisReads\":[{\"readPosition\":11,\"readName\":\"none\",\"activity\":true},{\"readPosition\":12,\"readName\":\"fluorescence\",\"activity\":false},{\"readPosition\":13,\"readName\":\"luminescence\",\"activity\":false}],\"transformationRules\":[{\"transformationRule\":\"percent efficacy\"},{\"transformationRule\":\"sd\"},{\"transformationRule\":\"null\"}],\"primaryScreenAnalysisParameters\":{\"positiveControl\":{\"batchCode\":\"CMPD-12345678-01\",\"concentration\":10,\"concentrationUnits\":\"uM\"},\"negativeControl\":{\"batchCode\":\"CMPD-87654321-01\",\"concentration\":1,\"concentrationUnits\":\"uM\"},\"agonistControl\":{\"batchCode\":\"CMPD-87654399-01\",\"concentration\":250753.77,\"concentrationUnits\":\"uM\"},\"vehicleControl\":{\"batchCode\":\"CMPD-00000001-01\",\"concentration\":null,\"concentrationUnits\":null},\"instrumentReader\":\"flipr\",\"signalDirectionRule\":\"increasing signal (highest = 100%)\",\"aggregateBy\":\"compound batch concentration\",\"aggregationMethod\":\"median\",\"normalizationRule\":\"plate order only\",\"hitEfficacyThreshold\":42,\"hitSDThreshold\":5,\"thresholdType\":\"sd\",\"transferVolume\":12,\"dilutionFactor\":21,\"volumeType\":\"dilution\",\"assayVolume\":24,\"autoHitSelection\":false,\"htsFormat\":false,\"matchReadName\":false,\"primaryAnalysisReadList\":[{\"readPosition\":11,\"readName\":\"none\",\"activity\":true},{\"readPosition\":12,\"readName\":\"fluorescence\",\"activity\":false},{\"readPosition\":13,\"readName\":\"luminescence\",\"activity\":false}],\"transformationRuleList\":[{\"transformationRule\":\"percent efficacy\"},{\"transformationRule\":\"sd\"},{\"transformationRule\":\"null\"}]}}")
############ testMode TRUE #############
# file.copy("/Users/smeyer/Documents/clients/XXX/Specific Data Processor/Archive (2).zip", "privateUploads/")
# file.copy("public/src/modules/PrimaryScreen/spec/specFiles/Step2_Renormalize_Input_v2.txt", "privateUploads/")
# request <- structure(list(fileToParse = "Archive (2).zip", reportFile = "Step2_Renormalize_Input_v2.txt", dryRunMode = TRUE, user = "bob", primaryAnalysisExperimentId = 203528, testMode = "true", flaggedWells = "Step2_Renormalize_Input_v2.txt", inputParameters = "{\"positiveControl\":{\"batchCode\":\"XXX001315929\",\"concentration\":0.5,\"concentrationUnits\":\"uM\"},\"negativeControl\":{\"batchCode\":\"XXX000000001\",\"concentration\":0,\"concentrationUnits\":\"uM\"},\"agonistControl\":{\"batchCode\":\"null\",\"concentration\":null,\"concentrationUnits\":\"null\"},\"vehicleControl\":{\"batchCode\":\"null\",\"concentration\":null,\"concentrationUnits\":null},\"instrumentReader\":\"flipr\",\"signalDirectionRule\":\"increasing signal (highest = 100%)\",\"aggregateBy\":\"compound batch concentration\",\"aggregationMethod\":\"median\",\"normalizationRule\":\"plate order only\",\"hitEfficacyThreshold\":42,\"hitSDThreshold\":5,\"thresholdType\":\"sd\",\"transferVolume\":12,\"dilutionFactor\":21,\"volumeType\":\"dilution\",\"assayVolume\":24,\"autoHitSelection\":false,\"htsFormat\":false,\"matchReadName\":false,\"primaryAnalysisReadList\":[{\"readPosition\":1,\"readName\":\"none\",\"activity\":true}],\"transformationRuleList\":[{\"transformationRule\":\"percent efficacy\"},{\"transformationRule\":\"sd\"},{\"transformationRule\":\"null\"}]}"), .Names = c("fileToParse", "reportFile", "dryRunMode", "user", "primaryAnalysisExperimentId", "testMode", "flaggedWells", "inputParameters"))
############ testMode FALSE #############
# file.copy("/Users/smeyer/Documents/clients/XXX/Specific Data Processor/ArchiveNonTest.zip", "privateUploads/")
# request <- structure(list(fileToParse = "ArchiveNonTest.zip", reportFile = "", imagesFile = "", dryRunMode = "true", user = "bob", inputParameters = "{\"instrumentReader\":\"flipr\",\"signalDirectionRule\":\"increasing signal (highest = 100%)\",\"aggregateBy\":\"compound batch concentration\",\"aggregationMethod\":\"median\",\"normalizationRule\":\"plate order only\",\"assayVolume\":24,\"transferVolume\":1.1428571428571428,\"dilutionFactor\":21,\"hitEfficacyThreshold\":null,\"hitSDThreshold\":5,\"positiveControl\":{\"batchCode\":\"XXX001315929\",\"concentration\":0.1},\"negativeControl\":{\"batchCode\":\"XXX000000001\",\"concentration\":0},\"vehicleControl\":{\"batchCode\":\"\",\"concentration\":null},\"agonistControl\":{\"batchCode\":\"\",\"concentration\":\"\"},\"thresholdType\":\"sd\",\"volumeType\":\"dilution\",\"htsFormat\":false,\"autoHitSelection\":false,\"matchReadName\":false,\"primaryAnalysisReadList\":[{\"readPosition\":1,\"readName\":\"test\",\"activity\":true}],\"transformationRuleList\":[{\"transformationRule\":\"percent efficacy\"},{\"transformationRule\":\"sd\"}]}", primaryAnalysisExperimentId = "1086654", testMode = "false"), .Names = c("fileToParse", "reportFile", "imagesFile", "dryRunMode", "user", "inputParameters", "primaryAnalysisExperimentId", "testMode"))


source("src/r/ServerAPI/customFunctions.R", local=TRUE)
# TODO: Test structure, probably removing this folder eventually
clientName <- "exampleClient"

# Source the client specific compound assignment functions
compoundAssignmentFilePath <- file.path("src/r/PrimaryScreen/compoundAssignment",
                                        clientName)
compoundAssignmentFileList <- list.files(compoundAssignmentFilePath, full.names=TRUE, pattern = "*.R$")
for (sourceFile in compoundAssignmentFileList) { # Cannot use lapply because then "local" is inside lapply
  source(sourceFile, local=TRUE)
}

# inputParameters$timeWindowList <- list(
#   list(windowName = "T1", statistic="max", windowStart=15, windowEnd=30, windowUnit = "s"),
#   list(windowName = "T2", statistic="min", windowStart=5, windowEnd=10, windowUnit = "s")
#   )


getWellFlagging <- function (flaggedWells, resultTable, flaggingStage, experiment, parameters) {
  # flaggedWells: the name of a csv or Excel file that lists each well's barcode, 
  #               well number, and if it's flagged. If NULL, the file did not exist,
  #               and no wells are flagged. Also may include information to flag analysis groups.
  
  if(is.null(flaggedWells) || flaggedWells == "") {
    resultTable[, flag:=NA_character_]
    resultTable[, flagType:=NA_character_]
    resultTable[, flagObservation:=NA_character_]
    resultTable[, flagReason:=NA_character_]
    resultTable[, flagComment:=NA_character_]
    return(resultTable)
  }

  # Get a table of flags associated with the data. If there was no file name given, then all flags are NA
  flagData <- getWellFlags(flaggedWells, resultTable, flaggingStage, experiment, parameters)
  
  # In order to merge with a data.table, the columns have to have the same name
  resultTable <- merge(resultTable, flagData, by = c("assayBarcode", "well"), all.x = TRUE, all.y = FALSE)
  
  # Sort the data ? Why do this ?
  if (all(c("row","column") %in% names(resultTable))) {
    setkeyv(resultTable, c("assayBarcode","row","column"))
  }
  
  resultTable[ , flag := as.character(NA)]
  
  resultTable[flagType=="knocked out", flag := "KO"]
  
  checkFlags(resultTable)
  
  return(resultTable)
}

getWellFlags <- function(flaggedWells, resultTable, flaggingStage, experiment, parameters) {
  # Reads the flagged wells from an input csv or Excel file
  # Input: flaggedWells, the name of a file in privateUploads that contains well-flagging information
  #        resultTable, a data.table that must contain all of the barcodes and wells for the data set
  #        flaggingStage, a string indicating whether the user intends to modify "wellFlags" or
  #                       "analysisGroupFlags" or spotfire "KOandHit"
  # Returns: a data.table with each barcode, well, and associated flag. All column names are lowercase.
  
  # Extract information from the flag file
  flagData <- parseWellFlagFile(flaggedWells, resultTable)
  
  flagData <- changeColNameReadability(flagData, "humanToComputer", parameters)
  
  # Ensure that the data is in the proper form
  validatedFlagData <- validateWellFlagData(flagData, resultTable)
  
  # Throw errors if the user is supposed to be flagging wells, but has actually flagged analysis groups
  if(flaggingStage == "wellFlags") {
    validateFlaggingStage(validatedFlagData, flaggingStage, experiment)
  }
  
  # Remove unneeded columns
  # flagData <- data.table(assayBarcode = validatedFlagData$assayBarcode, well = validatedFlagData$well, flag = validatedFlagData$flag)
  flagData <- as.data.table(validatedFlagData[, list(assayBarcode, well, flagType, 
                                                     flagObservation, flagReason, flagComment)])
  
  return(flagData)
}
getUserHits <- function(analysisGroupData, flaggedWells, resultTable, replicateType, experiment, flaggingStage) {
  # Determines which analysis groups the user believes should count as a 'hit'
  #
  # Input:   analysisGroupData, a table containing (at minumum) the barcode, batch ID, and
  #             threshold (system-defined hit) for each analysis group
  #          flaggedWells, a string containing the name of the file in privateUploads that 
  #             has flagging information
  #          resultTable, a data frame containing, at the minumum, the barcode, threshold,
  #             batchName and well for each test
  #          replicateType, a string that defines an analysis group (ie, "across plate")
  #          experiment, a list that is an experiment, and contains a code name
  #          flaggingStage, a string indicating whether the user intends to modify "wellFlags" or
  #                       "analysisGroupFlags" or spotfire "KOandHit"
  # Returns: analysisGroupData: the original table, including a column indicating whether the user specified
  #             an analysis group as a hit or a miss
  #          summaryFlagData: the batchName and userHit columns for every piece of data
  
  # Extract information from the flag file
  flagData <- parseAnalysisFlagFile(flaggedWells, resultTable)
  
  # Ensure that the data is in the proper form
  validatedFlagData <- validateAnalysisFlagData(flagData, analysisGroupData, replicateType, flaggingStage)
  
  # Throw errors if the user is supposed to be flagging analysis groups, but has actually flagged wells
  if(!is.null(flaggingStage) && flaggingStage == "analysisGroupFlags") {
    validateFlaggingStage(validatedFlagData, flaggingStage, experiment)
  }
  
  # If the validation returned null, then there wasn't enough information to flag analysis groups,
  # so we use the system hits. Ditto if we're in "wellFlags" mode
  if (is.null(validatedFlagData) || flaggingStage == "wellFlags") {
    analysisGroupData$userHit <- analysisGroupData$threshold
  } else {
    # Get a data table of the identifying analysis group columns (eg, batch and barcode) 
    # along with the user-defined hit, for all groups that had a hit defined (also handles errors)
    testFlagData <- removeControls(validatedFlagData)
    minimalFlagInformation <- summarizeAnalysisFlags(testFlagData, replicateType)
    analysisGroupData <- fillAnalysisFlags(replicateType, analysisGroupData, minimalFlagInformation)
  }
  
  summaryFlagData <- data.frame(userHit = validatedFlagData$userHit, 
                                batchName = validatedFlagData$batchName,
                                stringsAsFactors = FALSE)
  
  return(list(analysisGroupData = analysisGroupData, flagData = summaryFlagData))
}

removeControls <- function(validatedFlagData) {
  # Remove all rows that are not labeled "test", and adds warnings if you try to flag a non-test well
  #
  # Input: validatedFlagData, a data.table which should contain columns labeled "wellType", "hit", and "userHit"
  # Returns: The same data frame, with only the rows with a wellType of "test"
  
  testOnly <- validatedFlagData[wellType == "test"]
  controlOnly <- validatedFlagData[wellType != "test"]
  
  flaggedControls <- controlOnly[!is.na(userHit) & userHit != ""]
  diffList <- which(flaggedControls$hit != tolower(flaggedControls$userHit))
  if (length(diffList) > 0) {
    stopUser(paste0("Only hits in wells marked as 'test' can be overriden by the user. Please ensure ",
                    "that the 'User Defined Hit' matches the 'Hit' column for non-test wells in the following ",
                    "coroprate batch IDs: ", paste0(unique(flaggedControls[diffList]$batchName), collapse = ", ")))
  }
  
  return(testOnly)
}
getWellTypes <- function(batchNames, concentrations, concentrationUnits, testMode=F,
                         standardsDT, normalizationRule) {
  # Takes vectors of batchNames, concentrations, and concunits 
  # and compares to named lists of the same for positive and negative controls
  wellTypes <- rep.int("test", length(batchNames))

  toleranceRange <- racas::applicationSettings$client.service.control.tolerance.percentage # percent
  if (is.null(toleranceRange)) {
    warnUser("Config issue: control tolerance client.service.control.tolerance.percentage not set")
    toleranceRange <- 0
  }
  #   toleranceRange <- 0.01


  # Throw an error if absolutely no standards are defined in the GUI
  if (nrow(standardsDT)==0) {
    stopUser("No Standards were defined whatsoever.")
  }
  # Throw an error if no negative controls are defined in the GUI
  if (!any(standardsDT$standardType=='NC') && normalizationRule != "none") {
    stopUser("No Negative Control Standards were defined. Either set negative controls, or use normalization of 'none'.")
  }
  # Throw an error if no positive controls are defined in the GUI
  if (!any(standardsDT$standardType=='PC') && normalizationRule != "none") {
    stopUser("No Positive Control Standards were defined. Either set negative controls, or use normalization of 'none'.")
  }
  # Throw an error if any of the standards was left unassigned in the GUI
  if (any(standardsDT$standardType=="unassigned")) {
    stopUser("The standard type for at least one Standard was not defined. Please select a type: Positive Control, Negative Control, or Vehicle Control")
  }
  
  # Cycling through all the standards, update well types accordingly, checking each standard within tolerance
  # from the corresponding concentrations (as defined in the standards section of the GUI)
  for (row in 1:nrow(standardsDT)) {
    targetConc <- standardsDT$concentration[row]
    targetBatchCode <- standardsDT$batchCode[row]
    concFilter <- TRUE
    if (!is.na(targetConc)) {
      concFilter <- abs(concentrations-targetConc) <= (targetConc * toleranceRange)/100
    }
    wellTypes[batchNames==targetBatchCode & concFilter] <- standardsDT$standardTypeEnumerated[row]
  }
  
  return(wellTypes)
}
getAnalysisGroupColumns <- function(replicateType) {
  # Determines what data is necessary to define an analysis group
  # Input: replicateType, a string indicating the type of well grouping in the experiment
  # Output: a vector of strings indicating what characteristics are required to uniquely define
  #         an analysis group
  switch(replicateType,
         "across plates" = {
           requiredColumns <- c("batchName")
         },
         "within plates" = {
           requiredColumns <- c("batchName", "assayBarcode")
         },
         {
           requiredColumns <- c("well")
         })
  return(requiredColumns)
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

createPlots <- function(resultTable, parameters){
  source("primaryAnalysisPlots.R", local = TRUE)
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
  #create heatmap for average of set (median or mean, depending on user input)
  plateDataTable <- data.table(values = resultTable$normalized, 
                               well = resultTable$well)
  plateData <- plateDataTable[,list(values = useAggregationMethod(values, parameters)), by=well]
  createHeatMap("All Plates", plateData)
  
}

saveData <- function(subjectData, treatmentGroupData, analysisGroupData, user, experimentId, parameters){
  # NOT IN USE
  #save(subjectData, experimentId, file="test.Rda")
  
#   recordedBy <- user
#
#   originalNames <- names(subjectData)
#   subjectData <- as.data.frame(subjectData)
#
#   # Fix names
#   nameChange <- c(
#     'well'='well name', 'Maximum'='maximum', 'Minimum'='minimum', 'sequence'='fluorescencePoints',
#     'batchName'='batchCode', 'concentration'='Dose', 'concUnit'='DoseUnit', 'wellType' = 'well type',
#     'transformed'='transformed efficacy','normalized'='normalized efficacy', 'maxTime' = 'max time',
#     'latePeak'='late peak', 'threshold'='over efficacy threshold', 'hasAgonist' = 'has agonist',
#     'comparisonTraceFile'='comparison graph')
#   names(subjectData)[names(subjectData) %in% names(nameChange)] <- nameChange[names(subjectData)[names(subjectData) %in% names(nameChange)]]
#
#   stateGroups <- list(list(entityKind = "subject",
#                            stateType = "data",
#                            stateKind = "test compound treatment",
#                            valueKinds = c("Dose"),
#                            includesOthers = FALSE,
#                            includesCorpName = TRUE),
#                       list(entityKind = "subject",
#                            stateType = "metadata",
#                            stateKind = "plate information",
#                            valueKinds = c("well type","barcode","well name"),
#                            includesOthers = FALSE,
#                            includesCorpName = FALSE),
#                       list(entityKind = "subject",
#                            stateType = "data",
#                            stateKind = "results",
#                            valueKinds = c("maximum","minimum", "fluorescent", "transformed efficacy",
#                                           "normalized efficacy", "over efficacy threshold",        #"fluorescencePoints", "timePoints",
#                                           "max time", 'late peak', 'has agonist'),
#                            includesOthers = FALSE,
#                            includesCorpName = FALSE),
#                       list(entityKind = "analysis group",
#                            stateType = "data",
#                            stateKind = "results",
#                            valueKinds = c("fluorescent", "normalized efficacy", "transformed efficacy", "transformed efficacy without sweetener", "over efficacy threshold", "normalized efficacy without sweetener", "comparison graph"),
#                            includesOthers = FALSE,
#                            includesCorpName = TRUE),
#                       list(entityKind = "analysis group",
#                            stateType = "metadata",
#                            stateKind = "plate information",
#                            valueKinds = c("well type"),
#                            includesOthers = FALSE,
#                            includesCorpName = FALSE),
#                       list(entityKind = "treatment group",
#                            stateType = "data",
#                            stateKind = "results",
#                            valueKinds = c("fluorescent", "normalized efficacy", "over efficacy threshold", "transformed efficacy"),
#                            includesOthers = FALSE,
#                            includesCorpName = TRUE),
#                       list(entityKind = "treatment group",
#                            stateType = "metadata",
#                            stateKind = "plate information",
#                            valueKinds = c("well type"),
#                            includesOthers = FALSE,
#                            includesCorpName = FALSE)
#   )
#
#   # Turn logicals into "yes" and "no"
#   columnClasses <- lapply(subjectData, class)
#
#   for (i in 1:length(columnClasses)) {
#     if (columnClasses[[i]]=="logical") {
#       subjectData[[names(columnClasses)[i]]] <- ifelse(subjectData[[names(columnClasses)[i]]],"yes","no")
#     }
#   }
#
#   # Turn all others into character
#   subjectData <- as.data.frame(lapply(subjectData, as.character), stringsAsFactors=FALSE, optional=TRUE)
#
#   # TODO: check that all dose units are same
#   resultTypes <- data.frame(
#     DataColumn = c('barcode', 'well name', 'maximum', 'minimum', 'fluorescent',               #'timePoints', 'fluorescencePoints',
#                    'Dose', 'well type', 'transformed efficacy', 'normalized efficacy', 'over efficacy threshold',
#                    'max time', 'late peak', 'has agonist', 'comparison graph'),
#     Type = c('barcode', 'well name', 'maximum', 'minimum', 'fluorescent',                     #'timePoints', 'fluorescencePoints',
#              'Dose', 'well type', 'transformed efficacy', 'normalized efficacy', 'over efficacy threshold',
#              'max time', 'late peak', 'has agonist', 'comparison graph'),
#     Units = c(NA, NA, 'rfu', 'rfu', NA, #'sec', 'rfu',
#               subjectData$DoseUnit[1], NA, NA, NA, NA, 'sec', NA, NA, NA),
#     valueType = c('codeValue','stringValue', 'numericValue','numericValue','stringValue', #'clobValue', 'clobValue',
#                   'numericValue','stringValue','numericValue','numericValue','stringValue',
#                   'numericValue','stringValue', 'stringValue', 'inlineFileValue'),
#     stringsAsFactors = FALSE)
#
#   if(is.null(subjectData$"comparison graph")) {
#     resultTypes <- resultTypes[resultTypes$DataColumn != 'comparison graph', ]
#   }
#
#   subjectData$DoseUnit <- NULL
#   subjectData$fileName <- NULL
#
#   makeLongData <- function(entityData, resultTypes, splitTreatmentGroupsBy) {
#     library('reshape2')
#     library('gdata')
#
#     entityData$entityID <- seq(1,nrow(entityData))
#     entityData$treatmentGroupID <- do.call(paste,entityData[,splitTreatmentGroupsBy])
#     entityData$treatmentGroupID <- as.numeric(factor(entityData$treatmentGroupID))
#     blankSpaces <- lapply(as.list(entityData), function(x) return (x != ""))
#     emptyColumns <- unlist(lapply(blankSpaces, sum) == 0)
#     resultTypes <- resultTypes[!(resultTypes$DataColumn %in% names(entityData)[emptyColumns]),]
#
#     longResults <- reshape(entityData, idvar=c("id"), ids=row.names(entityData), v.names="UnparsedValue",
#                            times=resultTypes$DataColumn, timevar="resultTypeAndUnit",
#                            varying=list(resultTypes$DataColumn), direction="long", drop = names(entityData)[emptyColumns])
#
#     # Add the extract result types information to the long format
#     longResults$valueUnit <- resultTypes$Units[match(longResults$"resultTypeAndUnit",resultTypes$DataColumn)]
#     longResults$concentration <- resultTypes$Conc[match(longResults$"resultTypeAndUnit",resultTypes$DataColumn)]
#     longResults$concentrationUnit <- resultTypes$concUnits[match(longResults$"resultTypeAndUnit",resultTypes$DataColumn)]
#     longResults$valueType <- resultTypes$valueType[match(longResults$"resultTypeAndUnit",resultTypes$DataColumn)]
#     longResults$valueKind <- resultTypes$Type[match(longResults$"resultTypeAndUnit",resultTypes$DataColumn)]
#     longResults$comments <- NA
#
#     longResults$UnparsedValue <- trim(as.character(longResults$"UnparsedValue"))
#
#     # Parse numeric data from the unparsed values
#     matches <- is.na(suppressWarnings(as.numeric(gsub("^(>|<)(.*)", "\\2", gsub(",","",longResults$"UnparsedValue")))))
#     longResults$numericValue <- longResults$"UnparsedValue"
#     longResults$numericValue[matches] <- ""
#
#     # Parse string values from the unparsed values
#     longResults$stringValue <- as.character(longResults$"UnparsedValue")
#     longResults$stringValue[!matches & longResults$valueType != "stringValue"] <- ""
#
#     longResults$clobValue <- as.character(longResults$"UnparsedValue")
#     longResults$clobValue[!longResults$valueType=="clobValue"] <- NA
#     longResults$stringValue[longResults$valueType=="clobValue"] <- NA
#
#     longResults$fileValue <- as.character(longResults$"UnparsedValue")
#     fileValueRows <- longResults$valueType %in% c("fileValue", "inlineFileValue")
#     longResults$fileValue[!fileValueRows] <- NA
#     longResults$comments[fileValueRows] <- basename(longResults$fileValue[fileValueRows])
#     longResults$stringValue[fileValueRows] <- NA
#
#     longResults$codeValue <- as.character(longResults$"UnparsedValue")
#     longResults$codeValue[!longResults$valueType=="codeValue"] <- NA
#     longResults$stringValue[longResults$valueType=="codeValue"] <- NA
#
#     # Parse Operators from the unparsed value
#     matchExpression <- ">|<"
#     longResults$valueOperator <- longResults$numericValue
#     matches <- gregexpr(matchExpression,longResults$numericValue)
#     regmatches(longResults$valueOperator,matches, invert = TRUE) <- ""
#
#     # Turn result values to numeric values
#     longResults$numericValue <-  as.numeric(gsub(",","",gsub(matchExpression,"",longResults$numericValue)))
#
#     # For the results marked as "stringValue":
#     #   Set the Result Desc to the original value
#     #   Clear the other categories
#     longResults$numericValue[which(longResults$valueType=="stringValue")] <- rep(NA, sum(longResults$valueType=="stringValue"))
#     longResults$valueOperator[which(longResults$valueType=="stringValue")] <- rep(NA, sum(longResults$valueType=="stringValue"))
#
#
#     # For the results marked as "dateValue":
#     #   Apply the function validateDate to each entry
#     longResults$dateValue <- rep(NA, length(longResults$entityID))
#     if (length(which(longResults$valueType=="dateValue")) > 0) {
#       longResults$dateValue[which(longResults$valueType=="dateValue")] <- sapply(longResults$UnparsedValue[which(longResults$valueType=="dateValue")], FUN=validateDate)
#     }
#     longResults$numericValue[which(longResults$valueType=="dateValue")] <- rep(NA, sum(longResults$valueType=="dateValue"))
#     longResults$valueOperator[which(longResults$valueType=="dateValue")] <- rep(NA, sum(longResults$valueType=="dateValue"))
#     longResults$stringValue[which(longResults$valueType=="dateValue")] <- rep(NA, sum(longResults$valueType=="dateValue"))
#
#     longResults$stringValue[longResults$stringValue == ""] <- NA
#     longResults$valueOperator[longResults$valueOperator == ""] <- NA
#
#     return(longResults)
#   }
#   meltedSubjectData <- makeLongData(subjectData, resultTypes=resultTypes, splitTreatmentGroupsBy=c("Dose","batchCode", "barcode", "well type"))
#   experiment <- fromJSON(getURL(paste0(racas::applicationSettings$client.service.persistence.fullpath,"experiments/",experimentId)))
#
#   subjectData <- meltedSubjectData
#   subjectData$subjectID <- subjectData$entityID
#   subjectData$publicData <- TRUE
#
#   subjectData$analysisGroupID <- subjectData$treatmentGroupID
#
#   lsTransaction <- createLsTransaction(comments="Primary Analysis load")$id
#
#   # Get a list of codes
#   analysisGroupCodeNameList <- unlist(getAutoLabels(thingTypeAndKind="document_analysis group",
#                                                     labelTypeAndKind="id_codeName",
#                                                     numberOfLabels=length(unique(subjectData$analysisGroupID))),
#                                       use.names=FALSE)
#   #numberOfLabels=length(analysisGroupData$batchName))
#   #numberOfLabels=length(unique(analysisGroupData$batchName)))
#
#   subjectCodeNameList <- unlist(getAutoLabels(thingTypeAndKind="document_subject",
#                                               labelTypeAndKind="id_codeName",
#                                               numberOfLabels=length(unique(subjectData$entityID))),
#                                 use.names=FALSE)
#
#   treatmentGroupCodeNameList <- unlist(getAutoLabels(thingTypeAndKind="document_treatment group",
#                                                      labelTypeAndKind="id_codeName",
#                                                      numberOfLabels=length(unique(subjectData$treatmentGroupID))),
#                                        use.names=FALSE)
#   #numberOfLabels=length(treatmentGroupData$batchName))
#   #numberOfLabels=length(unique(treatmentGroupData$batchName)))
#
#   recordedBy <- user
#   experiment$lsStates <- NULL
#   experiment$analysisGroups <- NULL
#   analysisGroups <- lapply(FUN= createAnalysisGroup, X= analysisGroupCodeNameList,
#                            recordedBy=recordedBy, lsTransaction=lsTransaction, experiment=experiment)
#
#   savedAnalysisGroups <- saveAcasEntities(analysisGroups, "analysisgroups")
#
#   analysisGroupIds <- sapply(savedAnalysisGroups, getElement, "id")
#
#   subjectData$analysisGroupID <- analysisGroupIds[match(subjectData$analysisGroupID,1:length(analysisGroupIds))]
#
#   subjectData$treatmentGroupCodeName <- treatmentGroupCodeNameList[subjectData$treatmentGroupID]
#
#   createLocalTreatmentGroup <- function(subjectData) {
#     return(createTreatmentGroup(
#       analysisGroup=list(id=subjectData$analysisGroupID[1], version=0),
#       codeName=subjectData$treatmentGroupCodeName[1],
#       recordedBy=recordedBy,
#       lsTransaction=lsTransaction))
#   }
#
#   treatmentGroups <- dlply(.data= subjectData, .variables= .(treatmentGroupID), .fun= createLocalTreatmentGroup)
#   names(treatmentGroups) <- NULL
#
#   savedTreatmentGroups <- saveAcasEntities(treatmentGroups, "treatmentgroups")
#
#   treatmentGroupIds <- sapply(savedTreatmentGroups, getElement, "id")
#
#   subjectData$treatmentGroupID <- treatmentGroupIds[subjectData$treatmentGroupID]
#
#   # Subjects
#   subjectData$subjectCodeName <- subjectCodeNameList[subjectData$subjectID]
#
#   createRawOnlySubject <- function(subjectData) {
#     return(createSubject(
#       treatmentGroup=list(id=subjectData$treatmentGroupID[1],version=0),
#       codeName=subjectData$subjectCodeName[1],
#       recordedBy=recordedBy,
#       lsTransaction=lsTransaction))
#   }
#
#   subjects <- dlply(.data= subjectData, .variables= .(subjectID), .fun= createRawOnlySubject)
#   names(subjects) <- NULL
#   savedSubjects <- saveAcasEntities(subjects, "subjects")
#
#   subjectIds <- sapply(savedSubjects, getElement, "id")
#
#   subjectData$subjectID <- subjectIds[subjectData$subjectID]
#
#   ### Subject States ===============================================
#   #######
#
#   stateGroupIndex <- 1
#   subjectData$stateGroupIndex <- NA
#   for (stateGroup in stateGroups) {
#     includedRows <- subjectData$valueKind %in% stateGroup$valueKinds
#     newRows <- subjectData[includedRows & !is.na(subjectData$stateGroupIndex), ]
#     subjectData$stateGroupIndex[includedRows & is.na(subjectData$stateGroupIndex)] <- stateGroupIndex
#     if (nrow(newRows)>0) newRows$stateGroupIndex <- stateGroupIndex
#     subjectData <- rbind.fill(subjectData,newRows)
#     stateGroupIndex <- stateGroupIndex + 1
#   }
#
#   othersGroupIndex <- which(sapply(stateGroups, FUN=getElement, "includesOthers"))
#   if (length(othersGroupIndex) > 0) {
#     subjectData$stateGroupIndex[is.na(subjectData$stateGroupIndex)] <- othersGroupIndex
#   }
#
#   subjectData$stateID <- paste0(subjectData$subjectID, "-", subjectData$stateGroupIndex)
#
#   stateAndVersion <- saveStatesFromLongFormat(subjectData, "subject", stateGroups, "stateID", recordedBy, lsTransaction)
#   subjectData$stateID <- stateAndVersion$entityStateId
#   subjectData$stateVersion <- stateAndVersion$entityStateVersion
#
#   ### Subject Values =======================================================================
#   batchCodeStateIndices <- which(sapply(stateGroups, getElement, "includesCorpName"))
#   if (is.null(subjectData$stateVersion)) subjectData$stateVersion <- 0
#   subjectDataWithBatchCodeRows <- rbind.fill(subjectData, meltBatchCodes(subjectData, batchCodeStateIndices))
#
#   savedSubjectValues <- saveValuesFromLongFormat(subjectDataWithBatchCodeRows, "subject", stateGroups, lsTransaction, recordedBy)
#
#   #
#   #####
#   # Treatment Group states =========================================================================
#   treatmentGroupIndices <- which(sapply(stateGroups, function(x) {x$entityKind})=="treatment group")
#   analysisGroupIndices <- which(sapply(stateGroups, function(x) {x$entityKind})=="analysis group")
#
#   treatmentValueKinds <- unlist(lapply(stateGroups[treatmentGroupIndices], getElement, "valueKinds"))
#   analysisValueKinds <- unlist(lapply(stateGroups[analysisGroupIndices], getElement, "valueKinds"))
#   listedValueKinds <- do.call(c,lapply(stateGroups, getElement, "valueKinds"))
#   otherValueKinds <- setdiff(unique(subjectData$valueKind),listedValueKinds)
#   resultsDataValueKinds <- stateGroups[sapply(stateGroups, function(x) x$stateKind)=="results"][[1]]$valueKinds
#   extraDataValueKinds <- stateGroups[sapply(stateGroups, function(x) x$stateKind)=="plate information"][[1]]$valueKinds
#   treatmentDataValueKinds <- c(treatmentValueKinds, otherValueKinds, resultsDataValueKinds, extraDataValueKinds)
#   excludedSubjects <- subjectData$subjectID[subjectData$valueKind == "Exclude"]
#   treatmentDataStart <- subjectData[subjectData$valueKind %in% c(treatmentDataValueKinds, analysisValueKinds)
#                                     & !(subjectData$subjectID %in% excludedSubjects),]
#
#   createRawOnlyTreatmentGroupDataDT <- function(subjectData, parameters) {
#     isGreaterThan <- any(subjectData$valueOperator==">", na.rm=TRUE)
#     isLessThan <- any(subjectData$valueOperator=="<", na.rm=TRUE)
#     resultValue <- NA
#     if(isGreaterThan && isLessThan) {
#       resultOperator <- "<>"
#       resultValue <- NA
#     } else if (isGreaterThan) {
#       resultOperator <- ">"
#       resultValue <- max(subjectData$numericValue)
#     } else if (isLessThan) {
#       resultOperator <- "<"
#       resultValue <- min(subjectData$numericValue)
#     } else {
#       resultOperator <- as.character(NA)
#       resultValue <- useAggregationMethod(subjectData$numericValue, parameters)
#     }
#     return(list(
#       "stateID" = subjectData$stateID[1],
#       "stateVersion" = subjectData$stateVersion[1],
#       "numericValue" = resultValue,
#       "stringValue" = if (length(unique(subjectData$stringValue)) == 1) {subjectData$stringValue[1]}
#       else if (all(subjectData$stringValue %in% c("yes", "no"))) {"sometimes"}
#       else if (is.nan(resultValue)) {'NA'}
#       else {as.character(NA)},
#       "valueOperator" = resultOperator,
#       "dateValue" = if (length(unique(subjectData$dateValue)) == 1) subjectData$dateValue[1] else NA,
#       "fileValue" = if (length(unique(subjectData$fileValue)) == 1) subjectData$fileValue[1] else as.character(NA),
#       "comments" = if (length(unique(subjectData$comments)) == 1) subjectData$comments[1] else as.character(NA),
#       "publicData" = subjectData$publicData[1],
#       "numberOfReplicates" = nrow(subjectData),
#       "uncertaintyType" = if(is.numeric(resultValue)) "standard deviation" else as.character(NA),
#       "uncertainty" = sd(subjectData$numericValue)
#     ))
#   }
#
#   treatmentDataStartDT <- as.data.table(treatmentDataStart)
#
#   keepValueKinds <- c("maximum", "minimum", "Dose", "transformed efficacy","normalized efficacy","over efficacy threshold","max time","late peak", "has agonist", "comparison graph")
#   treatmentGroupDataDT <- treatmentDataStartDT[ valueKind %in% keepValueKinds, createRawOnlyTreatmentGroupDataDT(.SD, parameters), by = c("analysisGroupID", "treatmentGroupCodeName", "treatmentGroupID", "resultTypeAndUnit", "stateGroupIndex",
#                                                                                                                                           "batchCode", "valueKind", "valueUnit", "valueType")]
#   #setkey(treatmentGroupDataDT, treatmentGroupID)
#   treatmentGroupData <- as.data.frame(treatmentGroupDataDT)
#
#   treatmentGroupIndices <- c(treatmentGroupIndices,othersGroupIndex)
#
#   treatmentGroupData$stateID <- paste0(treatmentGroupData$treatmentGroupID, "-", treatmentGroupData$stateGroupIndex)
#
#   stateAndVersion <- saveStatesFromLongFormat(entityData = treatmentGroupData,
#                                               entityKind = "treatmentgroup",
#                                               stateGroups = stateGroups,
#                                               stateGroupIndices = treatmentGroupIndices,
#                                               idColumn = "stateID",
#                                               recordedBy = recordedBy,
#                                               lsTransaction = lsTransaction)
#
#   treatmentGroupData$stateID <- stateAndVersion$entityStateId
#   treatmentGroupData$stateVersion <- stateAndVersion$entityStateVersion
#
#   treatmentGroupData$treatmentGroupStateID <- treatmentGroupData$stateID
#
#   #### Treatment Group Values =====================================================================
#   batchCodeStateIndices <- which(sapply(stateGroups, function(x) return(x$includesCorpName)))
#   if (is.null(treatmentGroupData$stateVersion)) treatmentGroupData$stateVersion <- 0
#
#   treatmentGroupDataWithBatchCodeRows <- rbind.fill(treatmentGroupData, meltBatchCodes(treatmentGroupData, batchCodeStateIndices))
#   # This is a hack to fix issues with batch codes
#   treatmentGroupDataWithBatchCodeRows$stateVersion <- 0
#
#   savedTreatmentGroupValues <- saveValuesFromLongFormat(entityData = treatmentGroupDataWithBatchCodeRows,
#                                                         entityKind = "treatmentgroup",
#                                                         stateGroups = stateGroups,
#                                                         stateGroupIndices = treatmentGroupIndices,
#                                                         lsTransaction = lsTransaction,
#                                                         recordedBy=recordedBy)
#
#
#   if (length(analysisGroupIndices > 0)) {
#     analysisGroupData <- treatmentGroupDataWithBatchCodeRows
#
#     ###
#     # Correction for non-agonist data to put in separate column
#     if (any(analysisGroupData$valueKind == "has agonist")) {
#       #analysisGroupKeep <- analysisGroupData$analysisGroupID[(analysisGroupData$valueKind == "has agonist" & analysisGroupData$stringValue == "yes")]
#       #analysisGroupData <- analysisGroupData[analysisGroupData$analysisGroupID %in% analysisGroupKeep, ]
#
#       analysisGroupHasAgonist <- analysisGroupData$analysisGroupID[(analysisGroupData$valueKind == "has agonist" & analysisGroupData$stringValue == "yes")]
#       analysisGroupDataNoAgonist <- analysisGroupData[!(analysisGroupData$analysisGroupID %in% analysisGroupHasAgonist), ]
#       analysisGroupDataHasAgonist <- analysisGroupData[(analysisGroupData$analysisGroupID %in% analysisGroupHasAgonist), ]
#
#       analysisGroupDataNoAgonist$valueKind[analysisGroupDataNoAgonist$valueKind == "normalized efficacy"] <- "normalized efficacy without sweetener"
#       analysisGroupDataNoAgonist$valueKind[analysisGroupDataNoAgonist$valueKind == "transformed efficacy"] <- "transformed efficacy without sweetener"
#       analysisGroupDataNoAgonist <- analysisGroupDataNoAgonist[!(analysisGroupDataNoAgonist$valueKind %in% c("over efficacy threshold", "comparison graph")), ]
#       analysisGroupData <- rbind.fill(analysisGroupDataNoAgonist, analysisGroupDataHasAgonist)
#       # Remove empty comparison graphs (happens for controls across plates)
#       analysisGroupDataRemove <- analysisGroupData$valueKind == "comparison graph" & is.na(analysisGroupData$fileValue)
#       analysisGroupData <- analysisGroupData[!analysisGroupDataRemove, ]
#     }
#
#     ###
#     analysisGroupData$stateID <- paste0(analysisGroupData$analysisGroupID, "-", analysisGroupData$stateGroupIndex)
#
#     stateAndVersion <- saveStatesFromLongFormat(entityData = analysisGroupData,
#                                                 entityKind = "analysisgroup",
#                                                 stateGroups = stateGroups,
#                                                 stateGroupIndices = analysisGroupIndices,
#                                                 idColumn = "stateID",
#                                                 recordedBy = recordedBy,
#                                                 lsTransaction = lsTransaction)
#
#     analysisGroupData$stateID <- stateAndVersion$entityStateId
#     analysisGroupData$stateVersion <- stateAndVersion$entityStateVersion
#
#     analysisGroupData$analysisGroupStateID <- analysisGroupData$stateID
#
#     #### Analysis Group Values =====================================================================
#     savedAnalysisGroupValues <- saveValuesFromLongFormat(entityData = analysisGroupData,
#                                                          entityKind = "analysisgroup",
#                                                          stateGroups = stateGroups,
#                                                          stateGroupIndices = analysisGroupIndices,
#                                                          lsTransaction = lsTransaction,
#                                                          recordedBy = recordedBy)
#   }
#
#   return(lsTransaction)
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
  #collect the names of files
  fileList <- list.files(path = dataDirectory, pattern = "\\.stat[^\\.]*", full.names = TRUE)
  seqFileList <- list.files(path = dataDirectory, pattern = "\\.seq\\d$", full.names = TRUE)
  
  # the program exits when there are no files
  if (length(fileList) == 0) {
    stopUser("No files found")
  }
  
  stat1List <- grep("\\.stat1$", fileList, value="TRUE")
  stat2List <- grep("\\.stat2$", fileList, value="TRUE")
  
  if (length(stat1List) != length(stat2List) | length(stat1List) != length(seqFileList)) {
    stopUser("Number of Maximum and Minimum and sequence files do not match")
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
    stopUser("File names do not match")
  }
  
  return(fileNameTable)
}
validateWellFlagData <- function(flagData, resultTable) {
  # Ensures that the flagData is in a reasonable format, so we can throw helpful
  #   errors before the rest of the code generates unhelpful (R) errors
  #
  # flagData:    A data.frame that should contain (at a minimum) the barcode, well, and flag
  #                for flagged wells
  # resultTable: A data.table containing, among other fields, a complete list of barcodes and wells
  # Returns: the input data frame, with accumulated warnings and errors, and with empty strings as NA
  
  columnsIncluded <- c("well", "assayBarcode", "flagType","flagObservation","flagReason","flagComment") %in% names(flagData)
  if (!all(columnsIncluded)) {
    stopUser(paste0("An important column appears to be missing from the input. ",
                    "Please ensure that the uploaded file contains columns for Well, ", 
                    "Assay Barcode, Flag Type, Flag Observation, Flag Reason, and Flag Comment. ",
                    "If the uploaded file contained calculated ", 
                    "results, please ensure that you only modified the columns marked ",
                    "as editable."))
  }
  
  duplicateIndices <- duplicated(data.frame(flagData$assayBarcode, flagData$well))
  if (any(duplicateIndices)) {
    duplicateTests <- unique(data.frame(flagData$assayBarcode[duplicateIndices], flagData$well[duplicateIndices]))
    stopUser(paste0("The same barcode and well combination was listed multiple times in the flag file. Please remove ",
                    "duplicates for ", paste(duplicateTests[[1]], duplicateTests[[2]], collapse = ", "), "."))
  }
  
  results <- data.table(assayBarcode = resultTable$assayBarcode, well = resultTable$well)
  flags <- data.table(assayBarcode = flagData$assayBarcode, well = flagData$well)
  setkey(flags, assayBarcode, well)
  extraTests <- flags[!results]
  if (nrow(extraTests) > 0) {
    warnUser(paste0("Some of the wells listed in the flag file were not found in the experiment ",
                    "data, and will be ignored. Please remove or modify ", 
                    paste(extraTests[[1]], extraTests[[2]], collapse = ", "), "."))
  }
  
  # If the table is blank, readExcelOrCsv decides all of the column types should be "logical",
  # so we change them to "character"
  if (nrow(flagData) == 0) {
    flagData <- as.data.table(sapply(flagData, as.character))
  }
  
  return(flagData)
}
validateAnalysisFlagData <- function(flagData, analysisGroupData, replicateType, flaggingStage) {
  # Ensures that the flag data is in a reasonable format, so we can throw errors now
  #  instead of R throwing them later
  #
  # flagData:    A data.frame that should contain (at a minimum) the barcode, well, and flag
  #                for flagged wells
  #              Could be NULL, if no flag data was found in the file.
  # analysisGroupData: A data.table containing, among other fields, the threshold for each
  #                analysis group
  # replicateType: a string that defines an analysis group (ie, "across plate")
  # Returns: the input data frame, with accumulated warnings and errors
  #          Errors if we don't have enough information to flag analysis groups
  
  if(is.null(flagData)) {
    return(flagData)
  }
  # Get a list of all the columns we need to work with analysis group flags
  analysisColumns <- getAnalysisGroupColumns(replicateType)
  requiredColumns <- c("userHit", "wellType", "hit", "well", "assayBarcode", analysisColumns)
  
  columnsIncluded <- requiredColumns %in% names(flagData)
  
  if (all(columnsIncluded)) {
    # replace missing values with the 'default' value
    replaceMissing <- function(userHit, systemHit) {
      #userHit will be the collection of user-defined hits for the analysis group
      userHit <- tolower(userHit)
      registeredHits <- unique(userHit[!is.na(userHit) & userHit != ""])
      if(length(registeredHits) == 0) {
        return(systemHit)
      } else if (length(registeredHits) == 1) {
        return(registeredHits)
      } else {
        stopUser(paste0("There were ", length(registeredHits), " different entries under ",
                        "'User Defined Hits' for a single ",
                        paste0(analysisColumns, collapse = "/"), " grouping: ",
                        paste0(registeredHits, collapse = ", "), ". Please enter either 'yes'",
                        " or 'no'."))
      }
    }
    
    flagData <- flagData[, userHit := replaceMissing(userHit, hit), by = c(analysisColumns, "wellType")]
    
  } else if(flaggingStage == "analysisGroupFlags"){
    stopUser(paste0("The flag file does not appear to contain enough information ",
                    "to modify which trials were hits and which were not."))
  } else {
    return(NULL)
  }
  
  # If the table is blank, readExcelOrCsv decides all of the column types should be "logical",
  # so we change them to "character"
  if (!is.null(flagData) && nrow(flagData) == 0) {
    flagData <- as.data.table(sapply(flagData, as.character))
  }
  
  return(flagData)
}
validateFlaggingStage <- function(validatedFlagData, flaggingStage, experiment) {
  # Throws an error if the user promised to modify one type of flag
  # and actually modified another.
  #
  # validatedFlagData: a (validated) table containing information about which wells
  #               (and possibly analysis groups) are flagged
  # flaggingStage: a string indicating whether the user intends to modify "wellFlags" or
  #                       "analysisGroupFlags" or spotfire "KOandHit"
  
  if(is.null(validatedFlagData)) {
    #There was no flag file given, so we aren't doing any flagging
    return(invisible(NULL))
  }
  
  if(flaggingStage == "wellFlags") {
    # We want to make sure they haven't been flagging analysis groups
    requiredColumns <- c("userHit", "hit", "well")
    columnsIncluded <- requiredColumns %in% names(validatedFlagData)
    if(all(columnsIncluded)) {
      if(any(validatedFlagData$'userHit' != validatedFlagData$'hit', na.rm = TRUE)) {
        disagreeingIndices <- which(validatedFlagData$'userHit' != validatedFlagData$'hit')
        disagreeingWells <- unique(validatedFlagData$"well"[disagreeingIndices])
        warnUser(paste0("During this step of data analysis, you can only flag individual wells. ",
                        "However, the 'User Defined Hit' column no longer agrees with the 'Hit' column for ",
                        "at least one trial in each of the following wells: ", 
                        paste0(disagreeingWells, collapse = ", "), ". The data in the 'Hit' column will ",
                        "override the data in the 'User Defined Hit' column. If this is not what you intended, ",
                        "please re-upload your file, and check the box to indicate that you have finished ",
                        "flagging wells."))
      }
    }
  } else if(!is.null(flaggingStage) && flaggingStage == "analysisGroupFlags") {
    # We want to make sure they haven't modified their well flags since they last time they uploaded data
    pathToLastUpload <- paste0("experiments/", experiment$codeName,
                               "draft/", experiment$codeName, "_OverrideDRAFT.csv")
    if(file.exists(racas::getUploadedFilePath(pathToLastUpload))) {
      # They have uploaded flag data before -- compare to that
      previousFlagData <- as.data.table(parseWellFlagFile(pathToLastUpload))
      setkey(previousFlagData, assayBarcode, well)
      setkey(validatedFlagData, assayBarcode, well)
      if(any(previousFlagData$"flag" != validatedFlagData$"flag")) {
        disagreeingIndices <- which(previousFlagData$"flag" != validatedFlagData$"flag")
        disagreeingWells <- unique(validatedFlagData$"well"[disagreeingIndices])
        warnUser(paste0("During this step of data analysis, you cannot flag wells. However, it appears that ",
                        "the following wells have at least one changed flag: ", 
                        paste0(disagreeingWells, collapse = ", "), 
                        ". The new flags will be ignored. If you wish to flag more wells, please re-upload ",
                        "the file and uncheck the box that indicates you are done flagging wells. Please be ",
                        "aware that you cannot flag wells and override hits during the same upload."))
      }
    } else {
      # They haven't uploaded flag data before -- make sure they have no flags
      if(any(!is.na(validatedFlagData$"flag"))) {
        disagreeingIndices <- which(!is.na(validatedFlagData$"flag"))
        disagreeingWells <- unique(validatedFlagData$"well"[disagreeingIndices])
        warnUser(paste0("During this step of data analysis, you cannot flag wells. However, it appears that ",
                        "the following wells have at least one changed flag: ", 
                        paste0(disagreeingWells, collapse = ", "), 
                        ". The new flags will be ignored. If you wish to flag more wells, please re-upload ",
                        "the file and uncheck the box that indicates you are done flagging wells. Please be ",
                        "aware that you cannot flag wells and override hits during the same upload."))
      }
    }
  }
  #Otherwise, flagging hasn't been implemented yet, so we don't do anything
  return(invisible(NULL))
}




parseAnalysisFlagFile <- function(flaggedWells, resultTable) {
  # Turns a csv or Excel file into a table of analysis group level flag information
  #
  # Input:  flaggedWells, the name of a file in privateUploads that contains well-flagging information
  #         resultTable, a table containing, among other columns, the barcode, well, and batch code for
  #             every test
  # Returns: a data.frame containing the barcode, batch id, well, user defined hit (userHit), and flag for every test
  #             in the flaggedWells file (which may not include all the tests in resultTable). If the user
  #             didn't define a hit, it is left as NA
  #          OR "NULL" if the data frame wasn't given, or was in the wrong format
  
  # If we don't have a file, send it back as "null" and don't do the analysis
  if(is.null(flaggedWells) || flaggedWells == "") {
    return(NULL)
  } else {
    flaggedWellPath <- racas::getUploadedFilePath(flaggedWells)
    flagData <- readExcelOrCsv(flaggedWellPath, header = FALSE)
    
    # Check if there is a 'calculated results' section
    flagData <- tryCatch({
      flagData <- racas::getSection(flagData, lookFor = "Calculated Results")
      # Remove "Editable" Row
      flagData <- flagData[1:nrow(flagData)>1,]
      # Get the headers in the appropriate place
      names(flagData) <- tolower(flagData[1:nrow(flagData)==1,])
      flagData <- flagData[1:nrow(flagData)>1,]
      flagData <- as.data.table(flagData)
    }, error = function(e) {
      if (any(class(e) == "userStop")) {
        # If we received an error that we defined, it means the section heading wasn't there
        # (or there were too few rows), so we probably got the basic csv file, and we don't have
        # any analysis flags
        return(NULL)
      } else {
        stopUser("The system encountered an error while reading the user-defined hits.")
      }
    })
    # If possible, set these names. Otherwise, the user will get told about it in the validation function
    if ("user defined hit" %in% names(flagData)) {setnames(flagData, "user defined hit", "userHit")}
    if ("well type" %in% names(flagData)) {setnames(flagData, "well type", "wellType")}
    if ("corporate batch id" %in% names(flagData)) {setnames(flagData, "corporate batch id", "batchName")}
    
    # If there aren't enough wells given, we're going to have a hard time filling in the appropriate
    # default flag, so we stop the user (because we know this isn't the 'basic csv' format)
    if (!is.null(flagData) && NROW(resultTable) != NROW(flagData)) {
      stopUser(paste0("There were ", NROW(flagData), " rows of flag data in the given file, but the experiment has ",
                      NROW(resultTable), " wells. If any rows were deleted from the QC file, please download it again."))
    }
  }
  return(flagData)
}
parseWellFlagFile <- function(flaggedWells, resultTable) {
  # Turns a csv, Excel, or .txt file into a table of well-level flag information
  #
  # Input:  flaggedWells, the name of a file in privateUploads that contains well-flagging information
  #         resultTable, a table containing, among other columns, the barcode, well, and batch code for
  #             every test
  # Returns: a data.table containing the barcode, batch id, well, user defined hit (userHit), and flag for every test
  #             in the flaggedWells file (which may not include all the tests in resultTable). If the user
  #             didn't define a hit, it is left as NA
  
  # If we don't have a file, make all flags NA
  if(is.null(flaggedWells) || flaggedWells == "") {
    flagData <- data.table(assayBarcode = resultTable$assayBarcode, 
                           well = resultTable$well, 
                           batchName = resultTable$batchName,
                           flag = c(NA_character_))
  } else {
    flaggedWellPath <- racas::getUploadedFilePath(flaggedWells)
    flagData <- readExcelOrCsv(flaggedWellPath, header = FALSE)
    
    # We want to accept two formats: the file we output, which the user has edited, and a file
    # that contains just the barcode, well, and flag information
    flagData <- tryCatch({
      flagData <- racas::getSection(flagData, lookFor = "Calculated Results")
      # Remove "Editable" Row
      flagData <- flagData[1:nrow(flagData)>1,]
      # Get the headers in the appropriate place
      names(flagData) <- flagData[1:nrow(flagData)==1,]
      flagData <- flagData[1:nrow(flagData)>1,]
    }, error = function(e) {
      if (any(class(e) == "userStop")) {
        # If we received an error that we defined, it means the section heading wasn't there
        # (or there were too few rows); we assume we just had the basic csv file
        names(flagData) <- flagData[1:nrow(flagData)==1,]
        flagData <- flagData[1:nrow(flagData)>1,]
        return(flagData)
      } else {
        stopUser("The system encountered an error while reading the flagged wells.")
      }
    })
    flagData <- as.data.table(flagData)
    # If possible, set these names.
    if ("user defined hit" %in% names(flagData)) {setnames(flagData, "user defined hit", "userHit")}
    if ("well type" %in% names(flagData)) {setnames(flagData, "well type", "wellType")}
    if ("corporate batch id" %in% names(flagData)) {setnames(flagData, "corporate batch id", "batchName")}
  }
  return(flagData)
}
summarizeAnalysisFlags <- function(validatedFlagData, replicateType) {
  # Ensures that all flags were entered appropriately, and massages the data
  #   into a summarized format. Flags must be either 'yes' or 'no', and no
  #   compound can be flagged with two different flags
  # Inputs: validatedFlagData, a data.table containing the identifying information
  #         for an analysis group, along with userHits. Should already have been
  #         checked for correct column headers
  #         replicateType, (string) how analysis groups are defined in the experiment
  # Returns: A data.table with columns for each defining feature of an analysis group
  #          (ie, batchName and barcode), as well as a column of userHits, for each
  #          analysis group where such a hit was recorded
  
  analysisColumns <- getAnalysisGroupColumns(replicateType)
  
  collectFlags <- function(hitVector) {
    # Determines how a user intended to flag an analysis group
    # Input: hitVector, a vector of all the flags listed for a given analysis group
    #        Normally, we hope that one of them is "yes" or "no", and the others are
    #        either in agreement or missing
    # Returns: The flag, if unambiguous. Errors if the flag is ambiguous (if it's something
    #          other than 'yes' or 'no', or if multiple flags are present). If no flag is
    #          specified, returns NULL.
    cleanedVector <- unique(hitVector[!(is.na(hitVector) | hitVector == "")])
    if(length(cleanedVector) == 0) {
      # Everything must have been empty; don't include this flag
      return(NULL)
    } else if (length(cleanedVector) == 1) {
      # There was agreement about what the flag was
      if (tolower(cleanedVector) == 'yes' || tolower(cleanedVector) == 'no') {
        return(cleanedVector)
      } else {
        stopUser(paste0("Unrecognized value in 'User Defined Hits': ", cleanedVector, 
                        ". Please enter 'yes' or 'no'."))
      }
    } else {
      stopUser(paste0("There were ", length(cleanedVector), " different entries under ",
                      "'User Defined Hits' for a single ",
                      paste0(analysisColumns, collapse = "/"), " grouping: ",
                      paste0(cleanedVector, collapse = ", "), ". Please enter either 'yes'",
                      " or 'no'."))
    }
  }
  
  # The file we gave to users to edit has more than one entry for each analysis group.
  # Merge them together, being mindful that users could get the input format wrong.
  hitData <- validatedFlagData[, collectFlags(userHit), by = eval(paste0(analysisColumns, collapse = ","))]
  
  # Check if we didn't put a third column in (there were no flags)
  if(ncol(hitData) == length(analysisColumns)) {
    userHit <- character()
    hitData <- cbind(hitData, userHit)
  } else {
    setnames(hitData, length(analysisColumns)+1, "userHit") 
  }
  
  return(hitData)
}
fillAnalysisFlags <- function(replicateType, analysisGroupData, minimalFlagInformation) {
  # Adds a column to the analysis group table that records the user's preference for whether the
  # analysis group is a hit or a miss (or the system's record, if the user hasn't specified a flag)
  #
  # Input: replicateType: a string indicating how analysis groups are determined
  #        analysisGroupData: a data.table containing the columns needed to specify an analysis group,
  #            as well as a "threshold" column indicating whether the system thought the group was a hit
  #
  # Output: the analysis group data, with a column labeled 'userHit' that contains the user's preference
  #         for whether a group should be flagged or not
  
  analysisColumns <- getAnalysisGroupColumns(replicateType)
  
  allData <- merge(minimalFlagInformation, analysisGroupData, by = analysisColumns, all.x = FALSE, all.y = TRUE)
  
  replaceNAorEmpty <- function(userHit, Id) {
    # If the userHit is absent, we use the default
    # userHit should be one element
    if(is.na(userHit) || userHit == "") {
      userHit <- analysisGroupData[analysisGroupId == Id]$threshold
    } else {
      return(userHit)
    }
  }
  filledData <- allData[, userHit := replaceNAorEmpty(userHit, analysisGroupId)]
  
  return(filledData)
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
saveFileLocations <- function (rawResultsLocation, resultsLocation, pdfLocation, overrideLocation, experiment, dryRun, recordedBy, lsTransaction) {
  # Saves the locations of the results, pdf, flags, and raw R resultTable as experiment values
  #
  # Args:
  #   rawResultsLocation:   A string of the file location where the raw R resultTable is located
  #   resultsLocation:      A string of the results csv location
  #   pdfLocation:          A string of the pdf summary report location
  #   overrideLocation:     A string telling where the override csv is located
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
    
    overrideLocationValue <- createStateValue(
      lsType = "fileValue",
      lsKind = "override location",
      fileValue = overrideLocation,
      lsState = locationState)
    
    saveExperimentValues(list(rawLocationValue,resultsLocationValue,pdfLocationValue,overrideLocationValue))
  }, error = function(e) {
    stopUser("Could not save the summary and result locations")
  })
  
  
  
  return(NULL)
}
saveInputParameters <- function(inputParameters, experiment, lsTransaction, recordedBy) {
  # input: inputParameters a string that is JSON
  updateValueByTypeAndKind(inputParameters, "experiment", experiment$id, "metadata", 
                           "experiment metadata", "clobValue", "data analysis parameters")
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
  
  if(!is.null(parameters$dilutionFactor) && is.null(parameters$dilutionRatio)) {
    parameters$dilutionRatio <- parameters$dilutionFactor
  } else if (is.null(parameters$dilutionRatio)) {
    parameters$dilutionRatio <- 2
  }
  
  return(parameters)
}

loadInstrumentReadParameters <- function(instrumentType) {
  # Loads the parameters for instruments. Only works if the instrument 
  # folder has been loaded in to conf. 
  #
  # Input:  instrumentType
  # Output: assay file parameters (list)
  
  # Checks to make sure that all of the required files have been loaded in to the correct folder
  if (is.null(instrumentType) || 
      !file.exists(file.path("src/r/PrimaryScreen/conf/instruments",instrumentType)) ||
      !file.exists(file.path("src/r/PrimaryScreen/conf/instruments",instrumentType,"instrumentType.json")) ||
      !file.exists(file.path("src/r/PrimaryScreen/conf/instruments",instrumentType,"detectionLine.json")) ||
      !file.exists(file.path("src/r/PrimaryScreen/conf/instruments",instrumentType,"paramList.json")))
  {
    stopUser("Configuration error: Instrument not loaded in system.")
  } 
  
  # Doublechecks to make sure that the instrument type matches 
  instrument <- fromJSON(readLines(file.path("src/r/PrimaryScreen/conf/instruments",
                                             instrumentType,"instrumentType.json")))$instrumentType
  if(instrumentType != instrument) {
    stopUser("Configuration error: Instrument data loaded incorrectly.")
  }
  
  paramList <- fromJSON(readLines(file.path("src/r/PrimaryScreen/conf/instruments",
                                            instrumentType,"paramList.json")))$paramList
  if(paramList$dataTitleIdentifier == "NA") {
    paramList$dataTitleIdentifier <- NA
  }
  if(paramList$headerRowSearchString == "NA") {
    paramList$headerRowSearchString <- NA
  }
  
  return(paramList)  
}

getReadOrderTable <- function(readList) {
  # Takes the reads list from the GUI and outputs a data.table
  #
  # Input:  readList (list of lists)
  # Output: readsTable (data.table)
  
  library(plyr)

  readsTable <- data.table(ldply(readList, function(item) {
    data.frame(
      userReadOrder = item$readNumber,
      readPosition = ifelse(is.null(item$readPosition), NA_real_, item$readPosition),
      readName = item$readName,
      activity = item$activity,
      calculatedRead = FALSE
    )
  }))
  readsTable[grep("^Calc:", readName), calculatedRead := TRUE]
  
  if(length(unique(readsTable$readName)) != length(readsTable$readName)) {
    stopUser("Some reads have the same name.")
  }
  
  if(length(unique(readsTable$activity)) != 2 && !unique(readsTable$activity)) {
    stopUser("No read has been marked as activity.")
  } 
  
  if(length(unique(readsTable$activity)) == 2 && nrow(readsTable[readsTable$activity, ]) != 1) {
    stopUser("More than one read has been marked as activity.")
  }
  
  return(readsTable)
}

checkFlags <- function(resultTable) {
  # Checks to see if flags leave enough data for analysis. 
  # 
  # Input:  resultTable (data.table)
  # Output: none
  
  # Error handling -- what if there are no unflagged PC's or NC's? 
  if (!any(is.na(resultTable$flag))) { 
    stopUser("All data points appear to have been flagged, so the data cannot be analyzed")
  }
  if (!any(resultTable$wellType == "NC" & is.na(resultTable$flag))) {
    stopUser("All negative controls appear to have been flagged, so the data cannot be normalized.")
  }
  if (!any(resultTable$wellType == "PC" & is.na(resultTable$flag))) {
    stopUser("All positive controls appear to have been flagged, so the data cannot be normalized.")
  }
  if (!any(resultTable$wellType == "test" & is.na(resultTable$flag))) {
    stopUser("All of the test wells appear to have been flagged, so there is no data to analyze.")
  } else if (length(which(resultTable$wellType == "test" & is.na(resultTable$flag))) == 1) {
    stopUser("Only one of the test wells is unflagged, so there is not enough data to analyze.")
  }
}

checkControls <- function(resultTable, normalizationDataFrame) {
  # Checks to see if the controls are present in the plate.
  # 
  # Input:  resultTable (data.table)
  # Output: none
  
  controlsExist <- list(posExists=TRUE, negExists=TRUE)
  if (!any(resultTable$wellType == "PC")) {
    controlsExist$posExists <- FALSE
  }
  
  if (!any(resultTable$wellType == "NC")) {
    controlsExist$negExists <- FALSE
  }

  # Modify the cases where both PC standard AND default value for PC are missing AND/OR the same applies to NC
  if(!controlsExist$posExists & is.na(normalizationDataFrame$defaultValue[normalizationDataFrame$standardType=='PC']) &&
     !controlsExist$negExists & is.na(normalizationDataFrame$defaultValue[normalizationDataFrame$standardType=='NC'])) {
    stopUser("Either (1) the positive and negative controls at the stated concentrations were not found in the plates, or (2) no standards were
              selected while no Input Values were defined for positive and negative control. Make sure all transfers have been loaded
              and your controls and dilution factor are defined correctly, and either standards are selected or input values are defined.")
  } else if (!controlsExist$posExists & is.na(normalizationDataFrame$defaultValue[normalizationDataFrame$standardType=='PC'])) {
    stopUser("Either (1) the Positive Control at the stated concentration was not found in the plates, or (2) no Standard was
              selected while no Input Value was defined for Positive Control. Make sure all transfers have been loaded
              and your Positive Control (or dilution factor) is defined correctly, and either a standard is selected or an input value
              is defined for the Positive Control.")
  } else if (!controlsExist$negExists & is.na(normalizationDataFrame$defaultValue[normalizationDataFrame$standardType=='NC'])) {
    stopUser("Either (1) the Negative Control at the stated concentration was not found in the plates, or (2) no Standard was
              selected while no Input Value was defined for Negative Control. Make sure all transfers have been loaded
              and your Negative Control (or dilution factor) is defined correctly, and either a standard is selected or an input value
              is defined for the Negative Control.")
  }
}

removeColumns <- function(colNamesToCheck, colNamesToKeep, inputDataTable) {
  # This function diffs the column names in an data.table and removes 
  # the columns not in a list of columns to keep.
  #
  # Input:  colNamesToCheck (list)
  #         colNamesToKeep (list)
  #         inputDataTable (data.table)
  # Output: inputDataTable (data.table)
  
  removeList <- setdiff(colNamesToCheck, colNamesToKeep)
  if(length(removeList) > 0) {
    inputDataTable[ , (removeList) := NULL]
  }
  
  # No need to warn user when not using some of the data columns.
  #   if(length(removeList) == 1) {
  #     warnUser(paste0("Removed 1 data column: '", removeList[[1]], "'"))
  #   } else if(length(removeList) > 1) {
  #     warnUser(paste0("Removed ",length(removeList)," data columns: '", paste(removeList, collapse="','"), "'"))
  #   }
  return(inputDataTable)
}

addMissingColumns <- function(requiredColNames, inputDataTable, warnAdd = TRUE)  {
  # This function cycles through a list of required column names and compares them to 
  # colnames in a data.table. It adds any columns with a value of "NA" if they are not found.
  #
  # Input:  requiredColNames (list)
  #         inputDataTable (data.table)
  # Output: inputDataTable (data.table)
  
  addList <- list()
  for(column in requiredColNames) {
    if(!grepl("^R[0-9]+ \\{Calc: *", column) && !grepl("^Activity*", column)) { # check to see if the column name is not a calculated read
      if(!any(column == colnames(inputDataTable))) {
        inputDataTable[[column]] <- as.numeric(NA)
        addList[[length(addList) + 1]] <- column
      }
    }
  }
  
  if (warnAdd) {
    if(length(addList) == 1) {
      warnUser(paste0("Added 1 data column: '", addList[[1]], "', coercing to NA."))
    } else if(length(addList) > 1) {
      warnUser(paste0("Added ",length(addList)," data columns: '", paste(addList, collapse="','"), "', coercing to NA"))
    }
  }
  
  return(inputDataTable)
}

unzipDataFolder <- function (zipFile, targetFolder, experiment) {
  if(!grepl("\\.zip$", zipFile)) {
    stopUser("The file provided must be a zip file or a directory")
  }
  
  dir.create(targetFolder, showWarnings = FALSE)
  oldFiles <- as.list(paste0(targetFolder,"/",list.files(targetFolder)))
  
  do.call(unlink, list(oldFiles, recursive=T))
  
  unzip(zipfile = zipFile, exdir = targetFolder)
  return(targetFolder)
}



findTimeWindowBrackets <- function(vectTime, timeWindowStart, timeWindowEnd) {
  # This function is used in autoFlagWells() and finds the indices of two elements in a vector containing incrementing timepoints,
  # one pointing to the start the other to the end of the time window of interest
  #
  # Args:
  #   vectTime:         a vector that contains time points sorted in an incremental fashion
  #   timeWindowStart:  time in seconds denoting the start of the time window of interest
  #   timeWindowEnd:    time in seconds denoting the end of the time window of interest
  # Returns:
  #   A list containing two values: element index pointing to the start and element index pointing to the end of the time window

  logicTimeStart <- (vectTime>=timeWindowStart)
  startReadIndex <- min(which(logicTimeStart == TRUE))
  logicTimeEnd <- (vectTime<timeWindowEnd)
  endReadIndex <- max(which(logicTimeEnd == TRUE))
  components <- list(startReadIndex = startReadIndex, endReadIndex = endReadIndex)
  return(components)
}


findFluoroTabDelimited <- function(stringElement, startIndex, endIndex, functionThreshold) {
  # This function is used in autoFlagWells() and finds if the well is fluorescent, given the raw measurements as a tab-delimited string,
  # by calculating the difference in magnitude between the start and the end of the predetermined time window and determining
  # if that difference is larger than the number of raw measurement units specified by the user as fluorescent step size
  #
  #
  # Args:
  #   stringElement:     A string containing all tab-delimited measurements as a sequence (T_sequence corresponding to T_timePoints)
  #   startIndex:        Index of the vector element that defines the start of the time window to apply the function
  #   endIndex:          Index of the vector element that defines the end of the time window to apply the function
  #   functionThreshold: Value in measurement units (representing fluorescent step size, specified by the user) - threshold which
  #                      if exceeded allows the current function to flag the well as fluorescent
  #
  #
  # Returns:
  #   A logical value: TRUE if >100 units otherwise FALSE

  # Vectorize the tab-delimited string as numeric values
  vectElement <- as.numeric(unlist(strsplit(stringElement, "\t")))

  # Calculate difference in magnitude between the end and the start of the target time window
  diffMagnitude <- vectElement[endIndex] - vectElement[startIndex]

  # If difference equals or exceeds 100 units then set Fluorescent well as True, else as False
  isFluorescent <- ifelse(diffMagnitude>=functionThreshold, yes=TRUE, no=FALSE)

  return(isFluorescent)
}


findLatePeakIndex <- function(stringElement, timePoints, latePeakThreshold) {
  # This function is used in autoFlagWells() and finds if the well icorresponds to a late peak, given the raw measurements as a tab-delimited string,
  # by calculating what timepoint corresponds to the max value of all measurements acquired and if that timepoint is later than a late peak threshold
  #
  #
  # Args:
  #   stringElement:        A string containing all tab-delimited measurements as a sequence (T_sequence corresponding to T_timePoints)
  #   timePoints:           The vector of timepoints based on which the tab-delimited string was acquired
  #   latePeakThreshold:    A time (in seconds) after which the max value of the tab-delimited measurements is considered a late peak
  #
  #
  # Returns:
  #   A logical value:      TRUE if the time corresponding to the max value in the tab-delimited string is later than the late peak threshold, otherwise FALSE

  # Vectorize the tab-delimited string as numerical values
  vectElement <- as.numeric(unlist(strsplit(stringElement, "\t")))

  # Find the index within the vector that corresponds to the max value of that same vector
  index <- which.max(vectElement) #(vectElement==max(vectElement))

  # Determine what time value corresponds to the aforementioned index and compare with late peak threshold
  latePeakFlag <- timePoints[index]>=latePeakThreshold #ifelse(timePoints[index]>=latePeakThreshold, yes=TRUE, no=FALSE)

  return(latePeakFlag)
}



autoFlagWells <- function(resultTable, parameters) {
  # resultTable: a data.table with columns T_sequence, T_timePoints, "transformed_percent efficacy"
  # parameters: list of parameters
  #
  # returns update resultTable with added columns "autoFlagType", "autoFlagObservation", "autoFlagReason"
  library(data.table)
  resultTable[, autoFlagType:=NA_character_]
  resultTable[, autoFlagObservation:=NA_character_]
  resultTable[, autoFlagReason:=NA_character_]

  # Add fluorescent as algorithm  c("autoFlagType", "autoFlagObservation", "autoFlagReason") := list("knocked out", "fluorescent", "slope")

  # Add late peak as algorithm  c("autoFlagType", "autoFlagObservation", "autoFlagReason") := list("knocked out", "late peak", "max time")


  # Determine whether all, none or some of the parameters regarding fluorescent well determination exist
  if (!(is.null(parameters$fluorescentStart) | parameters$fluorescentStart=="") &
      !(is.null(parameters$fluorescentEnd) | parameters$fluorescentEnd=="") &
      !(is.null(parameters$fluorescentStep) | parameters$fluorescentStep=="")) {
    statusFluorescent <- "complete"
  } else if ((is.null(parameters$fluorescentStart) | parameters$fluorescentStart=="") &
             (is.null(parameters$fluorescentEnd) | parameters$fluorescentEnd=="") &
             (is.null(parameters$fluorescentStep) | parameters$fluorescentStep=="")) {
    statusFluorescent <- "pass"
  } else {
    statusFluorescent <- "incomplete"
  }


  # If some but not all parameters regarding fluorescent well determination exist, alarm the user
  if (statusFluorescent=="incomplete") {
    stopUser("Not all necessary parameters regarding fluorescent wells were defined. Please set values for all three fields:
              Fluorescent Start, Fluorescent End and Fluorescent Step Size.")
  }


  # Only if all parameters regarding fluorescent well determination exist, set up the proper variables
  if (statusFluorescent=="complete") {
    # Get the start/end of the time window target for fluorescent wells
    timeWindowStart <- parameters$fluorescentStart
    timeWindowEnd <- parameters$fluorescentEnd

    # Get the threshold step for determining fluorescent wells
    fluoroThreshold <- parameters$fluorescentStep
  }

  # Skip the step of parsing the (first) string representing every element of column T_timePoints only if at least one NA entry is found
  # in T_timepoints
  if (!any(is.na(resultTable$T_timePoints))) {
    # Take the (first) string representing every element of column T_timePoints and parse it into a vector (string is tab-delimited)
    vectTime <- as.numeric(unlist(strsplit(resultTable[1, T_timePoints], "\t")))
  }



  # Only if all parameters regarding fluorescent well determination exist, determine fluorescent wells
  if (statusFluorescent=="complete") {
    # Find the index for elements corresponding to start and end of target time window
    indexPairStartEnd <- findTimeWindowBrackets(vectTime, timeWindowStart, timeWindowEnd)

    # Apply the function that determines if a well is fluorescent to all wells
    wellsKO <- vapply(resultTable[, T_sequence], findFluoroTabDelimited, TRUE, startIndex=indexPairStartEnd$startReadIndex, endIndex=indexPairStartEnd$endReadIndex, fluoroThreshold)
    wellsKO <- unname(wellsKO)
  }

  # Perform the following commands only if the user provided a value for the late peak time parameter
  if (!(is.null(parameters$latePeakTime) | parameters$latePeakTime=="")) {
    # Apply the function that determines if a well corresponds to a late peak
    wellsLate <- vapply(resultTable[, T_sequence], findLatePeakIndex, TRUE, vectTime, parameters$latePeakTime)
    wellsLate <- unname(wellsLate)

    # First update the appropriate resultTable columns to reflect the wells knocked out as late peaks
    resultTable[wellsLate, c("autoFlagType", "autoFlagObservation", "autoFlagReason") := list("knocked out", "late peak", "max time")]
  }


  # Only if all parameters regarding fluorescent well determination exist, then update resultTable with fluorescent wells
  if (statusFluorescent=="complete") {
    # Update the appropriate resultTable columns to reflect the wells found to be fluorescent
    resultTable[wellsKO, c("autoFlagType", "autoFlagObservation", "autoFlagReason") := list("knocked out", "fluorescent", "slope")]
  }


  # Flag HITs
  if(!parameters$autoHitSelection) {
    return(resultTable)
  }
  if(is.null(parameters$thresholdType) || parameters$thresholdType == "") {
    return(resultTable)
  } else if(parameters$thresholdType == "efficacy") {
    hitThreshold <- parameters$hitEfficacyThreshold
    thresholdType <- "percent efficacy"
    
    setnames(resultTable, "transformed_percent efficacy","transformed_efficacy")
    resultTable[(transformed_efficacy > hitThreshold) & (is.na(flagType) | flagType != "knocked out") & (wellType == "test"), autoFlagType := "HIT"]
    setnames(resultTable, "transformed_efficacy","transformed_percent efficacy")
  } else if(parameters$thresholdType == "sd") {
    hitThreshold <- parameters$hitSDThreshold
    thresholdType <- "standard deviation"
    resultTable[(transformed_sd > hitThreshold) & (is.na(flagType) | flagType != "knocked out") & (wellType == "test"), autoFlagType := "HIT"]
  } else {
    stopUser(paste0("Config error: threshold type of ", parameters$thresholdType, " not recognized"))
  }
  
  resultTable[autoFlagType == "HIT", autoFlagObservation := "hit"]
  resultTable[autoFlagType == "HIT", autoFlagReason := "hit"]
  
  return(resultTable)
  
}

removeNonCurves <- function(analysisData) {
  # Removes non-curve analysis group data, leaving only enough information to create the 
  # analysis groups without states and values so treatment groups can be created
  doseRespData <- analysisData[stateKind == "dose response"]
  singlePointData <- analysisData[stateKind != "dose response"]
  clearThese <- setdiff(names(analysisData), c("tempId", "parentId"))
  newColOrder <- c("tempId", "parentId", clearThese)
  # Need to set up a data table keeping on the parentId of the singlePointData 
  newSingle <- unique(singlePointData[,list(tempId, parentId)])
  newSingle[, (clearThese):=NA]
  setcolorder(newSingle, newColOrder)
  setcolorder(doseRespData, newColOrder)
  return(rbind(doseRespData, newSingle))
}

get_compound_properties <- function(ids, propertyNames) {
  # ids: vector of compound ids
  # propertyNames: vector of property names
  # example input (works in node stubsMode): 
  #   get_compound_properties(c("FRD76", "FRD2", "FRD78"), c("HEAVY_ATOM_COUNT", "MONOISOTOPIC_MASS"))
  
  requestBody <- list(properties = as.list(propertyNames), entityIdStringLines=paste(ids, collapse="\n"))
  url <- paste0(racas::applicationSettings$server.nodeapi.path, "/api/testedEntities/properties")
  response <- fromJSON(postURLcheckStatus(url, toJSON(requestBody)))
  properties <- fread(response$resultCSV)
  return(properties)
}

validateBatchCodes <- function(batchCodes, testMode = FALSE) {
  # Valides a vector of batch codes
  #
  # Args:
  #   batchCodes:	              A vector of batch codes
  #   testMode:                 A boolean
  #
  # Returns:
  #   a vector of fixed batchCodes
  
  # Get the current batch Ids
  #batchesToCheck <- resultTable$batchCode != "::"
  uBatchCodes <- unique(batchCodes)
  newBatchCodes <- getPreferredId(uBatchCodes, testMode=testMode)
  
  # If the preferred Id service does not return anything, errors will already be thrown, just move on
  if (is.null(newBatchCodes)) {
    return(batchCodes)
  }
  
  # Give warning and error messages for changed or missing id's
  for (batchId in newBatchCodes) {
    if (is.null(batchId["preferredName"]) || batchId["preferredName"] == "") {
      addError(paste0("Corporate Batch ID", " '", batchId["requestName"], 
                      "' has not been registered in the system. Contact your system administrator for help."))
    } else if (as.character(batchId["requestName"]) != as.character(batchId["preferredName"])) {
      warnUser(paste0("A ", "Corporate Batch ID", " that you entered, '", batchId["requestName"], 
                      "', was replaced by preferred ", "Corporate Batch ID", " '", batchId["preferredName"], 
                      "'. If this is not what you intended, replace the ", "Corporate Batch ID", " with the correct ID."))
    }
  }
  
  # Put the batch id's into a useful format
  preferredIdFrame <- as.data.frame(do.call("rbind", newBatchCodes), stringsAsFactors=FALSE)
  names(preferredIdFrame) <- names(newBatchCodes[[1]])
  preferredIdFrame <- as.data.frame(lapply(preferredIdFrame, unlist), stringsAsFactors=FALSE)
  
  # Use the data frame to replace Corp Batch Ids with the preferred batch IDs
  if (!is.null(preferredIdFrame$referenceName)) {
    prefDT <- as.data.table(preferredIdFrame)
    prefDT[ referenceName == "", referenceName := preferredName ]
    preferredIdFrame <- as.data.frame(prefDT)
  }
  
  # Return the validated results
  return(preferredIdFrame$preferredName[match(batchCodes, preferredIdFrame$requestName)])
}

verifyCalculationInputs <- function(inputDataTable, inputColumnTable, numberOfColumnsToCheck) {
  # Purpose of this is to check input columns that are used for the GUI calculation
  # throws error if the column is of class character
  # throws error if all of the numbers are the same
  #
  # inputDataTable: Created through PrimaryAnalysis - must have column names listed in inputColumnTable
  # inputColumnTable: Created through PrimaryAnalysis, based on user GUI input
  # numberOfColumnsToCheck: This is determined by the number of reads used in the GUI calculation
  
  if(is.null(numberOfColumnsToCheck) || numberOfColumnsToCheck == 0) {
    stopUser("Please see your system administrator with this message: 'Calculation verification function called with no columns to check.'")
  }
  if(numberOfColumnsToCheck >= 1) {
    columnToCheck <- inputColumnTable[userReadOrder == 1, newActivityColName]
    if(class(inputDataTable[ , get(columnToCheck)]) == "character") {
      stopUser("Please check your read position numbers. If you think you have received this message in error, please see your system administrator with this message: 'Read 1 is of class character'")
    }
    if(length(unique(inputDataTable[ , get(columnToCheck)])) == 1) {
      stopUser(paste0("All of the values for '", columnToCheck, "' are the same. Please check your read position numbers or your input files."))
    }
  }
  if(numberOfColumnsToCheck >= 2) {
    columnToCheck <- inputColumnTable[userReadOrder == 2, newActivityColName]
    if(class(inputDataTable[ , get(columnToCheck)]) == "character") {
      stopUser("Please check your read position numbers. If you think you have received this message in error, please see your system administrator with this message: 'Read 2 is of class character'")
    }
    if(length(unique(inputDataTable[ , get(columnToCheck)])) == 1) {
      stopUser(paste0("All of the values for '", columnToCheck, "' are the same. Please check your read position numbers or your input files."))
    }
  }
  if(numberOfColumnsToCheck >= 3) {
    stopUser("Please see your system administrator with this message: 'Number of calculation inputs exceed verification function.'")
  }
}

####### Main function
runMain <- function(folderToParse, user, dryRun, testMode, experimentId, inputParameters, flaggedWells=NULL, flaggingStage, externalFlagging) {
  # Runs main functions that are inside the tryCatch.W.E
  # flaggedWells: the name of a csv or Excel file that lists each well's barcode, 
  #               well number, and if it's flagged. If NULL, the file did not exist,
  #               and no wells are flagged. Also may include information to flag analysis groups.
  # flaggingStage: a string indicating whether the user intends to modify "wellFlags" or
  #                       "analysisGroupFlags" or spotfire "KOandHit"
  library("data.table")
  library("plyr")

  if (folderToParse == "") {
    stopUser("Input file not found. If you are trying to load a previous experiment, please upload the original data files again.")
  }
  
  fullPathToParse <- racas::getUploadedFilePath(folderToParse)
  
  if (!file.exists(fullPathToParse)) {
    stopUser("Input file not found")
  }
  
  if(!testMode) {
    experiment <- getExperimentById(experimentId)
    setExperimentStatus(status = "running", experiment, dryRun=dryRun)
  } else {
    experiment <- list(id = experimentId, codeName = "test", version = 0)
  }

  parameters <- getExperimentParameters(inputParameters)

  if(parameters$autoHitSelection) {
    if(is.null(parameters$thresholdType)) {
      stopUser("No hit selection parameter was calculated because no threshold was selected.")
    } else if(parameters$thresholdType != "efficacy" && parameters$thresholdType != "sd") {
      if(length(unique(grepl(parameters$thresholdType, parameters$transformationRuleList))) < 2 && 
         !grepl(parameters$thresholdType, parameters$transformationRuleList)) {
        stopUser(paste0("Hit selection parameter (", parameters$thresholdType, ") not calculated in transformation section."))
      }
    }
  }

  # Define the data frame that holds information about multiple standards, as defined in the GUI
  standardsDT <- rbindlist(parameters$standardCompoundList)
  standardsDT[concentration=="", concentration:=NA_character_]
  standardsDT[, concentration:=as.numeric(concentration)]

  # Define the data frame that holds information about normalization controls, as defined in the GUI
  normalizationDataFrame <- as.data.frame(rbind(parameters$normalization$positiveControl,
                                                parameters$normalization$negativeControl))


  setnames(normalizationDataFrame, c('standardNumber','defaultValue'))
  normalizationDataFrame$standardType <- c('PC', 'NC')

  normalizationDataFrame$defaultValue[normalizationDataFrame$defaultValue==""] <- NA
  normalizationDataFrame$defaultValue <- as.numeric(normalizationDataFrame$defaultValue)
  #normalizationDataFrame$standardNumber <- paste0("S",normalizationDataFrame$standardNumber)



  # Throw an error if no PC and no NC were defined for normalization (absence of standards and default values)
  if (normalizationDataFrame$standardNumber[normalizationDataFrame$standardType=='PC'] == 'unassigned' &
      normalizationDataFrame$standardNumber[normalizationDataFrame$standardType=='NC'] == 'unassigned') {
    stopUser("No Standards were defined for Positive Control and Negative Control in the normalization section.
                Standards, or alteratively Input Values, for Positive and Negative Controls are required for normalization calculations.")
  }

  # Throw an error either PC or NC were defined as unassigned
  if ((normalizationDataFrame$standardNumber[normalizationDataFrame$standardType=='PC'] == 'unassigned' | #&
       #normalizationDataFrame$standardNumber[normalizationDataFrame$standardType=='NC'] != 'unassigned') |
      #(normalizationDataFrame$standardNumber[normalizationDataFrame$standardType=='PC'] != 'unassigned' &
       normalizationDataFrame$standardNumber[normalizationDataFrame$standardType=='NC'] == 'unassigned')) {
    stopUser("No Standard and no Input Value was defined for either the Positive Control or Negative Control
              in the normalization section. Standards, or alternatively Input Values, for Positive and Negative Controls
              are required for normalization calculations.")
  }


  # Throw an error if only normalization-associated NC standards are defined via default value in the GUI
  # (i.e. absence of positive control standard AND default value for positive control)
  scenarioOnlyNC <- (normalizationDataFrame$standardNumber[normalizationDataFrame$standardType=='PC'] == 'input value' &
                     is.na(normalizationDataFrame$defaultValue[normalizationDataFrame$standardType=='PC']) &
                     normalizationDataFrame$standardNumber[normalizationDataFrame$standardType=='NC'] == 'input value' &
                     !is.na(normalizationDataFrame$defaultValue[normalizationDataFrame$standardType=='NC'])  )

  # Throw an error if only normalization-associated PC standards are defined via default value in the GUI
  # (i.e. absence of negative control standard AND default value for negative control)
  scenarioOnlyPC <- (normalizationDataFrame$standardNumber[normalizationDataFrame$standardType=='PC'] == 'input value' &
                     !is.na(normalizationDataFrame$defaultValue[normalizationDataFrame$standardType=='PC']) &
                     is.na(normalizationDataFrame$defaultValue[normalizationDataFrame$standardType=='NC']) &
                     normalizationDataFrame$standardNumber[normalizationDataFrame$standardType=='NC'] == 'input value')

  if (scenarioOnlyNC) {
    stopUser("In the normalization section, only a Negative Control was defined -- no Positive Control or input value in lieu of a Positive Control
              were detected. Selecting a Positive Control standard or setting an input value for Positive Control is required
              for normalization calculations.")
  }

  if (scenarioOnlyPC) {
    stopUser("In the normalization section, only a Positive Control was defined -- no Negative Control or input value in lieu of a Negative Control
              were detected. Selecting a Negative Control standard or setting an input value for Negative Control is required
              for normalization calculations.")
  }


  # Throw an error if input values were selected for both PC and NC were defined for normalization but no numerical values were provided
  if (normalizationDataFrame$standardNumber[normalizationDataFrame$standardType=='PC'] == 'input value' &
      normalizationDataFrame$standardNumber[normalizationDataFrame$standardType=='NC'] == 'input value') {
    # If both PC and NC input values are NA then display the error
    if (is.na(normalizationDataFrame$defaultValue[normalizationDataFrame$standardType=='PC']) &
        is.na(normalizationDataFrame$defaultValue[normalizationDataFrame$standardType=='NC'])) {
      stopUser("Although Input Values were selected for both Positive Control and Negative Control, no numeric values were defined.
                Numeric Input Values in lieu of Standards for Positive and Negative Controls are required for normalization calculations.")
    }
  }


  # Throw an error if (in the case where both PC and NC were defined for normalization) the same standard was used for both PC and NC
  # regarding normalization when defined in the GUI
  if (normalizationDataFrame$standardNumber[normalizationDataFrame$standardType=='PC'] != 'input value' &
      normalizationDataFrame$standardNumber[normalizationDataFrame$standardType=='NC'] != 'input value') {
    if (identical(normalizationDataFrame$standardNumber[normalizationDataFrame$standardType=='PC'],
                  normalizationDataFrame$standardNumber[normalizationDataFrame$standardType=='NC'])) {
      stopUser("The same Standard was defined for both Positive Control and Negative Control in the normalization section.
                Different Standards for Positive and Negative Controls are required for normalization calculations.")
    }
  }

  # Add a column to the data frame that holds information about multiple standards, enumerating all available standards
  standardsDT[, standardTypeEnumerated:=paste0(standardType, "-S", standardNumber)]


  # If a normalization-related PC is defined then mark it separately in the standards database
  normalizationPC <- normalizationDataFrame$standardNumber[normalizationDataFrame$standardType=='PC']
  if (normalizationPC != 'input value') {
    standardsDT[standardNumber==normalizationPC, standardTypeEnumerated:='PC']
  }

  # If a normalization-related NC is defined then mark it separately in the standards database
  normalizationNC <- normalizationDataFrame$standardNumber[normalizationDataFrame$standardType=='NC']
  if (normalizationNC != 'input value') {
    standardsDT[standardNumber==normalizationNC, standardTypeEnumerated:='NC']
  }

  # Validate all the batchcodes entered for multiple standards in the GUI
  standardsDT[, batchCode:=validateBatchCodes(batchCode)]

  dir.create(racas::getUploadedFilePath("experiments"), showWarnings = FALSE)
  dir.create(paste0(racas::getUploadedFilePath("experiments"),"/",experiment$codeName), showWarnings = FALSE)
  
  
  # If the fullPathToParse is actually a zip file
  zipFile <- NULL
  experimentFolderPath <- file.path(racas::getUploadedFilePath("experiments"),experiment$codeName)
  
  targetLocation <- file.path(experimentFolderPath, "rawData")
  dryRunFileLocation <- file.path("experiments", experiment$codeName, "dryRun")
  specDataPrepFileLocation <- file.path(experimentFolderPath, "parseLogs")
  parsedInputFileLocation <- file.path(experimentFolderPath, "parsedInput")
  dir.create(racas::getUploadedFilePath(dryRunFileLocation), showWarnings = FALSE)
  dir.create(specDataPrepFileLocation, showWarnings = FALSE)
  dir.create(parsedInputFileLocation, showWarnings = FALSE)
  
  if (!file.info(fullPathToParse)$isdir) {
    fullPathToParse <- unzipDataFolder(fullPathToParse, targetLocation, experiment)
  } 
  
  if(externalFlagging && file.exists(file.path(parsedInputFileLocation, "primaryAnalysis-resultTable.Rda"))) { 
    ## if this is  a spotfire reanalysis and the saved .Rda is found
    load(file.path(parsedInputFileLocation,"primaryAnalysis-resultTable.Rda"))
  } else {
    ## if this is not a spotfire reanalysis and/or the saved .Rda is not found

    # GREEN (instrument-specific)
    if (parameters$instrumentReader == 'generic plate') {
      # For the case where no instrument files (.txt) are uploaded through a
      # zipped folder. In that case, function specificDataPreProcessor is not
      # executed to populate instrumentData, which leads to table instrumentData
      # being constructed with the information entered through the plate files
      # (.xlsx) in the uploaded zipped file
      instrumentData <- genericPlateDataPreProcessor(parameters=parameters,
                                                     folderToParse=fullPathToParse,
                                                     tempFilePath=specDataPrepFileLocation)
    } else if (as.logical(racas::applicationSettings$server.service.genericSpecificPreProcessor)) {
      instrumentReadParams <- loadInstrumentReadParameters(parameters$instrumentReader)
      instrumentData <- specificDataPreProcessor(parameters=parameters,
                                                 folderToParse=fullPathToParse,
                                                 errorEnv=errorEnv,
                                                 dryRun=dryRun,
                                                 instrumentClass=instrumentReadParams$dataFormat,
                                                 testMode=testMode,
                                                 tempFilePath=specDataPrepFileLocation)
    } else {
      instrumentReadParams <- loadInstrumentReadParameters(parameters$instrumentReader)
      instrumentData <- specificDataPreProcessorStat1Stat2Seq(parameters=parameters,
                                                              folderToParse=fullPathToParse,
                                                              errorEnv=errorEnv,
                                                              dryRun=dryRun,
                                                              instrumentClass=instrumentReadParams$dataFormat,
                                                              testMode=testMode,
                                                              tempFilePath=specDataPrepFileLocation)
    }
    

    # RED (client-specific)
    # getCompoundAssignments

    # exampleClient is set at the head of runMain function
    if (checkPlateContentInFiles(fullPathToParse)) {
      resultTable <- getCompoundAssignmentsFromFiles(fullPathToParse, instrumentData, parameters)
      # Validate batch codes because they came from files
      resultTable[, batchCode:=validateBatchCodes(batchCode)]
    } else if (as.logical(racas::applicationSettings$server.service.internalPlateRegistration)) {
      resultTable <- getCompoundAssignmentsInternal(fullPathToParse, instrumentData,
                                                    testMode, parameters)
    } else {
      resultTable <- getCompoundAssignments(fullPathToParse, instrumentData,
                                            testMode, parameters,
                                            tempFilePath=specDataPrepFileLocation)
    }

    # this also performs any calculations from the GUI
    source("src/r/PrimaryScreen/instrumentSpecific/specificDataPreProcessorFiles/adjustColumnsToUserInput.R", local = TRUE)
    # TODO: break this function into customer-specific usable parts
    resultTable <- adjustColumnsToUserInput(inputColumnTable=instrumentData$userInputReadTable, inputDataTable=resultTable)

    resultTable$wellType <- getWellTypes(
      batchNames=resultTable$batchCode, concentrations=resultTable$cmpdConc,
      concentrationUnits=resultTable$concUnit, testMode=testMode, standardsDT=standardsDT, 
      parameters$normalization$normalizationRule)

    resultTable[is.na(cmpdConc)]$wellType <- "BLANK"
    checkControls(resultTable, normalizationDataFrame)
    setkeyv(instrumentData$assayData,c('assayBarcode', 'row', 'well'))
    setkeyv(instrumentData$assayData,c('assayBarcode', 'rowName', 'wellReference'))
    resultTable[, well:= instrumentData$assayData$wellReference]
    save(resultTable, file=file.path(parsedInputFileLocation, "primaryAnalysis-resultTable.Rda"))
    
    # instrumentData is still needed, but pulling out assayData could let us clean it up
    #rm(instrumentData)
    #gc()
  }

  ## User Well Flagging Here
  
  # user well flagging
  resultTable <- getWellFlagging(flaggedWells,resultTable, flaggingStage, experiment, parameters)

  ## End User Well Flagging
  
  ## RED SECTION - Client Specific
  #calculations
  if(length(unique(resultTable$activity)) == 1) {
    stopUser(paste0("All of the activity values are the same (",unique(resultTable$activity),"). Please check your read name selections and adjust as necessary."))
  }

  # knock out the controls with NA values
  # it would be technically more correct if these reasons could be placed in the "autoFlag" columns, 
  # but those aren't created until later in the code
  resultTable[(wellType == 'NC' | wellType == 'PC') & is.na(activity), 
              c("flag", "flagType", "flagObservation", "flagReason") := list("KO", "knocked out", "empty well", "reader")]

  # Perform calculations related to normalization and transformation (performCalculationsStat1Stat2Seq() is no longer relevant)
  resultTable <- performCalculations(resultTable, parameters, experiment$codeName, dryRun, normalizationDataFrame, standardsDT)


  if(length(unique(resultTable$normalizedActivity)) == 1 && unique(resultTable$normalizedActivity) == "NaN") {
    stopUser("Activity normalization resulted in 'divide by 0' errors. Please check the data and your read name selections.")
  }
  
  ## BLUE SECTION - Auto Well Flagging
  
  resultTable <- autoFlagWells(resultTable, parameters)
  resultTable[autoFlagType=="KO", flag := "KO"]
  
  # END Auto Well Flagging
  
  # Save full resultTable, including wells with no compounds, to write to the spotfire file.
  # Remove the wells with no compounds to save to the database
  spotfireResultTable <- copy(resultTable)
  resultTable <- resultTable[!is.na(batchCode) & batchCode != "::"]
  
  # was "across plates"
  groupBy <- getGroupBy(parameters)
  treatmentGroupBy <- c(groupBy, "cmpdConc", "agonistConc", "agonistBatchCode")
  
  resultTable[, tempParentId:=.GRP, by=treatmentGroupBy]
  
  batchDataTable <- resultTable[is.na(flag)]
  allFlaggedTable <- resultTable[!is.na(flag)]



  treatmentGroupData <- getTreatmentGroupData(batchDataTable, parameters, treatmentGroupBy)

  rm(batchDataTable)
  gc()

  # allFlaggedTable is only for treatment groups mising from treatmentGroupData
  allFlaggedTable <- allFlaggedTable[!(tempParentId %in% treatmentGroupData$tempId)]
  # TODO 1.6: clean this up, maybe make it not return standardDeviation and numberOfReplicates
  flaggedTreatmentGroupData <- getTreatmentGroupData(allFlaggedTable, list(aggregationMethod = "returnNA"), treatmentGroupBy)
  treatmentGroupData <- rbind(treatmentGroupData, flaggedTreatmentGroupData)
  # If one concentration, no problem, if three or more, it's a curve, with two... split them
  treatmentGroupData[, concIndex := as.integer(as.factor(cmpdConc)), by = groupBy]
  treatmentGroupData[, secondConc := (length(unique(cmpdConc)) == 2 & concIndex == 2), by = groupBy]
  treatmentGroupData[, concIndex := NULL]
  agonistComparisonScreen <- "noAgonist" %in% lapply(parameters$transformationRuleList, getElement, name="transformationRule")
  # agonistComparisonScreen <- !is.null(agonistComparisonScreen) && as.logical(agonistComparisonScreen)
  if (!agonistComparisonScreen) {
    analysisGroupBy <- c(groupBy, "secondConc")
  } else {
    analysisGroupBy <- groupBy
  }
  treatmentGroupData[, tempParentId:=.GRP, by=analysisGroupBy]
  analysisGroupData <- getAnalysisGroupData(treatmentGroupData, analysisGroupBy)
  if (agonistComparisonScreen) {
    analysisGroupData <- analysisGroupData[, combineTwoAgonist(.SD), by=tempId]
  }
  analysisGroupData[, secondConc := NULL]
  treatmentGroupData[, secondConc := NULL]
  
  ### TODO: write a function to decide what stays in analysis group data, plus any renaming like 'has agonist' or 'without agonist'     
  # e.g.      analysisGroupData <- treatmentGroupData[hasAgonist == T & wellType=="test"]

  library('RCurl')
  protocol <- getProtocolById(experiment$protocol$id)
  protocolName <- getPreferredName(protocol)

  summaryInfo <- list(
    info = list(
      "Plates analyzed" = paste0(length(unique(resultTable$assayBarcode)), " plates:\n  ", paste(unique(resultTable$assayBarcode), collapse = "\n  ")),
      "Unique compounds analyzed" = length(unique(resultTable$batchName)),
      "Unique batches analyzed" = length(unique(resultTable$batchCode)),
      "Automatic hits" = nrow(resultTable[autoFlagType == "HIT"]),
      "User hits" = nrow(resultTable[tolower(flagType) == "hit"]),
      # "Threshold" = signif(efficacyThreshold, 3),
      # "SD Threshold" = ifelse(hitSelection == "sd", parameters$hitSDThreshold, "NA"),
      # "Fluorescent wells" = sum(resultTable$fluorescent),
      "Flagged wells" = sum(!is.na(resultTable$flag)),
      "Number of wells" = nrow(resultTable),
      "Hit rate" = paste(round((nrow(resultTable[autoFlagType == "HIT" | tolower(flagType) == "hit"])/nrow(resultTable))*100,2), "%"),
      "Z Prime" = round(unique(resultTable$zPrime),5),
      # "Z'" = format(computeZPrime(resultTable$transformed[resultTable$wellType=="PC"], resultTable$transformed[resultTable$wellType=="NC"]),digits=3,nsmall=3),
      # "Robust Z'" = format(computeRobustZPrime(resultTable$transformed[resultTable$wellType=="PC"], resultTable$transformed[resultTable$wellType=="NC"]),digits=3,nsmall=3),
      # "Z" = format(computeZPrime(resultTable$transformed[resultTable$wellType=="PC"], resultTable$transformed[resultTable$wellType=="test" & !resultTable$fluorescent]),digits=3,nsmall=3),
      # "Robust Z" = format(computeRobustZPrime(resultTable$transformed[resultTable$wellType=="PC"], resultTable$transformed[resultTable$wellType=="test"& !resultTable$fluorescent]),digits=3,nsmall=3),
      "Positive Control summary" = paste0("\n  Batch code: ",parameters$positiveControl$batchCode,
                                          "\n  Count: ",nrow(resultTable[wellType == "PC" & is.na(flag)]),
                                          "\n  Mean: ",round(mean(resultTable[wellType=="PC" & is.na(flag)]$normalizedActivity),5),
                                          "\n  Median: ",round(median(resultTable[wellType=="PC" & is.na(flag)]$normalizedActivity),5),
                                          "\n  Standard Deviation: ",round(sd(resultTable[wellType=="PC" & is.na(flag)]$normalizedActivity),5),
                                          "\n  CV: ",round(sd(resultTable[wellType=="PC" & is.na(flag)]$normalizedActivity) / mean(resultTable[wellType=="PC" & is.na(flag)]$normalizedActivity),5)),
      "Negative Control summary" = paste0("\n  Batch code: ",parameters$negativeControl$batchCode,
                                          "\n  Count: ",nrow(resultTable[wellType == "NC" & is.na(flag)]),
                                          "\n  Mean: ",round(mean(resultTable[wellType=="NC" & is.na(flag)]$normalizedActivity),5),
                                          "\n  Median: ",round(median(resultTable[wellType=="NC" & is.na(flag)]$normalizedActivity),5),
                                          "\n  Standard Deviation: ",round(sd(resultTable[wellType=="NC" & is.na(flag)]$normalizedActivity),5),
                                          "\n  CV: ",round(sd(resultTable[wellType=="NC" & is.na(flag)]$normalizedActivity) / mean(resultTable[wellType=="NC" & is.na(flag)]$normalizedActivity),5)),
      "Date analysis run" = format(Sys.time(), "%a %b %d %X %z %Y")
    )
  )
  if (!is.null(parameters$agonist$batchCode) && parameters$agonist$batchCode != "") {
    summaryInfo$info$"Agonist" <- parameters$agonist$batchCode
  }
  
  # This runs on dryRun and save, could be split to save different values
  if (!testMode) {
    lsTransaction <- createLsTransaction()$id
    saveInputParameters(inputParameters, experiment, lsTransaction, user)
  } else {
    lsTransaction <- 1345
  }

  serverFlagFileLocation <- NULL
  if (dryRun && !testMode) {
    serverFileLocation <- saveAcasFileToExperiment(
      folderToParse, experiment, 
      "metadata", "experiment metadata", "dryrun source file", user, lsTransaction,
      deleteOldFile = FALSE, customSourceFileMove = customSourceFileMove)
    if (!is.null(flaggedWells) && flaggedWells != "") {
      serverFlagFileLocation <- saveAcasFileToExperiment(
        flaggedWells, experiment,
        "metadata", "experiment metadata", "dryrun flag file", user, lsTransaction,
        deleteOldFile = FALSE, customSourceFileMove = customSourceFileMove)
    }
  }
  
  resultTable[tolower(flagType) == "hit" | tolower(autoFlagType) == "hit", flag := "HIT"]
  resultTable[tolower(flagType) == "knocked out" | tolower(autoFlagType) == "knocked out", flag := "KO"]
  if (dryRun) {
    lsTransaction <- NULL
    dryRunLocation <- racas::getUploadedFilePath(file.path("experiments", experiment$codeName, "draft"))
    dir.create(dryRunLocation, showWarnings = FALSE)
    
    source(file.path("src/r/PrimaryScreen/createReports/",
                     clientName,"createPDF.R"), local = TRUE)
    
    if(!parameters$autoHitSelection) {
      hitThreshold <- ""
    } else if(!is.null(parameters$hitEfficacyThreshold) && parameters$hitEfficacyThreshold != "") {
      hitThreshold <- parameters$hitEfficacyThreshold
    } else if (!is.null(parameters$hitSDThreshold) && parameters$hitSDThreshold != "") {
      hitThreshold <- parameters$hitSDThreshold
    } else {
      hitThreshold <- ""
    }
    activityName <- getReadOrderTable(parameters$primaryAnalysisReadList)[activity == TRUE]$readName

    pdfLocation <- createPDF(resultTable, instrumentData$assayData, parameters, summaryInfo,
                               threshold = hitThreshold, experiment, dryRun, activityName) 

    summaryInfo$info$"Summary" <- paste0('<a href="/dataFiles/experiments/', experiment$codeName, "/draft/",
                                         experiment$codeName,'_SummaryDRAFT.pdf" target="_blank">Summary</a>')

    summaryInfo$dryRunReports <- saveReports(resultTable, spotfireResultTable, saveLocation=dryRunFileLocation, 
                                             experiment, parameters, user, customSourceFileMove=customSourceFileMove)
    
    for (dryRunReport in summaryInfo$dryRunReports) {
      summaryInfo$info[[dryRunReport$title]] <- paste0(
        '<a href="', dryRunReport$link, '" target="_blank" ',
        ifelse(dryRunReport$download, 'download', ''), '>', dryRunReport$title, '</a>')
    }
  } else { #This section is "If not dry run"
    reportLocation <- file.path("experiments", experiment$codeName, "analysis")
    dir.create(getUploadedFilePath(reportLocation), showWarnings = FALSE)
    
    source(file.path("src/r/PrimaryScreen/createReports/",
                     clientName,"createPDF.R"), local = TRUE)
    
    # Create the actual PDF
    if(!parameters$autoHitSelection) {
      hitThreshold <- ""
    } else if(!is.null(parameters$hitEfficacyThreshold) && parameters$hitEfficacyThreshold != "") {
      hitThreshold <- parameters$hitEfficacyThreshold
    } else if (!is.null(parameters$hitSDThreshold) && parameters$hitSDThreshold != "") {
      hitThreshold <- parameters$hitSDThreshold
    } else {
      hitThreshold <- ""
    }
    activityName <- getReadOrderTable(parameters$primaryAnalysisReadList)[activity == TRUE]$readName
    pdfLocation <- createPDF(resultTable, instrumentData$assayData, parameters, summaryInfo,
                             threshold = hitThreshold, experiment, dryRun, activityName) 

    rm(instrumentData)
    gc()

    summaryInfo$info$"Summary" <- paste0('<a href="/dataFiles/experiments/', experiment$codeName, "/analysis/", 
                                         experiment$codeName,'_Summary.pdf" target="_blank">Summary</a>')
    
    # Create the final Spotfire File
    summaryInfo$reports <- saveReports(resultTable, spotfireResultTable, saveLocation=reportLocation, 
                                       experiment, parameters, user, customSourceFileMove=customSourceFileMove)

    rm(spotfireResultTable)
    gc()

    for (singleReport in summaryInfo$reports) {
      summaryInfo$info[[singleReport$title]] <- paste0(
        '<a href="', singleReport$link, '" target="_blank" ',
        ifelse(singleReport$download, 'download', ''), '>', singleReport$title, '</a>')
    }

    rm(singleReport)
    gc()

    if (!is.null(zipFile)) {
      file.rename(zipFile, 
                  paste0(racas::getUploadedFilePath("experiments"),"/",experiment$codeName,"/rawData/", 
                         basename(zipFile)))
    }
    
    dir.create(paste0(racas::getUploadedFilePath("experiments"),"/",experiment$codeName,"/analysis"), showWarnings = FALSE)
    
    updateHtsFormat(parameters$htsFormat, experiment)
    
    deleteAnalysisGroupsByExperiment(experiment)
    deleteModelSettings(experiment)
    
    serverFileLocation <- saveAcasFileToExperiment(
      folderToParse, experiment, 
      "metadata", "experiment metadata", "source file", user, lsTransaction,
      deleteOldFile = FALSE, customSourceFileMove = customSourceFileMove)
    if (!is.null(flaggedWells) && flaggedWells != "") {
      serverFlagFileLocation <- saveAcasFileToExperiment(
        flaggedWells, experiment, 
        "metadata", "experiment metadata", "flag file", user, lsTransaction,
        deleteOldFile = FALSE, customSourceFileMove = customSourceFileMove)
      summaryInfo$info$"Original Flag File" <- paste0(
        '<a href="', getAcasFileLink(serverFlagFileLocation, login=T), '" target="_blank">Original Flag File</a>')
    }
    
    # Save plate order and compound plate order
    plateOrderDT <- unique(resultTable[, list(assayBarcode, plateOrder)])
    setkey(plateOrderDT, plateOrder)
    # Save to experiment for screening campaigns
    updateValueByTypeAndKind(paste(plateOrderDT$assayBarcode, collapse = ","), "experiment", experiment$id, 
                             "metadata", "experiment metadata", "clobValue", "plate order")
    
    # TODO: move to correct location
    # Removes rows that have no compound data
    analysisGroupData <- analysisGroupData[ analysisGroupData$batchCode != "NA::NA", ]
    # transformed and normalized should be included if they are not null
    # resultKinds should include activityColumns, numericValue, data, results
    # example set:
    #       resultTypes <- data.table(valueKind=c("barcode", "well name", "well type", "normalized activity","transformed efficacy", "transformed standard deviation"),
    #                                 valueType=c("codeValue", "stringValue", "stringValue", "numericValue", "numericValue", "numericValue"),
    #                                 columnName=c("assayBarcode", "well", "wellType", "normalizedActivity", "transformed_percent efficacy", "transformed_sd"),
    #                                 stateType=c("metadata","metadata","metadata", "data", "data", "data"),
    #                                 stateKind=c("plate information", "plate information", "plate information", "results", "results", "results"),
    #                                 stringsAsFactors=FALSE)
    #
    resultTypes <- fread(file.path(racas::applicationSettings$appHome, "src/r/PrimaryScreen/conf/savingSettings.csv"))

    #       resultTypes <- data.table(valueKind=c("barcode", "well name", "well type", "normalized activity","transformed efficacy", "transformed standard deviation"),
    #                                 valueType=c("codeValue", "stringValue", "stringValue", "numericValue", "numericValue", "numericValue"),
    #                                 columnName=c("assayBarcode", "well", "wellType", "normalizedActivity", "transformed_percent efficacy", "transformed_sd"),
    #                                 stateType=c("metadata","metadata","metadata", "data", "data", "data"),
    #                                 stateKind=c("plate information", "plate information", "plate information", "results", "results", "results"),
    #                                 publicData=c(TRUE, TRUE, TRUE, TRUE, TRUE, TRUE),
    #                                 stringsAsFactors=FALSE)

    resultTable[, tempId:=index]
    subjectDataLong <- meltKnownTypes(resultTable, resultTypes, "saveAsSubject")
		rm(resultTable)
		gc()


    # Remove empty rows (getting rid of NA flags)
    subjectDataLong <- subjectDataLong[!(is.na(numericValue) & is.na(stringValue) & is.na(codeValue))]

    treatmentGroupDataLong <- meltKnownTypes(treatmentGroupData, resultTypes, "saveAsTreatment")
		rm(treatmentGroupData)
		gc()

    analysisGroupDataLong <- meltKnownTypes(analysisGroupData, resultTypes, "saveAsAnalysis",
                                            forceBatchCodeAdd = TRUE)
		rm(analysisGroupData)
		gc()
    analysisGroupDataLong[, parentId:=experimentId]

    # Removes blank rows
    treatmentGroupDataLong <- treatmentGroupDataLong[!(is.na(stringValue) & is.na(numericValue) & is.na(codeValue) & is.na(fileValue))]
    analysisGroupDataLong <- analysisGroupDataLong[!(is.na(stringValue) & is.na(numericValue) & is.na(codeValue) & is.na(fileValue))]
    if (parameters$htsFormat) {
      analysisGroupDataLong <- removeNonCurves(analysisGroupDataLong)
    }

    # Change subject hits to be saved in lowercase
    subjectDataLong[valueKind == "flag status" & tolower(codeValue) == "hit", codeValue := "hit"]
    subjectDataLong[valueKind == "flag status" & tolower(codeValue) == "ko", codeValue := "knocked out"]

		# TODO: Replacing uploadData to possibly save memory here
		# This area needs cleanup and testing to see if it actually saves memory
		analysisGroupData <- analysisGroupDataLong
		rm(analysisGroupDataLong)
		gc()
		treatmentGroupData <- treatmentGroupDataLong
		rm(treatmentGroupDataLong)
		gc()
		subjectData <- subjectDataLong
		rm(subjectDataLong)
		gc()
		recordedBy <- user

		# Start replacement of uploadData function
		library('plyr')

		valueKindDF <- unique(data.frame(
			valueKind = c(analysisGroupData$valueKind, treatmentGroupData$valueKind, subjectData$valueKind),
			valueType = c(analysisGroupData$valueType, treatmentGroupData$valueType, subjectData$valueType)
		))
		valueKindDF <- valueKindDF[!is.na(valueKindDF$valueKind), ]
		validateValueKinds(valueKindDF$valueKind, valueKindDF$valueType)

		if(is.null(lsTransaction)) {
			lsTransaction <- createLsTransaction()$id
		}

		### Analysis Group Data
		# Not all of these will be filled
		analysisGroupData$tempStateId <- as.numeric(as.factor(paste0(analysisGroupData$tempId, "-", analysisGroupData$stateGroupIndex, "-",
																																 analysisGroupData$stateKind)))
		analysisGroupData[is.na(stateKind), tempStateId:=NA_real_]

		if(is.null(analysisGroupData$publicData) && nrow(analysisGroupData) > 0) {
			analysisGroupData$publicData <- TRUE
		}
		if(is.null(analysisGroupData$stateGroupIndex) && nrow(analysisGroupData) > 0) {
			analysisGroupData$stateGroupIndex <- 1
		}

		#analysisGroupData <- rbind.fill(analysisGroupData, meltConcentrations(analysisGroupData))
		#analysisGroupData <- rbind.fill(analysisGroupData, meltTimes(analysisGroupData))
		#analysisGroupData <- rbind.fill(analysisGroupData, meltBatchCodes(analysisGroupData, batchCodeStateIndices=1, optionalColumns = "analysisGroupID"))

		analysisGroupData$lsTransaction <- lsTransaction
		analysisGroupData$recordedBy <- recordedBy
		analysisGroupData$lsType <- "default"
		analysisGroupData$lsKind <- "default"

		#analysisGroupIDandVersion <- saveFullEntityData(analysisGroupData, "analysisGroup")

		if(!is.null(treatmentGroupData)) {
			### TreatmentGroup Data
			treatmentGroupData$lsTransaction <- lsTransaction
			treatmentGroupData$recordedBy <- recordedBy
			treatmentGroupData$tempStateId <- as.numeric(as.factor(paste0(treatmentGroupData$tempId, "-", treatmentGroupData$stateGroupIndex, "-",
																																		treatmentGroupData$stateKind)))

			treatmentGroupData$lsType <- "default"
			treatmentGroupData$lsKind <- "default"

		}

		if(!is.null(subjectData)) {
			### subject Data
			subjectData$lsTransaction <- lsTransaction
			subjectData$recordedBy <- recordedBy
			subjectData$tempStateId <- as.numeric(as.factor(paste0(subjectData$tempId, "-", subjectData$stateGroupIndex, "-",
																														 subjectData$stateKind)))
			subjectData$lsType <- "default"
			subjectData$lsKind <- "default"
		}

		# Start replacement of saveAllViaDirectDatabase function
		appendCodeName <- list(analysisGroup = "curve id")
		sendFiles <- list()

		if (!(is.null(appendCodeName$analysisGroup))) {
			analysisGroupData <- appendCodeNames(analysisGroupData, appendCodeName$analysisGroup, "analysis group")
		}
		if (!(is.null(appendCodeName$treatmentGroup))) {
			treatmentGroupData <- appendCodeNames(treatmentGroupData, appendCodeName$treatmentGroup, "treatment group")
		}
		if (!(is.null(appendCodeName$subject))) {
			subjectData <- appendCodeNames(subjectData, appendCodeName$subject, "subject")
		}
		setkey(analysisGroupData, NULL)
		setkey(treatmentGroupData, NULL)
		setkey(subjectData, NULL)
#       response <- saveDataDirectDatabase(analysisGroupData,
#                                          treatmentGroupData,
#                                          subjectData)
		# Start replacement of saveDataDirectDatabase function
		lsTransactionId <- NA
		agData <- analysisGroupData
		rm(analysisGroupData)
		gc()
		tgData <- treatmentGroupData
		rm(treatmentGroupData)
		gc()


		if (is.na(lsTransactionId)) {
			if (is.null(agData$lsTransaction)) {
				stop("If lsTransactionId is NA, lsTransaction must be defined in input data tables")
			} else {
				lsTransactionId <- unique(agData$lsTransaction)
				if (length(lsTransactionId) > 1) {
					stop("multiple lsTransaction's found in agData")
				}
				if (is.na(lsTransactionId)) {
					stop("lsTransactionId cannot be NA when all lsTransaction in agData are NA")
				}
			}
		}

		conn <- getDatabaseConnection(racas::applicationSettings)
		on.exit(dbDisconnect(conn))
		result <- tryCatchLog({
			if (grepl("Oracle", racas::applicationSettings$server.database.driver)){
				sqlDeferConstraints <- "SET CONSTRAINTS ALL DEFERRED"
				rs1 <- dbSendQuery(conn, sqlDeferConstraints)
				Sys.setenv(ORA_SDTZ = "PST8PDT")
				Sys.setenv(TZ = "PST8PDT")
				recordedDate <- Sys.time()
			} else {
				dbSendQuery(conn, "BEGIN TRANSACTION")
				recordedDate <- as.character(format(Sys.time(), "%Y-%m-%d %H:%M:%OS"))
			}

			# Saving each set. The garbage collection may be unnecessary, but won't hurt
			if (!is.null(agData)) {
				agData <- prepareTableForDD(agData)
				outputAgDT <- saveAgDataDD(conn, agData, experimentId, lsTransactionId, recordedDate)
				rm(agData)
				gc()
			}

			if (!is.null(tgData)) {
				tgData <- prepareTableForDD(tgData)
				outputTgDT <- saveTgDataDD(conn, tgData, outputAgDT, lsTransactionId, recordedDate)
				rm(tgData)
				rm(outputAgDT)
				gc()
			}

			if (!is.null(subjectData)) {
				subjectData <- prepareTableForDD(subjectData)
				outputSubjectDT <- saveSubjectDataDD(conn, subjectData, outputTgDT, lsTransactionId, recordedDate)
				rm(subjectData)
				rm(outputTgDT)
				rm(outputSubjectDT)
				gc()
			}
			TRUE
		})

		# If anything fails, roll the transaction back
		if (is.null(result) || is.null(result$value)){
			dbRollback(conn)
			if (grepl("Oracle", racas::applicationSettings$server.database.driver)){
				# On Oracle, delete everything saved in this transaction
				limitQuery <-  paste("where ls_transaction =", lsTransactionId)
				dbSendQuery(conn, paste("delete from subject_value", limitQuery))
				dbSendQuery(conn, paste("delete from subject_state", limitQuery))
				dbSendQuery(conn, paste("delete from treatment_group_value", limitQuery))
				dbSendQuery(conn, paste("delete from treatment_group_state", limitQuery))
				dbSendQuery(conn, paste("delete from analysis_group_value", limitQuery))
				dbSendQuery(conn, paste("delete from analysis_group_state", limitQuery))
				dbSendQuery(conn, paste("delete from treatmentgroup_subject where treatment_group_id in ",
																"(select id from treatment_group", limitQuery, ")"))
				dbSendQuery(conn, paste("delete from analysisgroup_treatmentgroup where analysis_group_id in ",
																"(select id from analysis_group", limitQuery, ")"))
				dbSendQuery(conn, paste("delete from subject", limitQuery))
				dbSendQuery(conn, paste("delete from treatment_group", limitQuery))
				dbSendQuery(conn, paste("delete from experiment_analysisgroup where analysis_group_id in ",
																"(select id from analysis_group", limitQuery, ")"))
				dbSendQuery(conn, paste("delete from analysis_group", limitQuery))
				dbCommit(conn)
			}
			stop("direct database save failed")
		} else {
			dbCommit(conn)
		}

    viewerLink <- racas::getViewerLink(experiment = experiment)

    summaryInfo$viewerLink <- viewerLink
  }
  
  summaryInfo$info$"Original Data File" <- paste0(
    '<a href="', getAcasFileLink(serverFileLocation, login=T), '" target="_blank">Original Data File</a>')
  if (!is.null(serverFlagFileLocation)) {
    summaryInfo$info$"Original Flag File" <- paste0(
      '<a href="', getAcasFileLink(serverFlagFileLocation, login=T), '" target="_blank">Original Flag File</a>')
  }
  summaryInfo$lsTransactionId <- lsTransaction
  summaryInfo$experiment <- experiment
  
  return(summaryInfo)
}

combineTwoAgonist <- function(agData) {
  if(nrow(agData) == 1) {
    return(agData)
  } else if (nrow(agData) > 2) { # This should not happen, these should be curves
    stop(paste("Too many rows for combineTwoAgonist:", nrow(agData)))
  } else if (sum(agData$agonistConc == 0) != 1) {
    stopUser(paste("At least one concentration must be 0 for ", agData$batchCode[1]))
  } else {
    outputTable <- agData[agonistConc > 0]
    # outputTable[, transformed_noAgonist := agData[agonistConc == 0, normalizedActivity]]
    return(outputTable)
  }
}

validateValueKinds <- function(valueKinds, valueTypes, createNew=TRUE) {
  # valueKinds a vector of valueKinds
  # valueTypes a vector of matching valueTypes
  # createNew a boolean marking to cerate new valueKinds rather than just validating
  currentValueKindsList <- getAllValueKinds()
  if (length(currentValueKindsList) == 0) {
    stopUser("Setup error: valueKinds are missing")
  }
  currentValueKinds <- sapply(currentValueKindsList, getElement, "kindName")
  matchingValueTypes <- sapply(currentValueKindsList, function(x) x$lsType$typeName)
  
  newValueKinds <- setdiff(valueKinds, currentValueKinds)
  oldValueKinds <- intersect(valueKinds, currentValueKinds)
  
  # Check that the value kinds that have been entered before have the correct Datatype (valueType)
  oldValueKindTypes <- valueTypes[match(oldValueKinds, valueKinds)]
  currentValueKindTypeFrame <- data.frame(currentValueKinds, matchingValueTypes, stringsAsFactors=FALSE)
  oldValueKindTypeFrame <- data.frame(oldValueKinds, oldValueKindTypes, stringsAsFactors=FALSE)
  
  comparisonFrame <- merge(oldValueKindTypeFrame, currentValueKindTypeFrame, 
                           by.x = "oldValueKinds", by.y = "currentValueKinds")
  wrongValueTypes <- comparisonFrame$oldValueKindTypes != comparisonFrame$matchingValueTypes
  
  if (any(wrongValueTypes)) {
    stopUser("Invalid value types")
  }
  
  if (createNew && length(newValueKinds) > 0) {
    # Create the new valueKinds, using the correct valueType
    newValueKindTypes <- valueTypes[match(newValueKinds, valueKinds)]
    
    saveValueKinds(newValueKinds, newValueKindTypes)
  }
  
  return(NULL)
}




# uploadData <- function(lsTransaction=NULL,analysisGroupData,treatmentGroupData=NULL,subjectData=NULL,
#                        recordedBy) {
#   # Uploads all the data to the server
#   #
#   # Args:
#   #   lsTransaction:          An id of the transaction
#   #   analysisGroupData:      A data.table of the analysis group data
#   #   treatmentGroupData:     A data.table of the treatment group data
#   #   subjectData:            A data.table of the subject data
#   #   recordedBy:             The username of the current user
#   #
#   #   Returns:
#   #     lsTransaction
#
#   library('plyr')
#
#   valueKindDF <- unique(data.frame(
#     valueKind = c(analysisGroupData$valueKind, treatmentGroupData$valueKind, subjectData$valueKind),
#     valueType = c(analysisGroupData$valueType, treatmentGroupData$valueType, subjectData$valueType)
#   ))
#   valueKindDF <- valueKindDF[!is.na(valueKindDF$valueKind), ]
#   validateValueKinds(valueKindDF$valueKind, valueKindDF$valueType)
#
#   if(is.null(lsTransaction)) {
#     lsTransaction <- createLsTransaction()$id
#   }
#
#   ### Analysis Group Data
#   # Not all of these will be filled
#   analysisGroupData$tempStateId <- as.numeric(as.factor(paste0(analysisGroupData$tempId, "-", analysisGroupData$stateGroupIndex, "-",
#                                       analysisGroupData$stateKind)))
#   analysisGroupData[is.na(stateKind), tempStateId:=NA_real_]
#
#   if(is.null(analysisGroupData$publicData) && nrow(analysisGroupData) > 0) {
#     analysisGroupData$publicData <- TRUE
#   }
#   if(is.null(analysisGroupData$stateGroupIndex) && nrow(analysisGroupData) > 0) {
#     analysisGroupData$stateGroupIndex <- 1
#   }
#
#   #analysisGroupData <- rbind.fill(analysisGroupData, meltConcentrations(analysisGroupData))
#   #analysisGroupData <- rbind.fill(analysisGroupData, meltTimes(analysisGroupData))
#   #analysisGroupData <- rbind.fill(analysisGroupData, meltBatchCodes(analysisGroupData, batchCodeStateIndices=1, optionalColumns = "analysisGroupID"))
#
#   analysisGroupData$lsTransaction <- lsTransaction
#   analysisGroupData$recordedBy <- recordedBy
#   analysisGroupData$lsType <- "default"
#   analysisGroupData$lsKind <- "default"
#
#   #analysisGroupIDandVersion <- saveFullEntityData(analysisGroupData, "analysisGroup")
#
#   if(!is.null(treatmentGroupData)) {
#     ### TreatmentGroup Data
#     treatmentGroupData$lsTransaction <- lsTransaction
#     treatmentGroupData$recordedBy <- recordedBy
#     treatmentGroupData$tempStateId <- as.numeric(as.factor(paste0(treatmentGroupData$tempId, "-", treatmentGroupData$stateGroupIndex, "-",
#                                          treatmentGroupData$stateKind)))
#
#     treatmentGroupData$lsType <- "default"
#     treatmentGroupData$lsKind <- "default"
#
#   }
#
#   if(!is.null(subjectData)) {
#     ### subject Data
#     subjectData$lsTransaction <- lsTransaction
#     subjectData$recordedBy <- recordedBy
#     subjectData$tempStateId <- as.numeric(as.factor(paste0(subjectData$tempId, "-", subjectData$stateGroupIndex, "-",
#                                   subjectData$stateKind)))
#     subjectData$lsType <- "default"
#     subjectData$lsKind <- "default"
#   }
#
#   saveAllViaDirectDatabase(analysisGroupData, treatmentGroupData, subjectData,
#                 appendCodeName = list(analysisGroup = "curve id"))
#
#   return (lsTransaction)
# }

changeColNameReadability <- function(inputTable, readabilityChange, parameters) {
  # Changes column names of inputTable human-readable to non-spaced computer-readable
  # inputTable: a data.table
  # readabilityChange: "computerToHuman" or "humanToComputer"
  colNameChangeTable <- getColNameChangeDataTables(parameters)[[readabilityChange]]
  
  colNameChangeTable <- selectColNamesToChange(colnames(inputTable), colNameChangeTable)
  
  setnames(inputTable, 
           colNameChangeTable[!is.na(colNamesToChange)]$oldColNames, 
           colNameChangeTable[!is.na(colNamesToChange)]$newColNames)
  
  return(inputTable)
  
}

selectColNamesToChange <- function(currentColNames, colNameChangeTable) {
  
  for(name in colNameChangeTable$oldColNames) {
    columnCount <- 0
    for(currentName in currentColNames) {
      if(name == currentName) {
        colNameChangeTable[oldColNames==name, colNamesToChange := name]
        columnCount <- columnCount + 1
      }
    }
    if(columnCount > 1) {
      stopUser(paste0("Non-unique colnames when changing between computer and human readability."))
    } 
  } 
  
  return(colNameChangeTable)
}
getGroupBy <- function(parameters) {
  groupBy <- switch(parameters$aggregateBy,
                    "entire assay" = c("batchCode", "wellType"),
                    "cmpd plate" = c("batchCode", "wellType", "cmpdBarcode"),
                    "assay plate" = c("batchCode", "wellType", "assayBarcode"),
                    "none" = c("batchCode", "wellType", "assayBarcode", "well"),
                    "cmpd batch conc" = c("batchCode", "wellType"),               # TODO: remove this line when done with old tests
                    "compound batch concentration" = c("batchCode", "wellType"))  # TODO: remove this line when done with old tests
  if (is.null(groupBy)) {
    warnUser("No valid aggregation selected. Using no aggregation.")
    groupBy <- c("batchCode", "wellType", "assayBarcode", "well")
  }
  return(groupBy)
}
getColNameChangeDataTables <- function(parameters) {
  
  colNameDataTable <- data.table(computerColNames = c("plateType",
                                                      "assayBarcode",
                                                      "cmpdBarcode",
                                                      "sourceType",
                                                      "well",
                                                      "row",
                                                      "column",
                                                      "plateOrder",
                                                      "wellType",
                                                      "batchName",
                                                      "batch_number",
                                                      "batchCode",
                                                      "cmpdConc",
                                                      "transformed_percent efficacy",
                                                      "transformed_sd",
                                                      "zPrimeByPlate",
                                                      "rawZPrimeByPlate",
                                                      "zPrime",
                                                      "rawZPrime",
                                                      "activity",
                                                      "normalizedActivity",
                                                      "flagType",  
                                                      "flagObservation",
                                                      "flagReason",
                                                      "flagComment",
                                                      "autoFlagType",
                                                      "autoFlagObservation",
                                                      "autoFlagReason"),
                                 humanColNames = c("Plate Type",
                                                   "Assay Barcode",
                                                   "Compound Barcode",
                                                   "Source Type",
                                                   "Well",
                                                   "Row",
                                                   "Column",
                                                   "Plate Order",
                                                   "Well Type",
                                                   "Corporate Name",
                                                   "Batch Number",
                                                   "Corporate Batch Name",
                                                   "Compound Concentration",
                                                   "Efficacy",
                                                   "SD Score",
                                                   "Z' By Plate",
                                                   "Raw Z' By Plate",
                                                   "Z'",
                                                   "Raw Z'",
                                                   getActivityFullName(parameters),
                                                   "Normalized Activity",
                                                   "Flag Type",
                                                   "Flag Observation",
                                                   "Flag Reason",
                                                   "Flag Comment",
                                                   "Auto Flag Type",
                                                   "Auto Flag Observation",
                                                   "Auto Flag Reason"))
  
  colNameDataTableList <- formatColumnNameChangeDT(colNameDataTable)
  
  return(colNameDataTableList)
}
getActivityFullName <- function(parameters) {
  # Gets a full activity name with read name and position included
  if (is.null(parameters$primaryAnalysisReadList)) {
    return("NotActivity")
  }
  rot <- getReadOrderTable(parameters$primaryAnalysisReadList)
  activityReadName <- rot[rot$activity, paste0("R", userReadOrder, " {", readName, "}")]
  return(paste0("Activity - ", activityReadName))
}
formatColumnNameChangeDT <- function(colDataTable) {
  # Takes a data.table containing two columns: compColNames and humColNames. Returns a list containing two data tables. 
  # One will translate human to computer readable, the other will be computer to human readable. 
  # Depending on what you want, you can pick the data.table that you need for translation.
  # Input:  colDataTable (colnames = "compColNames", "humColNames")
  # Output: list of two data.tables - computerToHuman and humanToComputer
  
  colDataTable$colNamesToChange <- as.character(NA)
  
  computerToHuman <- copy(colDataTable)
  setnames(computerToHuman, c("computerColNames","humanColNames"), c("oldColNames","newColNames"))
  
  
  humanToComputer <- copy(colDataTable)
  setnames(humanToComputer, c("humanColNames","computerColNames"), c("oldColNames","newColNames"))
  
  
  return(list(computerToHuman=computerToHuman, humanToComputer=humanToComputer))
}
getTreatmentGroupData <- function(batchDataTable, parameters, groupBy) {
  # batchDataTable: data.table with columns listed in groupBy plus "tempParentId"
  # parameters: list, currently only used for aggregationMethod
  # groupBy: character vector of grouping columns for which subjects belong to one treatment group
  #
  # Averages numeric values, keeps stringValue and codeValue if they are unique

  groupBy <- c(groupBy, "tempParentId")
  
  resultTypes <- fread(file.path(racas::applicationSettings$appHome, "src/r/PrimaryScreen/conf/savingSettings.csv"))

  # get means of meanTarget columns
  meanTarget <- c(grep("^R\\d+ ", names(batchDataTable), value=TRUE),
                  "activity", "normalizedActivity",
                  grep("^transformed_", names(batchDataTable)[vapply(batchDataTable, class, "") == "numeric"], value=TRUE)
  )
  yesNoSometimesTarget <- c("") # Text transformations... should these be in meanTarget, and key on class?
  allRequiredTarget <- c("") # Same problem # Used when all booleans must be true for aggregate to be true
  # Returns unique or NA if non-unique within the group
  uniqueTarget <- intersect(resultTypes[valueType %in% c("stringValue", "codeValue") & saveAsTreatment, columnName],
                            names(batchDataTable))
  uniqueTarget <- setdiff(uniqueTarget, groupBy)
  uniqueTarget <- c(uniqueTarget, grep("^transformed_", names(batchDataTable)[vapply(batchDataTable, class, "") == "character"], value=TRUE))

  # get SD of sdTarget columns... they happen to be the same as meanTarget, but aren't required to be
  sdTarget <- c(grep("^R\\d+ ", names(batchDataTable), value=TRUE),
                "activity", "normalizedActivity",
                grep("^transformed_", names(batchDataTable)[vapply(batchDataTable, class, "") == "numeric"], value=TRUE)
  )

  uniqueResults <- batchDataTable[ , lapply(.SD, function(x) {
    result <- unique(x)
    if (length(x) == 1) {
      return(x)
    } else {
      return(as(NA, class(x)))
    }
  }), by = groupBy, .SDcols = uniqueTarget]

  aggregationFunction <- switch(parameters$aggregationMethod,
                                "mean" = function(x) {as.numeric(mean(x, na.rm = T))},
                                "median" = function(x) {as.numeric(median(x, na.rm = T))},
                                "returnNA" = function(x) {NA_real_},
                                stopUser("Internal error: Aggregation method not defined in system.")
  )
  aggregationResults <- batchDataTable[ , lapply(.SD, aggregationFunction), by = groupBy, .SDcols = meanTarget]
  sds <- batchDataTable[ , lapply(.SD, sd), by = groupBy, .SDcols = sdTarget] 
  
  ### get numberOfReplicates
  numRep <- batchDataTable[ , lapply(.SD, function(x) {as.numeric(length(x))}), by = groupBy, .SDcols = sdTarget] 
  setnames(sds, sdTarget, paste0("standardDeviation_", sdTarget))
  setnames(numRep, sdTarget, paste0("numberOfReplicates_", sdTarget))
  
  ### combine all tables together by setting keys
  setkeyv(sds, groupBy)
  setkeyv(numRep, groupBy)
  setkeyv(aggregationResults, groupBy)
  setkeyv(uniqueResults, groupBy)
  treatmentData <- sds[aggregationResults][numRep]
  treatmentData <- merge(treatmentData, uniqueResults, all.x = TRUE)

  setnames(treatmentData, "tempParentId", "tempId")
  
  return(treatmentData)
}
getAnalysisGroupData <- function(treatmentGroupData, analysisGroupBy) {
  # Inputs:
  #   treatmentGroupData: data.table with columns for each kind of data, at least:
  #     "tempParentId" for marking each analysis group
  #     "cmpdConc" concentration
  #     "agonistConc" agonist concentration
  #     "agonistBatchCode" agonist batch code
  #     all columns listed in analysisGroupBy
  #     any other data columns
  #   analysisGroupBy: character vector of columns used for grouping. Their information will be kept even curves
  # Returns a data.table where curves have been compressed into a single row, they gain a "curveId"
  # Note: do not input a column named doseResponse, it would be removed

  library(data.table)
  preCurveData <- copy(treatmentGroupData)
  preCurveData[, curveId:=NA_character_]
  preCurveData[, doseResponse := length(unique(paste(cmpdConc, "-", agonistConc, "-", agonistBatchCode))) >= 3, by=tempParentId]
  setkey(preCurveData, tempParentId)

  curveData <- preCurveData[doseResponse == TRUE][J(unique(tempParentId)), mult = "first"]

  curveData[, names(preCurveData)[!names(preCurveData) %in% c('tempParentId', analysisGroupBy)] := NA, with = FALSE]
  curveData[, curveId := as.character(1:nrow(curveData))]
  otherData <- preCurveData[doseResponse == FALSE]
  analysisData <- rbind(curveData, otherData)
  analysisData[, tempId := NULL]
  setnames(analysisData, "tempParentId", "tempId")
  analysisData[, doseResponse := NULL]  
  return(analysisData)
  
  # TODO: bring hasAgonist back in (in 1.5.1), or put in a config
  
  #       if (parameters$aggregateReplicates == "across plates") {
  #         treatmentGroupData <- batchDataTable[, list(groupAggregate = useAggregationMethod(values, parameters), 
  #                                                     stDev = sd(values), n=length(values), 
  #                                                     sdScore = useAggregationMethod(sdScore, parameters), 
  #                                                     threshold = ifelse(all(threshold), "yes", "no"),
  #                                                     latePeak = if (all(latePeak)) "yes" else if (!any(latePeak)) "no" else "sometimes"),
  #                                              by=list(batchName,fluorescent,concUnit,hasAgonist, wellType)]
  #       } else if (parameters$aggregateReplicates == "within plates") {
  #         treatmentGroupData <- batchDataTable[, list(groupAggregate = useAggregationMethod(values, parameters), 
  #                                                     stDev = sd(values), 
  #                                                     n=length(values),
  #                                                     sdScore = useAggregationMethod(sdScore, parameters),
  #                                                     threshold = ifelse(all(threshold), "yes", "no"),
  #                                                     latePeak = if (all(latePeak)) "yes" else if (!any(latePeak)) "no" else "sometimes"),
  #                                              by=list(batchName,fluorescent,barcode,concUnit,hasAgonist, wellType)]
  #       } else {
  #         treatmentGroupData <- batchDataTable[, list(batchName = batchName, 
  #                                                     fluorescent = fluorescent, 
  #                                                     wellType = wellType, 
  #                                                     groupMean = values, 
  #                                                     stDev = NA, 
  #                                                     n = 1, 
  #                                                     sdScore = sdScore,
  #                                                     maxTime = maxTime,
  #                                                     overallMaxTime = overallMaxTime,
  #                                                     threshold = ifelse(threshold, "yes", "no"),
  #                                                     hasAgonist = hasAgonist)]
  #       }
  #       treatmentGroupData$treatmentGroupId <- 1:nrow(treatmentGroupData)
  ##### TODO: End Sam Fix
  
}
meltKnownTypes <- function(resultTable, resultTypes, includedColumn, forceBatchCodeAdd = FALSE) {
  # includedColumn is "saveAsSubject" or "saveAsTreatment" or "saveAsAnalysis"
  # resultTable is a Data Table, tempId is a required column, tempParentId is optional
  # resultTypes is a data table with information about each valueKind/columnHeader
  # forceBatchCodeAdd boolean to decide if batch code state kind is changed to match others
  library(reshape2)
  
  idVars <- "tempId"
  if ("tempParentId" %in% names(resultTable)) {
    idVars <- c(idVars, "tempParentId")
  }

  # Cannot use a single concentration column for more than one columnName
  codeConcVector <- na.omit(resultTypes$concColumn)
  codeIdVars <- c(idVars, codeConcVector)
  
  # Get columns that are in resultTypes and are correct for this melt type
  usedCol <- (resultTypes$columnName %in% names(resultTable)) & (resultTypes[, includedColumn, with=F][[1]])
  
  # Numeric results include standard deviation and number of replicates, others do not
  numericResultColumns <- resultTypes[valueType=="numericValue" & usedCol, columnName]
  stDevColumns <- paste0("standardDeviation_", numericResultColumns)
  stDevColumns <- intersect(stDevColumns, names(resultTable))
  numRepColumns <- paste0("numberOfReplicates_", numericResultColumns)
  numRepColumns <- intersect(numRepColumns, names(resultTable))
  codeResultColumns <- resultTypes[valueType=="codeValue" & usedCol, columnName]
  stringResultColumns <- resultTypes[valueType=="stringValue" & usedCol, columnName]
  inlineFileResultColumns <- resultTypes[valueType=="inlineFileValue" & usedCol, columnName]

  ### Melt each group
  numericResults <- melt(resultTable, id.vars=idVars, measure.vars=numericResultColumns, 
                         variable.name="columnName", value.name="numericValue")
  stDevResults <- melt(resultTable, id.vars=idVars, measure.vars=stDevColumns, 
                       variable.name="columnName", value.name="uncertainty")
  numRepResults <- melt(resultTable, id.vars=idVars, measure.vars=numRepColumns, 
                        variable.name="columnName", value.name="numberOfReplicates")
  codeResults <- melt(resultTable, id.vars=codeIdVars, measure.vars=codeResultColumns, 
                      variable.name="columnName", value.name="codeValue")
  stringResults <- melt(resultTable, id.vars=idVars, measure.vars=stringResultColumns, 
                        variable.name="columnName", value.name="stringValue", 
                        variable.factor = FALSE)
  inlineFileResults <- melt(resultTable, id.vars=idVars, measure.vars=inlineFileResultColumns,
                            variable.name="columnName", value.name="fileValue",
                            variable.factor = FALSE)

  if (!"fileValue" %in% names(inlineFileResults)) {
    inlineFileResults[, fileValue := NA_character_]
  }
  inlineFileResults[, comments := basename(fileValue)]

  ### Combine numericValues with their standard deviations and number of replicates
  keyCols <- c(idVars, "columnName")
  setkeyv(numericResults, keyCols)
  if (length(stDevColumns) > 0) {
    stDevResults[, columnName := gsub("standardDeviation_", "", columnName, fixed = TRUE)]
    stDevResults[, uncertaintyType:="standard deviation"]
    setkeyv(stDevResults, keyCols)
    numericResults <- numericResults[stDevResults]
  }
  if (length(numRepColumns) > 0) {
    numRepResults[, columnName := gsub("numberOfReplicates_", "", columnName, fixed = TRUE)]
    setkeyv(numRepResults, keyCols)
    setkeyv(numericResults, keyCols)
    numericResults <- numericResults[numRepResults]
  }
  
  # Get concentrations
  codeResults[, concentration:=NA_real_]
  setkeyv(codeResults, "columnName")
  for (concCol in codeConcVector) {
    codeResults[columnName == resultTypes[concColumn == concCol, columnName], concentration:=get(concCol)]
  }
  codeResults[, (codeConcVector) := NULL]
  codeConcDT <- resultTypes[!is.na(concColumn), list(columnName, concUnit)]
  setkeyv(codeConcDT, "columnName")

  codeResults <- merge(codeResults, codeConcDT, all.x = TRUE)
  
  # Combines all tables, filling with NA
  longResults <- rbindlist(list(numericResults, codeResults, stringResults, inlineFileResults), fill = TRUE)
  
  # Get publicData, stateType, stateKind, etc.
  resultTypesCopy <- copy(resultTypes)
  resultTypesCopy[, c("concColumn", "concUnit") := NULL]
  fullTable <- merge(longResults, resultTypesCopy, by = "columnName")
  
  if (forceBatchCodeAdd) {
    fullTable <- fullTable[!(is.na(numericValue) & is.na(stringValue) & is.na(codeValue) & is.na(fileValue))]
    # This line seems to do nothing... so removed
    #fullTable[valueKind=="batch code", stateKind:=unique(stateKind[valueKind!="batch code"]), by=tempId]
    # If the only value in the tempId is a batch code, there was a missing value input, so we just remove it
    fullTable[, removeMe := (valueKind=="batch code" && .N==1), by=tempId]
    fullTable <- fullTable[!(removeMe)]
    fullTable[, removeMe := NULL]
    fullTable[, stateKindCount := length(unique(stateKind[valueKind != "batch code"])), by=tempId]
    if (any(fullTable$stateKindCount) == 0) {
      stop("at least one tempId had no stateKinds, probably missing stateKinds")
    }
    fullTable[stateKindCount == 1, c("stateType", "stateKind") := matchBatchCodeStateKind(stateType, stateKind, valueKind), by=tempId]
    duplicatedRows <- fullTable[stateKindCount > 1, duplicateBatchCodes(.SD), by=tempId]
    fullTable <- rbind(fullTable[stateKindCount == 1], duplicatedRows)
    fullTable[, stateKindCount := NULL]
  }
  
  return(fullTable)  
}
duplicateBatchCodes <- function(DT) {
  # Duplicates rows with batch codes to have one batch code per state kind in the rest of the set
  # Input: DT, a data.table with at least columns valueKind, stateKind, stateType
  # Output: a data.table with the same columns as DT, but rows added
  newBatchCodeStateKinds <- unique(DT[valueKind != "batch code", list(stateType, stateKind)])
  if (sum(DT$valueKind == "batch code") != 1) {
    stop("Coding error: not expecting more than one batch code in group")
  }
  batchCodeRows <- DT[rep(which(valueKind == "batch code"), nrow(newBatchCodeStateKinds))]
  batchCodeRows[, stateType := newBatchCodeStateKinds$stateType]
  batchCodeRows[, stateKind := newBatchCodeStateKinds$stateKind]
  return(rbindlist(list(DT[valueKind != "batch code"], batchCodeRows)))
}
matchBatchCodeStateKind <- function(stateTypeVect, stateKindVect, valueKindVect) {
  # helper for meltKnownTypes
  # Input: character vectors
  # output: data.table with columns "stateType" and "stateKind"
  newState <- data.table(stateType = stateTypeVect, stateKind = stateKindVect)
  newBatchCodeStateTypeAndKind <- unique(newState[valueKindVect!="batch code"])
  if (nrow(newBatchCodeStateTypeAndKind) != 1) {
    stop("Coding Error: unable to find unique stateKind for batch codes")
  }
  newState[valueKindVect=="batch code", stateKind := newBatchCodeStateTypeAndKind$stateKind]
  newState[valueKindVect=="batch code", stateType := newBatchCodeStateTypeAndKind$stateType]
  return(newState)
}
deleteModelSettings <- function(experiment) {
  # Sets model fit settings back to their original values
  # Not changing model fit type, should not be checked if "model fit status"
  #   is "not started"
  updateValueByTypeAndKind("not started", "experiment", experiment$codeName, "metadata", 
                           "experiment metadata", "codeValue", "model fit status")
  #   updateValueByTypeAndKind("unassigned", "experiment", experiment$codeName, "metadata",
  #                            "experiment metadata", "codeValue", "model fit type")
  #   updateValueByTypeAndKind("[]", "experiment", experiment$codeName, "metadata",
  #                            "experiment metadata", "clobValue", "model fit parameters")
  updateValueByTypeAndKind("", "experiment", experiment$codeName, "metadata", 
                           "experiment metadata", "clobValue", "model fit result html")
}
updateHtsFormat <- function (htsFormat, experiment) {
  # Updates htsFormat to a standardized form of htsFormat, "true" or "false"
  htsFormat <- ifelse(as.logical(htsFormat), "true", "false")
  updateValueByTypeAndKind(htsFormat, "experiment", experiment$id, "metadata", "experiment metadata",
                           "stringValue", "hts format")
}
runPrimaryAnalysis <- function(request, externalFlagging=FALSE) {
  # Highest level function, runs everything else 
  #   externalFlagging should be TRUE when flagging is coming from a service,
  #   e.g. when called by spotfire

  library('racas')
  globalMessenger <- messenger()$reset()
  globalMessenger$devMode <- FALSE
  options("scipen"=15)
  #save(request, file="request.Rda")

  request <- as.list(request)
  experimentId <- request$primaryAnalysisExperimentId
  folderToParse <- request$fileToParse
  dryRun <- request$dryRunMode
  user <- request$user
  testMode <- request$testMode
  inputParameters <- request$inputParameters
  ## GUI json is locked into calling the second file a report file...
  request$flaggedFile <- request$reportFile
  flaggedWells <- request$flaggedFile
  flaggingStage <- ifelse(is.null(request$flaggingStage), "KOandHit", request$flaggingStage)
  # Fix capitalization mismatch between R and javascript
  dryRun <- interpretJSONBoolean(dryRun)
  testMode <- interpretJSONBoolean(testMode)
  developmentMode <- globalMessenger$devMode

  if (developmentMode) {
    loadResult <- list(value = runMain(folderToParse = folderToParse, 
                                       user = user, 
                                       dryRun = dryRun, 
                                       testMode = testMode, 
                                       experimentId = experimentId, 
                                       inputParameters = inputParameters,
                                       flaggedWells = flaggedWells,
                                       flaggingStage = flaggingStage,
                                       externalFlagging = externalFlagging))
  } else {
    loadResult <- tryCatchLog(runMain(folderToParse = folderToParse, 
                                      user = user, 
                                      dryRun = dryRun, 
                                      testMode = testMode, 
                                      experimentId = experimentId, 
                                      inputParameters = inputParameters,
                                      flaggedWells = flaggedWells,
                                      flaggingStage = flaggingStage,
                                      externalFlagging = externalFlagging))
  }
  
  allTextErrors <- getErrorText(loadResult$errorList)
  warningList <- getWarningText(loadResult$warningList)
  
  # Organize the error outputs
  hasError <- length(allTextErrors) > 0
  hasWarning <- length(warningList) > 0
  
  errorMessages <- list()
  
  # This is code that could put the error and warning messages into a format that is displayed at the bottom of the screen
  errorMessages <- c(errorMessages, lapply(allTextErrors, function(x) {list(errorLevel="error", message=x)}))
  errorMessages <- c(errorMessages, lapply(warningList, function(x) {list(errorLevel="warning", message=x)}))
  #   errorMessages <- c(errorMessages, list(list(errorLevel="info", message=countInfo))) 
  
  # Create the HTML to display
  htmlSummary <- createHtmlSummary(hasError, allTextErrors, hasWarning, warningList, 
                                   summaryInfo=loadResult$value, dryRun)
  
  tryCatch({
    if(is.null(loadResult$value$experiment)) {
      experiment <- getExperimentById(experimentId)
    } else {
      experiment <- loadResult$value$experiment
    }
    saveAnalysisResults(experiment, hasError, htmlSummary, user, dryRun)
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
  if (externalFlagging) {
    response$results$jsonSummary <- list(dryRunReports = loadResult$value$dryRunReports)
  }
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

# fix assayBarcode class
# Finish other TODO items
