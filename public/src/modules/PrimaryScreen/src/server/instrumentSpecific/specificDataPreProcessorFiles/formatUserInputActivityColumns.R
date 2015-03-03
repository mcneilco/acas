# If matchNames is false, overwrites (with warning) existing dataTitles
# If matchNames is true, scans through data titles for what we want
# Sets the activity and column names to the user input. 
# Sets column names included in input parameters to the format of Rn {acivity}
# Inputs: readsTable (data.table with columns readOrder, readNames, activity)
#         activityColNames (assayData) (from instrument files)
# Output: data table that can be used as a reference. Columns: readPosition, readName, ativityColName, newActivityColName, activity

formatUserInputActivityColumns <- function(readsTable, activityColNames, tempFilePath, matchNames) {
  
  # For log file
  write.table(paste0(Sys.time(), "\tbegin formatUserInputActivityColumns"), file = file.path(tempFilePath, "runlog.tab"), append=FALSE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  
  userInput <- copy(readsTable)
  setnames(userInput, c("readPosition", "readName","activity"), c("userReadPosition", "userReadName","activityCol"))
  #userInput$activityCol <- NULL
  userInput[ , activityColName := "None"]
  userInput[ , newActivityColName := "None"]
  
  noMatch <- list()
  overWrite <- list()
  
  if(nrow(readsTable[readsTable$activity]) > 1) {
    stopUser("More than one read column chosen as the activity column.")
  } else if (nrow(readsTable[readsTable$activity]) < 1) {
    stopUser("At least one read column needs to be chosen as the activity column.")
  }
  
  if(length(activityColNames) < nrow(userInput[calculatedRead == FALSE])) {
    stopUser("More fields are defined in read input than are available from data file.")
  }
  
  if (matchNames) {
    # Finds activity columns that match the user input activity. 
    # Assigns new activity column names of format "Rn {activity}"
    # Filters out calculated read columns since those won't match.
    for(name in userInput[calculatedRead == FALSE]$userReadName) {
      columnCount <- 0
      for(activity in activityColNames) {
        if(name == activity) {
          userInput[userReadName==name, activityColName := activity]
          userInput[userReadName==name, newActivityColName := paste0("R",userInput[userReadName==name, ]$userReadOrder, " {",activity,"}")]
          columnCount <- columnCount + 1
        }
      }
      if(columnCount == 0) {
        noMatch[[length(noMatch) + 1]] <- name
        userInput[userReadName==name, newActivityColName := paste0("R",userInput[userReadName==name, ]$userReadOrder, " {",name,"}")]
      } else if(columnCount > 1) {
        stopUser(paste0("Multiple activity columns found for read name: '", name, "'"))
      } 
    } 
  } else {
    # Finds activity columns that match the user input read position. 
    # Assigns new activity column names of format "Rn {userInputReadName}"
    # Filters out calculated read columns since those don't have a position in the raw data files
    for (order in userInput[calculatedRead == FALSE]$userReadPosition) {
      userInput[userReadPosition == order, activityColName := activityColNames[[order]]]
    }
    # Checks to see if data has a generic name (Rn)
    for(name in userInput[calculatedRead == FALSE]$userReadName) {
      if(!grepl("^R[0-9]+$", userInput[userReadName==name, ]$activityColName) && name != userInput[userReadName==name, ]$activityColName){
        overWrite[[length(overWrite) + 1]] <- userInput[userReadName==name, ]$activityColName
      }
      userInput[userReadName==name, newActivityColName := paste0("R",userInput[userReadName==name, ]$userReadOrder, " {",name,"}")]
    }
  }
  
  # Assigns new activity column names to Calculated Reads
  for(name in userInput[calculatedRead == TRUE]$userReadName) {
    userInput[userReadName == name , newActivityColName := paste0("R", userInput[userReadName==name, ]$userReadOrder, " {",name,"}")]
  }
  
  # these warnings/errors will only happen if matchNames = TRUE
  validActivityColumns <- userInput[activityColName != "None", ]$activityColName
  if(length(noMatch) > 0) {
    warnUser(paste0("No match found for read name(s): '", paste(noMatch, collapse="','"),"'"))
  }
  if(length(validActivityColumns) == 0) {
    stopUser("No valid acvitivy columns were found from user input.")
  } else if(length(unique(validActivityColumns)) != length(validActivityColumns)) {
    warnUser("A single activity column is assigned to multiple input reads.")
  } 
  
  # these warnings/errors will only happen if matchNames = FALSE
  #   if(length(overWrite) > 0) {
  #     warnUser(paste0("Overwriting the following column(s) with user input read names: '", paste(overWrite, collapse="','"),"'"))
  #   }
  
  return(userInput)
}
