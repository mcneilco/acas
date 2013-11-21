## modify script to update views faster.
## will ping pong between tables. (possibly a little more brittle)
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


options(scipen=99)
currentTime <- as.numeric(format(Sys.time(), "%s"))*1000

tryCatch({
	logger$info('API_ANALYSIS_GROUP_RESULTS Updater Initiated')
	#connect and build api_analysis_group_results table
	conn <- getDatabaseConnection(applicationSettings = updaterApplicationSettings)
	error_api_analysis_group_results <- FALSE

## ping pong between table A and table B
	
	if (dbExistsTable(conn, 'API_ALL_RESULTS_A')){
		pingPongTableNew <- 'B'
		pingPongTableOld <- 'A'
		print(paste0("New ping pong table is ", pingPongTableNew))
		print(paste0("Old ping pong table is ", pingPongTableOld))
	} else {
		pingPongTableNew <- 'A'
		pingPongTableOld <- 'B'
		print(paste0("New ping pong table is ", pingPongTableNew))
		print(paste0("Old ping pong table is ", pingPongTableOld))
	}
	
	## do something if both table A and B exists -- flag as an error or choose
	if (dbExistsTable(conn, 'API_ALL_RESULTS_A') & dbExistsTable(conn, 'API_ALL_RESULTS_B')){
		  logger$error('ERROR: Ping Pong Results Table A and B are present')
	}	
	

	## results
	
	## refresh views
	qu <- " alter view seurat.api_vw_all_results compile "
	query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
	
	#drop Results _NEW table if exist
	if (dbExistsTable(conn, paste0('API_ALL_RESULTS_', pingPongTableNew))){
		newResultTblRemoved <- query(paste0("drop table SEURAT.API_ALL_RESULTS_", pingPongTableNew), applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
		if(class(newResultTblRemoved) == "list") {
		  logger$error(paste0('Could not remove SEURAT.API_ALL_RESULTS_', pingPongTableNew))
		  logger$error(newResultTblRemoved$error)
		}
	}
	
	#create new table A or B
	qu <- paste0("CREATE TABLE API_ALL_RESULTS_", pingPongTableNew,
		" TABLESPACE KALYPSYSADMIN_NOLOG NOLOGGING  
		AS SELECT * FROM API_VW_ALL_RESULTS")
	newResultTblCreated <- query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
	if(class(newResultTblCreated) == "list") {
	  logger$error(qu)
	  logger$error(newResultTblCreated$error)
	  error_api_analysis_group_results <- TRUE
	} else {
	  logger$info(paste0(qu, " Successful"))
	}

	#create new primary key index on new table
	qu <- paste0(" ALTER TABLE SEURAT.API_ALL_RESULTS_", pingPongTableNew," ADD PRIMARY KEY (RESULT_ID) USING INDEX tablespace KALYPSYSADMIN_NOLOG NOLOGGING compute statistics ")
	resultIdxCreated <- query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
	if(class(resultIdxCreated) == "list") {
	  logger$error(qu)
	  logger$error(resultIdxCreated$error)
	  error_api_analysis_group_results <- TRUE
	} else {
	  logger$info(paste0(qu, " Successful"))
	}
	
	#create new db_map index on new table
	qu <- paste0(" CREATE INDEX RESULTS_IDX1_", currentTime," ON SEURAT.API_ALL_RESULTS_", pingPongTableNew," (DB_MAP) tablespace KALYPSYSADMIN_NOLOG NOLOGGING compute statistics ")
	rsltDbMapIdxCreated <- query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
	if(class(rsltDbMapIdxCreated) == "list") {
	  logger$error(qu)
	  logger$error(rsltDbMapIdxCreated$error)
	  error_api_analysis_group_results <- TRUE
	} else {
	  logger$info(paste0(qu, " Successful"))
	}
	
	#create new db_map index on new table
	qu <- paste0(" CREATE INDEX RESULTS_IDX2_", currentTime, " ON SEURAT.API_ALL_RESULTS_", pingPongTableNew, " (EXPERIMENT_ID) tablespace KALYPSYSADMIN_NOLOG NOLOGGING compute statistics ")
	rsltExptIdxCreated <- query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
	if(class(rsltExptIdxCreated) == "list") {
	  logger$error(qu)
	  logger$error(rsltExptIdxCreated$error)
	  error_api_analysis_group_results <- TRUE
	} else {
	  logger$info(paste0(qu, " Successful"))
	}
	
	#create new db_map index on new table
	qu <- paste0(" CREATE INDEX RESULTS_IDX3_", currentTime, " ON SEURAT.API_ALL_RESULTS_", pingPongTableNew, "(BATCH_ID) tablespace KALYPSYSADMIN_NOLOG NOLOGGING compute statistics ")
	rsltBatchIdxCreated <- query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
	if(class(rsltBatchIdxCreated) == "list") {
	  logger$error(qu)
	  logger$error(rsltBatchIdxCreated$error)
	  error_api_analysis_group_results <- TRUE
	} else {
	  logger$info(paste0(qu, " Successful"))
	}
	

	## experiments
	## refresh views
	qu <- " alter view seurat.api_vw_all_experiments compile "
	query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)

	#drop Experiment _NEW table if exist
	if (dbExistsTable(conn, paste0('API_ALL_EXPERIMENTS_', pingPongTableNew))){
		newExperimentTblRemoved <- query(paste0("drop table SEURAT.API_ALL_EXPERIMENTS_", pingPongTableNew), applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
		if(class(newExperimentTblRemoved) == "list") {
		  logger$error(paste0('Could not remove SEURAT.API_ALL_EXPERIMENTS_', pingPongTableNew))
		  logger$error(newExperimentTblRemoved$error)
		}
	}

	#create new table _NEW
	qu <- paste0("CREATE TABLE API_ALL_EXPERIMENTS_", pingPongTableNew,
		" TABLESPACE KALYPSYSADMIN_NOLOG NOLOGGING   
		AS SELECT * FROM api_vw_all_experiments")
	newExperimentTblCreated <- query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
	if(class(newExperimentTblCreated) == "list") {
	  logger$error(qu)
	  logger$error(newExperimentTblCreated$error)
	  error_api_analysis_group_results <- TRUE
	} else {
	  logger$info(paste0(qu, " Successful"))
	}

	#create new db_map index on new table
	qu <- paste0(" CREATE INDEX EXPTS_IDX1_", currentTime," ON seurat.API_ALL_EXPERIMENTS_", pingPongTableNew," (DB_MAP) tablespace KALYPSYSADMIN_NOLOG NOLOGGING compute statistics ")
	rsltDbMapIdxCreated <- query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
	if(class(rsltDbMapIdxCreated) == "list") {
	  logger$error(qu)
	  logger$error(rsltDbMapIdxCreated$error)
	  error_api_analysis_group_results <- TRUE
	} else {
	  logger$info(paste0(qu, " Successful"))
	}

	#create new experiment ID index on new table
	qu <- paste0(" CREATE INDEX EXPTS_IDX2_", currentTime," ON seurat.API_ALL_EXPERIMENTS_", pingPongTableNew," (EXPERIMENT_ID) tablespace KALYPSYSADMIN_NOLOG NOLOGGING compute statistics ")
	rsltExptIdxCreated <- query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
	if(class(rsltExptIdxCreated) == "list") {
	  logger$error(qu)
	  logger$error(rsltExptIdxCreated$error)
	  error_api_analysis_group_results <- TRUE
	} else {
	  logger$info(paste0(qu, " Successful"))
	}

	#create new experiment name index on new table
	qu <- paste0(" CREATE INDEX EXPTS_IDX3_", currentTime," ON seurat.API_ALL_EXPERIMENTS_", pingPongTableNew," (EXPERIMENT_NAME) tablespace KALYPSYSADMIN_NOLOG NOLOGGING compute statistics ")
	rsltBatchIdxCreated <- query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
	if(class(rsltBatchIdxCreated) == "list") {
	  logger$error(qu)
	  logger$error(rsltBatchIdxCreated$error)
	  error_api_analysis_group_results <- TRUE
	} else {
	  logger$info(paste0(qu, " Successful"))
	}

	#create new protocol index on new table
	qu <- paste0(" CREATE INDEX EXPTS_IDX4_", currentTime," ON seurat.API_ALL_EXPERIMENTS_", pingPongTableNew," (PROTOCOL_NAME) tablespace KALYPSYSADMIN_NOLOG NOLOGGING compute statistics ")
	rsltBatchIdxCreated <- query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
	if(class(rsltBatchIdxCreated) == "list") {
	  logger$error(qu)
	  logger$error(rsltBatchIdxCreated$error)
	  error_api_analysis_group_results <- TRUE
	} else {
	  logger$info(paste0(qu, " Successful"))
	}

	## protocols
	## refresh views
	qu <- paste0(" CREATE OR REPLACE FORCE VIEW seurat.API_VW_ALL_PROTOCOLS
					as
					SELECT DISTINCT DB_MAP, PROTOCOL_NAME
					FROM api_all_experiments_", pingPongTableNew)
	query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
		
	#drop Protocol _NEW table if exist
	if (dbExistsTable(conn, paste0('API_ALL_PROTOCOLS_', pingPongTableNew))){
		newProtocolTblRemoved <- query(paste0("drop table SEURAT.API_ALL_PROTOCOLS_", pingPongTableNew), applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
		if(class(newProtocolTblRemoved) == "list") {
		  logger$error(paste0('Could not remove SEURAT.API_ALL_PROTOCOLS_', pingPongTableNew))
		  logger$error(newProtocolTblRemoved$error)
		}
	}

	#create new table _NEW
	qu <- paste0("CREATE TABLE API_ALL_PROTOCOLS_", pingPongTableNew,"
		TABLESPACE KALYPSYSADMIN_NOLOG NOLOGGING   
		AS SELECT * FROM api_vw_all_protocols")
	newProtocolTblCreated <- query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
	if(class(newProtocolTblCreated) == "list") {
	  logger$error(qu)
	  logger$error(newProtocolTblCreated$error)
	  error_api_analysis_group_results <- TRUE
	} else {
	  logger$info(paste0(qu, " Successful"))
	}

	## refresh results views
	qu <- paste0(" CREATE OR REPLACE FORCE VIEW seurat.api_vw_core_results
					as
					SELECT *
					FROM api_all_results_", pingPongTableNew,"
					WHERE DB_MAP = 'CORE' ")
	query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)

	qu <- paste0(" CREATE OR REPLACE FORCE VIEW seurat.api_vw_kb_results
					as
					SELECT *
					FROM api_all_results_", pingPongTableNew,"
					WHERE DB_MAP = 'KB' ")
	query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)

	qu <- paste0(" CREATE OR REPLACE FORCE VIEW seurat.api_vw_srt_results
					as
					SELECT *
					FROM api_all_results_", pingPongTableNew,"
					WHERE DB_MAP = 'SRT' ")
	query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)

	qu <- paste0(" CREATE OR REPLACE FORCE VIEW seurat.api_vw_acas_results
					as
					SELECT *
					FROM api_all_results_", pingPongTableNew,"
					WHERE DB_MAP = 'ACAS' ")
	query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)

		
	## refresh experiment views
	qu <- paste0(" CREATE OR REPLACE FORCE VIEW seurat.api_vw_core_experiments
					as
					SELECT exp.*, exp.experiment_id as id, 'NONE' as comments
					FROM api_all_experiments_", pingPongTableNew," exp
					WHERE DB_MAP = 'CORE' ")
	query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)

	qu <- paste0(" CREATE OR REPLACE FORCE VIEW seurat.api_vw_kb_experiments
					as
					SELECT *
					FROM api_all_experiments_", pingPongTableNew,"
					WHERE DB_MAP = 'KB' ")
	query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)

	qu <- paste0(" CREATE OR REPLACE FORCE VIEW seurat.api_vw_srt_experiments
					as
					SELECT *
					FROM api_all_experiments_", pingPongTableNew,"
					WHERE DB_MAP = 'SRT' ")
	query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
	
	qu <- paste0(" CREATE OR REPLACE FORCE VIEW seurat.api_vw_acas_experiments
					as
					SELECT *
					FROM api_all_experiments_", pingPongTableNew,"
					WHERE DB_MAP = 'ACAS' ")
	query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
	
	## refresh protocol views
	qu <- paste0(" CREATE OR REPLACE FORCE VIEW seurat.api_vw_core_protocols
					as
					SELECT DB_MAP, PROTOCOL_NAME
					FROM api_all_protocols_", pingPongTableNew,"
					WHERE DB_MAP = 'CORE' ")
	query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)

	qu <- paste0(" CREATE OR REPLACE FORCE VIEW seurat.api_vw_kb_protocols
					as
					SELECT DB_MAP, PROTOCOL_NAME
					FROM api_all_protocols_", pingPongTableNew,"
					WHERE DB_MAP = 'KB' ")
	query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)

	qu <- paste0(" CREATE OR REPLACE FORCE VIEW seurat.api_vw_srt_protocols
					as
					SELECT DB_MAP, PROTOCOL_NAME
					FROM api_all_protocols_", pingPongTableNew,"
					WHERE DB_MAP = 'SRT' ")
	query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)

	qu <- paste0(" CREATE OR REPLACE FORCE VIEW seurat.api_vw_acas_protocols
					as
					SELECT DB_MAP, PROTOCOL_NAME
					FROM api_all_protocols_", pingPongTableNew,"
					WHERE DB_MAP = 'ACAS' ")
	query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)

	#drop Results _OLD table
	if (dbExistsTable(conn, paste0('API_ALL_RESULTS_', pingPongTableOld))){
		qu <- paste0(" DROP table SEURAT.API_ALL_RESULTS_", pingPongTableOld)
		dropOldResultsTable <- query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
		if(class(dropOldResultsTable) == "list") {
			logger$error(qu)
			logger$error(paste0('Could not remove SEURAT.API_ALL_RESULTS_', pingPongTableOld))
		  	logger$error(dropOldResultsTable$error)
		    error_api_analysis_group_results <- TRUE
		} else {
		  	logger$info(paste0(qu, " Successful"))
		}
	}
	
	#drop Experiment _OLD table
	if (dbExistsTable(conn, paste0('API_ALL_EXPERIMENTS_', pingPongTableOld))){
		qu <- paste0(" DROP table SEURAT.API_ALL_EXPERIMENTS_", pingPongTableOld)
		dropOldExperimentTable <- query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
		if(class(dropOldExperimentTable) == "list") {
			logger$error(qu)
			logger$error(paste0('Could not remove SEURAT.API_ALL_EXPERIMENTS_', pingPongTableOld))
			logger$error(dropOldExperimentTable$error)
			error_api_analysis_group_results <- TRUE
		} else {
		  	logger$info(paste0(qu, " Successful"))
		}
	}

	#drop Protocol _OLD table
	if (dbExistsTable(conn, paste0('API_ALL_PROTOCOLS_', pingPongTableOld))){
		qu <- paste0(" DROP table SEURAT.API_ALL_PROTOCOLS_", pingPongTableOld)
		dropOldProtocolTable <- query(qu, applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
		if(class(dropOldProtocolTable) == "list") {
			logger$error(qu)
			logger$error(paste0('Could not remove SEURAT.API_ALL_PROTOCOLS_', pingPongTableOld))
			logger$error(dropOldProtocolTable$error)
			error_api_analysis_group_results <- TRUE
		} else {
		  	logger$info(paste0(qu, " Successful"))
		}	
	}

#############

	if(error_api_analysis_group_results) {
		rollback <- dbRollback(conn)
		logger$error("API_ANALYSIS_GROUP_RESULTS update unsuccessful, rolledback ")
		stop(paste0("API_ANALYSIS_GROUP_RESULTS update unsuccessful, rolled back\n for details see\napi_analysis_group_results_updater.log"))
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

logger$info("Finished API_ANALYSIS_GROUP_RESULTS Successfully")


