# generateCompoundPlateDF.R
#
## parse out file to create a fake compound plate DF
## Run this script when you need to add additional compound plates to the compound plate test fixture

currentWD <- getwd()
setwd("inst/docs/test_well_data_out_files")
print(getwd())
outFiles <- list.files(pattern="_well_data.out")
allCompoundWellData <- c()
for (outFile in outFiles){
  print(outFile)
  outFileNames <- read.csv(file=outFile, header=TRUE, skip=0, nrows=1, sep="\t", stringsAsFactors=FALSE)
  compoundWellData <- read.csv(file=outFile, header=FALSE, skip=2, sep="\t", stringsAsFactors=FALSE)
  names(compoundWellData) <- names(outFileNames)
  compoundWellData <- compoundWellData[ ,c("CmpdBar..Compound.Barcode.", 
                                           "PT..Source.Plate.Type.",
                                           "WR..Well.Ref.",
                                           "Cmpd..Compound.ID.",
                                           "Batch..Batch.Ref.",
                                           "Conc..Concentration.",
                                           "Lib..Library.ID.")]

  names(compoundWellData) <- c("cmpdBarcode", "plateType", "wellReference", "corp_name", "batch_number", "cmpdConc", "supplier")
  
  allCompoundWellData <- rbind(allCompoundWellData, compoundWellData)
}

allCompoundWellData <- unique(allCompoundWellData)
write.table(allCompoundWellData, file="../compoundDataFile.tab", append=FALSE, quote=FALSE, sep="\t", row.names=FALSE, col.names=TRUE)

setwd(currentWD)
