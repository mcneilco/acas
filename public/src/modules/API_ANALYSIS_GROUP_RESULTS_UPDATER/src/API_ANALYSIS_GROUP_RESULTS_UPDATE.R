#API_ANALYSIS_GROUP_RESULTS_UPDATER.R
require(racas)
require(sendmailR)

logger <- createLogger(logName = "com.dartneuroscience.acas.api_analysis_group_results_updater", logFileName = "api_analysis_group_results_updater.log")

updaterApplicationSettings <- data.frame(
  server.database.r.driver = racas::applicationSettings$server.database.r.driver,
  server.database.username = "seurat",
  server.database.password = "seurat",
  server.database.name = racas::applicationSettings$server.database.name,
  server.database.host = racas::applicationSettings$server.database.host,
  server.database.port = racas::applicationSettings$server.database.port,
  stringsAsFactors = FALSE
)


#Send mail
from <- sprintf("<API_ANALYSIS_GROUP_RESULTS_UPDATER@%s>", Sys.info()[4])

#Get DeployMode (used to determine email settings)
dnsDeployMode <- Sys.getenv("DNSDeployMode")
if(dnsDeployMode == "") {
	dnsDeployMode <- "Local"
	logger$info('DNSDeployMode was not found. Using \'Local\' settings')
}
logger$info(paste0("DNSDeployMode set to \'",dnsDeployMode,"\'"))

if(dnsDeployMode != "Prod") {
	toEmails <- c("bbolt")
} else {
	toEmails <- c("DL_INFORMATICS_SUPPORT")
}

