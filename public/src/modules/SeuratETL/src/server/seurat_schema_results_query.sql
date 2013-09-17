SELECT PARENT.CORP_NAME                  AS "Corporate ID",
  syn_phenomenon_type.name               AS "Assay Name", 
  syn_observation_protocol.version_num   AS "Assay Protocol",
  BATCH.BATCH_NUMBER                     AS "Lot Number", 
  syn_observation_type.name              AS "Expt Result Type",
  syn_observation.obs_operator           AS "Expt Result Operator",
  synresultunit.label                    AS "Expt Result Units",
  syn_observation.quantity               AS "Expt Result Value", 
  syn_observation.quantity_std_dev       AS "Expt Result Std Dev",
  syn_observation.cat_obs_phenomenon     AS "Expt Result Desc",
  syn_observation.secondary_groupno_date AS "Expt Date",
  syn_observation.comments               AS "Expt Result Comment",
  syn_observation.quantity_conc          AS "Expt Concentration",
  synconcunit.label                      AS "Expt Conc Units",
  syn_observation.document_page          AS "Expt Nb Page",
  htsassaynotebook.name                  AS "Expt Notebook",
  syn_observation.primary_groupno        AS "Expt Batch Number",
  PARENT.ID                              AS "Compound ID",
  syn_observation.secondary_groupno      AS "Experiment ID",
  BATCH.ID                               AS "Sample ID",
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
  syn_observation_protocol
WHERE DNS_SYN_SAMPLE.sample_id                 =syn_observation.observed_item_id
AND DNS_SYN_SAMPLE.batchid                     =BATCH.id
AND BATCH.PARENT_ID                            =PARENT.ID
AND syn_observation.protocol_id                =syn_observation_protocol.id
AND syn_observation_protocol.phenomenon_type_id=syn_phenomenon_type.id
AND syn_observation.quantity_conc_unit         =synconcunit.id(+)
AND syn_observation.type_id                    =syn_observation_type.id
AND syn_observation.document_id                =htsassaynotebook.id(+)
AND syn_observation.unit_id                    =synresultunit.id
AND syn_observation.id                        IN
  (SELECT syn_observation.id AS subquery_select_id
  FROM syn_observation,
    syn_observation_protocol,
    syn_phenomenon_type
  WHERE syn_phenomenon_type.name                 = '<PROTOCOL_TO_SEARCH>'
  AND syn_observation.protocol_id                =syn_observation_protocol.id
  AND syn_observation_protocol.phenomenon_type_id=syn_phenomenon_type.id
  )
