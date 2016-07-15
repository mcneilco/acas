

adjustColumnsToUserInput <- function(inputColumnTable, inputDataTable) {
  # Calculates calculated reads, changes names of colums in inputDataTable, 
  #   and returns the modified inputDataTable
  # Inputs:
  # inputColumnTable: 
  #   userReadPosition: null if "match names" = TRUE in GUI
  #   userReadName: character
  #   activityCol: boolean (only 1 can be true)
  #   userReadOrder: integers (from 1:nrow)
  #   calculatedRead: boolean
  #   activityColName: character
  #   newActivityColName: character
  # inputDataTable:
  #   everthing else....
  
  # These columns should always exist
  lockedColumns <- c("T_timePoints", "T_sequence", "agonistConc", "agonistBatchCode")
  
  # sets the names for all of the "defined" reads, but none of the calculated reads
  setnames(inputDataTable, 
           inputColumnTable[activityColName != "None", ]$activityColName, 
           inputColumnTable[activityColName != "None", ]$newActivityColName)
  
  # adds in any calculated columns
  # TODO: this should be in its own function
  if(nrow(inputColumnTable[calculatedRead==TRUE])>0) {
    for (calculation in inputColumnTable[calculatedRead==TRUE]$userReadName) {
      if(calculation == "Calc: (R1/R2)*100") {
        verifyCalculationInputs(inputDataTable, inputColumnTable, numberOfColumnsToCheck = 2)
        
        if(!inputColumnTable[userReadOrder==1]$calculatedRead && !inputColumnTable[userReadOrder==2]$calculatedRead) {
          inputDataTable[ , calculatedRead := (get(inputColumnTable[userReadOrder==1]$newActivityColName) /
                                              get(inputColumnTable[userReadOrder==2]$newActivityColName)) 
                                              * 100]
          setnames(inputDataTable, "calculatedRead", inputColumnTable[userReadName == calculation]$newActivityColName)
        } else {
          stopUser("System not set up to calculate a read off another calculated read. Please redefine your read names.")
        }
      } else if(calculation == "Calc: (R2/R1)*100") {
        verifyCalculationInputs(inputDataTable, inputColumnTable, numberOfColumnsToCheck = 2)
        
        if(!inputColumnTable[userReadOrder==2]$calculatedRead && !inputColumnTable[userReadOrder==1]$calculatedRead) {
          inputDataTable[ , calculatedRead := (get(inputColumnTable[userReadOrder==2]$newActivityColName) /
                                              get(inputColumnTable[userReadOrder==1]$newActivityColName)) 
                                              * 100]
          setnames(inputDataTable, "calculatedRead", inputColumnTable[userReadName == calculation]$newActivityColName)
        } else {
          stopUser("System not set up to calculate a read off another calculated read. Please redefine your read names.")
        }
      } else if(calculation == "Calc: R1/R2") {
        verifyCalculationInputs(inputDataTable, inputColumnTable, numberOfColumnsToCheck = 2)
        
        if(!inputColumnTable[userReadOrder==1]$calculatedRead && !inputColumnTable[userReadOrder==2]$calculatedRead) {
          inputDataTable[ , calculatedRead := (get(inputColumnTable[userReadOrder==1]$newActivityColName) /
                                              get(inputColumnTable[userReadOrder==2]$newActivityColName))]
          setnames(inputDataTable, "calculatedRead", inputColumnTable[userReadName == calculation]$newActivityColName)
        } else {
          stopUser("System not set up to calculate a read off another calculated read. Please redefine your read names.")
        }
      } else if(calculation == "Calc: R2/R1") {
        verifyCalculationInputs(inputDataTable, inputColumnTable, numberOfColumnsToCheck = 2)
        
        if(!inputColumnTable[userReadOrder==2]$calculatedRead && !inputColumnTable[userReadOrder==1]$calculatedRead) {
          inputDataTable[ , calculatedRead := (get(inputColumnTable[userReadOrder==2]$newActivityColName) /
                                              get(inputColumnTable[userReadOrder==1]$newActivityColName))]
          setnames(inputDataTable, "calculatedRead", inputColumnTable[userReadName == calculation]$newActivityColName)
        } else {
          stopUser("System not set up to calculate a read off another calculated read. Please redefine your read names.")
        }
      } else if(calculation == "Calc: (R1-R2)/(R1+R2)*1000") {
        verifyCalculationInputs(inputDataTable, inputColumnTable, numberOfColumnsToCheck = 2)
        
        if(!inputColumnTable[userReadOrder==1]$calculatedRead && !inputColumnTable[userReadOrder==2]$calculatedRead) {
          inputDataTable[ , calculatedRead := ((get(inputColumnTable[userReadOrder==1]$newActivityColName) -
                                              get(inputColumnTable[userReadOrder==2]$newActivityColName)) /
                                              (get(inputColumnTable[userReadOrder==1]$newActivityColName) +
                                              get(inputColumnTable[userReadOrder==2]$newActivityColName))) * 1000 ]
          setnames(inputDataTable, "calculatedRead", inputColumnTable[userReadName == calculation]$newActivityColName)
        } else {
          stopUser("System not set up to calculate a read off another calculated read. Please redefine your read names.")
        }
      } else if(calculation == "Calc: (R2-R1)/R1") {
        verifyCalculationInputs(inputDataTable, inputColumnTable, numberOfColumnsToCheck = 2)
        if(!inputColumnTable[userReadOrder==2]$calculatedRead && !inputColumnTable[userReadOrder==1]$calculatedRead) {
          inputDataTable[ , calculatedRead := ((get(inputColumnTable[userReadOrder==2]$newActivityColName) - 
                                                  get(inputColumnTable[userReadOrder==1]$newActivityColName)) /
                                                 get(inputColumnTable[userReadOrder==1]$newActivityColName))]
          setnames(inputDataTable, "calculatedRead", inputColumnTable[userReadName == calculation]$newActivityColName)
        } else {
          stopUser("System not set up to calculate a read off another calculated read. Please redefine your read names.")
        }
      } else if(calculation == "Calc: (R5-R4)/R4") {
        verifyCalculationInputs(inputDataTable, inputColumnTable, numberOfColumnsToCheck = 2)
        if(!inputColumnTable[userReadOrder==5]$calculatedRead && !inputColumnTable[userReadOrder==4]$calculatedRead) {
          inputDataTable[ , calculatedRead := ((get(inputColumnTable[userReadOrder==5]$newActivityColName) - 
                                                  get(inputColumnTable[userReadOrder==4]$newActivityColName)) /
                                                 get(inputColumnTable[userReadOrder==4]$newActivityColName))]
          setnames(inputDataTable, "calculatedRead", inputColumnTable[userReadName == calculation]$newActivityColName)
        } else {
          stopUser("System not set up to calculate a read off another calculated read. Please redefine your read names.")
        }
      } else if(calculation == "Calc: R1/Heavy Atom Count") {
        verifyCalculationInputs(inputDataTable, inputColumnTable, numberOfColumnsToCheck = 1)
        
        if(!inputColumnTable[userReadOrder==1]$calculatedRead) {
          # Adds a new "read" so that this will one of the columns that are kept
          hacReadOrder <- nrow(inputColumnTable)+1
          newInputColumnTableRow <- data.table(userReadPosition="",
                                               userReadName="",
                                               activityCol=FALSE,
                                               userReadOrder=hacReadOrder,
                                               calculatedRead=FALSE,
                                               activityColName="HAC: Heavy Atom Count",
                                               newActivityColName=paste0("R",hacReadOrder," {HAC: Heavy Atom Count}"))
          inputColumnTable <- rbind(inputColumnTable, newInputColumnTableRow)
          
          # Call the service to get the heavy atom count
          heavyAtomCount <- data.table(batchCode=unique(inputDataTable$batchCode),
                                       heavyAtomCount=get_compound_properties(unique(inputDataTable$batchCode), 
                                                                              propertyNames = c("HEAVY_ATOM_COUNT"))$HEAVY_ATOM_COUNT)
          
          
          # Merge the HAC data table with the overall data table
          inputDataTable <- merge(inputDataTable, heavyAtomCount, by="batchCode")
          
          # Re sort the data table (merge sorted on batchCode)
          setkeyv(inputDataTable, c("plateOrder","row","column"))
          
          
          inputDataTable[ , calculatedRead := get(inputColumnTable[userReadOrder==1]$newActivityColName) / 
                                              heavyAtomCount]
          
          setnames(inputDataTable, "calculatedRead", inputColumnTable[userReadName == calculation]$newActivityColName)
          setnames(inputDataTable, "heavyAtomCount", inputColumnTable[activityColName == "HAC: Heavy Atom Count"]$newActivityColName)
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
  colNamesToKeep <- c(inputColumnTable$newActivityColName, lockedColumns)
  
  inputDataTable <- removeColumns(colNamesToCheck, colNamesToKeep, inputDataTable)
  inputDataTable <- addMissingColumns(inputColumnTable$newActivityColName, inputDataTable)
  inputDataTable <- addMissingColumns(lockedColumns, inputDataTable, warnAdd = FALSE)
  inputDataTable[, agonistBatchCode:=as.character(agonistBatchCode)]
  
  # copy the read column that we want to do transformation/normalization on (user input)
  activityColName <- inputColumnTable[activityCol==TRUE]$newActivityColName
  #     inputDataTable[ , activity := as.numeric(get(activityColName))]
  inputDataTable$activity <- as.numeric(inputDataTable[,get(activityColName)])
  
  return(inputDataTable)
}
