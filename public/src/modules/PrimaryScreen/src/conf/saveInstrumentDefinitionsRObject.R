

saveInstrumentDefinitionsRObject <- function(filePath="public/src/modules/PrimaryScreen/src/conf/instruments/", 
                                             instruments=list("acumen","arrayScan","biacore","envision","flipr","lumiLux","microBeta","thermalMelt","viewLux","flipr1")) {
  
  for(instrumentType in instruments) {
    instrumentExists <- TRUE
    
    # viewLuxDetectionLine     <- ";-"
    # thermalMeltDetectionLine <- "^Wells \t Tm Boltzmann"
    if (instrumentType == "acumen") {
      detectionLine  <- "^.*: .*: .*?, ?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12|^.*: .*?, ?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12"
      paramList <- list(headerRowSearchString = "Ratio .*,1,2,3,4,",
                        dataRowSearchString   = "^[A-Z]{1,2},",
                        sepChar               = ",",
                        headerExists          = TRUE,
                        beginDataColNumber    = 2,
                        dataTitleIdentifier   = NA,
                        dataFormat            = "plateFormatMultiFile")
    } else if (instrumentType == "arrayScan") {
      detectionLine   <- "^Feature: "
      paramList <- list(headerRowSearchString = "^\t 1 \t 2 \t 3 \t 4 \t 5|^\t1\t2\t3\t4\t5",
                        dataRowSearchString   = "^[A-Z]{1,2}\t",
                        sepChar               = "\t",
                        headerExists          = TRUE,
                        beginDataColNumber    = 2,
                        dataTitleIdentifier   = "^Feature: ",
                        dataFormat            = "plateFormatSingleFile")
    } else if (instrumentType == "biacore") {
      detectionLine     <- "^Well\tStability "
      paramList <- list(headerRowSearchString = "^Well\tStability ",
                        dataRowSearchString   = "^[A-Z]{1,2}[0-9]{1,2}\t",
                        sepChar               = "\t",
                        headerExists          = TRUE,
                        beginDataColNumber    = 1,
                        dataTitleIdentifier   = NA,
                        dataFormat            = "listFormatSingleFile")
    } else if (instrumentType == "envision") {
      detectionLine    <- "^Calculated results: Calc 1:|^Results for"
      paramList <- list(headerRowSearchString = "^,01,02,03,04",
                        dataRowSearchString   = "^[A-Z]{1,2},",
                        sepChar               = ",",
                        headerExists          = TRUE,
                        beginDataColNumber    = 2,
                        dataTitleIdentifier   = NA,
                        dataFormat            = "plateFormatSingleFile")
    } else if (instrumentType == "flipr") {
      detectionLine       <- "^Statistic ="
      paramList <- list(headerRowSearchString = "^\t1",
                        dataRowSearchString   = "^[A-Z]{1,2}\t",
                        sepChar               = "\t",
                        headerExists          = TRUE,
                        beginDataColNumber    = 2,
                        dataTitleIdentifier   = NA,
                        dataFormat            = "plateFormatSingleFile")
    } else if (instrumentType == "lumiLux") {
      detectionLine     <- "^Begin Analysis Info"
      paramList <- list(headerRowSearchString = "^Well,Group,Index",
                        dataRowSearchString   = "^[A-Z]{1,2}[0-9]{1,2},",
                        sepChar               = ",",
                        headerExists          = TRUE,
                        beginDataColNumber    = 1,
                        dataTitleIdentifier   = NA, 
                        dataFormat            = "listFormatSingleFile")
    } else if (instrumentType == "microBeta") {
      detectionLine     <- "^RUN INFORMATION|^Cassette information"  
      paramList <- list(headerRowSearchString = "^ \t1",
                        dataRowSearchString   = "^[A-Z]{1,2}\t",
                        sepChar               = "\t",
                        headerExists          = TRUE,
                        beginDataColNumber    = 2,
                        dataTitleIdentifier   = NA,
                        dataFormat            = "plateFormatSingleFile")
    } else if (instrumentType == "flipr1") {
      detectionLine     <- "NA"
      paramList <- list(headerRowSearchString = NA,
                        dataRowSearchString   = NA,
                        sepChar               = NA,
                        headerExists          = NA,
                        beginDataColNumber    = NA,
                        dataTitleIdentifier   = NA,
                        dataFormat            = "stat1stat2seq1")
    } else {
      instrumentExists <- FALSE
      warning(paste0("Instrument (",instrumentType,") has not been defined in helper function."))
    }
    
    if(instrumentExists) {
      if(!file.exists(file.path(filePath,instrumentType))) {
        dir.create(file.path(filePath,instrumentType))
      }
      
      setwd(file.path(filePath,instrumentType))
      write.table(toJSON(list(instrumentType=instrumentType)), file="instrumentType.json", quote=FALSE, row.names=FALSE, col.names=FALSE)
      write.table(toJSON(list(detectionLine=detectionLine)), file="detectionLine.json", quote=FALSE, row.names=FALSE, col.names=FALSE)
      write.table(toJSON(list(paramList=paramList)), file="paramList.json", quote=FALSE, row.names=FALSE, col.names=FALSE)
      #     save(instrumentType, file="instrumentType.Rda")
      #     save(detectionLine, file="detectionLine.Rda")
      #     save(paramList, file="paramList.Rda")
    }
  }
  
}

