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
  acasName <- acasExperimentNames[PROTOCOL_NAME == pNames[[1]] & EXPERIMENT_NAME == eNames[[1]]]$acasName
  hl[[4]] <- paste("Experiment Name,",acasName,"CREATETHISEXPERIMENT", sep="")
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
  yFormat <- strsplit(dateParts[[1]][[1]], "-")[[1]]
  if(nchar(yFormat) == 2) {
    assayDate <- paste0("20",dateParts[[1]][[1]])
  }
  assayDate <- gsub("^00","20",dateParts[[1]][[1]])
  hl[[8]] <- paste("Assay Date", assayDate, sep=",")
  
  
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
  #expt <- experiments[experiments$Experiment_Name==exptName, ]
  expt[ ,corp_batch_name := Corporate_Batch_ID]
  #Sometimes Expt_Batch_Number is not set correctly, 
  #We can't have 2 repeats of the same Corporate Batch ID, Expt Batch Number, and Expt Result Type combination
  #So here we are finding those and seperating them
  
  #First find repeated combinations of corporate_batch_name, Expt_Batch_Number, and Expt_Result_Type
  #This code creates a marks any duplicates by creating a sequence along the combination of corporate_batch_name, Expt_Batch_Number, and Expt_Result_Type
  expt[ ,artificialExptBatchNumber := paste0(corp_batch_name,"-",Expt_Batch_Number,"-",Expt_Result_Type)]
  expt <- expt[order(artificialExptBatchNumber)]
  expt[, repeatedSequenced := sequence(rle(expt$artificialExptBatchNumber)$lengths)]
 
  #Any "artificialExptBatchNumber" with a value above 1 means that it was a repeat and cannot be matched to any other result properly
  #So for anything like this, we create a unique new (and unique) Expt_Batch_Number
  expt[, newExpt_Batch_Number := Expt_Batch_Number]
  createUniqueExptBatchNumber <- expt$artificialExptBatchNumber %in% unique(expt$artificialExptBatchNumber[expt$repeatedSequenced > 1])
  expt[ createUniqueExptBatchNumber, newExpt_Batch_Number := 1:length(createUniqueExptBatchNumber[createUniqueExptBatchNumber])]
 
  castExpt <- cast(expt, corp_batch_name + newExpt_Batch_Number ~ Expt_Result_Type + Expt_Result_Units + Expt_Concentration + Expt_Conc_Units,
                   add.missing=TRUE, fill="NA", fun.aggregate=aggregateValues)

  i <- sapply(castExpt, is.factor)
  castExpt[i] <- lapply(castExpt[i], as.character)
  castExpt[castExpt=="NA"] <- ""
  drops <- c("newExpt_Batch_Number")
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
      if (units=="NA" | units=="") {
        nameParts[[len-2]] = "()" 
      } else {
        nameParts[[len-2]] = paste(" (", units, ")", sep="" )
      }
      if (concentration=="NA") {
        nameParts[[len-1]] = ""
      } else {
        nameParts[[len-1]] = paste(" [", concentration, " ",concentrationUnits,"]", sep="" )
      }
      nameParts[[len]] = ""
      types <- paste(nameParts[-((len-2):len)], collapse="_")
      theRest <- paste(nameParts[(len-2):len], collapse = "")
      headers <- c(headers, (paste0(types, theRest, collapse="")))
      dataTypes <- c(dataTypes, lookupType(types))
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
runSeuratETL <- function(databaseSettings = seuratDatabaseSettings, protocolQuery, logName = "com.acas.dartneuroscience.etl", logFileName = "etl.log", logLevel = "INFO") {
  #databaseSettings = seuratDatabaseSettings
  #protocolQuery <- protocolNameQuery
  #logName <- "com.dartneuroscience.seurat.etl"
  #logFileName <- "seuratETL.log"
  #logLevel <- "INFO"
  #runSeuratETL(databaseSettings = seuratDatabaseSettings, protocolQuery - protocolQuery, logName = "com.dartneuroscience.seurat.etl",logFileName = "seuratETL.log", logLevel = "INFO")
  require(racas)
  require(data.table)
  require(reshape)
  require(logging)
  require(tools)
  
#   basicConfig(level = logLevel)
#   logDir <- getwd()
#   logPath <- paste0(logDir,"/",logFileName)
#   getLogger(logName)$addHandler(writeToFile, file=logPath, level = logLevel)
#   logger <- getLogger(logName)
#   setLevel(logLevel, logger)
  logger <- createLogger(logName = "com.dartneuroscience.etl.seurat", 
                          logFileName = "seuratETL.log",
                         logDir <- getwd(),
                         logLevel = "INFO")
  
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
  
  #SOmetimes Seurat "experiments" had the same name across multiple protocols
  #Here is where we track this and increment the number by 1 on each repeat of the same experiment
  # For instance,
  # "Report_050412.csv" gets uploaded once
  # It is found again in another protocol
  # "Report_050412.csv_1" is uploaded for the next protocol
  
  experimentNames <- as.data.table(query("SELECT distinct syn_phenomenon_type.name as Protocol_Name, syn_observation_protocol.version_num as Experiment_Name
        FROM syn_observation,
        syn_observation_protocol,
        syn_phenomenon_type
        where syn_observation.protocol_id                =syn_observation_protocol.id
        AND syn_observation_protocol.phenomenon_type_id=syn_phenomenon_type.id", applicationSettings = databaseSettings))
  experimentNames <- experimentNames[order(EXPERIMENT_NAME,PROTOCOL_NAME)]
  #experimentNames[repeatedSequenced > 1]
  experimentNames[, repeatedSequenced := sequence(rle(experimentNames$EXPERIMENT_NAME)$lengths)-1]
  experimentNames[, acasName := EXPERIMENT_NAME]
  experimentNames[repeatedSequenced > 0, acasName := paste0(EXPERIMENT_NAME,"_",repeatedSequenced)]
  acasExperimentNames <<- experimentNames
  
  logger$info(paste0("found ",nrow(protocolNames)," protocols to etl"))
  
  logger$info("creating SEL files for each experiment by protocol")
  
  protocolsToSearch <- protocolNames[,1]
  for(p in 1:length(protocolsToSearch)) {
    protocolName <- protocolsToSearch[[p]]
    logger$info(paste("...creating SEL files for protocol:", protocolsToSearch[[p]]))
    experiments <- queryProtocol(protocolsToSearch[[p]], applicationSettings = databaseSettings)
    dbDisconnect(conn)
    
    exptNames <- levels(as.factor(experiments$Experiment_Name))
    experiments <- as.data.table(experiments)
    columnTypes <<- list()
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
  
  logger$info("checking protocol existance and registering those not registered")

  protocolsExist <- checkExistence(protocolsToSearch, type = "protocolName")
  protocolsExist[unlist(protocolsExist)] <- NULL
  protocolsToRegister <- names(protocolsExist)
  if(length(protocolsToRegister) > 0) {
    logger$info(paste0("found, ", length(protocolsToRegister), " protocols to register"))
    registeredProtocols <- api_createProtocol(protocolsToRegister, shortDescription = "created by seurat etl", recordedBy = "bbolt")
    logger$info(paste0("registered, ", length(registeredProtocols), " protocols"))
  }
  originalWD <- getwd()
  source(paste0(Sys.getenv("ACAS_HOME"),"/public/src/modules/GenericDataParser/src/server/generic_data_parser.R"))
  fileList <- list.files(file_path_as_absolute("seuratETLFiles"), recursive=TRUE, full.names=TRUE)
  logger$info(paste0("running SEL on ",length(fileList), " files"))
  setwd(Sys.getenv("ACAS_HOME"))
  
  dryRunMode <<- "false"
  user <<- "bbolt"
  selTime <- system.time(responseList <- lapply(fileList, parseGenericDataWrapper))
  logger$info(paste0("finished running SEL on ",length(fileList), " files in ", selTime[3], " seconds "))
  
  logger$info(paste0("gathering run info"))
  
  setwd(originalWD)
  getErrorMessages <- function(errorList) {
    unlist(lapply(errorList, getElement, "message"))
  }
  messageList <- unique(unlist(lapply(responseList, function(x) getErrorMessages(x$errorMessages))))
  
  logger$info("unique error messages")
  logger$info(messageList)
  logger$info("\n============================================================================")
  
  for (response in responseList) {
    logger$info(response$results$fileToParse)
    for (errorMessage in response$errorMessage) {
      logger$info(errorMessage$errorLevel)
      logger$info(errorMessage$message)
    }
  }
  
}

runSeuratETL()