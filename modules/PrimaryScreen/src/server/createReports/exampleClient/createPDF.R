createPDF <- function(resultTable, assayData, parameters, summaryInfo, threshold, experiment, dryRun=F, activityName) {
  # exampleClient
  require('data.table')
  require('reshape')
  require('gplots')
  require('gridExtra')
  source("src/r/PrimaryScreen/primaryAnalysisPlots.R", local = TRUE)
  
  #change this accordingly
  colCompare <- FALSE
  
  allResultTable <- resultTable
  resultTable <- resultTable[is.na(resultTable$flag),]
  resultTable <- resultTable[!is.na(resultTable$activity),]
  
  if(dryRun) {
    pdfLocation <- paste0("experiments/",experiment$codeName, "/draft/", experiment$codeName, "_SummaryDRAFT.pdf")
  } else {
    pdfLocation <- paste0("experiments/",experiment$codeName,"/analysis/",experiment$codeName,"_Summary.pdf")
  }
  pdfSave <- racas::getUploadedFilePath(pdfLocation)
  pdf(file = pdfSave, width = 8.5, height = 11)
  if(dryRun) {
    gplots::textplot("Validation DRAFT")
  }
  textToShow <- paste0("------------------------------------------------------------------------------------------------\n",
                       paste(paste0(names(summaryInfo$info),": ",summaryInfo$info),collapse="\n"))
  
  textplot(textToShow, halign="left",valign="top")
  title("Primary Screen")
  
  if(nrow(resultTable[wellType == "NC", ]) != 1 & nrow(resultTable[wellType == "PC", ]) != 1) {
    # density plot needs at least 2 points to select a bandwidth automatically
    # this function already handles 0 points but does not handle 1 point. This is a workaround.
    createDensityPlot(resultTable$normalizedActivity, resultTable$wellType, threshold = threshold, margins = c(25,4,4,8), activityName)
  }
  
  print(createGGComparison(graphTitle = "Plate Comparison", xColumn=resultTable$plateOrder,
                           wellType = resultTable$wellType, dataRow = resultTable$normalizedActivity, xLabel = "Plate Order", yLabel=activityName,
                           margins = c(4,2,20,4), rotateXLabel = FALSE, test = FALSE, colourPalette = c("blue","#4eb02e")))
 
  if(!is.null(resultTable$"transformed_percent efficacy")) {
    print(createGGComparison(graphTitle = "Efficacy by Compound Barcode", xColumn=resultTable$batchCode,
                             wellType = resultTable$wellType, dataRow = resultTable$"transformed_percent efficacy", xLabel = "Compound Batch", 
                             margins = c(4,2,20,4), rotateXLabel = TRUE, test = TRUE, colourPalette = c("blue","green","black"),
                             yLabel="percent efficacy", checkXLabel=TRUE))
    
    print(createGGComparison(graphTitle = "Efficacy by Plate Order", xColumn=resultTable$plateOrder,
                             wellType = resultTable$wellType, dataRow = resultTable$"transformed_percent efficacy", xLabel = "Plate Order", 
                             margins = c(4,2,20,4), rotateXLabel = FALSE, test = TRUE, colourPalette = c("blue","green","black"),
                             yLabel="percent efficacy"))
  }

  
  if(!any(is.na(resultTable$zPrimeByPlate))) {
    createZPrimeByPlatePlot(resultTable)
  }
  
  plateDataTable <- data.table(normalizedActivity = resultTable$normalizedActivity, 
                               wellReference = resultTable$well)
  rowVector <- gsub("\\d", "", resultTable$well)
  columnVector <- gsub("\\D", "", resultTable$well)
  
  # TODO: add to config file whether client needs a column comparison feature
  # colCompare is initialized in line 10 of this file (createPDF.R)
  if (!colCompare) {
    plateData <- plateDataTable[,list(normalizedValues = mean(normalizedActivity)), by=wellReference]
    print(createGGHeatmap("Heatmap of the Average of All Plates", plateData, margins=c(0,0,20,0),activityName))
  } else { #if column Compare is on
    for (barcode in unique(resultTable$assayBarcode)) {
      plateData <- data.frame(normalizedValues = resultTable$normalizedActivity[resultTable$assayBarcode==barcode], 
                              well = resultTable$well[resultTable$assayBarcode==barcode]) #, hits=resultTable$threshold[resultTable$assayBarcode==barcode])
      g1 <- createGGHeatmap(paste("Heatmap ",barcode), plateData, activityName=activityName)
      #     g2 <- createGGComparison(graphTitle = paste("Row Comparison ",barcode), 
      #                            yLimits = c(-1,2), 
      #                            xColumn = rowVector[resultTable$barcode==barcode],
      #                            wellType = resultTable$wellType[resultTable$barcode == barcode],
      #                            dataRow = plateData$transformedValues,
      #                              hits = plateData$hits,
      #                            xLabel = "Row",
      #                            colourPalette = c("red","green","black"))
      g3 <- createGGComparison(graphTitle = paste("Column Comparison ", barcode),
                               xColumn = columnVector[resultTable$assayBarcode==barcode],
                               wellType = resultTable$wellType[resultTable$assayBarcode == barcode],
                               dataRow = plateData$normalizedValues,
                               #hits = plateData$hits,
                               xLabel = "Column",
                               yLabel = "Normalized Activity (rfu)",
                               colourPalette = c("blue", "green", "red", "black"),
                               threshold = threshold)
      #     resultTable$well <- factor(resultTable$well, levels = levels(resultTable$well)[order(gsub("\\D", "", levels(resultTable$well)))])
      #     resultTable <- resultTable[order(gsub("\\D", "", resultTable$well)),]
      plateData <- data.frame(normalizedActivity = resultTable$normalizedActivity[resultTable$assayBarcode==barcode], 
                              well = resultTable$well[resultTable$assayBarcode==barcode]) #, hits=resultTable$threshold[resultTable$assayBarcode==barcode])
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
  }
#   allResultTable[, fluorescent := as.character(assayData$fluorescent)]
#   allResultTable[, timePoints := as.character(assayData$timePoints)]
#   allResultTable[, sequence := as.character(assayData$sequence)]

  setkeyv(allResultTable, c("assayBarcode", "batchCode"))
    
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
      mapply(plotFigure, wellType$T_timePoints, wellType$T_sequence, wellType$assayBarcode, wellType$well, wellType$batchCode, wellTypeName)
    }
  }
  fluorescentWells <- allResultTable[allResultTable$autoFlagObservation == "fluorescent", ]
  hitWells <- allResultTable[allResultTable$flag == "HIT", ]
  latePeakWells <- allResultTable[allResultTable$autoFlagObservation == "late peak", ]
  flaggedWells <- allResultTable[allResultTable$flag == "KO", ] #,well,sequence,timePoints,batchName)]
  positiveControlWells <- allResultTable[allResultTable$wellType == "PC", ]
  negativeControlWells <- allResultTable[allResultTable$wellType == "NC", ]
  
  plotWells(fluorescentWells, "Fluorescent Wells")
  plotWells(latePeakWells, "Late Peak Wells")
  plotWells(hitWells, "Hit Wells")
  plotWells(flaggedWells, "Flagged Wells")

  # Define scenario missingDataForControls is TRUE if at least one pair of T_timePoints, T_sequence corresponding to a PC, NC standard is NA (ignore VCs) 
  missingDataForControls <- ((any(is.na(allResultTable$T_timePoints[allResultTable$wellType!="test" & !(grepl("^VC",resultTable$wellType))]))) & 
                               (any(is.na(allResultTable$T_sequence[allResultTable$wellType!="test" & !(grepl("^VC",resultTable$wellType))]))))
  
  # Plot PC, NC only if all PC, NC standards have data in their corresponding T_timePoints and T_sequence
  if (!missingDataForControls) {
    plotWells(positiveControlWells, "Positive Control Wells")
    plotWells(negativeControlWells, "Negative Control Wells")
  }
  
  dev.off()
  
  
  return(pdfLocation)
}

