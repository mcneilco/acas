test.behavior <- function () {
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/behaviorOutput.Rda")
  behaviorSaved <- query("select protocol_name, experiment_name, analysis_group_code_name, treatment_group_code_name, subject_code_name, tested_lot, tested_conc, tested_conc_unit, tested_time, tested_time_unit, ls_kind, operator_kind, numeric_value, uncertainty, unit_kind, string_value, comments, public_data, state_id, state_kind, state_type from api_subject_container_results 
                         where experiment_name='EXP23110_rCFC_PDE2A_test347'
                         order by subject_code_name, ls_kind")
  behaviorSavedGeneralized <- behaviorSaved
  behaviorSavedGeneralized$ANALYSIS_GROUP_CODE_NAME <- as.numeric(as.factor(behaviorSaved$ANALYSIS_GROUP_CODE_NAME))
  behaviorSavedGeneralized$TREATMENT_GROUP_CODE_NAME <- as.numeric(as.factor(behaviorSaved$TREATMENT_GROUP_CODE_NAME))
  behaviorSavedGeneralized$SUBJECT_CODE_NAME <- as.numeric(as.factor(behaviorSaved$SUBJECT_CODE_NAME))
  # This allows the order of state ids to be maintainable
  behaviorSavedGeneralized$STATE_ID <- as.numeric(factor(behaviorSaved$STATE_ID,levels=unique(behaviorSaved$STATE_ID)))
  checkIdentical(behaviorSavedGeneralizedOriginal, behaviorSavedGeneralized)
  
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/cnsOutput.Rda")
  cnsSaved <- query("select protocol_name, experiment_name, analysis_group_code_name, treatment_group_code_name, subject_code_name, tested_lot, tested_conc, tested_conc_unit, tested_time, tested_time_unit, ls_kind, operator_kind, numeric_value, uncertainty, unit_kind, string_value, comments, public_data, state_id, state_kind, state_type from api_subject_container_results 
                    where experiment_name='PKXXX_CMPD001317368_3'
                    order by subject_code_name, ls_kind")
  cnsSavedGeneralized <- cnsSaved
  cnsSavedGeneralized$ANALYSIS_GROUP_CODE_NAME <- as.numeric(as.factor(cnsSaved$ANALYSIS_GROUP_CODE_NAME))
  cnsSavedGeneralized$TREATMENT_GROUP_CODE_NAME <- as.numeric(as.factor(cnsSaved$TREATMENT_GROUP_CODE_NAME))
  cnsSavedGeneralized$SUBJECT_CODE_NAME <- as.numeric(as.factor(cnsSaved$SUBJECT_CODE_NAME))
  # This allows the order of state ids to be maintainable
  cnsSavedGeneralized$STATE_ID <- as.numeric(factor(cnsSaved$STATE_ID,levels=unique(cnsSaved$STATE_ID)))
  checkIdentical(cnsSavedGeneralizedOriginal, cnsSavedGeneralized)
  
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/pkOutput.Rda")
  pkSaved <- query("select protocol_name, experiment_name, analysis_group_code_name, treatment_group_code_name, subject_code_name, tested_lot, tested_conc, tested_conc_unit, tested_time, tested_time_unit, ls_kind, operator_kind, numeric_value, uncertainty, unit_kind, string_value, comments, public_data, state_id, state_kind, state_type from api_subject_container_results 
                    where experiment_name='PK205'
                    order by subject_code_name, ls_kind, tested_time")
  pkSavedGeneralized <- pkSaved
  pkSavedGeneralized$ANALYSIS_GROUP_CODE_NAME <- as.numeric(as.factor(pkSaved$ANALYSIS_GROUP_CODE_NAME))
  pkSavedGeneralized$TREATMENT_GROUP_CODE_NAME <- as.numeric(as.factor(pkSaved$TREATMENT_GROUP_CODE_NAME))
  pkSavedGeneralized$SUBJECT_CODE_NAME <- as.numeric(as.factor(pkSaved$SUBJECT_CODE_NAME))
  # This allows the order of state ids to be maintainable
  pkSavedGeneralized$STATE_ID <- as.numeric(factor(pkSaved$STATE_ID,levels=unique(pkSaved$STATE_ID)))
  checkIdentical(pkSavedGeneralizedOriginal, pkSavedGeneralized)
}
