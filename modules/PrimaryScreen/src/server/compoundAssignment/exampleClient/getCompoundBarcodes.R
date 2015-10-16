
## getCompoundBarcodes.R



getCompoundBarcodes <- function(inputDT, tempFilePath){
  # Args:
  #   inputDT:          plate association data.table
  # Returns:
  #   A character vector of barcodes 
  
  # runlog
  write.table(paste0(Sys.time(), "\tbegin getCompoundBarcodes"), file = file.path(tempFilePath, "runlog.tab"), append=TRUE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  
  compoundCols <- grep("sidecarBarcode|compoundBarcode", names(inputDT))
  barcodes <- c()
  for (i in compoundCols){
    barcodes <- c(barcodes, inputDT[ ,c(i), with=FALSE][[1]])
  }
  barcodes <- unique(barcodes[barcodes != ""])
  
  return(barcodes)
}