# createPDFStat1Stat2Seq <- function(resultTable, parameters, summaryInfo, threshold, experiment, dryRun=F, activityName) {
#   require('gplots')
#   require('gridExtra')
#   require('data.table')
#   require('reshape')
#   source("public/src/modules/PrimaryScreen/src/server/primaryAnalysisPlots.R")
#   
#   allResultTable <- resultTable
#   resultTable <- resultTable[!resultTable$fluorescent & is.na(resultTable$flag),]
# 
#   
#   
#   if(dryRun) {
#     pdfLocation <- paste0("experiments/",experiment$codeName, "/draft/", experiment$codeName, "_SummaryDRAFT.pdf")
#   } else {
#     pdfLocation <- paste0("experiments/",experiment$codeName,"/analysis/",experiment$codeName,"_Summary.pdf")
#   }
#   pdfSave <- racas::getUploadedFilePath(pdfLocation)
#   pdf(file = pdfSave, width = 8.5, height = 11)
#   if(dryRun) {
#     textplot("Validation DRAFT")
#   }
#   textToShow <- paste0("------------------------------------------------------------------------------------------------\n",
#                        paste(paste0(names(summaryInfo$info),": ",summaryInfo$info),collapse="\n"))
#   
#   textplot(textToShow, halign="left",valign="top")
#   title("Primary Screen")
#   
#   createDensityPlot(resultTable$normalized, resultTable$wellType, threshold = threshold, margins = c(25,4,4,8), activityName)
#   
#   print(createGGComparison(graphTitle = "Plate Comparison", xColumn=resultTable$assayBarcode,
#                            wellType = resultTable$wellType, dataRow = resultTable$transformed, xLabel = "Plate", 
#                            margins = c(4,2,20,4), rotateXLabel = TRUE, test = FALSE, colourPalette = c("blue","green")))
#   
#   plateDataTable <- data.table(transformedValues = resultTable$transformed, 
#                                well = resultTable$well)
#   plateData <- plateDataTable[,list(transformedValues = mean(transformedValues)), by=well]
# 
#   print(createGGHeatmap("Heatmap of the Average of All Plates", plateData, margins=c(0,0,20,0)))
#   
#   rowVector <- gsub("\\d", "", resultTable$well)
#   columnVector <- gsub("\\D", "", resultTable$well)
#   for (barcode in levels(resultTable$barcode)) {
#     plateData <- data.frame(transformedValues = resultTable$normalized[resultTable$barcode==barcode], 
#                             well = resultTable$well[resultTable$barcode==barcode], hits=resultTable$threshold[resultTable$barcode==barcode])
#     g1 <- createGGHeatmap(paste("Heatmap ",barcode), plateData)
#     #     g2 <- createGGComparison(graphTitle = paste("Row Comparison ",barcode), 
#     #                            yLimits = c(-1,2), 
#     #                            xColumn = rowVector[resultTable$barcode==barcode],
#     #                            wellType = resultTable$wellType[resultTable$barcode == barcode],
#     #                            dataRow = plateData$transformedValues,
#     #                              hits = plateData$hits,
#     #                            xLabel = "Row",
#     #                            colourPalette = c("red","green","black"))
#     g3 <- createGGComparison(graphTitle = paste("Column Comparison ", barcode),
#                              xColumn = columnVector[resultTable$barcode==barcode],
#                              wellType = resultTable$wellType[resultTable$barcode == barcode],
#                              dataRow = plateData$transformedValues,
#                              hits = plateData$hits,
#                              xLabel = "Column",
#                              yLabel = "Normalized Activity (rfu)",
#                              colourPalette = c("blue", "green", "red", "black"),
#                              threshold = threshold)
#     #     resultTable$well <- factor(resultTable$well, levels = levels(resultTable$well)[order(gsub("\\D", "", levels(resultTable$well)))])
#     #     resultTable <- resultTable[order(gsub("\\D", "", resultTable$well)),]
#     plateData <- data.frame(transformedValues = resultTable$transformed[resultTable$barcode==barcode], 
#                             well = resultTable$well[resultTable$barcode==barcode], hits=resultTable$threshold[resultTable$barcode==barcode])
#     #     g4 <- createGGComparison(graphTitle = paste("Well Comparison ",barcode), 
#     #                              yLimits = c(-1,2), 
#     #                              xColumn = resultTable$well[resultTable$barcode==barcode],
#     #                              wellType = resultTable$wellType[resultTable$barcode == barcode],
#     #                              dataRow = resultTable$transformed[resultTable$barcode==barcode],
#     #                              hits = resultTable$efficacyThreshold[resultTable$barcode==barcode],
#     #                              xLabel = "Column",
#     #                              colourPalette = c("red","green","black"))
#     
#     print(grid.arrange(g1, g3))
#     
#   }
#   
#   fluorescentWells <- allResultTable[allResultTable$fluorescent,list(barcode,well,sequence,timePoints,batchName)]
#   hitWells <- allResultTable[allResultTable$threshold,list(barcode,well,sequence,timePoints,batchName)]
#   latePeakWells <- allResultTable[allResultTable$latePeak,list(barcode,well,sequence,timePoints,batchName)]
#   flaggedWells <- allResultTable[!is.na(allResultTable$flag),list(barcode,well,sequence,timePoints,batchName)]
#   
#   plotFigure <- function(xData,yData, barcode, well, batchCode, title) {
#     xData <- as.numeric(unlist(strsplit(xData,"\t", fixed= TRUE)))
#     yData <- as.numeric(unlist(strsplit(yData,"\t", fixed= TRUE)))
#     type="l"; xlab="Time (sec)"; ylab="Activity (rfu)"
#     plot(xData, yData, type=type, xlab=xlab, ylab=ylab)
#     title(main=paste0(barcode, " : ", well, "\n", batchCode))
#     mtext(title, 3, line=0, adj=0.5, cex=1.2, outer=TRUE)
#   }
#   
#   plotWells <- function(wellType, wellTypeName) {
#     # wellType could be fluorescentWells, and then wellTypeName would be "Fluorescent Wells"
#     if(nrow(wellType) > 0) {
#       par(mfcol=c(4,3), mar=c(4,4,4,4), oma =c(2,2,2,2))
#       mapply(plotFigure, wellType$timePoints, wellType$sequence, wellType$barcode, wellType$well, wellType$batchName, wellTypeName)
#     }
#   }
#   
#   plotWells(fluorescentWells, "Fluorescent Wells")
#   plotWells(latePeakWells, "Late Peak Wells")
#   plotWells(hitWells, "Hit Wells")
#   plotWells(flaggedWells, "Flagged Wells")
#   
#   dev.off()
#   
#   
#   return(pdfLocation)
# }
