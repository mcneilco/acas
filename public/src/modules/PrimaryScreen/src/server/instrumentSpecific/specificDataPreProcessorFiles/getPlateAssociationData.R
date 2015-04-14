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
  
  # Removes blank rows from plate association file
  plateAssociationData <- plateAssociationData[do.call(paste0, plateAssociationData) != "", ]
  
  if (ncol(plateAssociationData) == 3) {
    # Removes the third column if it is blank
    if(all(is.na(plateAssociationData[ , 3]))) {
      plateAssociationData[ , 3] <- NULL
      compoundColumns <- "compoundBarcode_1"
    } else {
      compoundColumns <- c("sidecarBarcode", paste0("compoundBarcode_", 1:(ncol(plateAssociationData)-2)))
      
      # In some cases with multiple compound barcodes, the second column is blank but the 
      # third is not. This is adjusted by moving the third value in to the second column.
      for(i in 1:nrow(plateAssociationData)) {
        if(plateAssociationData[i, 2] == "") {
          warnUser("Blank sidecar barcode found in plate association file, adjusting barcodes to compensate.")
          plateAssociationData[i, 2] <- plateAssociationData[i, 3]
          plateAssociationData[i, 3] <- ""
        }
      }
    }
  } else if (ncol(plateAssociationData) == 2) {
    compoundColumns <- "compoundBarcode_1"
  } else { 
    # Currently not coded for more than 3 columns because the potential
    # of a blank sidecar is not handled for 'n' columns.
    stopUser("More than three columns found in the plate association file. Contact your administrator.")
  }
  colnames(plateAssociationData) <- c("assayBarcode", compoundColumns)
  plateAssociationData$plateOrder <- (1:nrow(plateAssociationData))

  return(data.table(plateAssociationData))
}