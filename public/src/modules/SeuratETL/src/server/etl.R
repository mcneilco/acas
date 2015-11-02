# Configs for seurat ETL to ACAS Schema
# Example:
#   server.database.seurat.etl.rawData=false
#   server.database.seurat.r.driver=${server.database.r.driver}
#   server.database.seurat.r.package=${server.database.r.package}
#   server.database.seurat.host=${server.database.host}
#   server.database.seurat.port=${server.database.port}
#   server.database.seurat.name=${server.database.name}
#   server.database.seurat.username=seurat
#   server.database.seurat.password=seurat


getSeuratResultsForProtocol <- function(replacementName, replaceString, ...) {
  if(replaceString == "<PROTOCOL_TO_SEARCH>") {
    qu <- paste(readLines('seurat_schema_results_query.sql'), collapse=" ")
  }
  protQuery <- sub(replaceString, replacementName, qu)
  return( query(protQuery, ...))
}
getACASResultsForProtocol <- function(replacementName, replaceString, ...) {
  if(replaceString == "<PROTOCOL_TO_SEARCH>") {
    qu <- paste(readLines('acas_schema_results_query.sql'), collapse=" ")
  }
  protQuery <- sub(replaceString, replacementName, qu)
  return( query(protQuery, ...))
}

seuratDatabaseSettings <- data.frame(
  server.database.r.driver = racas::applicationSettings$server.database.seurat.r.driver,
  server.database.host = racas::applicationSettings$server.database.seurat.host,
  server.database.port = racas::applicationSettings$server.database.seurat.port,
  server.database.name = racas::applicationSettings$server.database.seurat.name,
  server.database.username = racas::applicationSettings$server.database.seurat.username,
  server.database.password = racas::applicationSettings$server.database.seurat.password,
  stringsAsFactors = FALSE
)