removeInstrumentFiles <- function(filePath=file.path("public/src/modules/PrimaryScreen/src/conf/instruments"), 
                                  instruments=list("acumen","arrayScan","biacore","envision","flipr","lumiLux","microBeta","thermalMelt","viewLux","flipr1"),
                                  extension=".Rda"){
  for (instrumentType in instruments) {
    setwd(file.path(filePath,instrumentType))
    
    for (file in list.files(pattern=extension)) {
      file.remove(file)
    }
  }
}


saveInstrumentDefinitionsTextFile <- function(filePath="~/Documents/acas/dns-rdap/inst/instruments/") {
  
  instruments <- list("acumen","arrayScan","biacore","envision","flipr","lumiLux","microBeta")#,"thermalMelt","viewLux")
  
  for(instrumentType in instruments) {
    
    # viewLuxDetectionLine     <- ";-"
    # thermalMeltDetectionLine <- "^Wells \t Tm Boltzmann"
    if (instrumentType == "acumen") {
      detectionLine  <- "^.*: .*: .*?, ?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12|^.*: .*?, ?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12"
      paramList <- data.table(headerRowSearchString = "Ratio .*,1,2,3,4,",
                              dataRowSearchString   = "^[A-Z]{1,2},",
                              sepChar               = ",",
                              headerExists          = TRUE,
                              beginDataColNumber    = 2,
                              dataTitleIdentifier   = NA,
                              formattedData         = FALSE)
    } else if (instrumentType == "arrayScan") {
      detectionLine   <- "^Feature: "
      paramList <- data.table(headerRowSearchString = "^\t 1 \t 2 \t 3 \t 4 \t 5|^\t1\t2\t3\t4\t5",
                              dataRowSearchString   = "^[A-Z]{1,2}\t",
                              sepChar               = "\t",
                              headerExists          = TRUE,
                              beginDataColNumber    = 2,
                              dataTitleIdentifier   = "^Feature: ",
                              formattedData         = FALSE)
    } else if (instrumentType == "biacore") {
      detectionLine     <- "^Well\tStability "
      paramList <- data.table(headerRowSearchString = "^Well\tStability ",
                              dataRowSearchString   = "^[A-Z]{1,2}[0-9]{1,2}\t",
                              sepChar               = "\t",
                              headerExists          = TRUE,
                              beginDataColNumber    = 1,
                              dataTitleIdentifier   = NA,
                              formattedData         = TRUE)
    } else if (instrumentType == "envision") {
      detectionLine    <- "^Calculated results: Calc 1:|^Results for"
      paramList <- data.table(headerRowSearchString = "^,01,02,03,04",
                              dataRowSearchString   = "^[A-Z]{1,2},",
                              sepChar               = ",",
                              headerExists          = TRUE,
                              beginDataColNumber    = 2,
                              dataTitleIdentifier   = NA,
                              formattedData         = FALSE)
    } else if (instrumentType == "flipr") {
      detectionLine       <- "^Statistic ="
      paramList <- data.table(headerRowSearchString = "^\t1",
                              dataRowSearchString   = "^[A-Z]{1,2}\t",
                              sepChar               = "\t",
                              headerExists          = TRUE,
                              beginDataColNumber    = 2,
                              dataTitleIdentifier   = NA,
                              formattedData         = FALSE)
    } else if (instrumentType == "lumiLux") {
      detectionLine     <- "^Begin Analysis Info"
      paramList <- data.table(headerRowSearchString = "^Well,Group,Index",
                              dataRowSearchString   = "^[A-Z]{1,2}[0-9]{1,2},",
                              sepChar               = ",",
                              headerExists          = TRUE,
                              beginDataColNumber    = 1,
                              dataTitleIdentifier   = NA, 
                              formattedData         = TRUE)
    } else if (instrumentType == "microBeta") {
      detectionLine     <- "^RUN INFORMATION|^Cassette information"  
      paramList <- data.table(headerRowSearchString = "^ \t1",
                              dataRowSearchString   = "^[A-Z]{1,2}\t",
                              sepChar               = "\t",
                              headerExists          = TRUE,
                              beginDataColNumber    = 2,
                              dataTitleIdentifier   = NA,
                              formattedData         = FALSE)
    } 
    setwd(file.path(filePath,instrumentType))
    write.table(paste0("Definition for instrument: ", instrumentType), file = "instrumentDefinition.txt", append=FALSE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
    write.table("\n[Detection Line]", file = "instrumentDefinition.txt", append=TRUE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
    write.table(detectionLine, file = "instrumentDefinition.txt", append=TRUE, quote=TRUE, sep="\t", row.names=FALSE, col.names=FALSE)
    write.table("\n[Instrument Parameters]", file = "instrumentDefinition.txt", append=TRUE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
    write.table(paramList, file = "instrumentDefinition.txt", append=TRUE, quote=TRUE, sep="\t", row.names=FALSE, col.names=FALSE)
  }
  
  
  
  
  
}
