createPDF <- function(resultTable, parameters, summaryInfo, threshold, experiment, dryRun=F) {
  # DNS
  require('gplots')
  require('gridExtra')
  require('data.table')
  require('reshape')
  source("public/src/modules/PrimaryScreen/src/server/primaryAnalysisPlots.R")
  
  allResultTable <- resultTable
  resultTable <- resultTable[is.na(resultTable$flag),]
  
  if(dryRun) {
    pdfLocation <- paste0("experiments/",experiment$codeName, "/draft/", experiment$codeName, "_SummaryDRAFT.pdf")
  } else {
    pdfLocation <- paste0("experiments/",experiment$codeName,"/analysis/",experiment$codeName,"_Summary.pdf")
  }
  pdfSave <- racas::getUploadedFilePath(pdfLocation)
  pdf(file = pdfSave, width = 8.5, height = 11)
  if(dryRun) {
    textplot("Validation DRAFT")
  }
  textToShow <- paste0("------------------------------------------------------------------------------------------------\n",
                       paste(paste0(names(summaryInfo$info),": ",summaryInfo$info),collapse="\n"))
  
  textplot(textToShow, halign="left",valign="top")
  title("Primary Screen")
  
  createDensityPlot(resultTable$normalized, resultTable$wellType, threshold = threshold, margins = c(25,4,4,8))
  
  print(createGGComparison(graphTitle = "Plate Comparison", xColumn=resultTable$assayBarcode,
                           wellType = resultTable$wellType, dataRow = resultTable$normalizedActivity, xLabel = "Plate", 
                           margins = c(4,2,20,4), rotateXLabel = TRUE, test = FALSE, colourPalette = c("blue","green")))
  
  plateDataTable <- data.table(normalizedActivity = resultTable$normalizedActivity, 
                               well = resultTable$well)
  plateData <- plateDataTable[,list(normalizedValues = mean(normalizedActivity)), by=well]
  print(createGGHeatmap("Heatmap of the Average of All Plates", plateData, margins=c(0,0,20,0)))
  
  rowVector <- gsub("\\d", "", resultTable$well)
  columnVector <- gsub("\\D", "", resultTable$well)
  for (barcode in levels(resultTable$assayBarcode)) {
    plateData <- data.frame(normalizedActivity = resultTable$normalizedActivity[resultTable$assayBarcode==barcode], 
                            well = resultTable$well[resultTable$assayBarcode==barcode]) #, hits=resultTable$threshold[resultTable$assayBarcode==barcode])
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
                             xColumn = columnVector[resultTable$assayBarcode==barcode],
                             wellType = resultTable$wellType[resultTable$assayBarcode == barcode],
                             dataRow = plateData$normalizedActivity,
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
  
  #fluorescentWells <- allResultTable[allResultTable$fluorescent,list(barcode,well,sequence,timePoints,batchName)]
  #hitWells <- allResultTable[allResultTable$threshold,list(barcode,well,sequence,timePoints,batchName)]
  #latePeakWells <- allResultTable[allResultTable$latePeak,list(barcode,well,sequence,timePoints,batchName)]
  flaggedWells <- allResultTable[!is.na(allResultTable$flag),list(assayBarcode, batchName)] #,well,sequence,timePoints,batchName)]
  
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
  
  #   plotWells(fluorescentWells, "Fluorescent Wells")
  #   plotWells(latePeakWells, "Late Peak Wells")
  #   plotWells(hitWells, "Hit Wells")
  #   plotWells(flaggedWells, "Flagged Wells")
  
  dev.off()
  
  
  return(pdfLocation)
}