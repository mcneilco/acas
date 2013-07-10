queryProtocol <- function(protocolName) {
	query <- paste(readLines('public/src/modules/CoreETL/src/server/core_results_query.sql'), collapse=" ")
	protQuery <- sub("<PROTOCOL_TO_SEARCH>", protocolName, query)
	return( query(protQuery, globalConnect=TRUE) )
}

convertScientistName <- function(sname) {
	nameParts <- strsplit(sname, ", ")
	return( tolower(paste(substring(nameParts[[1]][[2]], 1, 1), nameParts[[1]][[1]], sep="")))
}

getHeaderLines <- function(expt) {
	hl <- I("Experiment Meta Data,")
	hl[[2]] <- "Format,Generic"
	pNames <- levels(as.factor(expt$Protocol_Name))
	if (length(pNames) != 1) "problem with experiment results, more than one protocol name"
	hl[[3]] <- paste("Protocol Name",pNames[[1]], sep=",")
	eNames <- levels(as.factor(expt$Experiment_Name))
	if (length(eNames) != 1) "problem with experiment results, more than one experiment name"
	hl[[4]] <- paste("Experiment Name",eNames[[1]], sep=",")
	eSci <- levels(as.factor(expt$Experiment_Scientist))
	if (length(eSci) != 1) "problem with experiment results, more than one scientist"
	hl[[5]] <- paste("Scientist",convertScientistName(eSci[[1]]), sep=",")
	eNBooks <- levels(as.factor(expt$Expt_Notebook))
	if (length(eNBooks) != 1) "problem with experiment results, more than one notebook"
	hl[[6]] <- paste("Notebook",eNBooks[[1]], sep=",")
	ePage <- levels(as.factor(expt$Expt_Nb_Page))
	if (length(ePage) != 1) "problem with experiment results, more than one notebook page"
	hl[[7]] <- paste("Page",ePage[[1]], sep=",")
	eDate <- levels(as.factor(expt$Expt_Date))
	if (length(eDate) != 1) "problem with experiment results, more than one experiment date"
	dateParts <- strsplit(eDate, " ")
	hl[[8]] <- paste("Assay Date", dateParts[[1]][[1]], sep=",")

	project <- levels(as.factor(expt$PROJECT))
	if (length(project) != 1) "problem with experiment results, more than one project"
	project <- project[[1]]
	if (project=="General Screen") project = "UNASSIGNED"
	hl[[9]] <- paste("Project", project, sep=",")
	hl[[10]] <- ","
	hl[[11]] <- "Calculated Results,"
	return(hl)
}

padHeadColumns <- function(headLines, cols) {
	if (cols <=2) return(headLines)
	tStr = ""
	for (c in 3:cols) {
		tStr = paste(tStr,",", sep="")
	}
	for (l in 1:length(headLines)) {
		headLines[[l]] = paste(headLines[[l]], tStr, sep="")
	}
	return(headLines)
}

makeFileName <- function(expt) {
	pNames <- levels(as.factor(expt$Protocol_Name))
	if (length(pNames) != 1) "problem with experiment results, more than one protocol name"
	pName <- gsub("/","-",pNames[[1]])
	eNames <- levels(as.factor(expt$Experiment_Name))
	if (length(eNames) != 1) "problem with experiment results, more than one experiment name"
	eName <- gsub("/","-",eNames[[1]])
	dir.create(paste("coreSELFilesToLoad3/", pName, sep=""))
	return(paste("coreSELFilesToLoad3/", pName,"/", eName, ".csv", sep=""))
}

makeValueString <- function(exptRow) {
	val <- paste(ifelse(is.na(exptRow$Expt_Result_Operator), "", exptRow$Expt_Result_Operator),
		ifelse(is.na(exptRow$Expt_Result_Value),
			ifelse(is.na(exptRow$Expt_Result_Desc), "",exptRow$Expt_Result_Desc),
			exptRow$Expt_Result_Value),
		sep="")
	return(val)
}

aggregateValues <- function(vals) {
	firstVal = vals[[1]]
	allMatch = TRUE
	for (val in vals) {
		if (val!=firstVal) allMatch = FALSE
	}
	if (allMatch) return(firstVal)
	else return("COREETL_BUG_DUPLICATE_ENTRIES")
}

