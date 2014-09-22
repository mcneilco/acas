# getAssayFileName.R
## get the name of the assay file with a given barcode
## this will allow additional characters in the assay file name

getAssayFileName <- function(barcode="barcode text", filePath=".", tempFilePath){

  # runlog
  write.table(paste0(Sys.time(), "\tbegin getAssayFileName\tbarcode=",barcode), file = file.path(tempFilePath, "runlog.tab"), append=TRUE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  
  assayFileNames <- list.files(pattern=barcode)
  if (length(assayFileNames) == 1){
    assayFileNames <- data.table(assayFileName=assayFileNames[1])
  } else if (length(assayFileNames) > 1) { 
    assayFileNames <- data.table(assayFileName=assayFileNames, readOrder=(seq.int(1, length(assayFileNames))))
  } else {
    stopUser("Assay FILE not found")
  }
  
  return(assayFileNames)
}
