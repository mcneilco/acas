seuratDatabaseSettings <- data.frame(
  db_driver = racas::applicationSettings$db_driver,
  db_user = "seurat",
  db_password = "seurat",
  db_name = racas::applicationSettings$db_name,
  db_host = racas::applicationSettings$db_host,
  db_port = racas::applicationSettings$db_port,
  stringsAsFactors = FALSE
)

protocolNameQuery <- "SELECT distinct(syn_phenomenon_type.name)
        FROM syn_observation,
        syn_observation_protocol,
        syn_phenomenon_type
        where syn_observation.protocol_id                =syn_observation_protocol.id
        AND syn_observation_protocol.phenomenon_type_id=syn_phenomenon_type.id"

queryProtocol <- function(protocolName, ...) {
  query <- paste(readLines('seurat_schema_results_query.sql'), collapse=" ")
  protQuery <- sub("<PROTOCOL_TO_SEARCH>", protocolName, query)
  return( query(protQuery, globalConnect=TRUE,...))
}
makeValueString <- function(exptRow, resultType) {
  # Sets the global list of values, the first two are just hard coded
  if (resultType == "Assay Date") type <- "Date"
  else if (resultType == "Dose") type <- "Number"
  else if (resultType == "Synopsis") type <- "Clob"
  else if (resultType == "IC50") type <- "Number"
  else if (resultType == "Observations") type <- "Text"
  else if (resultType == "Fasted") type <- "Text"
  else if (resultType == "Vehicle") type <- "Text"
  else if (all(is.na(exptRow$Expt_Result_Value))) type <- "Text"
  else type <- "Number"
  columnTypes[resultType] <<- type
  val <- paste(ifelse(is.na(exptRow$Expt_Result_Operator), "", exptRow$Expt_Result_Operator),
               ifelse(is.na(exptRow$Expt_Result_Value),
                      ifelse(is.na(exptRow$Expt_Result_Desc), "",exptRow$Expt_Result_Desc),
                      exptRow$Expt_Result_Value),
               sep="")
  return(val)
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
  hl[[4]] <- paste("Experiment Name,",eNames[[1]],"CREATETHISEXPERIMENT", sep="")
  eSci <- levels(as.factor(expt$Experiment_Scientist))
  if (length(eSci) != 1) "problem with experiment results, more than one scientist"
  hl[[5]] <- paste("Scientist",eSci[[1]], sep=",")
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
  if (project=="General Screen") project <- "UNASSIGNED"
  if (project=="General") project <- "UNASSIGNED"
  if (project=="MAOA") project <- "MAOB"
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
  dir.create(paste("seuratETLFiles/", pName, sep=""), recursive = TRUE, showWarnings=FALSE)
  return(paste("seuratETLFiles/", pName,"/", eName, ".csv", sep=""))
}

makeValueString <- function(exptRow, resultType) {
  # Sets the global list of values, the first two are just hard coded
  if (resultType == "Assay Date") type <- "Date"
  else if (resultType == "Dose") type <- "Number"
  else if (resultType == "Synopsis") type <- "Clob"
  else if (resultType == "IC50") type <- "Number"
  else if (resultType == "Observations") type <- "Text"
  else if (resultType == "Fasted") type <- "Text"
  else if (resultType == "Vehicle") type <- "Text"
  else if (all(is.na(exptRow$Expt_Result_Value))) type <- "Text"
  else type <- "Number"
  columnTypes[resultType] <<- type
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
  else return("SEURAT_BUG_DUPLICATE_ENTRIES")
}