tryCatch({
	logger$info('API_ANALYSIS_GROUP_RESULTS Updater Initiated')
	#connect and build api_analysis_group_results table
	conn <- getDatabaseConnection(applicationSettings = updaterApplicationSettings)
	error_api_analysis_group_results <- FALSE

	#drop _NEW table if exist
	newTblRemoved <- query("drop table SEURAT.API_ANALYSIS_GROUP_RESULTS_NEW", applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
	if(class(newTblRemoved) == "list") {
	  logger$error('Could not remove SEURAT.API_ANALYSIS_GROUP_RESULTS_NEW')
	  logger$error(newTblRemoved$error)
	}
	
	#create new table _NEW
	qu <- "CREATE table SEURAT.API_ANALYSIS_GROUP_RESULTS_NEW as 
								SELECT api_analysis_group_results.AG_ID,
    								api_analysis_group_results.EXPERIMENT_ID,
								    api_analysis_group_results.TESTED_LOT,
								    api_analysis_group_results.TESTED_CONC,
								    api_analysis_group_results.TESTED_CONC_UNIT,
								    api_analysis_group_results.AGV_ID,
								    api_analysis_group_results.LS_KIND,
								    api_analysis_group_results.OPERATOR_KIND,
								    api_analysis_group_results.NUMERIC_VALUE,
								    api_analysis_group_results.UNCERTAINTY,
								    api_analysis_group_results.UNIT_KIND,
								    api_analysis_group_results.STRING_VALUE,
								    api_analysis_group_results.COMMENTS,
								    api_analysis_group_results.RECORDED_DATE,
								    COALESCE(batch.id,v_api_batch_alias.batch_id) AS batch_id
								FROM acas.api_analysis_group_results
  									LEFT OUTER JOIN batch.batch
  									ON api_analysis_group_results.tested_lot=batch.corp_batch_name
  									LEFT OUTER JOIN batch.v_api_batch_alias
  									ON api_analysis_group_results.tested_lot=v_api_batch_alias.alias"
	newTblCreated <- query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
	if(class(newTblCreated) == "list") {
	  logger$error(qu)
	  logger$error(newTblCreated$error)
	  error_api_analysis_group_results <- TRUE
	} else {
	  logger$info(paste0(qu, " Successful"))
	}

	#rename existing expt_id index on old table
	qu <- " ALTER INDEX SEURAT.API_AGR_EXPT_ID_IDX1 RENAME TO API_AGR_EXPT_ID_IDX2 "
	experimentIDRenamed <- query(qu ,applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
	if(class(experimentIDRenamed) == "list") {
	  logger$error('Could not rename SEURAT.API_AGR_EXPT_ID_IDX1 to API_AGR_EXPT_ID_IDX2, creating from scratch')
	  logger$error(experimentIDRenamed$error)
	  error_api_analysis_group_results <- TRUE
	} else {
	  logger$info(paste0(qu, " Successful"))
	}
	
	qu <- " CREATE INDEX SEURAT.API_AGR_EXPT_ID_IDX1 ON SEURAT.API_ANALYSIS_GROUP_RESULTS_NEW (EXPERIMENT_ID) NOLOGGING TABLESPACE KALYPSYSADMIN_NOLOG "
	experimentIDCreated <- query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
	if(class(experimentIDCreated) == "list") {
		logger$error(qu)
	  	logger$error(experimentIDCreated$error)
	  	error_api_analysis_group_results <- TRUE
	} else {
	  logger$info(paste0(qu, " Successful"))
	}
	
	#rename existing sample_id index on old table 	
	qu <- " ALTER INDEX SEURAT.API_AGR_SAMPLE_ID_IDX1 RENAME TO API_AGR_SAMPLE_ID_IDX2 "
	sampleIDRenamed <- query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
	if(class(sampleIDRenamed) == "list") {
	  logger$error(qu)
	  logger$error(sampleIDRenamed$error)
	  error_api_analysis_group_results <- TRUE
	} else {
	  logger$info(paste0(qu, " Successful"))
	}
	
	#create new sample_id index on new table
	qu <- " CREATE INDEX SEURAT.API_AGR_SAMPLE_ID_IDX1 ON SEURAT.API_ANALYSIS_GROUP_RESULTS_NEW (TESTED_LOT) NOLOGGING TABLESPACE KALYPSYSADMIN_NOLOG "
	sampleIDCreated <- query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
	if(class(sampleIDCreated) == "list") {
	  logger$error(qu)
	  logger$error(sampleIDCreated$error)
	  error_api_analysis_group_results <- TRUE
	} else {
	  logger$info(paste0(qu, " Successful"))
	}
	
	#rename existing batch_id index on old table
	qu <- " ALTER INDEX SEURAT.API_AGR_BATCH_ID_IDX1 RENAME TO API_AGR_BATCH_ID_IDX2 "
	batchIDRenamed <- query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
	if(class(batchIDRenamed) == "list") {
	  logger$error(qu)
	  logger$error(batchIDRenamed$error)
	  error_api_analysis_group_results <- TRUE
	} else {
	  logger$info(paste0(qu, " Successful"))
	}
	
	#create new batch_id index on new table
	qu <- " CREATE INDEX SEURAT.API_AGR_BATCH_ID_IDX1 ON SEURAT.API_ANALYSIS_GROUP_RESULTS_NEW (BATCH_ID) NOLOGGING TABLESPACE KALYPSYSADMIN_NOLOG"
	batchIDCreated <- query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
	if(class(batchIDCreated) == "list") {
		logger$error(qu)
	  	logger$error(batchIDCreated$error)
	  error_api_analysis_group_results <- TRUE
	} else {
	  logger$info(paste0(qu, " Successful"))
	}

	#rename old table by adding _OLD
	qu <- " ALTER table SEURAT.API_ANALYSIS_GROUP_RESULTS RENAME TO API_ANALYSIS_GROUP_RESULTS_OLD"
	apiTableRenamedToOld <- query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
	if(class(apiTableRenamedToOld) == "list") {
		logger$error(qu)
	  	logger$error(apiTableRenamedToOld$error)
	  error_api_analysis_group_results <- TRUE
	} else {
	  logger$info(paste0(qu, " Successful"))
	}
	
	#rename new table by dropping the _NEW	
	qu <- " ALTER table SEURAT.API_ANALYSIS_GROUP_RESULTS_NEW RENAME TO API_ANALYSIS_GROUP_RESULTS"
	newTableToAPIName <- query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
	if(class(newTableToAPIName) == "list") {
	  logger$error(qu)
	  	logger$error(newTableToAPIName$error)
	  error_api_analysis_group_results <- TRUE
	} else {
	  logger$info(paste0(qu, " Successful"))
	}
	
	#drop _OLD table
	qu <- " DROP table SEURAT.API_ANALYSIS_GROUP_RESULTS_OLD"
	dropOldTable <- query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
	if(class(dropOldTable) == "list") {
		logger$error(qu)
	  	logger$error(dropOldTable$error)
	  error_api_analysis_group_results <- TRUE
	} else {
	  	logger$info(paste0(qu, " Successful"))
	}

	if(error_api_analysis_group_results) {
		rollback <- dbRollback(conn)
		logger$error("API_ANALYSIS_GROUP_RESULTS update unsuccessful, rolledback ")
		stop(paste0("API_ANALYSIS_GROUP_RESULTS update unsuccessful, rolled back\n for details see\n",logFilePath))
	} else {
		commited <- dbCommit(conn)
		logger$info("API_ANALYSIS_GROUP_RESULTS successfully updated and committed")
	}
},
error = function(ex) {
	logger$error(ex)
	if(dnsDeployMode!= "Local") {
		body <- paste("  Here is the error: ",ex$message)
		subject <- "Error performing API_ANALYSIS_GROUP_RESULTS Update"
		if(dnsDeployMode != "Prod") {
			subject <- paste0(dnsDeployMode,": ", subject)
		}
		for(t in toEmails) {
			to <- paste0("<",t,"@dartneuroscience.com>")
			tryCatch({
			  mailInfo <- sendmail(from, to, subject, body,
								   control=list(smtpServer="SMTP.DART.CORP")) 
			  if(mailInfo$code == "221") {
				logger$info(paste("  Email sent to:",t,"\n"))
			  } else {
				logger$info(mailInfo$msg)
			  }
			}, error = function(e) {
			  logger$error("caught error sending email")
			  logger$error(e$message)
			})
		}
	}
}, 
finally = {
	disconnected <- dbDisconnect(conn)
}
)

