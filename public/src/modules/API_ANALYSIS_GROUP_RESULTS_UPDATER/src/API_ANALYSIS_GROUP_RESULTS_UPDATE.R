#API_ANALYSIS_GROUP_RESULTS_UPDATER.R
require(racas)
require(logging)
logReset()
basicConfig(level='FINEST')
logName <- "com.dartneuroscience.acas.api_analysis_group_results_updater"
getLogger(logName)$addHandler(writeToFile, file="../../../../../../api_analysis_group_results_updater.log")
logger <- getLogger(logName)
logger$info('API_ANALYSIS_GROUP_RESULTS Updater Initiated')
  
updaterApplicationSettings <- data.frame(
  db_driver = racas::applicationSettings$db_driver,
  db_user = "seurat",
  db_password = "seurat",
  db_name = racas::applicationSettings$db_name,
  db_host = racas::applicationSettings$db_host,
  db_port = racas::applicationSettings$db_port,
  stringsAsFactors = FALSE
)

#Send mail
from <- sprintf("<API_ANALYSIS_GROUP_RESULTS_UPDATER@%s>", Sys.info()[4])
#to <- c("Brian-McNeilCo<brian@mcneilco.com>")
to <- c()

tryCatch(
	{
	#connect and build api_analysis_group_results table
	conn <- getDatabaseConnection(applicationSettings = updaterApplicationSettings)
	error_api_analysis_group_results <- FALSE
	error_log <- c()

	#drop _NEW table if exist
	remove_tbl <- query("drop table SEURAT.API_ANALYSIS_GROUP_RESULTS_NEW", applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
	#create new table _NEW
	create_tbl <- query("CREATE table SEURAT.API_ANALYSIS_GROUP_RESULTS_NEW as 
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
  									ON api_analysis_group_results.tested_lot=v_api_batch_alias.alias",
  									applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
  	
  	if(create_tbl) {
  		logger$info('API_ANALYSIS_GROUP_RESULTS_NEW Created')
		#rename existing expt_id index on old table
 		EXPERIMENT_ID <- query(" ALTER INDEX SEURAT.API_AGR_EXPT_ID_IDX1 RENAME TO API_AGR_EXPT_ID_IDX2 ",applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
 		if(EXPERIMENT_ID) {
 			#create new expt_id index on new table
 			EXPERIMENT_ID <- query(" CREATE INDEX SEURAT.API_AGR_EXPT_ID_IDX1 ON SEURAT.API_ANALYSIS_GROUP_RESULTS_NEW (EXPERIMENT_ID) NOLOGGING TABLESPACE KALYPSYSADMIN_NOLOG ", applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
 			if(EXPERIMENT_ID) {
 				#rename existing sample_id index on old table
				SAMPLE_ID <- query(" ALTER INDEX SEURAT.API_AGR_SAMPLE_ID_IDX1 RENAME TO API_AGR_SAMPLE_ID_IDX2 ", applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
				if(SAMPLE_ID) {
					#create new sample_id index on new table
					SAMPLE_ID <- query(" CREATE INDEX SEURAT.API_AGR_SAMPLE_ID_IDX1 ON SEURAT.API_ANALYSIS_GROUP_RESULTS_NEW (TESTED_LOT) NOLOGGING TABLESPACE KALYPSYSADMIN_NOLOG ", applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
					if(SAMPLE_ID) {
						#rename existing batch_id index on old table
						BATCH_ID <- query(" ALTER INDEX SEURAT.API_AGR_BATCH_ID_IDX1 RENAME TO API_AGR_BATCH_ID_IDX2 ", applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
						if(BATCH_ID) {
							#create new batch_id index on new table
							BATCH_ID <- query(" CREATE INDEX SEURAT.API_AGR_BATCH_ID_IDX1 ON SEURAT.API_ANALYSIS_GROUP_RESULTS_NEW (BATCH_ID) NOLOGGING TABLESPACE KALYPSYSADMIN_NOLOG ", applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
							if(BATCH_ID) {
								logger$info('API_ANALYSIS_GROUP_RESULTS_NEW Indexes created')
								#rename old table by adding _OLD
								rename_tbl <- query(" ALTER table SEURAT.API_ANALYSIS_GROUP_RESULTS RENAME TO API_ANALYSIS_GROUP_RESULTS_OLD", applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
								if(rename_tbl) {				
									logger$info('API_ANALYSIS_GROUP_RESULTS Renamed to API_ANALYSIS_GROUP_RESULTS_OLD')
									#rename new table by dropping the _NEW
									rename_tbl <- query(" ALTER table SEURAT.API_ANALYSIS_GROUP_RESULTS_NEW RENAME TO API_ANALYSIS_GROUP_RESULTS", applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
									if(rename_tbl) {
										logger$info('API_ANALYSIS_GROUP_RESULTS_NEW Renamed to API_ANALYSIS_GROUP_RESULTS')
										#drop _OLD table
										drop_tbl <- query(" DROP table SEURAT.API_ANALYSIS_GROUP_RESULTS_OLD ", applicationSettings = updaterApplicationSettings, globalConnect = TRUE)
										if(!drop_tbl) {
											error_api_analysis_group_results <- TRUE
											cat("drop old table error\n")
										} else {
											logger$info('Dropped API_ANALYSIS_GROUP_RESULTS_OLD')
										}
									} else {
										error_api_analysis_group_results <- TRUE
										logger$error("rename new table error\n")
									}
								} else {
									error_api_analysis_group_results <- TRUE
									logger$error("rename old table error\n")
								}
							} else {
								error_api_analysis_group_results <- TRUE
								logger$error("create new batch_id index error\n")
							}
						} else {
							error_api_analysis_group_results <- TRUE
							logger$error("rename batch_id index error\n")
						}
					} else {
						error_api_analysis_group_results <- TRUE
						logger$error("create new sample_id index error\n")
					}
				} else {
					error_api_analysis_group_results <- TRUE
					logger$error("rename old sample_id index error\n")
				}
			} else {
				error_api_analysis_group_results <- TRUE
				logger$error("create new expt_id index error\n")
			}
		} else {
			error_api_analysis_group_results <- TRUE
			logger$error("rename old expt_id index error\n")
		}
	} else {
		error_api_analysis_group_results <- TRUE
		logger$error("create new table error\n")
	}
	
	if(error_api_analysis_group_results) {
		rollback <- dbRollback(conn)
		logger$error("API_ANALYSIS_GROUP_RESULTS update unsuccessful\n")
	} else {
		commited <- dbCommit(conn)
		logger$error("API_ANALYSIS_GROUP_RESULTS successfully updated\n")
	}
	disconnected <- dbDisconnect(conn)
	},
	error = function(ex) {
		logger$error("  An error was detected.\n");
		logger$error(paste("  Here is the error:\n",ex))
		body <- paste("  Here is the error:\n",ex)
		subject <- "Error performing API_ANALYSIS_GROUP_RESULTS Update"
		send <- sendmail(from, to, subject, body)
	}
)

subject <- "Successful API_ANALYSIS_GROUP_RESULTS Update"
body <- list("Updated API_ANALYSIS_GROUP_RESULTS Successfully")
for(t in to) {
	send <- sendmail(from, t, subject, body)
	cat(paste("  Email sent to:",t,"\n"))
}
logger$info("Finished API_ANALYSIS_GROUP_RESULTS\n")