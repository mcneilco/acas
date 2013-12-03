generalizeApiAllData <- function(allData) {
  allDataGeneralized <- allData
  allDataGeneralized$AG_ID <- as.numeric(as.factor(allData$AG_ID))
  allDataGeneralized$AGV_ID <- as.numeric(as.factor(allData$AGV_ID))
  allDataGeneralized$TG_ID <- as.numeric(as.factor(allData$TG_ID))
  allDataGeneralized$TGV_ID <- as.numeric(as.factor(allData$TGV_ID))
  allDataGeneralized$TG_STATE_ID <- as.numeric(as.factor(allData$TG_STATE_ID))
  allDataGeneralized$S_ID <- as.numeric(as.factor(allData$S_ID))
  allDataGeneralized$SV_ID <- as.numeric(as.factor(allData$SV_ID))
  allDataGeneralized$S_STATE_ID <- as.numeric(as.factor(allData$S_STATE_ID))
  allDataGeneralized$C_ID <- as.numeric(as.factor(allData$C_ID))
  allDataGeneralized$CV_ID <- as.numeric(as.factor(allData$CV_ID))
  allDataGeneralized$C_STATE_ID <- as.numeric(as.factor(allData$C_STATE_ID))
  return(allDataGeneralized)
}

test.behavior <- function () {
  queryTemplate <- "select PROTOCOL_NAME, EXPERIMENT_NAME, COMPLETION_DATE, PROJECT, SCIENTIST, 
AG_ID, AG_TESTED_LOT, AG_TESTED_CONC, AG_TESTED_CONC_UNIT, AGV_ID, AG_VALUE_KIND, AG_OPERATOR, AG_NUMERIC_VALUE, AG_UNCERTAINTY, AG_UNIT, AG_STRING_VALUE, AG_COMMENTS, AG_PUBLIC_DATA, 
TG_ID, TG_TESTED_LOT, TG_TESTED_CONC, TG_TESTED_CONC_UNIT, TG_TESTED_TIME, TG_TESTED_TIME_UNIT, TGV_ID, TG_VALUE_KIND, TG_OPERATOR, TG_NUMERIC_VALUE, TG_UNCERTAINTY, TG_UNIT, TG_STRING_VALUE, TG_COMMENTS, TG_PUBLIC_DATA, TG_STATE_ID, TG_STATE_KIND, TG_STATE_TYPE, 
S_ID, S_TESTED_LOT, S_TESTED_CONC, S_TESTED_CONC_UNIT, S_TESTED_TIME, S_TESTED_TIME_UNIT, SV_ID, S_VALUE_KIND, S_OPERATOR, S_NUMERIC_VALUE, S_UNCERTAINTY, S_UNIT, S_STRING_VALUE, S_COMMENTS, S_PUBLIC_DATA, S_STATE_ID, S_STATE_KIND, S_STATE_TYPE, 
ITX_SUBJECT_CONTAINER_TYPE, ITX_SUBJECT_CONTAINER_KIND, 
C_ID, CV_ID, C_VALUE_KIND, C_OPERATOR, C_NUMERIC_VALUE, C_UNCERTAINTY, C_UNIT, C_STRING_VALUE, C_COMMENTS, C_PUBLIC_DATA, C_STATE_ID, C_STATE_KIND, C_STATE_TYPE
                          from api_all_data 
                          where experiment_name='%s'
                          order by sv_id, tgv_id, cv_id, agv_id"
  
  # Load .../other regression files/In_Vivo_Behavior_Example_short.xlsx twice first (need to be attaching to previous containers)
  # Local copy at ~/Documents/clients/DNS/ACAS\ Examples/In_Vivo_Behavior_Example_short.xlsx
  # but master is on DNS server
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/behaviorOutputv2.Rda")
  behaviorSaved <- query(sprintf(queryTemplate, 'EXP23110_rCFC_PDE2A_test347'))
  # This allows the order of state ids to be maintainable
  behaviorSavedGeneralized <- generalizeApiAllData(behaviorSaved)
  checkIdentical(behaviorSavedGeneralizedOriginal, behaviorSavedGeneralized)
  
  # Load smb://dart.corp/departments/Scientific Computing/Informatics/McNeilCo_Data/ACAS Examples/HJones regression files/CNS_Example_HJ.xlsx first
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/cnsOutput.Rda")
  cnsSaved <- query(sprintf(queryTemplate, 'PKXXX_DNS001317368_3'))
  cnsSavedGeneralized <- generalizeApiAllData(cnsSaved)
  checkIdentical(cnsSavedGeneralizedOriginal, cnsSavedGeneralized)
  
  # Load smb://dart.corp/departments/Scientific Computing/Informatics/McNeilCo_Data/ACAS Examples/HJones regression files/PK_205v1.xlsx first
  # Probably still needs work
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/pkOutput.Rda")
  pkSaved <- query(sprintf(queryTemplate, 'PK205'))
  pkSavedGeneralized <- generalizeApiAllData(pkSaved)
  checkIdentical(pkSavedGeneralizedOriginal, pkSavedGeneralized)
  
  # Load DNS6288_exp2643_PDE2_rloco_ACASupload_SMv1.xlsx
  # Probably still needs work
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/locomotorOutput.Rda")
  locomotorSaved <- query(sprintf(queryTemplate, 'Exp#2643'))
  locomotorSavedGeneralized <- generalizeApiAllData(locomotorSaved)
  checkIdentical(locomotorSavedGeneralizedOriginal, locomotorSavedGeneralized)
}
