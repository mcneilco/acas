SELECT BATCH.CORP_BATCH_NAME                  AS "Corporate_Batch_ID",
  syn_phenomenon_type.name               AS "Protocol_Name", 
  syn_observation_protocol.version_num   AS "Experiment_Name",
  syn_person.name 	 					 AS	"Experiment_Scientist",
  BATCH.BATCH_NUMBER                     AS "Lot_Number", 
  syn_observation_type.name              AS "Expt_Result_Type",
  syn_observation.obs_operator           AS "Expt_Result_Operator",
  synresultunit.label                    AS "Expt_Result_Units",
  syn_observation.quantity               AS "Expt_Result_Value",
  syn_observation.quantity_std_dev       AS "Expt_Result_Std_Dev",
  syn_observation.cat_obs_phenomenon     AS "Expt_Result_Desc",
  syn_observation.secondary_groupno_date AS "Expt_Date",
  syn_observation.comments               AS "Expt_Result_Comment",
  syn_observation.quantity_conc          AS "Expt_Concentration",
  synconcunit.label                      AS "Expt_Conc_Units",
  syn_observation.document_page          AS "Expt_Nb_Page",
  htsassaynotebook.name                  AS "Expt_Notebook",
  syn_observation.primary_groupno        AS "Expt_Batch_Number",
  PARENT.ID                              AS "Compound_ID",
  syn_observation.secondary_groupno      AS "Experiment_ID",
  BATCH.ID                               AS "Sample_ID",
  'UNASSIGNED' as Project,
  syn_observation.id
FROM syn_phenomenon_type,
  syn_document htsassaynotebook,
  syn_observation,
  BATCH,
  DNS_SYN_SAMPLE,
  PARENT,
  syn_observation_unit synconcunit,
  syn_observation_type,
  syn_observation_unit synresultunit,
  syn_observation_protocol,
  seurat_full.syn_person
WHERE DNS_SYN_SAMPLE.sample_id                 =syn_observation.observed_item_id
AND DNS_SYN_SAMPLE.batchid                     =BATCH.id
AND BATCH.PARENT_ID                            =PARENT.ID
AND syn_observation.protocol_id                =syn_observation_protocol.id
AND syn_observation_protocol.phenomenon_type_id=syn_phenomenon_type.id
AND syn_observation.quantity_conc_unit         =synconcunit.id(+)
AND syn_observation.type_id                    =syn_observation_type.id
AND syn_observation.document_id                =htsassaynotebook.id(+)
AND syn_observation.unit_id                    =synresultunit.id
AND syn_observation_protocol.person_id					= syn_person.id
AND syn_observation.id                        IN
  (SELECT syn_observation.id AS subquery_select_id
  FROM syn_observation,
    syn_observation_protocol,
    syn_phenomenon_type
  WHERE syn_phenomenon_type.name                 = '<PROTOCOL_TO_SEARCH>'
  AND syn_observation.protocol_id                =syn_observation_protocol.id
  AND syn_observation_protocol.phenomenon_type_id=syn_phenomenon_type.id
  )
