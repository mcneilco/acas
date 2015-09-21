select 
split_part(p_api_analysis_group_results.tested_lot,'-',1)										AS "Corporate_Batch_ID",
api_protocol.label_text								AS "Protocol_Name",
api_experiment.label_text 				AS "Experiment_Name",
'bfielder' 										AS "Experiment_Scientist",
split_part(p_api_analysis_group_results.tested_lot,'-',2)     AS "Lot_Number",
p_api_analysis_group_results.ls_kind 								AS "Expt_Result_Type",
p_api_analysis_group_results.operator_kind 			AS "Expt_Result_Operator",
p_api_analysis_group_results.unit_kind								AS "Expt_Result_Units",
p_api_analysis_group_results.numeric_value 				AS "Expt_Result_Value",
p_api_analysis_group_results.uncertainty 		AS "Expt_Result_Std_Dev",
p_api_analysis_group_results.string_value 	AS "Expt_Result_Desc",
api_experiment.completion_date AS "Expt_Date",
p_api_analysis_group_results.comments 				AS "Expt_Result_Comment",
p_api_analysis_group_results.tested_conc 			AS "Expt_Concentration",
p_api_analysis_group_results.tested_conc_unit 										AS "Expt_Conc_Units",
api_experiment.notebook_page 			AS "Expt_Nb_Page",
api_experiment.notebook	 								AS "Expt_Notebook",
p_api_analysis_group_results.ag_id 		AS "Expt_Batch_Number",
p_api_analysis_group_results.agv_id AS "OBSERVATION_ID"
from 
api_protocol,
api_experiment,
p_api_analysis_group_results
where api_protocol.protocol_id=api_experiment.protocol_id and
p_api_analysis_group_results.experiment_id=api_experiment.id and
api_protocol.label_text = '<PROTOCOL_TO_SEARCH>'
