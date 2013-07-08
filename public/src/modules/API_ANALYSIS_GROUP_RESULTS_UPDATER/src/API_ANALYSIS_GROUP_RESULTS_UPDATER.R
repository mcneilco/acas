#API_ANALYSIS_GROUP_RESULTS_UPDATER.R
require(racas)


#dnsDeployMode <- Sys.getenv("DNSDeployMode")
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
	cat(paste(date(),"\n"))
	#connect and build api_analysis_group_results table
	conn <- getDatabaseConnection(applicationSettings = updaterApplicationSettings)
	error_api_analysis_group_results <- FALSE
	error_log <- c()
	
	removed <- dbRemoveTable(conn,"SEURAT.API_ANALYSIS_GROUP_RESULTS_ON")

	create <- query("CREATE table SEURAT.API_ANALYSIS_GROUP_RESULTS_ON as 
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
  										applicationSettings = updaterApplicationSettings,
  										globalConnect = TRUE)

	EXPERIMENT_ID <- sqlQuery(con, " CREATE INDEX SEURAT.API_AGR_EXPT_ID_IDX ON SEURAT.API_ANALYSIS_GROUP_RESULTS_ON (EXPERIMENT_ID) NOLOGGING TABLESPACE KALYPSYSADMIN_NOLOG ",errors=FALSE)		
	SAMPLE_ID <- sqlQuery(con, " CREATE INDEX SEURAT.API_AGR_SAMPLE_ID_IDX ON SEURAT.API_ANALYSIS_GROUP_RESULTS_ON (TESTED_LOT) NOLOGGING TABLESPACE KALYPSYSADMIN_NOLOG ",errors=FALSE)
	BATCH_ID <- sqlQuery(con, " CREATE INDEX SEURAT.API_AGR_BATCH_ID_IDX ON SEURAT.API_ANALYSIS_GROUP_RESULTS_ON (BATCH_ID) NOLOGGING TABLESPACE KALYPSYSADMIN_NOLOG ",errors=FALSE)
	if(create==-1) {
		error_api_analysis_group_results <- TRUE
	}

	if(error_api_analysis_group_results) {
		odbcEndTran(con, commit = FALSE)
		cat(" API_ANALYSIS_GROUP_RESULTS update unsuccessful\n")
	} else {
		odbcEndTran(con, commit = TRUE)
		cat(" API_ANALYSIS_GROUP_RESULTS successfully updated\n")
	}
	odbcClose(con)
	},
	error = function(ex) {
		cat(" An error was detected.\n");
		cat(paste(" Here is the error:\n",ex))
		body <- paste(" Here is the error:\n",ex)
		subject <- "Error performing API_ANALYSIS_GROUP_RESULTS Update"
		send <- sendmail(from, to, subject, body)
		stop()
	}
)

subject <- "Successful API_ANALYSIS_GROUP_RESULTS Update"
body <- list("Updated API_ANALYSIS_GROUP_RESULTS Successfully")
for(t in to) {
	send <- sendmail(from, t, subject, body)
	cat(paste(" Email sent to:",t,"\n"))
}
cat("Finished API_ANALYSIS_GROUP_RESULTS\n")
