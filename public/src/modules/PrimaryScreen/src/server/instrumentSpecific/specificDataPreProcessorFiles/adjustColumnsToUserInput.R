

adjustColumnsToUserInput <- function(inputColumnTable, inputDataTable, tempFilePath) {
  # inputColumnTable: 
  #   userReadPosition: null if "match names" = TRUE in GUI
  #   userReadName: character
  #   activityCol: boolean (only 1 can be true)
  #   userReadOrder: integers (from 1:nrow)
  #   calculatedRead: boolean
  #   activityColName: character
  #   newActivityColName: character
  
  
  # For log file
  write.table(paste0(Sys.time(), "\tbegin adjustColumnsToUserInput"), file = file.path(tempFilePath, "runlog.tab"), append=FALSE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  
  # sets the names for all of the "defined" reads, but none of the calculated reads
  setnames(inputDataTable, 
           inputColumnTable[activityColName != "None", ]$activityColName, 
           inputColumnTable[activityColName != "None", ]$newActivityColName)
  
  # adds in any calculated columns
  # TODO: this should be in it's own function
  if(nrow(inputColumnTable[calculatedRead==TRUE])>0) {
    for (calculation in inputColumnTable[calculatedRead==TRUE]$userReadName) {
      if(calculation == "Calc: (R2 / R1) * 100") {
        if(!inputColumnTable[userReadOrder==2]$calculatedRead && !inputColumnTable[userReadOrder==1]$calculatedRead) {
          inputDataTable[ , calculatedRead := (get(inputColumnTable[userReadOrder==2]$newActivityColName) /
                                              get(inputColumnTable[userReadOrder==1]$newActivityColName)) 
                                              * 100]
          setnames(inputDataTable, "calculatedRead", inputColumnTable[userReadName == calculation]$newActivityColName)
        } else {
          stopUser("System not set up to calculate a read off another calculated read. Please redefine your read names.")
        }
      } else if (calculation == "Calc: R1 / R2") {
        if(!inputColumnTable[userReadOrder==2]$calculatedRead && !inputColumnTable[userReadOrder==1]$calculatedRead) {
          inputDataTable[ , calculatedRead := (get(inputColumnTable[userReadOrder==1]$newActivityColName) /
                                                 get(inputColumnTable[userReadOrder==2]$newActivityColName))]
          setnames(inputDataTable, "calculatedRead", inputColumnTable[userReadName == calculation]$newActivityColName)
        }
      } else {
        stopUser("Calculated read not defined in the system.")
      }
    }
  }
  
  
  colNamesToCheck <- setdiff(colnames(inputDataTable), c("assayFileName", "assayBarcode", "rowName", "colName", "wellReference", "plateOrder"))
  colNamesToKeep <- inputColumnTable$newActivityColName
  
  inputDataTable <- removeColumns(colNamesToCheck, colNamesToKeep, inputDataTable)
  inputDataTable <- addMissingColumns(colNamesToKeep, inputDataTable)
  
  # copy the read column that we want to do transformation/normalization on (user input)
  activityColName <- inputColumnTable$newActivityColName[inputColumnTable$activityCol]
  inputDataTable$activity <- as.numeric(inputDataTable[ , get(activityColName)])
  
  return(inputDataTable)
}