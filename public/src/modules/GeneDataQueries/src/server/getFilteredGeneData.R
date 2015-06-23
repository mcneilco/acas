# The next line is used by PrepareConfigFiles to include this file as a route in rapache, do not modify unless you intend to modify rapache routes (it can be anywhere in the files though)
# ROUTE: /getFilteredGeneData

#.libPaths('/opt/acas_home/app_1.4/acas/r_libs')

require('RCurl')
require('rjson')
require('data.table')
require('racas')
require('reshape2')

#setwd('/opt/acas_home/app_1.4/acas/public/src/modules/GeneDataQueries/src/server')
#setwd('/opt/acas_homes/acas/acas/public/src/modules/GeneDataQueries/src/server')
source('getSELColOrder.R')
source('getExperimentColOrder.R')

#.libPaths('/opt/acas_homes/acas/acas/r_libs')

Rprof(filename = "Rprof.out", append = FALSE, interval = 0.005,
      memory.profiling = FALSE, gc.profiling = FALSE, 
      line.profiling = TRUE, numfiles = 100L, bufsize = 10000L)


myLogger <- createLogger(logName = "1",
                         logFileName = 'geneData.log',
                         logLevel = "DEBUG", logToConsole = FALSE)

#myLogger$debug("get getFilteredGeneData data initiated")

### FUNCTIONS #####

#' Returns a data.table with term names in one column and corresponding SQL statements in the other.
#'
#' @param searchFilters This is a list of filters from a JSON string.
#' @return Outputs a data.table
#' @keywords JSON SQL, Advanced Query
#' @export
getSQLFromJSONFilterList <- function(searchFilters) {
  
  termsSQL <- data.table()
  filterList <- 1
    for (filterList in 1:length(searchFilters)) {
      sqlQuery <- "(SELECT tested_lot FROM api_experiment_results WHERE "
      if (!is.null(searchFilters[[filterList]]$termName)) {
        termName <- searchFilters[[filterList]]$termName
      } else {
        stop("Filter termName not specified.")
      }
      if (!is.null(searchFilters[[filterList]]$experimentCode)) {
        sqlQuery <- paste0(sqlQuery, "expt_code_name='", searchFilters[[filterList]]$experimentCode, "' AND")
      }
      if (!is.null(searchFilters[[filterList]]$lsKind)) {
        sqlQuery <- paste0(sqlQuery, " ls_kind='", searchFilters[[filterList]]$lsKind, "' AND")
      }

      if (!is.null(searchFilters[[filterList]]$lsType)) {
        sqlQuery <- paste0(sqlQuery, " ls_type='", searchFilters[[filterList]]$lsType, "' AND")
      }

      if (!is.null(searchFilters[[filterList]]$lsType) &&
           !is.null(searchFilters[[filterList]]$operator) &&
           !is.null(searchFilters[[filterList]]$filterValue)) {
        if(searchFilters[[filterList]]$lsType == "numericValue") {
          sqlQuery <- paste0(sqlQuery, " numeric_value", searchFilters[[filterList]]$operator, searchFilters[[filterList]]$filterValue, " AND")
        } else {
          stop(paste0("ls Type ", searchFilters[[filterList]]$lsType, " not defined yet"))
        }
      } else if (!is.null(searchFilters[[filterList]]$lsType) |
                   !is.null(searchFilters[[filterList]]$operator) |
                   !is.null(searchFilters[[filterList]]$filterValue)) {
        stop("lsType/operator/filterValue not completely defined")
      }

      # checks to see if the query string ends with " AND"
      if (substr(sqlQuery, start=nchar(sqlQuery)-3, stop=nchar(sqlQuery))==" AND") {
        sqlQuery <- paste0(substr(sqlQuery, start=1, stop=nchar(sqlQuery)-4), ")")
      } else {
        sqlQuery <- paste0(sqlQuery, ")")
      }
      # print(sqlQuery)
      # print(filterList)
      # print(searchFilters[[filterList]])

      #termsSQL <- rbind(termsSQL, list(termName, sqlQuery))

	  if (filterList == 1){
	      termsSQL <- as.data.table(list(termName, sqlQuery))
	  } else {
	      termsSQL <- rbind(termsSQL, list(termName, sqlQuery))
	  }

    }

    setnames(termsSQL, colnames(termsSQL), c("tableTermName", "tableSQLQuery"))
  return(termsSQL)
}

