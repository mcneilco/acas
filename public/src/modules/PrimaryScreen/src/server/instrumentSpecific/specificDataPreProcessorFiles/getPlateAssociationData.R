# Pull out Assay Barcode from plate association .csv file, which can then be used to pull the Assay plate file
# 
# Input: Plate association file
# Output: assayBarcode (text string)
# Potential problems: 
#   assay barcode does not follow standard file naming conventions
#   no plate association file exists
#   plate association file is empty
#   wrong file type
#   more than 2 compound columns

getPlateAssociationData <- function(fileName, header=FALSE, tempFilePath) {
  #
  # Reads the .csv file and formats it in to a data.table
  # 
  # Input:  fileName (name of the plate association .csv)
  #        tempFilePath (where log files and ini files are saved)
  # Output: plateAssociationDT (data.table with column names: assayBarcode, compoundBarcode_1, sidecarBarcode (optional))
  
  
  # runlog
  write.table(paste0(Sys.time(), "\tbegin getPlateAssociationData\tfileName=",fileName), file = file.path(tempFilePath, "runlog.tab"), append=TRUE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)

  plateAssociationData <- read.csv(fileName, header=header, stringsAsFactors=FALSE)
  
  if (ncol(plateAssociationData) == 3) {
    compoundColumns <- c("sidecarBarcode", paste0("compoundBarcode_", 1:(ncol(plateAssociationData)-2)))
    
    # In some cases with multiple compound barcodes, the second column is blank but the 
    # third is not. This is adjusted by moving the third value in to the second column.
    for(i in 1:nrow(plateAssociationData)) {
      if(plateAssociationData[i, 2] == "") {
        warnUser("Blank sidecar Barcode")
        plateAssociationData[i, 2] <- plateAssociationData[i, 3]
        plateAssociationData[i, 3] <- ""
      }
    }
  } else if (ncol(plateAssociationData) == 2) {
    compoundColumns <- "compoundBarcode_1"
  }
  colnames(plateAssociationData) <- c("assayBarcode", compoundColumns)
  plateAssociationData$plateOrder <- (1:nrow(plateAssociationData))

  return(data.table(plateAssociationData))
}