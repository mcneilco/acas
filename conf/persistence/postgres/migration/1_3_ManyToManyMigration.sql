INSERT INTO treatmentgroup_subject (treatment_group_id, subject_id) SELECT treatment_group_id, id FROM subject;
INSERT INTO analysisgroup_treatmentgroup (analysis_group_id, treatment_group_id) SELECT analysis_group_id, id FROM treatment_group;
INSERT INTO experiment_analysisgroup (experiment_id, analysis_group_id) SELECT experiment_id, id FROM analysis_group;


ALTER TABLE treatment_group DROP COLUMN analysis_group_id CASCADE;
ALTER TABLE analysis_group DROP COLUMN experiment_id CASCADE;
ALTER TABLE subject DROP COLUMN treatment_group_id CASCADE;
