## getExperimentColOrder.R or getExperimentColNames.R


pivotColOrderData <- function(lsKind, stringValue, numericValue){
	inputDT <- data.table(lsKind, stringValue, numericValue)
	columnName <- inputDT[lsKind=='column name']$stringValue
	columnType <- inputDT[lsKind=='column type']$stringValue
	columnOrder <- inputDT[lsKind=='column order']$numericValue
	hideColumn <- as.logical(inputDT[lsKind=='hide column']$stringValue)
	outputDT <- data.table(columnOrder, columnName, hideColumn)
	return (outputDT)
}

getExperimentColOrderValues <- function(experimentCode){
	dataCsv <- getURL(
	  paste0(racas::applicationSettings$client.service.persistence.fullpath, "experiments/", experimentCode, "/exptvalues/bystate/metadata/data%20column%20order/tsv"),
	  customrequest='GET',
	  httpheader=c('Content-Type'='application/json'))
	errorFlag <- TRUE
	tryCatch({
	  dataDF <- read.csv(text = dataCsv, colClasses=c("character"))},
	  error = function(ex) {
	  errorFlag <<- TRUE
	})
	if (errorFlag){
	        colOrderDT <- data.table()
	} else {
	        dataDT <- as.data.table(dataDF)
			colOrderDT <- dataDT[ ,pivotColOrderData(lsKind, stringValue, numericValue), by="stateId"]
			setkey(colOrderDT, columnOrder)
	}

	return(colOrderDT)
	
}


getExperimentColNames <- function(experimentCodeName, showAllColumns=TRUE){
	exptDataColumnsDT <- getExperimentColOrderValues(experimentCode=experimentCodeName)
	if (nrow(exptDataColumnsDT) == 0){
		## save the state values for the SEL column orders
		saveResult <- saveExptDataColOrder(experimentCodeName)
		if (saveResult){
			exptDataColumnsDT <- getExperimentColOrderValues(experimentCode=experimentCodeName)
		}
	}
	if (nrow(exptDataColumnsDT) > 0){
		exptDataColumnsDT$columnOrder <- as.integer(exptDataColumnsDT$columnOrder)
		setkey(exptDataColumnsDT, columnOrder)
		if (showAllColumns) {
			exptDataColumns <- exptDataColumnsDT[ ]$columnName
		} else {
			exptDataColumns <- exptDataColumnsDT[ hideColumn==FALSE]$columnName
		}
	} else {
		experimentFilters <- getURL(
			paste0(racas::applicationSettings$client.service.persistence.fullpath, "experiments/filters/jsonArray"),
			customrequest='POST',
			httpheader=c('Content-Type'='application/json'),
			postfields=paste0('[', experimentCodeName, ']'))

		efs <- fromJSON(experimentFilters)
		exptDataColumns <- c()
		for (i in 1:length(efs[[1]]$valueKinds)){
			exptDataColumns <- c(exptDataColumns, efs[[1]]$valueKinds[[i]]$lsKind)
		}

	}

	return(exptDataColumns)
}

