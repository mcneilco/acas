# Sets the activity and column names to the user input. 
# Sets column names included in input parameters to the format of Rn {acivity}
# Inputs: readOrder (user input)
#         readNames (user input)
#         activityColNames (assayData) (from instrument files)
# Output: data table that can be used as a reference. Columns: userReadOrder, userReadName, ativityColName, newActivityColName

formatUserInputActivityColumns <- function(readOrder, readNames, activityColNames, tempFilePath, matchNames) {
  
  # For log file
  write.table(paste0(Sys.time(), "\tbegin formatUserInputActivityColumns"), file = file.path(tempFilePath, "runlog.tab"), append=FALSE, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
  
  userInput <- data.table(userReadOrder=readOrder, userReadName=readNames, activityColName="None", newActivityColName="None")
  
  noMatch <- list()
  overWrite <- list()
  
  if(length(activityColNames) < nrow(userInput)) {
    stopUser("More fields are defined in read input than are available from data file.")
  }
  
  if (matchNames) {
    for(name in readNames) {
      columnCount <- 0
      for(activity in activityColNames) {
        if(name == activity) {
          userInput[userReadName==name, ]$activityColName <- activity
          userInput[userReadName==name, ]$newActivityColName <- paste0("R",userInput[userReadName==name, ]$userReadOrder, " {",activity,"}")
          columnCount <- columnCount + 1
        }
      }
      if(columnCount == 0) {
        noMatch[[length(noMatch) + 1]] <- name
        userInput[userReadName==name, ]$newActivityColName <- paste0("R",userInput[userReadName==name, ]$userReadOrder, " {",name,"}")
      } else if(columnCount > 1) {
        stopUser(paste0("Multiple activity columns found for read name: '", name, "'"))
      } 
    } 
  } else {
    for (order in readOrder) {
      userInput[userReadOrder == order, ]$activityColName <- activityColNames[[order]]
    }
    # Checks to see if data has a generic name (Rn)
    for(name in readNames) {
      if(!grepl("^R[0-9]+$", userInput[userReadName==name, ]$activityColName) && name != userInput[userReadName==name, ]$activityColName){
        overWrite[[length(overWrite) + 1]] <- userInput[userReadName==name, ]$activityColName
      }
      userInput[userReadName==name, ]$newActivityColName <- paste0("R",userInput[userReadName==name, ]$userReadOrder, " {",name,"}")
    }
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
  if(length(overWrite) > 0) {
    warnUser(paste0("Overwriting the following column(s) with user input read names: '", paste(overWrite, collapse="','"),"'"))
  }
  
  return(userInput)
}