#' Returns a sqlString that can be used to query against a server.
#'
#' @param termsSQL This is a data.table with term names in one column and sql strings in the other.
#' @param inputString This is an advanced query string. Example: '(Q1 and Q2) or (Q3 and Q4)'
#' @return Outputs a sqlString
#' @keywords JSON SQL, Advanced Query
#' @export
getFullSQLQuery <- function(termsSQL, sqlString) {
  sqlString <- toupper(sqlString)

  sqlString <- gsub(" AND ", " INTERSECT ", sqlString)
  sqlString <- gsub(" OR ", " UNION ", sqlString)
  sqlString <- gsub(" NOT ", " EXCEPT ", sqlString) # alternate SQL servers: s/except/minus
  sqlString <- gsub(" MINUS ", " EXCEPT ", sqlString) # alternate SQL servers: s/except/minus
  sqlString <- gsub(" EXCEPT ", " EXCEPT ", sqlString) # alternate SQL servers: s/except/minus

  for (rowSubstitute in 1:nrow(termsSQL)) {
    sqlString <- gsub(termsSQL[rowSubstitute, tableTermName], termsSQL[rowSubstitute, tableSQLQuery], sqlString)
  }


  return(sqlString)
}
### END FUNCTIONS #####

### GET INFO FROM ROO #####    
if(is.null(GET$format)){
  exportCSV <- FALSE
  onlyPublicData <- "true"
} else {
  exportCSV <- ifelse(GET$format == "CSV", TRUE, FALSE)
  onlyPublicData <- "false"
}

postData <- rawToChar(receiveBin())
save(postData,file="postData.Rda")

myLogger$debug(postData)

#postData <- '{"queryParams":{"batchCodes":"29 60","experimentCodeList":["EXPT-00017","tags_EXPT-00017","PROT-00014","_External data_Published Influenza Datasets"],"searchFilters":{"booleanFilter":"and","advancedFilter":""}},"maxRowsToReturn":"10000","user":"goshiro"}'
#postData <- '{"queryParams":{"batchCodes":"","experimentCodeList":["EXPT-00000039"],"searchFilters":{"booleanFilter":"and","advancedFilter":""}},"maxRowsToReturn":"10000","user":"goshiro"}'
#exportCSV <- TRUE
#onlyPublicData <- "false"

postData.list <- fromJSON(postData)

batchCodeList <- list()
if (!is.null(postData.list$queryParams$batchCodes)) {
  geneData <- postData.list$queryParams$batchCodes
  geneDataList <- strsplit(geneData, split="\\W")[[1]]
  geneDataList <- geneDataList[geneDataList!=""]
  
  if (length(geneDataList) > 0) {
    requestList <- list()
    for (i in 1:length(geneDataList)){
      requestList[[length(requestList)+1]] <- list(requestName=geneDataList[[i]])
    }
    requestObject <- list()
    requestObject$requests <- requestList
    geneNameList <- getURL(
      #			paste0("http://localhost:8080/acas/lsthings/getGeneCodeNameFromNameRequest"),
      paste0(racas::applicationSettings$client.service.persistence.fullpath, "lsthings/getGeneCodeNameFromNameRequest"),
      customrequest='POST',
      httpheader=c('Content-Type'='application/json'),
      postfields=toJSON(requestObject))
    
    genes <- fromJSON(geneNameList)$results
    batchCodeList <- list()
    for (i in 1:length(genes)){
      if (genes[[i]]$referenceName != ""){
        batchCodeList[[length(batchCodeList)+1]] <- genes[[i]]$referenceName
      }
    }
  }
}

searchParams <- list()
if (length(postData.list$queryParams$experimentCodeList) > 1){
  searchParams$experimentCodeList <- postData.list$queryParams$experimentCodeList
  
} else {
  searchParams$experimentCodeList <- list()
  searchParams$experimentCodeList[1] <- postData.list$queryParams$experimentCodeList
}
searchParams$batchCodeList <- batchCodeList
searchParams$searchFilters <- postData.list$queryParams$searchFilters$filters
searchParams$booleanFilter <- postData.list$queryParams$searchFilters$booleanFilter
searchParams$advancedFilter <- postData.list$queryParams$searchFilters$advancedFilter
save(searchParams,file="searchParams.rda")

