## getAssayCompoundDT.R


getAssayCompoundDT <- function(inputDT, tempFilePath){
  # Args:
  #   inputDT:          plate association data.table
  # Returns:
  #   A transformed data.table of the input plate association data.table 
  
  # runlog
  write.table(paste0(Sys.time(), "\tbegin getAssayCompoundDT"), file = file.path(tempFilePath, "runlog.tab"), append=TRUE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  
  compoundCols <- grep("sidecarBarcode|compoundBarcode", names(inputDT))
  assayBarcodeCol <- grep("assayBarcode", names(inputDT))
  
  if (length(compoundCols) > 1){
    sideCarExists <- TRUE
  } else {
    sideCarExists <- FALSE
  }
  firstPass <- TRUE
  for (i in compoundCols){
    if (firstPass){
      output <- inputDT[ ,c(assayBarcodeCol, i), with=FALSE]
      
      if(length(grep("sidecarBarcode", names(output))) == 1) {
        output$sourceType <- "sidecar"
      }	else {
        output$sourceType <- "compound"
      }
      firstPass <- FALSE
    } else {
      plateData <- inputDT[ ,c(assayBarcodeCol, i), with=FALSE]	
      
      if(length(grep("sidecarBarcode", names(plateData))) == 1) {
        plateData$sourceType <- "sidecar"
      } else {
        plateData$sourceType <- "compound"
      }
      output <- rbind(output, plateData, use.names=FALSE)	
    }
  }
  
  setnames(output, names(output)[[2]], "cmpdBarcode")
  
  # Only include rows where there is a compoundBarcode value
  output <- unique(output[output$cmpdBarcode != ""])

  return(output)
}