pivotExperiment <- function(expt) {
	expt[ ,value := makeValueString(.SD)]
	expt[ ,corp_batch_name := paste(Corporate_ID, Lot_Number, sep="::")]
	castExpt <- cast(expt, corp_batch_name + Expt_Batch_Number ~ Expt_Result_Type + Expt_Result_Units + Expt_Concentration + Expt_Conc_Units,
		add.missing=TRUE, fill="NA", fun.aggregate=aggregateValues)

	i <- sapply(castExpt, is.factor)
	castExpt[i] <- lapply(castExpt[i], as.character)
	castExpt[castExpt=="NA"] <- ""
	drops <- c("Expt_Batch_Number")
	for ( name in names(castExpt)) {
		if (all(castExpt[ ,name]=="") | all(castExpt[ ,name]=="NA") ) drops <- c(drops, name)
	}
	castExpt <- castExpt[ , !(names(castExpt) %in% drops)]
	return(castExpt)
}

getColumnHeaders <- function(castExpt) {
	headers <- c()
	dataTypes <- c()
	for (name in names(castExpt)) {
	# units and conc are split by _, but those might be in result type as well
		if (name!="corp_batch_name") {
			nameParts <- strsplit(name, "_")
			nameParts <- nameParts[[1]]
			len <- length(nameParts)
			units <- nameParts[[len-2]]
			concentration <- nameParts[[len-1]]
			concentrationUnits <- nameParts[[len]]
			if (units=="NA" | units=="") nameParts[[len-2]] = ""
			else nameParts[[len-2]] = paste(" (", units, ")", sep="" )
			if (concentration=="NA") nameParts[[len-1]] = ""
			else nameParts[[len-1]] = paste(" [", concentration, " ",concentrationUnits,"]", sep="" )
			nameParts[[len]] = ""
			headers <- c(headers, (paste(nameParts, collapse="")))
			dataTypes <- c(dataTypes, "Number")
		} else {
			headers <- c(headers, "Corporate Batch ID")
			dataTypes <- c(dataTypes, "Datatype")
		}
	}
	hLines = I(paste(dataTypes, collapse=","))
	hLines[[2]] <- paste(headers, collapse=",")
	return(hLines)
}



############################ Start of main #######################
#Sys.setenv(ACAS_HOME = '/Users/jam/Projects/runicLIMS/bitbucket/acas')
#setwd('/Users/jam/Projects/runicLIMS/bitbucket/acas')
Sys.setenv(ACAS_HOME = '~/coreetl')
setwd('~/coreetl')
library("racas")
library("data.table")
library("reshape")


protocolsToSearch = readLines("assaylist.txt")
#protocolsToSearch = I("CRO CYP DR 1A2")
for (p in 1:length(protocolsToSearch)) {
	print(paste("processing protocol:", protocolsToSearch[[p]]))
	experiments <- queryProtocol(protocolsToSearch[[p]])
	exptNames <- levels(as.factor(experiments$Experiment_Name))

	first <- TRUE
	for( exptName in exptNames) {
	#for now only do first of each to test formats
		if (TRUE) {
		#if(exptName=="EZE515") {
				expt <- data.table(experiments[experiments$Experiment_Name==exptName, ])
				headBlockLines <- getHeaderLines(expt)
				castExpt <- pivotExperiment(expt)
				columnHeaders <- getColumnHeaders(castExpt)
				headBlockLines <- padHeadColumns(headBlockLines, length(names(castExpt)))
			#TODO can I get query to return without factors so I don't have to conert here?
				print(paste(" Saving expt:",exptName,"dataRows:",length(castExpt$corp_batch_name)))
				if (length(castExpt$corp_batch_name)>0) {
					fName <- makeFileName(expt)
					outFile <- file(fName, "w")
					writeLines(headBlockLines, outFile)
					writeLines(columnHeaders, outFile)
					close(outFile)
					write.table(castExpt, file = fName, sep = ",", col.names = FALSE, row.names = FALSE, append = TRUE)
				#for (l in 1:nrow(castExpt)) {
					#	writeLines(paste(as.character(castExpt[l,]), collapse=","), outFile)
				#}
				}
			}
			first = FALSE
		}
	}


#TODO
# dont load unpublished experiments (make sure this is true)

