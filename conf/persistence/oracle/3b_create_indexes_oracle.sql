--Run this script as the acas user to create indexes
ALTER TABLE label_sequence
  ADD CONSTRAINT label_seq_uq UNIQUE (label_type_and_kind, thing_type_and_kind);
--ddict changes
ALTER TABLE ddict_value
  ADD CONSTRAINT dd_value_tk_fk FOREIGN KEY (ls_type_and_kind) REFERENCES ddict_kind (ls_type_and_kind);

--many to many changes
CREATE INDEX IDX_E_AG_ANALYSIS_GROUP_ID ON EXPERIMENT_ANALYSISGROUP (ANALYSIS_GROUP_ID);
CREATE INDEX IDX_E_AG_EXPERIMENT_ID ON EXPERIMENT_ANALYSISGROUP (EXPERIMENT_ID);
CREATE INDEX IDX_AG_TG_TREATMENT_GROUP_ID ON ANALYSISGROUP_TREATMENTGROUP (TREATMENT_GROUP_ID);
CREATE INDEX IDX_AG_TG_ANALYSIS_GROUP_ID ON ANALYSISGROUP_TREATMENTGROUP (ANALYSIS_GROUP_ID);
CREATE INDEX IDX_TG_S_TREATMENT_GROUP_ID ON TREATMENTGROUP_SUBJECT (TREATMENT_GROUP_ID);
CREATE INDEX IDX_TG_S_SUBJECT_GROUP_ID ON TREATMENTGROUP_SUBJECT (SUBJECT_ID);



--more indexes for FKs and other

create index expt_label_txt_idx on experiment_label(label_text);
create index prot_label_txt_idx on protocol_label(label_text);
create index cont_label_txt_idx on container_label(label_text);

create index sbjlbl_sbj_fk on subject_label(subject_id);
create index sbjst_sbj_fk on subject_state(subject_id);
create index sbjvl_sbjst_fk on subject_value(subject_state_id);

create index trtgrplbl_trtgrp_fk on treatment_group_label(treatment_group_id);
create index trtgrpst_trtgrp_fk on treatment_group_state(treatment_group_id);
create index trtgrpvl_trtgrpst_fk on treatment_group_value(treatment_state_id);

create index anlygrplbl_anlygrp_fk on analysis_group_label(analysis_group_id);
create index anlygrpst_anlygrp_fk on analysis_group_state(analysis_group_id);
create index anlygrpvl_anlygrpst_fk on analysis_group_value(analysis_state_id);

create index exptlbl_exp_fk on experiment_label(experiment_id);
create index expst_exp_fk on experiment_state(experiment_id);
create index exptvl_exp_fk on experiment_value(experiment_state_id);

create index protlbl_prot_fk on protocol_label(protocol_id);
create index protst_prot_fk on protocol_state(protocol_id);
create index protvl_protst_fk on protocol_value(protocol_state_id);

create index cntrlbl_cntr_fk on container_label(container_id);
create index cntrst_cntr_fk on container_state(container_id);
create index cntrvl_cntrst_fk on container_value(container_state_id); 


create index itxcntr_cntr1_fk on itx_container_container(first_container_id);
create index itxcntr_cntr2_fk on itx_container_container(second_container_id);
create index itxcntrst_itxcntr_fk on itx_container_container_state(itx_container_container);
create index itxcntrvl_itxcntrst_fk on itx_container_container_value(ls_state);

create index itxsubjcntr_subj_fk on itx_subject_container(subject_id);
create index itxsubjcntr_cntr_fk on itx_subject_container(container_id);
create index itxsbcntrst_itxcntr_fk on itx_subject_container_state(itx_subject_container);
create index itxsbcntrvl_itxcntrst_fk on itx_subject_container_value(ls_state);

-----
create index itx_cntrs_KIND_IDX on itx_container_container (ls_kind);
create index itx_cntrs_TRXN_IDX on itx_container_container (ls_transaction);
create index itx_cntrs_TYPE_IDX on itx_container_container (ls_type);
create index itx_cntrs_REC_BY_IDX on itx_container_container (recorded_by);
create index itx_cntrs_IGNORED_IDX on itx_container_container (ignored);
create index itx_cntrs_REC_DATE_IDX on itx_container_container (recorded_date);
create index itx_cntrs_state_TK_IDX on itx_container_container_state (ls_type_and_kind);
create index itx_cntrs_value_TRXN_IDX on itx_container_container_value (ls_transaction);
create index itx_cntrs_value_UNTK_IDX on itx_container_container_value (unit_type_and_kind);
create index itx_cntrs_value_TK_IDX on itx_container_container_value (ls_type_and_kind);
create index itx_cntrs_value_OPTK_IDX on itx_container_container_value (operator_type_and_kind);
create index itx_cntrs_value_REC_BY_IDX on itx_container_container_value (recorded_by);
create index itx_subj_cont_REC_BY_IDX on itx_subject_container (recorded_by);
create index itx_subj_cont_IGNORED_IDX on itx_subject_container (ignored);
create index itx_subj_cont_REC_DATE_IDX on itx_subject_container (recorded_date);
create index itx_subj_cont_state_TK_IDX on itx_subject_container_state (ls_type_and_kind);
create index itx_subj_cont_value_TRXN_IDX on itx_subject_container_value (ls_transaction);
create index itx_subj_cont_value_UNTK_IDX on itx_subject_container_value (unit_type_and_kind);
create index itx_subj_cont_value_TK_IDX on itx_subject_container_value (ls_type_and_kind);
create index itx_subj_cont_value_OPTK_IDX on itx_subject_container_value (operator_type_and_kind);
create index itx_subj_cont_value_REC_BY_IDX on itx_subject_container_value (recorded_by);

