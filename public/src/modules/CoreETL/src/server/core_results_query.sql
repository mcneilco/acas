SELECT BATCH.CORP_BATCH_NAME               AS "Corporate_Batch_ID",
  CORE_protocol_tbl.transformed_name  AS "Protocol_Name",
  CORE_experiment_tbl.experiment_name AS "Experiment_Name",
  CORE_experiment_tbl.EXPERIMENT_SCIENTIST AS "Experiment_Scientist",
  BATCH.BATCH_NUMBER                  AS "Lot_Number",
  CORE_results_all_tbl.type           AS "Expt_Result_Type",
  CORE_results_all_tbl.operator       AS "Expt_Result_Operator",
  CORE_results_all_tbl.units          AS "Expt_Result_Units",
  CORE_results_all_tbl.num_value      AS "Expt_Result_Value",
  NULL						          AS "Expt_Result_Std_Dev",
  CORE_results_all_tbl.text_value     AS "Expt_Result_Desc",
  CORE_experiment_tbl.expt_date       AS "Expt_Date",
  CORE_results_all_tbl.comments       AS "Expt_Result_Comment",
  NULL                                          AS "Expt_Concentration",
  NULL               AS "Expt_Conc_Units",
  CORE_experiment_tbl.experiment_notebook_page AS "Expt_Nb_Page",
  CORE_experiment_tbl.experiment_notebook      AS "Expt_Notebook",
  CORE_results_all_tbl.id                      AS "Expt_Batch_Number",
  PARENT.ID                                    AS "Compound_ID",
  CORE_experiment_tbl.new_experiment_id        AS "Experiment_ID",
  BATCH.ID                                     AS "Sample_ID",
  CORE_project.name as Project,
  CORE_results_all_tbl.assay_result_id
FROM CORE_results_all_tbl,
  PARENT,
  CORE_protocol_tbl,
  CORE_experiment_tbl,
  SEURAT_CORE_CMPD_BATCH,
  BATCH,
  CORE_project
WHERE CORE_results_all_tbl.batch_id              =SEURAT_CORE_CMPD_BATCH.id
AND SEURAT_CORE_CMPD_BATCH.batchid               =BATCH.id
AND BATCH.PARENT_ID                              =PARENT.ID
AND CORE_results_all_tbl.new_experiment_id       =CORE_experiment_tbl.new_experiment_id
AND CORE_experiment_tbl.protocol_transformed_name=CORE_protocol_tbl.transformed_name
AND CORE_experiment_tbl.project_id=CORE_project.id
AND CORE_results_all_tbl.assay_result_id        IN
  (SELECT CORE_results_all_tbl.assay_result_id AS subquery_select_id
  FROM CORE_results_all_tbl,
    CORE_experiment_tbl,
    CORE_protocol_tbl
  WHERE CORE_protocol_tbl.transformed_name         = '<PROTOCOL_TO_SEARCH>'
  AND CORE_results_all_tbl.new_experiment_id       =CORE_experiment_tbl.new_experiment_id
  AND CORE_experiment_tbl.protocol_transformed_name=CORE_protocol_tbl.transformed_name
  )
