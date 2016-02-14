# The next line is used by PrepareConfigFiles to include this file as a route in rapache, do not modify unless you intend to modify rapache routes (it can be anywhere in the files though)
# ROUTE: /getFilteredGeneData
#.libPaths('/opt/acas_home/app_1.4/acas/r_libs')
#Sys.setenv(ACAS_HOME = "/Users/goshiro2014/Documents/McNeilco_2012/clients/Development/acasBuilds/acas")
#.libPaths('/Users/goshiro2014/Documents/McNeilco_2012/clients/Development/acasBuilds/acas/r_libs')
require('RCurl')
require('rjson')
require('data.table')
require('racas')
require('reshape2')


source(file.path(racas::applicationSettings$appHome,"public/src/modules/DataViewer/src/server/getSELColOrder.R"))


# Load the configs
configList <- racas::applicationSettings

# # Used to profile the code
# Rprof(filename = "Rprof.out", append = FALSE, interval = 0.0001,
#       memory.profiling = FALSE, gc.profiling = FALSE,
#       line.profiling = TRUE, numfiles = 100L, bufsize = 10000L)


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

### FUNCTIONS FOR PROCESSING DATA INTO ROWS/COLS ETC...#####

# A function to take in a string and round using signif() if possible before converting back to a string.
# if the string cannot be coersed into a numeric type, the original string is returned as is.
# This is a vectorized function
# e.g roundString("retest", 3) = "retest"
#     roundString("128479823", 3) = "1.28e+08"
sigfig <- 4 #TODO pull from a config
roundString <- function(string,sigfigs=4){
  # The warning given here is about strings being coersed to NA, since we rely on
  # this behavior in the next line, we can ignore these warnings
  num <- suppressWarnings(as.numeric(string))
  ifelse(is.na(num), string, as.character(signif(num,sigfigs)) )
}

# functions that can deal with the < and > signs
arithMean <- function(data){
  if (length(data)==0){
    return ("NA")
  }
  firstChar = substring(data,1,1)
  hasOperator <- firstChar =="<" | firstChar == ">"
  # returns < or > if it is the only operator, *** if there are both
  finalOperator <- unique(subset(firstChar,hasOperator))
  if (length(finalOperator) > 1){
    finalOperator <- "***"
  }else if (length(finalOperator) == 1){
    finalOperator <- paste0("*",finalOperator)
  }
  valuesList <- as.numeric(c(subset(data,!hasOperator), substring(subset(data,hasOperator),2)))
  x <- (paste0(finalOperator,roundString(mean(valuesList, na.rm=TRUE),sigfig)))
  return(x)
}
geomMean <- function(data){
  if (length(data) == 0){
    return ("NA")
  }
  firstChar = substring(data,1,1)
  hasOperator <- firstChar =="<" | firstChar == ">"
  # returns < or > if it is the only operator, *** if there are both
  finalOperator <- unique(subset(firstChar,hasOperator))
  if (length(finalOperator) > 1){
    finalOperator <- "***"
  }else if (length(finalOperator) == 1){
    finalOperator <- paste0("*",finalOperator)
  }
  valuesList <- as.numeric(c(subset(data,!hasOperator), substring(subset(data,hasOperator),2)))
  gMean <- exp(sum(log(valuesList[valuesList > 0]), na.rm=TRUE) / length(subset(valuesList,!is.na(valuesList))))
  return (paste0(finalOperator,roundString(gMean,sigfig)))
}

# needs to be named fun.aggregate --Thanks BB
# http://stackoverflow.com/questions/24542976/how-to-pass-fun-aggregate-as-argument-to-dcast-data-table
fun.aggregate <- function(dataVector,type, exportCSV=exportCSV){
  if (length(dataVector)==1){
    return (dataVector)
  }
	if (exportCSV){
  		agData.values = dataVector		
	} else {
  		agData.values = sapply(dataVector,function(a) a[1])
  		agData.ids = paste(sapply(dataVector,function(a) a[2]),collapse=",")		
	}

  if (type == "geomMean"){
    agData.value = geomMean(agData.values)
  }else if(type == "arithMean"){
    agData.value = arithMean(agData.values)
  #curve renderer does overlay with curve id's delimited by ,
  }else if(type == "curve"){
		if (!exportCSV){
    		agData.value = paste(agData.values,collapse=",")
		} else {
    		agData.value = paste(agData.values,collapse=",")			
		}
  }else{
		if (!exportCSV){
    		agData.value = paste(agData.values,collapse="<br>")
		} else{
			agData.value = paste(agData.values,collapse=";")
		}
  }

	if (exportCSV){
		return(agData.value)
	} else {
  		return(list(c(agData.value,agData.ids)))	
	}
}