pivotExperiment <- function(expt) {
  expt[ ,corp_batch_name := Corporate_Batch_ID]
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

lookupType <- function(colName) {
  for (type in names(columnTypes)) {
    if (regexpr(type, colName, fixed=TRUE)>-1) return(columnTypes[type])
  }
  
  return("error can't get type")
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
      if (units=="NA" | units=="") nameParts[[len-2]] = "()"
      else nameParts[[len-2]] = paste(" (", units, ")", sep="" )
      if (concentration=="NA") nameParts[[len-1]] = ""
      else nameParts[[len-1]] = paste(" [", concentration, " ",concentrationUnits,"]", sep="" )
      nameParts[[len]] = ""
      headers <- c(headers, (paste(nameParts, collapse="")))
      dataTypes <- c(dataTypes, lookupType(nameParts[[1]]))
    } else {
      headers <- c(headers, "Corporate Batch ID")
      dataTypes <- c(dataTypes, "Datatype")
    }
  }
  hLines = I(paste(dataTypes, collapse=","))
  hLines[[2]] <- paste(headers, collapse=",")
  return(hLines)
}
parseGenericDataWrapper <- function(fileName) {
  print(fileName)
  parseGenericData(c(fileToParse=fileName, dryRunMode = dryRunMode, user=user))
}
runETL <- function(databaseSettings = seuratDatabaseSettings, protocolQuery, logName = "com.acas.customer.etl", logFileName = "etl.log", logLevel = "INFO") {
  #databaseSettings = seuratDatabaseSettings
  #protocolQuery <- protocolQuery
  #logName <- "com.dartneuroscience.seurat.etl"
  #logFileName <- "seuratETL.log"
  #logLevel <- "INFO"
  #runETL(databaseSettings = seuratDatabaseSettings, protocolQuery <- protocolQuery, logName <- "com.dartneuroscience.seurat.etl",logFileName <- "seuratETL.log", logLevel = "INFO")
  require(racas)
  require(data.table)
  require(reshape)
  require(logging)
  
  logger <- createLogger(logName = logName, logFileName = logFileName, logLevel = logLevel)
  
  logger$info(paste0(applicationSettings$appName," ETL initiated"))
  
  #Turns off scientific notation in rjson
  options(scipen=99)
  options(stringsAsFactors=FALSE)
  
  logger$info("getting protocols to etl")
  protocolNames <- query("SELECT distinct(syn_phenomenon_type.name)
        FROM syn_observation,
        syn_observation_protocol,
        syn_phenomenon_type
        where syn_observation.protocol_id                =syn_observation_protocol.id
        AND syn_observation_protocol.phenomenon_type_id=syn_phenomenon_type.id", applicationSettings = databaseSettings)
  
  logger$info(paste0("found ",nrow(seuratProtocolNames)," protocols to etl"))
  
  logger$info("creating SEL files for each experiment by protocol")
  
  protocolsToSearch <- protocolNames[,1]
  for(p in 1:length(protocolNames[,1])) {
    protocolName <- protocolsToSearch[[p]]
    logger$info(paste("...creating SEL files for protocol:", protocolsToSearch[[p]]))
    experiments <- queryProtocol(protocolsToSearch[[p]], applicationSettings = databaseSettings)
    exptNames <- levels(as.factor(experiments$Experiment_Name))
    experiments <- as.data.table(experiments)
    columnTypes <- list()
    experiments[ ,value := makeValueString(.SD, Expt_Result_Type), by=Expt_Result_Type]
    experiments[Expt_Result_Type=="Assay Date" , value := as.character(as.Date(Expt_Result_Desc[Expt_Result_Type=="Assay Date"], format="%m/%d/%Y"))]
    
    first <- TRUE
    for( exptName in exptNames) {
      expt <- experiments[experiments$Experiment_Name==exptName, ]
      headBlockLines <- getHeaderLines(expt)
      castExpt <- pivotExperiment(expt)
      columnHeaders <- getColumnHeaders(castExpt)
      headBlockLines <- padHeadColumns(headBlockLines, length(names(castExpt)))
      #TODO can I get query to return without factors so I don't have to conert here?
      logger$debug(paste("Saving expt:",exptName,"dataRows:",length(castExpt$corp_batch_name)))
      logger$debug(paste("input rows:",length(expt$Expt_Batch_Number),"input variable types",length(levels(factor(expt$Expt_Result_Type)))))
      if (length(castExpt$corp_batch_name)>0) {
        fName <- makeFileName(expt)
        outFile <- file(fName, "w")
        writeLines(headBlockLines, outFile)
        writeLines(columnHeaders, outFile)
        close(outFile)
        write.table(castExpt, file = fName, sep = ",", col.names = FALSE, row.names = FALSE, append = TRUE)
      }
      #}
      #first = FALSE
    }
  }
  
  logger$info("creating SEL files for each experiment")
  
  currentProtocols <- query("select label_text from api_protocol")[[1]]
  protocolsToSearch <- readLines("assaylist.txt")
  if (!all(protocolsToSearch %in%  currentProtocols)) {
    stop("You forgot to load the protocols first.")
  }
  source(paste0(Sys.getenv("ACAS_HOME"),"/public/src/modules/GenericDataParser/src/server/generic_data_parser.R"))
  fileList <- list.files("seuratETLFiles", recursive=TRUE, full.names=TRUE)
  system.time(responseList <- lapply(fileList, parseGenericDataWrapper))
  
  getErrorMessages <- function(errorList) {
    unlist(lapply(errorList, getElement, "message"))
  }
  messageList <- unique(unlist(lapply(responseList, function(x) getErrorMessages(x$errorMessages))))
  
  logger$info("Unique error messages")
  logger$info(messageList)
  logger$info("\n============================================================================")
  
  for (response in responseList) {
    logger$info("\n", response$results$fileToParse, "\n", sep="")
    for (errorMessage in response$errorMessage) {
      logger$info("\t*", errorMessage$errorLevel, "*\n", sep="")
      logger$info("\t", errorMessage$message, "\n", sep="")
    }
  }
  
}