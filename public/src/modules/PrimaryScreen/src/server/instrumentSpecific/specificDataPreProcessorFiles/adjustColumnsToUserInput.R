

adjustColumnsToUserInput <- function(inputColumnTable, inputDataTable) {
  # inputColumnTable: 
  #   userReadPosition: null if "match names" = TRUE in GUI
  #   userReadName: character
  #   activityCol: boolean (only 1 can be true)
  #   userReadOrder: integers (from 1:nrow)
  #   calculatedRead: boolean
  #   activityColName: character
  #   newActivityColName: character
  
  # sets the names for all of the "defined" reads, but none of the calculated reads
  setnames(inputDataTable, 
           inputColumnTable[activityColName != "None", ]$activityColName, 
           inputColumnTable[activityColName != "None", ]$newActivityColName)
  
  # adds in any calculated columns
  # TODO: this should be in it's own function
  if(nrow(inputColumnTable[calculatedRead==TRUE])>0) {
    for (calculation in inputColumnTable[calculatedRead==TRUE]$userReadName) {
      if(calculation == "Calc: (R1/R2)*100") {
        if(!inputColumnTable[userReadOrder==1]$calculatedRead && !inputColumnTable[userReadOrder==2]$calculatedRead) {
          inputDataTable[ , calculatedRead := (get(inputColumnTable[userReadOrder==1]$newActivityColName) /
                                              get(inputColumnTable[userReadOrder==2]$newActivityColName)) 
                                              * 100]
          setnames(inputDataTable, "calculatedRead", inputColumnTable[userReadName == calculation]$newActivityColName)
        } else {
          stopUser("System not set up to calculate a read off another calculated read. Please redefine your read names.")
        }
      } else if(calculation == "Calc: (R2/R1)*100") {
        if(!inputColumnTable[userReadOrder==2]$calculatedRead && !inputColumnTable[userReadOrder==1]$calculatedRead) {
          inputDataTable[ , calculatedRead := (get(inputColumnTable[userReadOrder==2]$newActivityColName) /
                                              get(inputColumnTable[userReadOrder==1]$newActivityColName)) 
                                              * 100]
          setnames(inputDataTable, "calculatedRead", inputColumnTable[userReadName == calculation]$newActivityColName)
        } else {
          stopUser("System not set up to calculate a read off another calculated read. Please redefine your read names.")
        }
      } else if(calculation == "Calc: R1/R2") {
        if(!inputColumnTable[userReadOrder==1]$calculatedRead && !inputColumnTable[userReadOrder==2]$calculatedRead) {
          inputDataTable[ , calculatedRead := (get(inputColumnTable[userReadOrder==1]$newActivityColName) /
                                              get(inputColumnTable[userReadOrder==2]$newActivityColName))]
          setnames(inputDataTable, "calculatedRead", inputColumnTable[userReadName == calculation]$newActivityColName)
        } else {
          stopUser("System not set up to calculate a read off another calculated read. Please redefine your read names.")
        }
      } else if(calculation == "Calc: R2/R1") {
        if(!inputColumnTable[userReadOrder==2]$calculatedRead && !inputColumnTable[userReadOrder==1]$calculatedRead) {
          inputDataTable[ , calculatedRead := (get(inputColumnTable[userReadOrder==2]$newActivityColName) /
                                              get(inputColumnTable[userReadOrder==1]$newActivityColName))]
          setnames(inputDataTable, "calculatedRead", inputColumnTable[userReadName == calculation]$newActivityColName)
        } else {
          stopUser("System not set up to calculate a read off another calculated read. Please redefine your read names.")
        }
      } else if(calculation == "Calc: R1/Heavy Atom Count") {
        if(!inputColumnTable[userReadOrder==1]$calculatedRead) {
          inputDataTable[ , calculatedRead := get(inputColumnTable[userReadOrder==1]$newActivityColName) / 
                                              get(inputColumnTable[userReadOrder==1]$newActivityColName)]
          warnUser(paste0(calculation," not defined in the system yet. Putting in a placeholder of 1."))
          setnames(inputDataTable, "calculatedRead", inputColumnTable[userReadName == calculation]$newActivityColName)
        } else {
          stopUser("System not set up to calculate a read off another calculated read. Please redefine your read names.")
        }
      } else {
        stopUser("Calculated read not defined in the system.")
      }
    }  
  }
  
  standardListOfColNames <- c("plateType",
                              "assayBarcode",
                              "cmpdBarcode",
                              "sourceType",
                              "well",
                              "row",
                              "column",
                              "plateOrder",
                              "batchName",
                              "batch_number",
                              "cmpdConc",
                              "batchCode")
  colNamesToCheck <- setdiff(colnames(inputDataTable), standardListOfColNames)
  colNamesToKeep <- inputColumnTable$newActivityColName
  
  inputDataTable <- removeColumns(colNamesToCheck, colNamesToKeep, inputDataTable)
  inputDataTable <- addMissingColumns(colNamesToKeep, inputDataTable)
  
  # copy the read column that we want to do transformation/normalization on (user input)
  activityColName <- inputColumnTable[activityCol==TRUE]$newActivityColName
  #     inputDataTable[ , activity := as.numeric(get(activityColName))]
  inputDataTable$activity <- as.numeric(inputDataTable[,get(activityColName)])
  
  return(inputDataTable)
}