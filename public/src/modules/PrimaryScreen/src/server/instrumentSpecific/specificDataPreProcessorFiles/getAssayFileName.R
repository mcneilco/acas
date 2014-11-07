# getAssayFileName.R
## get the name of the assay file with a given barcode
## this will allow additional characters in the assay file name

getAssayFileName <- function(barcode="barcode text", filePath=".", tempFilePath){

  # runlog
  write.table(paste0(Sys.time(), "\tbegin getAssayFileName\tbarcode=",barcode), file = file.path(tempFilePath, "runlog.tab"), append=TRUE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  
  assayFileNames <- list.files(path=filePath, pattern=barcode)
  if (length(assayFileNames) == 1){
    assayFileNames <- data.table(assayFileName=assayFileNames[1])
  } else if (length(assayFileNames) > 1) { 
    stopUser(paste0("Multiple assay files found for barcode: ", barcode))
    # save this for instrument specific file plateFormatMultiFile (and perhaps stat1stat2seq1 formats)
    # assayFileNames <- data.table(assayFileName=assayFileNames, readOrder=(seq.int(1, length(assayFileNames))))
  } else {
    stopUser(paste0("Assay file not found for barcode: ", barcode))
  }
  
  return(assayFileNames)
}