pivotResults <- function(geneId, lsKind, result, aggType="other", exportCSV=exportCSV){

  # dcast.data.table cannot find this if not pushed to global...........
  aggType <<- aggType

  exptSubset <- data.table(geneId, lsKind, result)
  if (nrow(exptSubset) == 0){  #can't use dcast on an empty data.table
    return (data.table(geneId))
  }
  dcast.data.table(exptSubset, geneId ~ lsKind, value.var=c("result"),fun.aggregate = fun.aggregate, type = aggType, exportCSV = exportCSV, fill=NA)
}

# wrapper function so that reduce can be called on data.table.merge with non-default arguments
myMerge <- function(x,y){
  merge(x,y,by="geneId",all=TRUE)
}

# A function to aggregate (or not) and pivot dataDT
# dataDT is the data returned from the server in a data.table
# expt is the experiment or protocol id for the current group of data
# returns outputDT, a data.table in the format of the final output (table of compounds vs. properies)
aggAndPivot <- function(dataDT, expt, exportCSV, aggregateData){
  if (aggregateData){
    # Get list of properties to aggregate with geometirc mean from config
    geomList <- unlist(strsplit(configList$server.sar.geomMean,","))

    # subset dataDT based aggregation type and dcast each subset by calling a different type of aggergation (last parameter to pivotResults)
    dataDTFilter <- dataDT[protocolId == expt]
    outputDTGeometric <- dataDTFilter[sub(" .*","",lsKind) %in% geomList , pivotResults(testedLot, lsKind, result, "geomMean", exportCSV)]
    outputDTArithmetic <- dataDTFilter[lsType == "numericValue" & !(sub(" .*","",lsKind) %in% geomList), pivotResults(testedLot, lsKind, result, "arithMean", exportCSV)]
    outputDTCurve <- dataDTFilter[lsKind == "curve id", pivotResults(testedLot, lsKind, result, "curve", exportCSV)]
    outputDTOther <- dataDTFilter[lsType != "numericValue" & lsKind != "curve id", pivotResults(testedLot, lsKind, result, "other", exportCSV)]

    # merge all subsets back into one outputDT
    outputDT <- Reduce(myMerge, list(outputDTGeometric,outputDTArithmetic,outputDTCurve,outputDTOther))

  }else{ # Aggregate is false
    outputDTCurve <- dataDT[experimentId == expt & (lsType == "stringValue" & lsKind == "curve id"), pivotResults(testedLot, lsKind, result, "curve", exportCSV)]
    outputDTNonCurve <- dataDT[experimentId == expt & !(lsType == "stringValue" & lsKind == "curve id"), pivotResults(testedLot, lsKind, result, "other", exportCSV)]

    # merge all subsets back into one outputDT
    outputDT <- Reduce(myMerge, list(outputDTCurve, outputDTNonCurve))

  }
}


# A function that calls getExperimentColNames to get all column names for current
#   experiment/protocol in the order from the original SEL file.
# exptCodes is data.table that has a column experimentCodeName and contains all the experiments in
#   current experiment/protocol. (yes, there is only one experiment in list is aggregate = false)
getColOrder <- function(experimentList, outputDT, exportCSV=exportCSV){
  exptDataColumns <- c()
  for (codeName in experimentList$experimentCodeName){
    exptDataColumns <- c(exptDataColumns,getExperimentColNames(experimentCode=codeName, showAllColumns=exportCSV))
  }

  # old code: exptDataColumns <- intersect(exptDataColumns, names(outputDT))
  # Can't take intersect anymore because lsKind might be modified with concentration info.
  # Instead use sapply and grep to keep values of exptDataColumns which have a value of outputDT as part of their name (in the same order as exptDataColumns)
  # The regex keeps things like look like Ki (uM) but excludes Ki.x (which is from curve curator)
  # unique(paste(unlist(...))) just ensures the the output is a single-demensional list with no duplicates (like the result of intersect)
  # Note that the implementation of unique guaruntees that order is preserved just like intersect
  exptDataColumns <- unique(paste(unlist(sapply(exptDataColumns,function(x) grep(paste0(x,"([^.]|$)"),names(outputDT),value=TRUE)))))
}