getSeuratRawData <- function(experiments) {
  qu <- paste(readLines('seurat_schema_get_raw_results.sql'), collapse=" ")
  rawData <- query_replace_string_with_values(qu, string = "OBSERVATIONIDS", values = experiments$Syn.Observation.Id, applicationSettings=seuratDatabaseSettings)
  rawData <- rbindlist(rawData)
  return(rawData)
}
getACASRawData <- function(experiments) {
  qu <- paste(readLines('acas_schema_get_raw_results.sql'), collapse=" ")
  rawData <- query_replace_string_with_values(qu, string = "CURVEIDS", values = experiments$Syn.Observation.Id, applicationSettings=seuratDatabaseSettings)
  rawData <- rbindlist(rawData)
  return(rawData)
}
addRawData <- function(experiments) {
  #   if(racas::applicationSettings$server.database.seurat.etl.rawData) {
  rawData <- getSeuratRawData(experiments)
  if(nrow(rawData)==0) {
    experimentsOut <- experiments
  } else {
    rawData[result_flag==0, result_flag := NA]
    setkey(rawData, observation_id)
    rawData[ , repeated := sequence(rle(observation_id)$lengths)-1]
    concs <- dcast.data.table(rawData, observation_id+result_type~repeated, value.var = "conc")
    setnames(concs, c("observation_id", "MP.Result.Type", paste0("MP.Conc.",names(concs)[3:ncol(concs)])))
    results <- dcast.data.table(rawData, observation_id+result_type~repeated, value.var = "result")
    setnames(results, c("observation_id", "MP.Result.Type", paste0("MP.Result.",names(results)[3:ncol(results)])))
    stddevs <- dcast.data.table(rawData, observation_id+result_type~repeated, value.var = "result_stddev")
    setnames(stddevs, c("observation_id", "MP.Result.Type", paste0("MP.StdDev.",names(stddevs)[3:ncol(stddevs)])))
    flags <- dcast.data.table(rawData, observation_id+result_type~repeated, value.var = "result_flag")
    setnames(flags, c("observation_id", "MP.Result.Type", paste0("MP.Flag.",names(flags)[3:ncol(flags)])))
    rawDataPivoted <- concs[results][stddevs][flags]
    setkey(experiments, "Syn.Observation.Id")
    setkey(rawDataPivoted, "observation_id")
    experimentsOut <- rawDataPivoted[experiments]
  }
  return(experimentsOut)
}
get_seurat_protocol_names <- function(seuratDatabaseSettings) {
  protocolNames <- query("SELECT distinct(syn_phenomenon_type.name)
                         FROM public.syn_observation,
                         public.syn_observation_protocol,
                         public.syn_phenomenon_type
                         where syn_observation.protocol_id                =syn_observation_protocol.id
                         AND syn_observation_protocol.phenomenon_type_id=syn_phenomenon_type.id
                         ", applicationSettings = seuratDatabaseSettings)
}
get_seurat_experiment_names <- function(seuratDatabaseSettings) {
  experimentNames <- as.data.table(query("SELECT distinct syn_phenomenon_type.name as Protocol_Name, syn_observation_protocol.version_num as Experiment_Name, syn_file.file_name as File_Name
                                         FROM public.syn_observation,
                                         public.syn_observation_protocol,
                                         public.syn_phenomenon_type,
                                         public.syn_file
                                         where syn_observation.protocol_id                =syn_observation_protocol.id
                                         AND syn_observation_protocol.phenomenon_type_id=syn_phenomenon_type.id
                                         AND syn_file.file_id=syn_observation_protocol.file_id
                                         ", applicationSettings = seuratDatabaseSettings))
}
runSeuratExportToSELFiles <- function() {
  source("parse.R", local = TRUE)
  require(racas)
  require(data.table)
  require(reshape)
  require(logging)
  
  logger <- createLogger(logName = "com.acas.etl.seurat", logToConsole = TRUE)
  logger$info(paste0(applicationSettings$appName," ETL initiated"))
  
  #Turns off scientific notation in rjson
  options(scipen=99)
  options(stringsAsFactors=FALSE)
  
  logger$info("getting protocols to etl")
  protocolNames <- get_seurat_protocol_names(seuratDatabaseSettings)
  
  experimentNames <- get_seurat_experiment_names(seuratDatabaseSettings)
  setnames(experimentNames, c("Assay.Name", "Assay.Protocol", "File.Name"))
  experimentNames[ , Assay.Protocol.Original := Assay.Protocol]
  experimentNames <- makeExperimentNamesUnique(experimentNames, by = c("Assay.Name", "File.Name"))
  
  logger$info(paste0("found ",nrow(protocolNames)," protocols to etl"))
  logger$info("creating SEL files for each experiment by protocol")
  
  protocolsToSearch <- protocolNames[,1]
  
  etlFolder <- "ETLFiles"
  unlink(etlFolder, recursive = TRUE)
  dir.create(etlFolder, showWarnings = FALSE)
  for(p in 1:length(protocolsToSearch)) {
    protocolName <- protocolsToSearch[[p]]
    protocolFolder <- file.path(etlFolder, protocolName)
    dir.create(protocolFolder, showWarnings = FALSE)
    logger$info(paste("...creating SEL files for protocol:", protocolName))
    experiments <- getSeuratResultsForProtocol(replacementName=protocolName, replaceString="<PROTOCOL_TO_SEARCH>", applicationSettings = seuratDatabaseSettings)
    names(experiments) <- c("Corporate.ID", "Assay.Name", "Assay.Protocol", "Experiment.Scientist", "Lot.Number", "Expt.Result.Type", "Expt.Result.Operator", "Expt.Result.Units",
                            "Expt.Result.Value", "Expt.Result.Std.Dev", "Expt.Result.Desc", "Expt.Date", "Expt.Result.Comment", "Expt.Concentration", "Expt.Conc.Units", "Expt.Nb.Page",
                            "Expt.Notebook", "Expt.Batch.Number", "Syn.Observation.Id")
    experiments <- as.data.table(experiments)
    setkey(experiments, "Assay.Name", "Assay.Protocol")
    setkey(experimentNames, "Assay.Name", "Assay.Protocol.Original")
    experiments <- experimentNames[experiments]
    experiments[ , c("value", "type") := makeValueString(.SD, Expt.Result.Type), by=Expt.Result.Type]
    experiments <- addRawData(experiments)
    selContent <- experiments[ , {
      logger$info(paste("......converting to SEL content for experiment:", unique(Assay.Protocol)))
      convertSeuratTableToSELContent(.SD)
    }, by = c("Assay.Protocol", "Assay.Name"), .SDcols = 1:ncol(experiments)]
    setnames(selContent, c("experimentName", "protocolName", "selContent"))
    selContent[ , {
      logger$info(paste("......writing SEL file for experiment:", experimentName))
      writeLines(selContent, con = file.path(protocolFolder,paste0(experimentName,".csv")))
    }, by = c("protocolName","experimentName")]
  }
}


bulkLoadSelFolder <- function(foldersLocation, dryRunMode, user = "unassigned") {
  library(racas)
  myLogger <- logger(racas = FALSE, logToConsole=TRUE, logFileName = "seuratETL.log", logName = "com.mcneilco.acas.etl.seurat")
  myLogger$info("bulk load sel folder initialized")
  #foldersLocation <- "ETLFiles"
  originalWD <- getwd()
  on.exit(setwd(originalWD))
  folderFullPath <- normalizePath(foldersLocation)
  setwd(racas::applicationSettings$appHome)
  source(file.path(racas::applicationSettings$appHome,"public/src/modules/GenericDataParser/src/server/generic_data_parser.R"))
  fileList <- list.files(folderFullPath, recursive=TRUE, full.names=TRUE)
  
  parseGenericDataWrapper <- function(fileFullPath) {
    myLogger$info(paste0("attempting ",ifelse(as.logical(dryRunMode), "dry run ", "real run "), "of sel on ", fileFullPath))
    newFileName <- file.path("privateUploads",basename(fileFullPath))
    file.copy(fileFullPath, newFileName, overwrite = TRUE)
    parseGenericData(c(fileToParse=basename(fileFullPath), dryRunMode = tolower(as.character(dryRunMode)), user= user))
  }
  system.time(responseList <- lapply(fileList, parseGenericDataWrapper))
  
  getErrorMessages <- function(errorList) {
    unlist(lapply(errorList, getElement, "message"))
  }
  messageList <- unique(unlist(lapply(responseList, function(x) getErrorMessages(x$errorMessages))))
  myLogger$error("Unique error messages")
  myLogger$error(messageList)
  
  myLogger$error("Error messages for each file")
  errorFiles = 0
  for (response in responseList) {
    myLogger$info(response$results$fileToParse)
    hasError = FALSE
    for (errorMessage in response$errorMessage) {
      switch(errorMessage$errorLevel,
             "error" = {myLogger$error(errorMessage$message); hasError = TRUE},
             "warn" = myLogger$warn(errorMessage$message)
      )
    }
    if (hasError) {
      errorFiles = errorFiles + 1
    }
  }
  
  myLogger$info(paste0("Files Attempted: ", length(fileList)))
  myLogger$info(paste0("Files Success: ", length(fileList)-errorFiles))
  myLogger$info(paste0("Files Failure: ", errorFiles))
  
  myLogger$info("Finished bulk load of folder")
}

verifySeuratETLResults <- function(ignoredLSKinds = c('curve id', 'Rendering Hint')) {
  library(testthat)
  library(racas)
  library(data.table)
  source("parse.R")
  logger <- createLogger(logName = "com.acas.etl.seurat", logToConsole = TRUE)
  logger$info(paste0(applicationSettings$appName," seurat etl verification initiated"))
  logger$info("verifying syn_sample and syn_compound_lot integrity")
  
  missingCompoundLots <- query("select syn_sample.sample_id from syn_sample left outer join syn_compound_lot on syn_sample.sample_id=syn_compound_lot.sample_id where syn_compound_lot.sample_id is null",
        applicationSettings=seuratDatabaseSettings)[,1]
  if(length(missingCompoundLots) > 0) {
    logger$error(paste0("some syn_sample ids missing from syn_compound_lot, this may cause some observatons and raw data to not etl (missing sample ids from syn_compound_lot: ",sqliz(missingCompoundLots),")"))
  }
  
  logger$info("getting protocols to validate")
  protocolNames <- get_seurat_protocol_names(seuratDatabaseSettings)$name
  
  experimentNames <- get_seurat_experiment_names(seuratDatabaseSettings)
  setnames(experimentNames, c("Assay.Name", "Assay.Protocol", "File.Name"))
  experimentNames[ , Assay.Protocol.Original := Assay.Protocol]
  experimentNames <- makeExperimentNamesUnique(experimentNames, by = c( "Assay.Name", "File.Name"))
  
  allPassedProtocols <- c()
  allFailedProtocols <- c()
  allPassedExperiments <- c()
  allFailedExperiments <- c()
  for(p in 1:length(protocolNames)) {
    protocolName <- protocolNames[[p]]
    logger$info(paste0("BEGIN validation for protocol '",protocolName, "'"))
    
    logger$info(paste0("...validating calculated results"))
    experimentsSeurat <- as.data.table(getSeuratResultsForProtocol(replacementName=protocolName, replaceString="<PROTOCOL_TO_SEARCH>", applicationSettings = seuratDatabaseSettings))
    setkey(experimentsSeurat, "Protocol_Name", "Experiment_Name")
    setnames(experimentNames, c("Protocol_Name", "Experiment_Name", "File_Name","Experiment_Name_Original"))
    setkey(experimentNames, "Protocol_Name", "Experiment_Name_Original")
    experimentsSeurat <- experimentNames[experimentsSeurat]
    experimentsACAS <- as.data.table(getACASResultsForProtocol(replacementName=protocolName, replaceString="<PROTOCOL_TO_SEARCH>",  applicationSettings = seuratDatabaseSettings))
    
    tests <- list(experiment = "Experiment_Name",
                  resultType = c("Experiment_Name", "Expt_Result_Type"))
    if(nrow(experimentsACAS) > 0) {
      calculatedResultsACAS <- experimentsACAS[!Expt_Result_Type %in% ignoredLSKinds]
    } else {
      calculatedResultsACAS <- experimentsACAS
    }
    testResults <- lapply(tests, test, experimentsSeurat = experimentsSeurat,  experimentsACAS = calculatedResultsACAS, logger = logger)
    failedExperiments <- unique(unlist(lapply(testResults, function(x) x$notMatched)))
    passedExperiments <- unique(unlist(lapply(testResults, function(x) x$matched)))
    passedExperiments <- passedExperiments[ !passedExperiments %in% failedExperiments]
    
    #Raw data validation
    logger$info(paste0("...validating raw results"))
    setnames(experimentsSeurat, "OBSERVATION_ID", "Syn.Observation.Id")
    seuratRawData <- getSeuratRawData(experimentsSeurat)
    
    if(nrow(seuratRawData) > 0 && nrow(experimentsACAS) > 0) {
      setnames(experimentsACAS, "OBSERVATION_ID", "Syn.Observation.Id")
      
      acasCurveData <- experimentsACAS[Expt_Result_Type == 'curve id']
      acasRawData <- getACASRawData(acasCurveData)
      
      setkey(experimentsSeurat, "Syn.Observation.Id")
      setkey(seuratRawData,  "observation_id")
      
      setkey(acasCurveData, "Syn.Observation.Id")
      setkey(acasRawData,  "observation_id")
      
      acasRawData <- acasCurveData[acasRawData]
      seuratRawData <- experimentsSeurat[seuratRawData]
      
      tests <- list(experiment = "Experiment_Name")
      testResults <- lapply(tests, test, experimentsSeurat = seuratRawData,  experimentsACAS = acasRawData, logger = logger)
      failedExperiments <- unique(c(failedExperiments, unlist(lapply(testResults, function(x) x$notMatched))))
      passedExperiments <- unique(c(passedExperiments, unlist(lapply(testResults, function(x) x$matched))))
      passedExperiments <- passedExperiments[ !passedExperiments %in% failedExperiments]
    }

    # Compiling all results
    allPassedExperiments <- c(allPassedExperiments, passedExperiments)
    allFailedExperiments <- c(allFailedExperiments, failedExperiments)
    if(length(failedExperiments) == 0) {
      allPassedProtocols <- c(allPassedProtocols, protocolName)
      logger$info(paste0("END validation PASSED for protocol '",protocolName, "' and all experiments",paste0(" '",passedExperiments, "'", collapse = ",")))
    } else {
      allFailedProtocols <- c(allFailedProtocols, protocolName)
      logger$info(paste0("END validation FAILED for protocol '",protocolName, "' and experiments",paste0(" '",failedExperiments, "'", collapse = ","), ifelse(length(passedExperiments) > 0, paste0(" (validation PASSED for experiments",paste0(" '",passedExperiments, "'", collapse = ","),")"), "")))
    }
  }
  logger$info("Validation summary:")
  logger$info(paste0("   PASSED Protocols (", length(allPassedProtocols),"):",paste0(" '",allPassedProtocols, "'", collapse = ",")))
  logger$info(paste0("   FAILED Protocols (", length(allFailedProtocols),"):",paste0(" '",allFailedProtocols, "'", collapse = ",")))
  logger$info(paste0("   PASSED Experiments (", length(allPassedExperiments),"):", paste0(" '",allPassedExperiments, "'", collapse = ",")))
  logger$info(paste0("   FAILED Experiments (", length(allFailedExperiments),"):", paste0(" '",allFailedExperiments, "'", collapse = ",")))
}

test <- function(test, experimentsSeurat, experimentsACAS, logger = logger) {
  countSeurat <- experimentsSeurat[ , .N, by = test]
  setnames(countSeurat, "N", "seuratCount")
  
  if(nrow(experimentsACAS) == 0) {
    logger$error(paste0("...0 results in acas by ",paste0(test, collapse = " and ")))
    notMatched <- countSeurat$Experiment_Name
    matched <- c()
  } else {
    countACAS <- experimentsACAS[ , .N, by = test]
    setnames(countACAS, "N", "acasCount")
    setkeyv(countSeurat, test)
    setkeyv(countACAS, test)
    counts <- countACAS[countSeurat]
    counts[is.na(acasCount), acasCount := 0]
    matched <- counts[seuratCount == acasCount]$Experiment_Name
    notMatched <- counts[seuratCount != acasCount]$Experiment_Name
    if(length(notMatched) > 0) {
      counts[seuratCount != acasCount, {
        logger$error(paste0("...counts by ",paste0(test, collapse = " and ")," do not match"))
        names <- as.data.frame(lapply(test, function(x) paste0(x, ":'",.SD[[x]],"'")), stringsAsFactors = FALSE)
        if(ncol(names) > 1) {
          names <- apply( names[ , 1:ncol(names) ] , 1, paste , collapse = "-" )
        } else {
          names <- names[,1]
        }
        logger$error(paste0("...",names, " Seurat Count: ", .SD$seuratCount, " ACAS Count: ",.SD$acasCount))
      }, .SDcols = 1:length(counts)]
    }
  }
  list(matched = matched, notMatched = notMatched)
}