-- note: may need to add additional foreign key constrains


alter table
   PROTOCOL
add constraint
   PROTOCOL_TK_FK FOREIGN KEY (LS_TYPE_AND_KIND)
references
   PROTOCOL_KIND (LS_TYPE_AND_KIND);

alter table
   EXPERIMENT
add constraint
   EXPERIMENT_TK_FK FOREIGN KEY (LS_TYPE_AND_KIND)
references
   EXPERIMENT_KIND (LS_TYPE_AND_KIND);

alter table
   PROTOCOL_STATE
add constraint
   PS_TK_FK FOREIGN KEY (LS_TYPE_AND_KIND)
references
   STATE_KIND (LS_TYPE_AND_KIND);

alter table
   EXPERIMENT_STATE
add constraint
   ES_TK_FK FOREIGN KEY (LS_TYPE_AND_KIND)
references
   STATE_KIND (LS_TYPE_AND_KIND);

alter table
   ANALYSIS_GROUP_STATE
add constraint
   AGS_TK_FK FOREIGN KEY (LS_TYPE_AND_KIND)
references
   STATE_KIND (LS_TYPE_AND_KIND);

alter table
   CONTAINER_STATE
add constraint
   CS_TK_FK FOREIGN KEY (LS_TYPE_AND_KIND)
references
   STATE_KIND (LS_TYPE_AND_KIND);

alter table
   TREATMENT_GROUP_STATE
add constraint
   TGS_TK_FK FOREIGN KEY (LS_TYPE_AND_KIND)
references
   STATE_KIND (LS_TYPE_AND_KIND);

alter table
   SUBJECT_STATE
add constraint
   SS_TK_FK FOREIGN KEY (LS_TYPE_AND_KIND)
references
   STATE_KIND (LS_TYPE_AND_KIND);

alter table
   PROTOCOL_VALUE
add constraint
   PV_TK_FK FOREIGN KEY (LS_TYPE_AND_KIND)
references
   VALUE_KIND (LS_TYPE_AND_KIND);

alter table
   EXPERIMENT_VALUE
add constraint
   EV_TK_FK FOREIGN KEY (LS_TYPE_AND_KIND)
references
   VALUE_KIND (LS_TYPE_AND_KIND);

alter table
   ANALYSIS_GROUP_VALUE
add constraint
   AGV_TK_FK FOREIGN KEY (LS_TYPE_AND_KIND)
references
   VALUE_KIND (LS_TYPE_AND_KIND);


alter table
   TREATMENT_GROUP_VALUE
add constraint
   TGV_TK_FK FOREIGN KEY (LS_TYPE_AND_KIND)
references
   VALUE_KIND (LS_TYPE_AND_KIND);

alter table
   SUBJECT_VALUE
add constraint
   SV_TK_FK FOREIGN KEY (LS_TYPE_AND_KIND)
references
   VALUE_KIND (LS_TYPE_AND_KIND);


alter table
   PROTOCOL_LABEL
add constraint
   PL_TK_FK FOREIGN KEY (LS_TYPE_AND_KIND)
references
   LABEL_KIND (LS_TYPE_AND_KIND);

alter table
   EXPERIMENT_LABEL
add constraint
   EL_TK_FK FOREIGN KEY (LS_TYPE_AND_KIND)
references
   LABEL_KIND (LS_TYPE_AND_KIND);


alter table
   ANALYSIS_GROUP_LABEL
add constraint
   AGL_TK_FK FOREIGN KEY (LS_TYPE_AND_KIND)
references
   LABEL_KIND (LS_TYPE_AND_KIND);

alter table
   TREATMENT_GROUP_LABEL
add constraint
   TGL_TK_FK FOREIGN KEY (LS_TYPE_AND_KIND)
references
   LABEL_KIND (LS_TYPE_AND_KIND);

alter table
   SUBJECT_LABEL
add constraint
   SL_TK_FK FOREIGN KEY (LS_TYPE_AND_KIND)
references
   LABEL_KIND (LS_TYPE_AND_KIND);


alter table
   CONTAINER_LABEL
add constraint
   CL_TK_FK FOREIGN KEY (LS_TYPE_AND_KIND)
references
   LABEL_KIND (LS_TYPE_AND_KIND);
   
create index idx_trtgrpvl_public_data on treatment_group_value(public_data);