# Modifies inlineFileValue columns to display a link to the uploaded image (e.g. Western Blot)
# fileValues is a list of the lsKind (column name) of each column to be modified
modifyFileValues <- function(outputDT, fileValues, exportCSV, aggregateData){
  if(exportCSV){
    # Do nothing?
  }else if (aggregateData){
    for (i in fileValues){  #for each image column
      ids <- vapply(outputDT[[i]],function(x) as.character(x[2]),"")  #get ids
      split <-  strsplit(vapply(outputDT[[i]],function(x) if(is.null(x)) as.character(NA) else as.character(x[1]),""),"<br>")  #get urls and split on <br> which was used to aggregate in aggregateData()
      urlSplit <- sapply(split,function(x) if (length(x) == 0 || is.na(x)) NA else paste0('<a href="',configList$server.nodeapi.path,'/dataFiles/',x,'" target="_blank"><img src="',configList$server.nodeapi.path,'/dataFiles/',x,'" style="height:240px"></a>'), simplify=FALSE)

      if (length(urlSplit[[1]]) > 1){  # There are multiple images in one cell, recombine
        urlCombined <- vapply(urlSplit,function(x) paste(x,collapse = "<br>"),"")
        outputDT[[i]] <- strsplit(paste(urlCombined,ids,sep="::"),split="::")
      }else{  # There is only one image per cell, urlSplit has correct dimensionality
        outputDT[[i]] <- strsplit(paste(urlSplit,ids,sep="::"),split="::") #strsplit is used to coerce into a list
      }
    }
  }else{ #aggregate is false
    # Replace each inlineFileValue with a link to the file
    for (i in fileValues){
      outputDT[[i]] <- sapply(outputDT[[i]],function(x) if (length(x) == 0 || is.na(x)) NA else list(c(paste0('<a href="',configList$server.nodeapi.path,'/dataFiles/',x[1],'" target="_blank"><img src="',configList$server.nodeapi.path,'/dataFiles/',x[1],'" style="height:240px"></a>'),x[2])))
    }
  }
  return(outputDT)
}

extractFileNameSingle <- function(inputFilePath){
	  	annotationFileSplit <- strsplit(inputFilePath, '/')[[1]]
  		annotationFileName <- annotationFileSplit[length(annotationFileSplit)]
return(annotationFileName)
}

extractFileName <- function(inputFilePath){
	firstPass <- TRUE
	for (singlePath in inputFilePath){
	  	annotationFileSplit <- strsplit(singlePath, '/')[[1]]
  		annotationFileName <- annotationFileSplit[length(annotationFileSplit)]	
		if (firstPass){
			combinedOutput <- annotationFileName
			firstPass <- FALSE
		} else {
			combinedOutput <- c(combinedOutput, annotationFileName)
		}
	}
return(combinedOutput)
}

modifyReportFileValues <- function(outputDT, reportFileValues, exportCSV, aggregateData){

  if(exportCSV){
    # Do nothing?
  }else if (aggregateData){
	i <- "report file"
      ids <- vapply(outputDT[[i]],function(x) as.character(x[2]),"")  #get ids
		if (length(ids) > 0){
	      split <-  strsplit(vapply(outputDT[[i]],function(x) if(is.null(x)) as.character(NA) else as.character(x[1]),""),"<br>")  #get urls and split on <br> which was used to aggregate in aggregateData()
	      urlSplit <- sapply(split,function(x) if (length(x) == 0 || is.na(x)) NA else paste0('<a href="',configList$server.nodeapi.path,'/dataFiles/',x,'" target="_blank" download>', extractFileName(x),'</a>'), simplify=FALSE)
	      if (length(urlSplit[[1]]) > 1){  # There are multiple report file links in one cell, recombine
	        urlCombined <- vapply(urlSplit,function(x) paste(x,collapse = "<br>"),"")
	        outputDT[[i]] <- strsplit(paste(urlCombined,ids,sep="::"),split="::")
	      } else{  # There is only one report file per cell, urlSplit has correct dimensionality
	        outputDT[[i]] <- strsplit(paste(urlSplit,ids,sep="::"),split="::") #strsplit is used to coerce into a list
	      }		
		}
  } else { #aggregate is false
    # Replace each inlineFileValue with a link to the file
    for (i in reportFileValues){
		outputDT[[i]] <- sapply(outputDT[[i]], 
	                      function(x) 
	                      if (length(x) == 0 || is.na(x)) NA 
	                      else list(c(
									paste0('<a href="',configList$server.nodeapi.path,'/dataFiles/',x[1], '" target="_blank" download>', extractFileNameSingle(x[1]), '</a>'),
	   							x[2])))
    }
  }
  return(outputDT)
}

