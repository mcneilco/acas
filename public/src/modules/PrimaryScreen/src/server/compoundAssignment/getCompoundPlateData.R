# getCompoundPlateData.R
#
#
# Guy Oshiro
# guy@mcneilco.com
# Copyright 2013 John McNeil & Co. Inc.
#######################################################################################
# Get compound plate data from the database
# Testing mode will query saved data file
#######################################################################################

#TODOs

# Questions
  
getCompoundPlateData <- function(barcodes, testMode=FALSE, tempFilePath) {
  # Args:
  #   barcodes:   A character vector of plate barcodes
  #   testMode:   boolean flag to allow running the function in testMode. In testMode the function will work with a saved data file. inst/docs/compoundDataFile.tab (add addition plate info to this file to extend tests)
  # Returns:
  #   A data.frame  of the compound plate data (7 columns):
  #     "barcode":      barcode of compound plate
  #     "plateType":    compound plate type
  #     "wellRef":      well name of plate
  #     "corp_name":    corp_name of the compound in the well
  #     "batch_number": batch number of the compound in the well
  #     concvalue:      concentration value of the compound in the well ([mM])
  #     supplier:       the supplier of the compound plate
  
  # runlog
  write.table(paste0(Sys.time(), "\tbegin getCompoundPlateData"), file = file.path(tempFilePath, "runlog.tab"), append=TRUE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  
  queryCompoundsFromDB <- function(barcodes){
    queryString <- paste0("select kp.barcode as cmpdBarcode, dd_plateType.value as plateType, kpw.wellref as wellreference, bp.corp_name, bb.batch_number, kwi.concvalue as cmpdConc, kp.supplier ",
                          "from kalypsysadmin.kplate kp ",
                          "join kalypsysadmin.kplatewell kpw on kpw.plateid = kp.plateid ",
                          "join kalypsysadmin.kwellitem kwi on kwi.wellid = kpw.wellid ",
                          "join batch.batch bb on bb.id = kwi.kbatchid ",
                          "join batch.v_api_active_parent bp on bp.id = bb.parent_id ",
                          "left outer join kalypsysadmin.datadictionary dd_plateType on dd_plateType.datadictid = kp.type_ld ",
                          "where kp.barcode in ('", paste(barcodes, collapse = "','"), "') ",
                          "order by kp.barcode, kpw.wellref ")
                          
    return(sqlQuery(queryString))
  }  
  
  ##   cmpdBarcode plateType wellRef corporateName batchRef cmpdConc libraryID
  ## kp.barcode, dd_plateType.value as plateType, kpw.wellref, bp.corp_name, bb.batch_number, kwi.concvalue, kp.supplier
                        
  
  queryCompoundsFromTestFile <- function(barcodes){    
    testFile  <- file.path(Sys.getenv("ACAS_HOME"), "public/src/modules/PrimaryScreen/spec/RTestSet/docs", "compoundDataFile.tab")
    testDF    <- read.csv(testFile, header=TRUE, sep="\t", stringsAsFactors=FALSE)
    testDF    <- subset(testDF, cmpdBarcode %in% barcodes) 
    return(testDF)
  }
  
  binSize <- 1000
  
  if (testMode) {
    return(queryCompoundsFromTestFile(barcodes))
  } else {
    if (length(barcodes) < binSize){
      returnDF <- queryCompoundsFromDB(barcodes)      
    } else {
      ## sql in clause limit is 1000; break into mutiple queries (or use a temp table)      
      numberOfSplits  <- ceiling(length(barcodes)/binSize)
      remainderBarcodes <- length(barcodes) %% binSize
      returnDF <- c()
      for (i in 1:numberOfSplits){
        if (i == 1){
          barcodeStart <- 1
          barcodeEnd <- binSize
        } else {
          barcodeStart <- (i * binSize) + 1
          barcodeEnd <- (i+1) * binSize
          if (barcodeEnd > length(barcodes)){
            barcodeEnd <- length(barcodes)
          }
        }        
        barcodesSplit <- barcodes[barcodeStart:barcodeEnd]
        returnDF <- rbind(returnDF, queryCompoundsFromDB(barcodesSplit))          
      }
    }
    names(returnDF) <- c("cmpdBarcode", "plateType", "wellReference", "corp_name", "batch_number", "cmpdConc", "supplier")
    return(returnDF)
  }
}


