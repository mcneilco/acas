INSERT INTO treatmentgroup_subject (treatment_group_id, subject_id) SELECT treatment_group_id, id FROM subject;
INSERT INTO analysisgroup_treatmentgroup (analysis_group_id, treatment_group_id) SELECT analysis_group_id, id FROM treatment_group;
INSERT INTO experiment_analysisgroup (experiment_id, analysis_group_id) SELECT experiment_id, id FROM analysis_group;


ALTER TABLE treatment_group DROP COLUMN analysis_group_id;
ALTER TABLE analysis_group DROP COLUMN experiment_id;
ALTER TABLE subject DROP COLUMN treatment_group_id;

--Run this script as the acas user to create indexes

--ddict changes
--TODO: fix
ALTER TABLE acas.ddict_value
  ADD CONSTRAINT dd_value_tk_fk FOREIGN KEY (ls_type_and_kind) REFERENCES acas.ddict_kind (ls_type_and_kind)
   ON UPDATE NO ACTION ON DELETE NO ACTION;

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

create index exp_prot_fk on experiment(protocol_id);
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



-- note: may need to add additional foreign key constrains