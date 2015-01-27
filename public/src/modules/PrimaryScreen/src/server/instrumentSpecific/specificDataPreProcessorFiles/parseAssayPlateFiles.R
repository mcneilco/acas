# parseAssayPlateFiles.R
#
#
# Guy Oshiro
# guy@mcneilco.com
# Copyright 2013 John McNeil & Co. Inc.
#######################################################################################
# Parse an assay plate file 
#######################################################################################


parseAssayPlateFiles <- function(assayFileName = "assayFileName", instrumentType = "microBeta", titleVector, tempFilePath){
# Args:
#   assayFileName:                assay file name
#   instrumentType:               instrument type to parse
#   dataTitles:                   vector of data titles found in assay plate
# Returns:
#   A data.table of the assay plate date 
  
  # runlog
  write.table(paste0(Sys.time(), "\tbegin parseAssayPlateFiles\tassayFileName=",assayFileName,"\tinstrumentType=",instrumentType), file = file.path(tempFilePath, "runlog.tab"), append=TRUE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  
  # returns a list of the params
  instrumentParams <- loadInstrumentReadParameters(instrumentType=instrumentType)
  
  parseInstrumentPlateData(fileName=assayFileName, 
                           parseParams=instrumentParams, 
                           titleVector, tempFilePath=tempFilePath)
    
}