# Whether or not to aggregate on protocol
aggregate <- as.logical(postData.list$queryParams$aggregate)

if (postData.list$queryParams$searchFilters$booleanFilter == 'advanced'){
	termsSQL <- getSQLFromJSONFilterList(postData.list$queryParams$searchFilters$filters)
#myLogger$debug("here is the termsSQL")
#myLogger$debug(termsSQL)

	advancedSqlQuery <- getFullSQLQuery(termsSQL, postData.list$queryParams$searchFilters$advancedFilter)
#myLogger$debug("here is the advancedSqlQuery")
#myLogger$debug(advancedSqlQuery)
	searchParams$advancedFilterSQL <- advancedSqlQuery
}

myLogger$debug("here is the final searchParams")
myLogger$debug(toJSON(searchParams))
myLogger$debug(searchParams)

serverURL <- racas::applicationSettings$client.service.persistence.fullpath
dataCsv <- getURL(
  paste0(serverURL, "experiments/agdata/batchcodelist/experimentcodelist?format=csv&onlyPublicData=", onlyPublicData),
  customrequest='POST',
  httpheader=c('Content-Type'='application/json'),
  postfields=toJSON(searchParams))
  

errorFlag <- FALSE
tryCatch({
  dataDF <- read.csv(text = dataCsv, colClasses=c("character"))},
  error = function(ex) {
  errorFlag <<- TRUE
})

if (errorFlag){
        dataDT <- data.table()
} else {
        dataDT <- as.data.table(dataDF)
}

### PROCESS DATA INTO ROWS/COLS ETC...#####

# A function to take in a string and round using signif() if possible before converting back to a string.
# if the string cannot be coersed into a numeric type, the original string is returned as is.
# e.g roundString("retest", 3) = "retest"
#     roundString("128479823", 3) = "1.28e+08"
sigfig <- 4 #TODO pull from a config
roundString <- function(string,sigfigs){
  num <- as.numeric(string)
  if (!is.na(num)){
    return(as.character(signif(num,sigfigs)))
  }else{
    return(string)
  }
}

# A function that can deal with the < and > signs
arithMean <- function(data){
  if (length(data)==0){
    return ("NA")
  }
  hasOperator <- sapply(data,function(x) substring(x,1,1)=="<"||substring(x,1,1)==">")
  # returns < or > if it is the only operator, *** if there are both
  finalOperator <- unique(sapply(subset(data,hasOperator),function(x) substring(x,1,1)))
  if (length(finalOperator) > 1){
    finalOperator <- "***"
  }else if (length(finalOperator) == 1){
    finalOperator <- paste0("*",finalOperator)
  }
  valuesList <- as.numeric(c(subset(data,!hasOperator),sapply(subset(data,hasOperator),function(x) substring(x,2))))
  x <- (paste0(finalOperator,roundString(mean(valuesList, na.rm=TRUE))))
  return(x)
}

geomMean <- function(data){
  if (length(data) == 0){
    return ("NA") 
  }
  hasOperator <- sapply(data,function(x) substr(x,1,1)=="<"||substr(x,1,1)==">")
  # returns < or > if it is the only operator, *** if there are both
  finalOperator <- unique(sapply(subset(data,hasOperator),function(x) substr(x,1,1)))
  if (length(finalOperator) > 1){
    finalOperator <- "***"
  }else if (length(finalOperator) == 1){
    finalOperator <- paste0("*",finalOperator)
  }
  valuesList <- as.numeric(c(subset(data,!hasOperator),sapply(subset(data,hasOperator),function(x) substring(x,2))))
  gMean <- exp(sum(log(valuesList[valuesList > 0]), na.rm=TRUE) / length(subset(valuesList,!is.na(valuesList))))
  return (paste0(finalOperator,roundString(gMean)))
}

