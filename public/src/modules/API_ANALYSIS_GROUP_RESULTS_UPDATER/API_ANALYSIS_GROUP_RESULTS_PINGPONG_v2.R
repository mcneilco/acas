#API_ANALYSIS_GROUP_RESULTS_UPDATER.R
require(RODBC);
require(sendmailR)
#dnsDeployMode <- Sys.getenv("DNSDeployMode")
dnsDeployMode <- "Dev"

#Send mail
from <- sprintf("<API_ANALYSIS_GROUP_RESULTS_UPDATER@%s>", Sys.info()[4])
#to <- c("Brian-McNeilCo<brian@mcneilco.com>")
to <- c()

if (dnsDeployMode == "Prod"){
	dsnMode <- "ORAPROD"
} else if (dnsDeployMode == "Test") {
	dsnMode <- "ORATEST"
} else if (dnsDeployMode == "Dev") {
	dsnMode <- "ORADEV"
} else if (dnsDeployMode == "Stage") {
	dsnMode <- "ORASTAGE"
} else if (dnsDeployMode == "Local") {
	dsnMode <- "Local"
}

tryCatch(
	{
	cat(paste(date(),"\n"))
	
	#connect and build api_analysis_group_results ping-pong table
	con <- odbcConnect(dsnMode,uid="seurat",pwd="seurat", believeNRows=FALSE, rows_at_time=1 )
	odbcSetAutoCommit(con,autoCommit=FALSE)
	error_api_analysis_group_results <- FALSE
	error_log <- c()
	
	#drop _NEW table if exist
	remove_tbl <- sqlDrop(con,"SEURAT.API_ANALYSIS_GROUP_RESULTS_NEW", errors=FALSE)
	
	#create new table _NEW
	create_tbl <- sqlQuery(con, "CREATE table SEURAT.API_ANALYSIS_GROUP_RESULTS_NEW as 
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
  									ON api_analysis_group_results.tested_lot=v_api_batch_alias.alias",errors=FALSE)	
  	
  	if(create_tbl!=-1) {
		#rename existing expt_id index on old table
 		EXPERIMENT_ID <- sqlQuery(con, " ALTER INDEX SEURAT.API_AGR_EXPT_ID_IDX1 RENAME TO API_AGR_EXPT_ID_IDX2 ",errors=FALSE)
 		if(EXPERIMENT_ID!=-1) {
 			#create new expt_id index on new table
 			EXPERIMENT_ID <- sqlQuery(con, " CREATE INDEX SEURAT.API_AGR_EXPT_ID_IDX1 ON SEURAT.API_ANALYSIS_GROUP_RESULTS_NEW (EXPERIMENT_ID) NOLOGGING TABLESPACE KALYPSYSADMIN_NOLOG ",errors=FALSE)
 			if(EXPERIMENT_ID!=-1) {
 				#rename existing sample_id index on old table
				SAMPLE_ID <- sqlQuery(con, " ALTER INDEX SEURAT.API_AGR_SAMPLE_ID_IDX1 RENAME TO API_AGR_SAMPLE_ID_IDX2 ",errors=FALSE)
				if(SAMPLE_ID!=-1) {
					#create new sample_id index on new table
					SAMPLE_ID <- sqlQuery(con, " CREATE INDEX SEURAT.API_AGR_SAMPLE_ID_IDX1 ON SEURAT.API_ANALYSIS_GROUP_RESULTS_NEW (TESTED_LOT) NOLOGGING TABLESPACE KALYPSYSADMIN_NOLOG ",errors=FALSE)
					if(SAMPLE_ID!=-1) {
						#rename existing batch_id index on old table
						BATCH_ID <- sqlQuery(con, " ALTER INDEX SEURAT.API_AGR_BATCH_ID_IDX1 RENAME TO API_AGR_BATCH_ID_IDX2 ",errors=FALSE)
						if(BATCH_ID!=-1) {
							#create new batch_id index on new table
							BATCH_ID <- sqlQuery(con, " CREATE INDEX SEURAT.API_AGR_BATCH_ID_IDX1 ON SEURAT.API_ANALYSIS_GROUP_RESULTS_NEW (BATCH_ID) NOLOGGING TABLESPACE KALYPSYSADMIN_NOLOG ",errors=FALSE)
							if(BATCH_ID!=-1) {
								#rename old table by adding _OLD
								rename_tbl <- sqlQuery(con, " ALTER table SEURAT.API_ANALYSIS_GROUP_RESULTS_PP RENAME TO API_ANALYSIS_GROUP_RESULTS_OLD",errors=FALSE)
								if(rename_tbl!=-1) {								
									#rename new table by dropping the _NEW
									rename_tbl <- sqlQuery(con, " ALTER table SEURAT.API_ANALYSIS_GROUP_RESULTS_NEW RENAME TO API_ANALYSIS_GROUP_RESULTS_PP",errors=FALSE)
									if(rename_tbl!=-1) {
										#drop _OLD table
										drop_tbl <- sqlQuery(con, " DROP table SEURAT.API_ANALYSIS_GROUP_RESULTS_OLD ",errors=FALSE)
										if(drop_tbl==-1) { 
											error_api_analysis_group_results <- TRUE
											cat("drop old table error\n")
										}
									} else {
										error_api_analysis_group_results <- TRUE
										cat("rename new table error\n")
									}
								} else {
									error_api_analysis_group_results <- TRUE
									cat("rename old table error\n")
								}
							} else {
								error_api_analysis_group_results <- TRUE
								cat("create new batch_id index error\n")
							}
						} else {
							error_api_analysis_group_results <- TRUE
							cat("rename batch_id index error\n")
						}
					} else {
						error_api_analysis_group_results <- TRUE
						cat("create new sample_id index error\n")
					}
				} else {
					error_api_analysis_group_results <- TRUE
					cat("rename old sample_id index error\n")
				}
			} else {
				error_api_analysis_group_results <- TRUE
				cat("create new expt_id index error\n")
			}
		} else {
			error_api_analysis_group_results <- TRUE
			cat("rename old expt_id index error\n")
		}
	} else {
		error_api_analysis_group_results <- TRUE
		cat("create new table error\n")
	}
	
	if(error_api_analysis_group_results) {
		odbcEndTran(con, commit = FALSE)
		cat("API_ANALYSIS_GROUP_RESULTS update unsuccessful\n")
	} else {
		odbcEndTran(con, commit = TRUE)
		cat("API_ANALYSIS_GROUP_RESULTS successfully updated\n")
	}
	odbcClose(con)
	},
	error = function(ex) {
		cat("  An error was detected.\n");
		cat(paste("  Here is the error:\n",ex))
		body <- paste("  Here is the error:\n",ex)
		subject <- "Error performing API_ANALYSIS_GROUP_RESULTS Update"
		send <- sendmail(from, to, subject, body)
		stop()
	}
)

subject <- "Successful API_ANALYSIS_GROUP_RESULTS Update"
body <- list("Updated API_ANALYSIS_GROUP_RESULTS Successfully")
for(t in to) {
	send <- sendmail(from, t, subject, body)
	cat(paste("  Email sent to:",t,"\n"))
}
cat("Finished API_ANALYSIS_GROUP_RESULTS2\n")