# Function to modify the curve id column to display a render of the actual curve
# curveIdCol is the column from outputDT containing curve id's
# For csv, only output url, without html tags
modifyCurveValues <- function(curveIdCol){
  if (!exportCSV){
    sapply(curveIdCol, function(x) list(c(paste0('<a href="http://',configList$client.host,':',configList$client.port,'/api/curve/render/?legend=false&showGrid=false&height=240&width=500&curveIds=',x[1],'&showAxes=true&labelAxes=true" target="_blank"><img src="http://',configList$client.host,':',configList$client.port,'/api/curve/render/?legend=false&showGrid=false&height=180&width=375&curveIds=',x[1],'&showAxes=true&labelAxes=true" height="180" width="375"></a>'),x[2])))
  }else{
    sapply(curveIdCol, function(x) paste0('http://',configList$client.host,':',configList$client.port,'/api/curve/render/?legend=false&showGrid=false&height=180&width=375&curveIds=',x[1],'&showAxes=true&labelAxes=true" height="180" width="375"'))
  }
}

# function to convert lsType to sType (used in js datatables)
setType <- function(lsType){
  if (lsType == "stringValue"){
    sType <- "string"
  } else {
    sType <- "numeric"
  }
  return(sType)
}

processData <- function(postData, exportCSV, onlyPublicData){

	postData.list <- fromJSON(postData)

	batchCodeList <- list()
	if (!is.null(postData.list$queryParams$batchCodes)) {
	  geneData <- postData.list$queryParams$batchCodes
	  #split on whitespace (except "-", don't split on that bc it is used in batch and reference codes)
	  geneDataList <- strsplit(geneData, split="[^A-Za-z0-9_-]")[[1]]
	  geneDataList <- geneDataList[geneDataList!=""]
	  if (length(geneDataList) == 1) {
	    batchCodeList <- list(geneDataList)
	  }else{
	     batchCodeList <- geneDataList
	  }
	}

	searchParams <- list()
	if (length(postData.list$queryParams$experimentCodeList) > 1){
	  experimentCodes <- unique(postData.list$queryParams$experimentCodeList)
	  searchParams$experimentCodeList <- experimentCodes[grepl("^EXPT-", experimentCodes)]
	} else {
	  searchParams$experimentCodeList <- list()
	  searchParams$experimentCodeList[1] <- postData.list$queryParams$experimentCodeList
	}
	searchParams$batchCodeList <- batchCodeList
	searchParams$searchFilters <- postData.list$queryParams$searchFilters$filters
	searchParams$booleanFilter <- postData.list$queryParams$searchFilters$booleanFilter
	searchParams$advancedFilter <- postData.list$queryParams$searchFilters$advancedFilter

	# Whether or not to aggregate on protocol
	# TODO refactor this so it is not a global -- pass param to all functions
	aggregateData <<- FALSE
	if (toupper(as.character(postData.list$queryParams$aggregate)) == "TRUE") aggregateData <<- TRUE

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
	#myLogger$debug(searchParams)
	#save(searchParams, file="searchParams.Rda")

	serverURL <- racas::applicationSettings$client.service.persistence.fullpath

	dataCsv <- getURL(
	  paste0(serverURL, "experiments/agdata/batchcodelist/experimentcodelist?format=csv&onlyPublicData=", onlyPublicData),
	  customrequest='POST',
	  httpheader=c('Content-Type'='application/json'),
	  postfields=toJSON(searchParams))

	myLogger$info(dataCsv)

	errorFlag <- tryCatch({
	  dataDF <- read.csv(text = dataCsv, colClasses=c("character"))
	  errorFlag <- FALSE
	  },
	  error = function(ex) {
	  errorFlag <- TRUE
	})

	if (errorFlag){
	        dataDT <- data.table()
	} else {
	        dataDT <- as.data.table(dataDF)
	}


	### PROCESS DATA RETURNED FROM SERVER #####

	#save(dataDT, file='dataDT.Rda')
	if (nrow(dataDT) > 0){  # If data was returned from the server
	  firstPass <- TRUE

		# Make a list of protocols if we are aggregating by protocol, otherwise make a list of experiments
		  if (aggregateData){
		    protocolIdDT <- unique(subset(dataDT, ,sel=c(protocolId, protocolName)))
		    setkey(protocolIdDT, protocolName)
		    experimentIdList <- protocolIdDT$protocolId
		  }else{
		    experimentIdDT <- unique(subset(dataDT, ,sel=c(experimentId, experimentCodeName, experimentName)))
		    setkey(experimentIdDT, experimentCodeName)
		    experimentIdList <- experimentIdDT$experimentId
		  }
	

	  # loop through all experiments/protocols
	  for (expt in experimentIdList){
	    myLogger$debug(paste0("current experiment(/protocol) ", expt))
	    if(firstPass){

	      # Modify lsKind to include units, concentration info, and time duration as well (if it exists)
	      dataDT[resultUnit != "", lsKind := paste0(lsKind," (",resultUnit,")",sep="")]
	      dataDT[testedConcentration != "", lsKind := paste0(lsKind,"at",testedConcentration,testedConcentrationUnit,sep=" ")]
	      dataDT[testedTime != "", lsKind := paste0(lsKind, "for", roundString(testedTime), testedTimeUnit, sep=" ")]
	      #TODO change "time units" to be the actual units...

	      # Keep only 4 sig-figs if displying in browser
	      if (!exportCSV){
	        #options( scipen = -2 )  # forces scientific notation more often
	        dataDT[, result := roundString(result,sigfig)]
	      }

	      # Add operators to the front of result if they exist
	      dataDT[, result := paste0(operator,result,sep = '')]

	      if (!exportCSV){
		      # Add id's to the results as the second item in a list
		      # This means that each element in the data.table is a two-element list: list(result,id)
		      dataDT[, result := strsplit(paste(result,id,sep=","),",")]
			}

	      # Aggregate and pivot the data
	      outputDT <- aggAndPivot(dataDT, expt, exportCSV, aggregateData)

	      # Store info about current protocol/experiment
	      if (aggregateData){
	        experimentList <- unique(dataDT[protocolId == expt,experimentCodeName, by = c("experimentCodeName","experimentId")])  # list of experiments in this protocol
	        protocolName <- protocolIdDT[protocolId==expt][["protocolName"]]
	        currentPassName <- protocolName
	      }else{
	        experimentList <- unique(dataDT[experimentId == expt,experimentCodeName, by = c("experimentCodeName","experimentId")])  # only has one element, but it allows use of same code for aggregate/not
	        experimentName <- experimentIdDT[experimentId==expt][["experimentName"]]
	        codeName <- experimentIdDT[experimentId==expt][["experimentCodeName"]]
	        currentPassName <- experimentName
	      }

	      # get the columns in outputDT in the same order as in the SEL file(s)

	      exptDataColumns <- getColOrder(experimentList, outputDT, exportCSV)

	## add in columns that are in the database but not in the original SEL file
	missingDataColumns <- setdiff(names(outputDT), exptDataColumns)
	missingDataColumns <- setdiff(missingDataColumns, "geneId")
	if (length(missingDataColumns) > 0){
		exptDataColumns <- c(exptDataColumns, missingDataColumns)
	}


	      # Handle inlineFileValue coluns (uploaded images e.g. Western Blot)
	      if (aggregateData){
	        fileValues <- paste(unlist(unique(subset(dataDT,lsType=="inlineFileValue" & protocolId == expt,lsKind))))
	      }else{
	        fileValues <- paste(unlist(unique(subset(dataDT,lsType=="inlineFileValue" & experimentId == expt,lsKind))))
	      }
	      outputDT <- modifyFileValues(outputDT, fileValues, exportCSV, aggregateData)
	#      exptDataColumns <- c(exptDataColumns,fileValues)

	      # Handle File Report columns (uploaded annotation file)
	      if (aggregateData){
	        reportFileValues <- paste(unlist(unique(subset(dataDT,lsType=="fileValue" & lsKind =="report file" & protocolId == expt, lsKind))))
	      } else {
	        reportFileValues <- paste(unlist(unique(subset(dataDT,lsType=="fileValue" & lsKind =="report file" & experimentId == expt, lsKind))))
	      }

	saveSession('bforeModReportFile.rda')
	      outputDT <- modifyReportFileValues(outputDT, reportFileValues, exportCSV, aggregateData)


	      # Modify curve id column to display curve
	      if (!is.null(outputDT[["curve id"]])){  # column exists
	        outputDT[["curve id"]] <- modifyCurveValues(outputDT[["curve id"]])
	      }

	  		myLogger$debug("exptDataColumns is:")
	  		myLogger$debug(exptDataColumns)

	  		# Get the data in same order as the column titles
	   	outputDT <- subset(outputDT, ,sel=c("geneId", exptDataColumns))

	  		for (colName in exptDataColumns){
	  			setnames(outputDT, colName, paste0(currentPassName, "::", colName))
	  		}

	  		firstPass <- FALSE

	  		orderCols <- as.data.frame(cbind(lsKind=exptDataColumns, order=seq(1:length(exptDataColumns))))
	  		orderCols$order <- as.integer(as.character(orderCols$order))

	      if (aggregateData){
	  		  colNamesDF <- subset(dataDT, protocolId == expt, select=c(protocolId, experimentId, experimentCodeName, experimentName, protocolName, lsType, lsKind))
	      }else{
	  		  colNamesDF <- subset(dataDT, experimentId == expt, select=c(experimentId, experimentCodeName, experimentName, lsType, lsKind))
	      }

	      colNamesDF <- unique(colNamesDF)
	      # Get rid of any column names that have the same lsKind (e.g. two "Slope" will appear if some values are strings and some are numbers)
	      colNamesDF <- subset(colNamesDF,!duplicated(colNamesDF[["lsKind"]]))
	  		allColNamesDF <- merge(colNamesDF, orderCols, by="lsKind")
	  		allColNamesDF <- allColNamesDF[order(allColNamesDF$order),]
	
			## clean up NAs into blanks
	      outputDT[is.na(outputDT)] <- " "

	    } else {  # firstPass is false
	  		myLogger$debug(paste0("current firstPass ", firstPass))

	  		# Aggregate and pivot the data
	      outputDT2 <- aggAndPivot(dataDT, expt, exportCSV, aggregateData)

	      # Store info about current protocol/experiment
	      if (aggregateData){
	        experimentList <- unique(dataDT[protocolId == expt,experimentCodeName, by = c("experimentCodeName","experimentId")])  # list of experiments in this protocol
	        protocolName <- protocolIdDT[protocolId==expt][["protocolName"]]
	        currentPassName <- protocolName
	      }else{
	        experimentList <- unique(dataDT[experimentId == expt,experimentCodeName, by = c("experimentCodeName","experimentId")])  # only has one element, but it allows use of same code for aggregate/not
	        experimentName <- experimentIdDT[experimentId==expt][["experimentName"]]
	        codeName <- experimentIdDT[experimentId==expt][["experimentCodeName"]]
	        currentPassName <- experimentName
	      }

	      # get the columns in outputDT in the same order as in the SEL file(s)
	      exptDataColumns <- getColOrder(experimentList, outputDT2, exportCSV)

	## add in columns that are in the database but not in the original SEL file
	missingDataColumns <- setdiff(names(outputDT2), exptDataColumns)
	missingDataColumns <- setdiff(missingDataColumns, "geneId")
	if (length(missingDataColumns) > 0){
		exptDataColumns <- c(exptDataColumns, missingDataColumns)
	}

	      # Handle inlineFileValue coluns (uploaded images e.g. Southern Blot)
	      if (aggregateData){
	        fileValues2 <- paste(unlist(unique(subset(dataDT,lsType=="inlineFileValue" & protocolId == expt,lsKind))))
	      }else{
	        fileValues2 <- paste(unlist(unique(subset(dataDT,lsType=="inlineFileValue" & experimentId == expt,lsKind))))
	      }
	      outputDT2 <- modifyFileValues(outputDT2, fileValues2, exportCSV, aggregateData)
	      #exptDataColumns <- c(exptDataColumns,fileValues2)
	      fileValues <- c(fileValues,fileValues2)  # save a list of all fileValues

	  		# Get the data in same order as the column titles
	  		outputDT2 <- subset(outputDT2, ,sel=c("geneId",exptDataColumns))


	      # Handle File Report columns (uploaded annotation file)
	      if (aggregateData){
	        reportFileValues2 <- paste(unlist(unique(subset(dataDT,lsType=="fileValue" & lsKind =="report file" & protocolId == expt,lsKind))))
	      } else {
	        reportFileValues2<- paste(unlist(unique(subset(dataDT,lsType=="fileValue" & lsKind =="report file" & experimentId == expt,lsKind))))
	      }
	      outputDT2 <- modifyReportFileValues(outputDT2, reportFileValues2, exportCSV, aggregateData)

	      # Modify curve id column to display curve
	      if (!is.null(outputDT2[["curve id"]])){  # column exists
	        outputDT2[["curve id"]] <- modifyCurveValues(outputDT2[["curve id"]])
	      }

	      for (colName in exptDataColumns){
	  			setnames(outputDT2, colName, paste0(currentPassName, "::", colName))
	  		}

			## clean up NAs into blanks
	      outputDT2[is.na(outputDT2)] <- " "
	
	  		outputDT <- merge(outputDT, outputDT2, by=c("geneId"), all=TRUE)
	
			## clean up NAs into blanks
	      outputDT[is.na(outputDT)] <- " "

	  		orderCols <- as.data.frame(cbind(lsKind=exptDataColumns, order=seq(1:length(exptDataColumns))))
	  		orderCols$order <- as.integer(as.character(orderCols$order))

	      if (aggregateData){
	        colNamesDF2 <- subset(dataDT, protocolId == expt, select=c(experimentId, protocolId, experimentCodeName, experimentName, protocolName, lsType, lsKind))
	      }else{
	        colNamesDF2 <- subset(dataDT, experimentId == expt, select=c(experimentId, experimentCodeName, experimentName, lsType, lsKind))
	      }

	  		colNamesDF2 <- unique(colNamesDF2)
	  		#   Get rid of any columns that have the same lsKind (e.g. two Slopes will appear if some values are strings and some are numbers, this gets rid of that)
	  		colNamesDF2 <- subset(colNamesDF2,!duplicated(colNamesDF2[["lsKind"]]))
	  		colNamesDF2 <- merge(colNamesDF2, orderCols, by="lsKind")
	  		colNamesDF2 <- colNamesDF2[order(colNamesDF2$order),]
	  		allColNamesDF <- rbind(allColNamesDF, colNamesDF2)
	
#exptIndex <- exptIndex + 1	
#expt <- experimentIdList[exptIndex]
	
	      }
	  }  # Done iterating through experiments/protocols

	  # Generate aaData for display in javascript datatable
	  columns = gsub('\\W','',names(outputDT))
	  numCols = length(columns)
	  aaData = list()
	  ids = list()
	  for (i in seq_along(outputDT[[1]])){
	    aaData[[i]] = list()
	    ids[[i]] = list()
	    for (j in seq(numCols)){
	      aaData[[i]][[columns[j]]]=if (is.null(outputDT[[i,j]][1])) NA else outputDT[[i,j]][1]
	      ids[[i]][[j]]=outputDT[[i,j]][2]
	    }
	  }

	  outputDF <- as.data.frame(outputDT)
	  names(outputDF) <- NULL
	  outputDT.list <- as.list(as.data.frame(t(outputDF)))
	  names(outputDT.list) <- NULL


	  allColNamesDF$originalOrder <- seq(1:nrow(allColNamesDF))
	  allColNamesDT <- as.data.table(allColNamesDF)
	  if (aggregateData){
	    allColNamesDT[ , exptColName := paste0(protocolName, '::', lsKind)]
	    allColNamesDT[ , sType := setType(lsType), by=list(lsKind, protocolId)]
	    allColNamesDT[ , numberOfColumns := length(lsKind), by=list(protocolId)]
	    allColNamesDT[ , titleText := paste0("Protocol: ",protocolName), by=list(protocolId)]
	  }else{
	    allColNamesDT[ , exptColName := paste0(experimentName, '::', lsKind)]
	    allColNamesDT[ , sType := setType(lsType), by=list(lsKind, experimentId)]
	    allColNamesDT[ , numberOfColumns := length(lsKind), by=list(experimentId)]
	    allColNamesDT[ , titleText := experimentName, by=list(experimentId)]
	  }

	  # If the lsKind is either curve id or any of the names which will hold external images, want to give them a unique class
	  #   so that the columns can be made wider in the .css
	  imageClass <- ifelse(allColNamesDT[["lsKind"]] == "curve id","curveId","fileValue")

	  allColNamesDT$sClass <- ifelse(allColNamesDT[["lsKind"]] %in% c("curve id",fileValues),imageClass,"center")
	  setnames(allColNamesDT, "lsKind", "sTitle")
	  allColNamesDT[,mData := columns[2:length(columns)]]

	  aoColumnsDF <- as.data.frame(subset(allColNamesDT, ,select=c(sTitle, sClass, mData)))
	  aoColumnsDF <- rbind(data.frame(sTitle=fromJSON(configList$server.sar.defaultTitle), sClass="center referenceCode", mData="geneId"), aoColumnsDF)

	  groupHeadersDF <- unique(as.data.frame(subset(allColNamesDT, ,select=c(numberOfColumns, titleText))))
	  groupHeadersDF <- rbind(data.frame(numberOfColumns=1, titleText=''), groupHeadersDF)

	  aoColumnsDF.list <- as.list(as.data.frame(t(aoColumnsDF)))
	  names(aoColumnsDF.list) <- NULL

	  groupHeadersDF.list <- as.list(as.data.frame(t(groupHeadersDF)))
	  names(groupHeadersDF.list) <- NULL

	  responseJson <- list()
	  responseJson$results$data$aaData <- aaData
	  responseJson$results$data$iTotalRecords <- nrow(outputDT)
	  responseJson$results$data$iTotalDisplayRecords <- nrow(outputDT)
	  responseJson$results$data$aoColumns <- aoColumnsDF.list
	  responseJson$results$data$groupHeaders <- groupHeadersDF.list
	  responseJson$results$ids <- ids
	  responseJson$results$aggregate <- aggregateData
	  responseJson$results$batchCodes <- batchCodeList
	  responseJson$results$experimentCodeList <- searchParams$experimentCodeList
	  responseJson$results$searchFilters <- postData.list$queryParams$searchFilters
	  responseJson$results$htmlSummary <- "OK"
	  responseJson$hasError <- FALSE
	  responseJson$hasWarning <- FALSE
	  responseJson$errorMessages <- list()
	  setStatus(status=200L)

	} else { #no results
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
#	  names = names(outputDT) # names of all the data columns
#	  cleanDT <- outputDT[ , lapply(.SD, function(x) unlist(lapply(x,'[', 1))), .SDcols = names]#
#	  rm(outputDT)
#	  outputDT <- cleanDT
#	  outputDT[, (names) := lapply(.SD, function(x) unlist(lapply(x,'[', 1))), .SDcols = names]

#	  for (j in names) set(outputDT, j=j, value=as.character(outputDT[[j]]))

	  # Note, this assumes there is only one entityType
	  if (configList$server.sar.csvLabel == "bestLabel"){

	    #save(outputDT,file="outputDT.Rda")

	    searchObject = list()
	    searchObject$requestText <- outputDT$geneId[1]
	    searchReturn <- getURL(
	      paste0(configList$server.nodeapi.path, "/api/entitymeta/searchForEntities"),
	      customrequest='POST',
	      httpheader=c('Content-Type'='application/json'),
	      postfields=toJSON(searchObject))

	    displayName <- fromJSON(searchReturn)$results[[1]]$displayName

	    requestObject <- list()
	    requestObject$displayName <- displayName
	    requestObject$referenceCodes <- paste(outputDT$geneId, collapse = "\n")

	    bestLabels <- getURL(
	        paste0(configList$server.nodeapi.path, "/api/entitymeta/pickBestLabels/csv"),
	        customrequest='POST',
	        httpheader=c('Content-Type'='application/json'),
	        postfields=toJSON(requestObject))

	    csv <- as.data.table(read.csv(text=fromJSON(bestLabels)$resultCSV))


	    csv[,Best.Label := as.character(Best.Label)]
	    csv[is.na(Best.Label), Best.Label := Requested.Name]
	    csv[Best.Label == "", Best.Label := Requested.Name]
	    outputDT[,geneId := (csv[Requested.Name==geneId]$Best.Label)]

	    setnames(outputDT, "geneId", displayName);
	    # outputDT[, (names) := lapply(.SD, function(x) unlist(lapply(x,'[', 1))), .SDcols = names]
	    #save(bestLabels,csv,outputDT, file="bestLabels.Rda")
	  }else{
	    setnames(outputDT, "geneId", "Reference Code");
	  }

	  setHeader("Access-Control-Allow-Origin" ,"*");
	  setContentType("application/text")
	  write.csv(outputDT, file="", row.names=FALSE, quote=TRUE)

	} else {
	  setHeader("Access-Control-Allow-Origin" ,"*");
	  setContentType("application/json")
	  cat(toJSON(responseJson))
	}

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

### for testing:
#  exportCSV <- TRUE
#  onlyPublicData <- "false"
#  postData <- '{"queryParams":{"batchCodes":"CMPD-0000013-01A CMPD-0000012-01A CMPD-0000011-01A","experimentCodeList":["EXPT-00000033","EXPT-00000011"],"searchFilters":{"booleanFilter":"and","advancedFilter":""},"aggregate":"false"},"maxRowsToReturn":"10000","user":"bob"}'


postData <- rawToChar(receiveBin())
myLogger$info(postData)

#postData <- '{"queryParams":{"batchCodes":"29 60","experimentCodeList":["EXPT-00017","tags_EXPT-00017","PROT-00014","_External data_Published Influenza Datasets"],"searchFilters":{"booleanFilter":"and","advancedFilter":""}},"maxRowsToReturn":"10000","user":"goshiro"}'
#postData <- '{"queryParams":{"batchCodes":"","experimentCodeList":["EXPT-00000039"],"searchFilters":{"booleanFilter":"and","advancedFilter":""}},"maxRowsToReturn":"10000","user":"goshiro"}'
#postData <- '{"queryParams":{"batchCodes":"","experimentCodeList":["EXPT-00000015"],"searchFilters":{"booleanFilter":"and","advancedFilter":""}},"maxRowsToReturn":"10000","user":"goshiro"}'
#exportCSV <- TRUE
#onlyPublicData <- "true"

processData(postData, exportCSV, onlyPublicData)

rm(postData)


# #stops timing the code profiling
# Rprof(NULL)

#saveSession('getFilteredGeneData-session.rda')