# This is bound to the global environment because pivotResults can't seem to find it otherwise. 
# pretty sure it's due to something related to this bug: https://github.com/Rdatatable/data.table/issues/713
aggregateData <<- function(x,type){
  if (length(x)==1){
    return (x)
  }
  if (type == "geomMean"){
    geomMean(x)
  }else if(type == "arithMean"){
    arithMean(x)
  #curve curator does overlay with curve id's delimited by &  
  }else if(type == "curve"){
    paste(x,sep=",",collapse=",")   
  }else{
    paste(x,sep="<br>",collapse="<br>")
  }
}

pivotResults <- function(geneId, lsKind, result, aggType="other"){
  exptSubset <- data.table(geneId, lsKind, result)
  if (nrow(exptSubset) == 0){  #can't use dcast on an empty data.table
    return (data.table(geneId))
  }
  return(dcast.data.table(exptSubset, geneId ~ lsKind, value.var=c("result"),fun.aggregate = aggregateData, type = aggType))
}

# wrapper function so that reduce can be called on data.table.merge with non-default arguments
myMerge <- function(x,y){
  merge(x,y,by="geneId",all=TRUE)
}


if (nrow(dataDT) > 0){
  firstPass <- TRUE


# Make a list of protocols if we are aggregating by protocol, otherwise make a list of experiments
  if (aggregate){
    protocolIdDT <- unique(subset(dataDT, ,sel=protocolId))
    experimentIdList <- protocolIdDT$protocolId
  }else{
    experimentIdDT <- unique(subset(dataDT, ,sel=c(experimentId, experimentCodeName)))
    setkey(experimentIdDT, experimentCodeName)
    experimentIdList <- experimentIdDT$experimentId
  }

  for (expt in experimentIdList){
    myLogger$debug(paste0("current experiment(/protocol) ", expt))
    if(firstPass){      
      # Modify lsKind to include units and concentration info as well (if it exists)
      dataDT[resultUnit != "", lsKind := paste(lsKind," (",resultUnit,")",sep="")]
      dataDT[testedConcentration != "", lsKind := paste(lsKind,"at",testedConcentration,testedConcentrationUnit,sep=" ")]
      
      # Keep only 4 sig-figs if displying in browser
      if (!exportCSV){
        options( scipen = -2 ) #This is to force scientific notation more often
        dataDT[,result := sapply(result,function(x) roundString(x,sigfig))]
      }
      
      # Add operators to the front of result if they exist
      dataDT[,result := paste(operator,result,sep = '')]

      #aggregate and pivot the data
      if (aggregate){
        # subset dataDT based aggregation type and dcast each subset by calling a different type of aggergation (last parameter to pivotResults)
        geomList = c("EC50","pH","Ki")
        dataDTFilter <- dataDT[protocolId == expt]   
        outputDTGeometric <- dataDTFilter[sub(" .*","",lsKind) %in% geomList , pivotResults(testedLot, lsKind, result,"geomMean")]
        outputDTArithmetic <- dataDTFilter[lsType == "numericValue" & !(sub(" .*","",lsKind) %in% geomList), pivotResults(testedLot, lsKind, result,"arithMean")]
        outputDTCurve <- dataDTFilter[lsKind == "curve id", pivotResults(testedLot, lsKind, result,"curve")]
        outputDTOther <- dataDTFilter[lsType != "numericValue" & lsKind != "curve id", pivotResults(testedLot, lsKind, result,"other")]
        
        # merge all subsets back into one outputDT
        outputDT <- Reduce(myMerge, list(outputDTGeometric,outputDTArithmetic,outputDTCurve,outputDTOther))              
        experimentList <- unique(dataDT[protocolId == expt,experimentName,by = c("experimentCodeName","experimentId")])
        
      }else{ 
        outputDT <- dataDT[ experimentId == expt , pivotResults(testedLot, lsKind, result), by=list(experimentCodeName, experimentId, experimentName) ]  
        experimentName <- as.character(unique(outputDT$experimentName))
        codeName <- as.character(unique(outputDT$experimentCodeName))
        outputDT <- subset(outputDT, ,-c(experimentCodeName, experimentId, experimentName)) 
      }

      # Add a column with the compound structure
# TODO replace hard-coded url with a reference to the config.properties
      # For HTML display include <tags>. For csv just give the url.
      if (!exportCSV){
  		  outputDT[, StructureImage := paste0('<img src="http://host4.labsynch.com:8080/cmpdreg/structureimage/lot/',geneId,'">')]
      }else{
        outputDT[, StructureImage := paste0("http://host4.labsynch.com:8080/cmpdreg/structureimage/lot/",geneId)]
      }
      # Even though a protocol can have multiple experiments, we still want to get the order of the columns from each experiment
      if (aggregate){
        exptDataColumns <- c()
        for (codeName in experimentList$experimentCodeName){
          exptDataColumns <- c(exptDataColumns,getExperimentColNames(experimentCode=codeName, showAllColumns=exportCSV)) 
        }
      }else{
  		  exptDataColumns <- getExperimentColNames(experimentCode=codeName, showAllColumns=exportCSV) 
      }
      # old code: exptDataColumns <- intersect(exptDataColumns, names(outputDT))
      # Can't take intersect anymore because lsKind might be modified with concentration info.
      # Instead use sapply and grep to keep values of exptDataColums which have a value of outputDT as part of their name (in the same order as exptDataColums)
      # The regex keeps things like look like Ki (uM) but excludes Ki.x (which is from curve curator)
      # unique(paste(unlist(...))) just ensures the the output is a single-demensional list with no duplicates (like the result of intersect)
      exptDataColumns <- unique(paste(unlist(sapply(exptDataColumns,function(x) grep(paste0(x,"([^.]|$)"),names(outputDT),value=TRUE)))))
      
      # Get names of inlineFileValue thigs if they exist (e.g. Western Blot) and add them to exptDataColums
#csv handling
#TODO replace hard-coded url with a reference to the properies file
      if (aggregate){
        fileValues <- paste(unlist(unique(subset(dataDT,lsType=="inlineFileValue" & protocolId == expt,lsKind))))
#Replace with vectorization
        for (i in fileValues){
          split <-  strsplit(outputDT[[i]],"<br>")
          urlSplit <- sapply(split,function(x) paste0('<a href="http://192.168.99.100:3000/dataFiles/',x,'" target="_blank"><img src="http://192.168.99.100:3000/dataFiles/',x,'"></a>'))
          if (length(urlSplit) > length(outputDT[[i]])){
            outputDT[[i]] <- apply(urlSplit,2,function(x) paste(x,sep="<br>",collapse="<br>"))
          }else{
            outputDT[[i]] <- urlSplit
          }
        }
      }else{
        fileValues <- paste(unlist(unique(subset(dataDT,lsType=="inlineFileValue" & experimentId == expt,lsKind))))
        # Replace inlineFileValue with a link to the file
        for (i in fileValues){
          outputDT[[i]] <- sapply(outputDT[[i]],function(x) paste0('<a href="http://192.168.99.100:3000/dataFiles/',x,'" target="_blank"><img src="http://192.168.99.100:3000/dataFiles/',x,'"></a>'))
        }
      }
      exptDataColumns <- c(exptDataColumns,fileValues)

  		myLogger$debug("exptDataColumns is:")
  		myLogger$debug(exptDataColumns)
  		
  		#setcolorder(outputDT, c("geneId",exptDataColumns))
   		outputDT <- subset(outputDT, ,sel=c("geneId","StructureImage", exptDataColumns))   

      # Try to convert curve id values into images from the server. If there is no "curve id" column, try fails and nothing happens
      # For csv, only output url, without html tags
      # TODO replace hard-coded url with a reference to config.properties
      if (!exportCSV){
        try(outputDT[,`curve id` := paste0('<a href="http://192.168.99.100:3000/api/curve/render/?legend=false&showGrid=false&height=240&width=500&curveIds=',`curve id`,'&showAxes=true&labelAxes=true" target="_blank"><img src="http://192.168.99.100:3000/api/curve/render/?legend=false&showGrid=false&height=180&width=375&curveIds=',`curve id`,'&showAxes=true&labelAxes=true"></a>')],TRUE)
      }else{
        try(outputDT[,`curve id` := paste0("http://192.168.99.100:3000/api/curve/render/?legend=false&showGrid=false&height=240&width=500&curveIds=",`curve id`,"&showAxes=true&labelAxes=true")],TRUE)
      }

#changed experimentName to expt 
  		for (colName in exptDataColumns){
  			setnames(outputDT, colName, paste0(expt, "::", colName))
  		}
  		firstPass <- FALSE
  
  		orderCols <- as.data.frame(cbind(lsKind=exptDataColumns, order=seq(1:length(exptDataColumns))))		
  		orderCols$order <- as.integer(as.character(orderCols$order))
  		
      if (aggregate){
  		  colNamesDF <- subset(dataDT, protocolId == expt, select=c(protocolId, experimentId, experimentCodeName, experimentName, lsType, lsKind))
      }else{
  		  colNamesDF <- subset(dataDT, experimentId == expt, select=c(experimentId, experimentCodeName, experimentName, lsType, lsKind))
      }
      colNamesDF <- unique(colNamesDF)
      # Get rid of any columns that have the same lsKind (e.g. two "Slope" will appear if some values are strings and some are numbers)
      colNamesDF <- subset(colNamesDF,!duplicated(colNamesDF[["lsKind"]]))
  		allColNamesDF <- merge(colNamesDF, orderCols, by="lsKind")
  		allColNamesDF <- allColNamesDF[order(allColNamesDF$order),]

    } else {
  		myLogger$debug(paste0("current firstPass ", firstPass))
      
  		#aggregate and pivot the data
  		if (aggregate){
  		  # subset dataDT based aggregation type and dcast each subset by calling a different type of aggergation (last parameter to pivotResults)
#TODO config  		  
        geomList = c("EC50","pH","Ki")
  		  dataDTFilter <- dataDT[protocolId == expt]         
  		  outputDTGeometric <- dataDTFilter[sub(" .*","",lsKind) %in% geomList , pivotResults(testedLot, lsKind, result,"geomMean")]
  		  outputDTArithmetic <- dataDTFilter[lsType == "numericValue" & !(sub(" .*","",lsKind) %in% geomList), pivotResults(testedLot, lsKind, result,"arithMean")]
  		  outputDTCurve <- dataDTFilter[lsKind == "curve id", pivotResults(testedLot, lsKind, result,"curve")]
  		  outputDTOther <- dataDTFilter[lsType != "numericValue" & lsKind != "curve id", pivotResults(testedLot, lsKind, result,"other")]
  		  # merge all subsets back into one outputDT
  		  outputDT2 <- Reduce(myMerge, list(outputDTGeometric,outputDTArithmetic,outputDTCurve,outputDTOther))        
  		  experimentList <- unique(dataDT[protocolId == expt,experimentName,by = c("experimentCodeName","experimentId")])
  		}else{
  		  outputDT2 <- dataDT[ experimentId == expt , pivotResults(testedLot, lsKind, result), by=list(experimentCodeName, experimentId, experimentName) ]
  		  experimentName <- as.character(unique(outputDT2$experimentName))
  		  codeName <- as.character(unique(outputDT2$experimentCodeName))
  		  outputDT2 <- subset(outputDT2, ,-c(experimentCodeName, experimentId, experimentName))
  		}

  		myLogger$debug(paste0("current outputDT2 ", nrow(outputDT2)))
  		myLogger$debug(paste0("current outputDT2 ", names(outputDT2)))

      if (!exportCSV){
        outputDT2[, StructureImage := paste0('<img src="http://host4.labsynch.com:8080/cmpdreg/structureimage/lot/',geneId,'">')]
      }else{
        outputDT2[, StructureImage := paste0("http://host4.labsynch.com:8080/cmpdreg/structureimage/lot/",geneId)]
      }

      # Even though a protocol can have multiple experiments, we still want to get the order of the columns from each experiment
      if (aggregate){
        exptDataColumns <- c()
        for (codeName in experimentList$experimentCodeName){
          exptDataColumns <- c(exptDataColumns,getExperimentColNames(experimentCode=codeName, showAllColumns=exportCSV) )
        }
      }else{
        exptDataColumns <- getExperimentColNames(experimentCode=codeName, showAllColumns=exportCSV) 
      }
      
      # old code: exptDataColumns <- intersect(exptDataColumns, names(outputDT))
      # Can't take intersect anymore because lsKind might be modified with concentration info.
      # Instead use sapply and grep to keep values of exptDataColums which have a value of outputDT as part of their name (in the same order as exptDataColums)
      # unique(paste(unlist(...))) just ensures the the output is a single-demensional list with no duplicates (like the result of intersect)
      exptDataColumns <- unique(paste(unlist(sapply(exptDataColumns,function(x) grep(x,names(outputDT2),value=TRUE)))))
      
      # Get names of inlineFileValue thigs if they exist (e.g. Western Blot) and add them to exptDataColums
      #aggregate
      #csv handling
      #TODO replace hard-coded url with a reference to the properies file
      if (aggregate){
        fileValues2 <- paste(unlist(unique(subset(dataDT,lsType=="inlineFileValue" & protocolId == expt,lsKind))))
        for (i in fileValues2){
          split <-  strsplit(outputDT2[[i]],"<br>")
          urlSplit <- sapply(split,function(x) paste0('<a href="http://192.168.99.100:3000/dataFiles/',x,'" target="_blank"><img src="http://192.168.99.100:3000/dataFiles/',x,'"></a>'))
          if (length(urlSplit) > length(outputDT2[[i]])){
            outputDT2[[i]] <- apply(urlSplit,2,function(x) paste(x,sep="<br>",collapse="<br>"))
          }else{
            outputDT2[[i]] <- urlSplit
          }
        }
      }else{
        fileValues2 <- paste(unlist(unique(subset(dataDT,lsType=="inlineFileValue" & experimentId == expt,lsKind))))
        # Replace inlineFileValue with a link to the file
        for (i in fileValues2){
          outputDT2[[i]] <- sapply(outputDT2[[i]],function(x) paste0('<a href="http://192.168.99.100:3000/dataFiles/',x,'" target="_blank"><img src="http://192.168.99.100:3000/dataFiles/',x,'"></a>'))
        }
      }
      exptDataColumns <- c(exptDataColumns,fileValues2)
      
      # save a list of all fileValues
      fileValues <- c(fileValues,fileValues2)

  		#setcolorder(outputDT2, c("geneId",exptDataColumns))
  		outputDT2 <- subset(outputDT2, ,sel=c("geneId","StructureImage",exptDataColumns))
  
  		# Try to convert curve id values into images from the server. If there is no "curve id" column, try fails and nothing happens
  		# TODO replace hard-coded url with a reference to config.properties
      if (!exportCSV){
        try(outputDT2[,`curve id` := paste0('<a href="http://192.168.99.100:3000/api/curve/render/?legend=false&showGrid=false&height=240&width=500&curveIds=',`curve id`,'&showAxes=true&labelAxes=true" target="_blank"><img src="http://192.168.99.100:3000/api/curve/render/?legend=false&showGrid=false&height=180&width=375&curveIds=',`curve id`,'&showAxes=true&labelAxes=true"></a>')],TRUE)
      }else{
        try(outputDT2[,`curve id` := paste0("http://192.168.99.100:3000/api/curve/render/?legend=false&showGrid=false&height=240&width=500&curveIds=",`curve id`,"&showAxes=true&labelAxes=true")],TRUE)
      }	
#changed experimentName to expt
      for (colName in exptDataColumns){
  			setnames(outputDT2, colName, paste0(expt, "::", colName))
  		}
  		outputDT <- merge(outputDT, outputDT2, by=c("geneId","StructureImage"), all=TRUE)
  		orderCols <- as.data.frame(cbind(lsKind=exptDataColumns, order=seq(1:length(exptDataColumns))))
  		orderCols$order <- as.integer(as.character(orderCols$order))

      if (aggregate){
        colNamesDF2 <- subset(dataDT, protocolId == expt, select=c(experimentId, protocolId, experimentCodeName, experimentName, lsType, lsKind))
      }else{
        colNamesDF2 <- subset(dataDT, experimentId == expt, select=c(experimentId, experimentCodeName, experimentName, lsType, lsKind))
      }
  		colNamesDF2 <- unique(colNamesDF2)
  		#   Get rid of any columns that have the same lsKind (e.g. two Slopes will appear if some values are strings and some are numbers, this gets rid of that)
  		colNamesDF2 <- subset(colNamesDF2,!duplicated(colNamesDF2[["lsKind"]]))
  		colNamesDF2 <- merge(colNamesDF2, orderCols, by="lsKind")
  		colNamesDF2 <- colNamesDF2[order(colNamesDF2$order),]
  		allColNamesDF <- rbind(allColNamesDF, colNamesDF2)
      }
  }


  
  outputDF <- as.data.frame(outputDT)
  names(outputDF) <- NULL
  outputDT.list <- as.list(as.data.frame(t(outputDF)))
  names(outputDT.list) <- NULL
  
  
  setType <- function(lsType){
    if (lsType == "stringValue"){
      sType <- "string"
    } else {
      sType <- "numeric"
    }
    return(sType)
  }


  
  allColNamesDF$originalOrder <- seq(1:nrow(allColNamesDF))
  allColNamesDT <- as.data.table(allColNamesDF)
  allColNamesDT[ , exptColName := paste0(experimentName, '::', lsKind)]
if (aggregate){
  allColNamesDT[ , sType := setType(lsType), by=list(lsKind, protocolId)]
  allColNamesDT[ , numberOfColumns := length(lsKind), by=list(protocolId)]
  allColNamesDT[ , titleText := paste0("Protocol: ",protocolId), by=list(protocolId)]
}else{
  allColNamesDT[ , sType := setType(lsType), by=list(lsKind, experimentId)]
  allColNamesDT[ , numberOfColumns := length(lsKind), by=list(experimentId)]
  allColNamesDT[ , titleText := experimentName, by=list(experimentId)]
}


  # If the lsKind is either curve id or any of the names which will hold external images, want to give them unique class
  # so that the columns can be made wider in the .css
  allColNamesDT$sClass <- sapply(allColNamesDT[["lsKind"]],function(x) if(x %in% c("curve id",fileValues)){"curveId"}else{"center"})
  setnames(allColNamesDT, "lsKind", "sTitle")
  
  aoColumnsDF <- as.data.frame(subset(allColNamesDT, ,select=c(sTitle, sClass)))
  aoColumnsDF <- rbind(data.frame(sTitle="Compound Structure", sClass="StructureImage"), aoColumnsDF)
  aoColumnsDF <- rbind(data.frame(sTitle="ID", sClass="center"), aoColumnsDF)
  
  
  groupHeadersDF <- unique(as.data.frame(subset(allColNamesDT, ,select=c(numberOfColumns, titleText))))
  groupHeadersDF <- rbind(data.frame(numberOfColumns=2, titleText='Compound Information'), groupHeadersDF)
  
  aoColumnsDF.list <- as.list(as.data.frame(t(aoColumnsDF)))
  names(aoColumnsDF.list) <- NULL
  
  groupHeadersDF.list <- as.list(as.data.frame(t(groupHeadersDF)))
  names(groupHeadersDF.list) <- NULL
  
  responseJson <- list()
  responseJson$results$data$aaData <- outputDT.list
  responseJson$results$data$iTotalRecords <- nrow(outputDT)
  responseJson$results$data$iTotalDisplayRecords <- nrow(outputDT)
  responseJson$results$data$aoColumns <- aoColumnsDF.list
  responseJson$results$data$groupHeaders <- groupHeadersDF.list
  responseJson$results$htmlSummary <- "OK"
  responseJson$hasError <- FALSE
  responseJson$hasWarning <- FALSE
  responseJson$errorMessages <- list()
  setStatus(status=200L)
  
} else {
  
  responseJson <- list()
  responseJson$results$data$aaData <- list()
  responseJson$results$data$iTotalRecords <- 0
  responseJson$results$data$iTotalDisplayRecords <- 0
  responseJson$results$data$aoColumns <- list()
  responseJson$results$data$groupHeaders <- list()
  responseJson$results$htmlSummary <- "NO Resulsts"
  responseJson$hasError <- TRUE	
  responseJson$hasWarning <- FALSE
  error1 <- list(errorLevel="error", message="No results found.")
  error2 <- list(errorLevel="error", message="Please load more data.")
  responseJson$errorMessages <- list(error1, error2)
  setStatus(status=506L)
  
}

if (exportCSV){
  setHeader("Access-Control-Allow-Origin" ,"*");
  setContentType("application/text")
  write.csv(outputDT, file="", row.names=FALSE, quote=TRUE)
  
} else {
  setHeader("Access-Control-Allow-Origin" ,"*");
  setContentType("application/json")
  cat(toJSON(responseJson))
}


    


