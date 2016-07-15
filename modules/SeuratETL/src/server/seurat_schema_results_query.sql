select 
syn_sample.alternate_id										AS "Corporate_Batch_ID", 
syn_phenomenon_type.name								AS "Protocol_Name",  
syn_observation_protocol.version_num 				AS "Experiment_Name", 
'bfielder' 										AS "Experiment_Scientist",
LPAD(syn_compound_lot.lot_id::text,3, '0')     AS "Lot_Number",
syn_observation_type.name 								AS "Expt_Result_Type",
syn_observation.obs_operator 			AS "Expt_Result_Operator",
synresultunit.label								AS "Expt_Result_Units",
syn_observation.quantity 				AS "Expt_Result_Value",
syn_observation.quantity_std_dev 		AS "Expt_Result_Std_Dev",
syn_observation.cat_obs_phenomenon 	AS "Expt_Result_Desc",
syn_observation.secondary_groupno_date AS "Expt_Date",
syn_observation.comments 				AS "Expt_Result_Comment",
syn_observation.quantity_conc 			AS "Expt_Concentration", 
synconcunit.label 										AS "Expt_Conc_Units",
syn_observation.document_page 			AS "Expt_Nb_Page",
htsassaynotebook.name	 								AS "Expt_Notebook",
syn_observation.primary_groupno 		AS "Expt_Batch_Number",
syn_observation.id AS "OBSERVATION_ID"
from 
public.syn_phenomenon_type, 
public.syn_compound_lot, 
public.syn_observation_type, 
public.syn_sample, 
public.syn_observation_unit synresultunit, 
public.syn_observation_protocol, 
public.syn_observation left outer join public.syn_observation_unit synconcunit on syn_observation.quantity_conc_unit=synconcunit.id 
left outer join public.syn_document htsassaynotebook on syn_observation.document_id=htsassaynotebook.id 
left outer join public.syn_person ON syn_person.id=htsassaynotebook.person_id
join public.syn_file on syn_file.file_id=syn_observation.file_id
 where 
syn_observation.protocol_id=syn_observation_protocol.id and 
syn_observation_protocol.phenomenon_type_id=syn_phenomenon_type.id and 
syn_sample.sample_id=syn_observation.observed_item_id and 
syn_sample.sample_id=syn_compound_lot.sample_id and 
syn_observation.type_id=syn_observation_type.id and 
syn_observation.unit_id=synresultunit.id 
 and syn_observation.id in 
(select 
syn_observation.id as subquery_select_id 
from 
syn_observation, 
syn_observation_protocol, 
syn_phenomenon_type 
where syn_phenomenon_type.name = '<PROTOCOL_TO_SEARCH>' and 
syn_observation.protocol_id=syn_observation_protocol.id and 
syn_observation_protocol.phenomenon_type_id=syn_phenomenon_type.id 
)
