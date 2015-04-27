--THERE IS AN ERROR IN THIS SCRIPT
-- missing version from inserts
-- duplicate values will be created for subject and treatment group values in data/results with kind batch code
-- the previous values came from curves having been fit (they don't have concentration and conc_unit).

INSERT INTO treatment_group_value 
(id, code_value, ignored, ls_kind, ls_transaction, ls_type, ls_type_and_kind, public_data, recorded_by, recorded_date, treatment_state_id, deleted, concentration, conc_unit)
(SELECT value_pkseq.NEXTVAL, bctgv.code_value, bctgv.ignored, bctgv.ls_kind, bctgv.ls_transaction, bctgv.ls_type, bctgv.ls_type_and_kind, bctgv.public_data, bctgv.recorded_by, bctgv.recorded_date, rtgs.id, bctgv.deleted, dtgv.numeric_value, dtgv.unit_kind
FROM treatment_group tg
JOIN treatment_group_state tcttgs ON tcttgs.treatment_group_id = tg.id
JOIN treatment_group_state rtgs ON rtgs.treatment_group_id = tg.id
JOIN treatment_group_value bctgv ON bctgv.treatment_state_id = tcttgs.id
JOIN treatment_group_value dtgv ON dtgv.treatment_state_id = tcttgs.id
WHERE tcttgs.ls_kind = 'test compound treatment'
AND rtgs.ls_kind = 'results'
AND bctgv.ls_kind = 'batch code'
AND (dtgv.ls_kind = 'Dose' OR dtgv.ls_kind = 'concentration'));

UPDATE treatment_group_state tgs SET ignored = 1
WHERE tgs.id IN (SELECT tcttgs.id
FROM treatment_group tg
JOIN treatment_group_state tcttgs ON tcttgs.treatment_group_id = tg.id
JOIN treatment_group_state rtgs ON rtgs.treatment_group_id = tg.id
JOIN treatment_group_value bctgv ON bctgv.treatment_state_id = tcttgs.id
JOIN treatment_group_value dtgv ON dtgv.treatment_state_id = tcttgs.id
WHERE tcttgs.ls_kind = 'test compound treatment'
AND rtgs.ls_kind = 'results'
AND bctgv.ls_kind = 'batch code'
AND (dtgv.ls_kind = 'Dose' OR dtgv.ls_kind = 'concentration'));

INSERT INTO subject_value 
(id, code_value, ignored, ls_kind, ls_transaction, ls_type, ls_type_and_kind, public_data, recorded_by, recorded_date, subject_state_id, deleted, concentration, conc_unit)
(SELECT value_pkseq.NEXTVAL, bcsv.code_value, bcsv.ignored, bcsv.ls_kind, bcsv.ls_transaction, bcsv.ls_type, bcsv.ls_type_and_kind, bcsv.public_data, bcsv.recorded_by, bcsv.recorded_date, rss.id, bcsv.deleted, dsv.numeric_value, dsv.unit_kind
FROM subject s
JOIN subject_state tctss ON tctss.subject_id = s.id
JOIN subject_state rss ON rss.subject_id = s.id
JOIN subject_value bcsv ON bcsv.subject_state_id = tctss.id
JOIN subject_value dsv ON dsv.subject_state_id = tctss.id
JOIN treatmentgroup_subject tgs ON tgs.subject_id = s.id
WHERE tctss.ls_kind = 'test compound treatment'
AND rss.ls_kind = 'results'
AND bcsv.ls_kind = 'batch code'
AND (dsv.ls_kind = 'Dose' OR dsv.ls_kind = 'concentration'));

UPDATE subject_state ss SET ignored = 1
WHERE ss.id IN (SELECT tctss.id
FROM subject s
JOIN subject_state tctss ON tctss.subject_id = s.id
JOIN subject_state rss ON rss.subject_id = s.id
JOIN subject_value bcsv ON bcsv.subject_state_id = tctss.id
JOIN subject_value dsv ON dsv.subject_state_id = tctss.id
JOIN treatmentgroup_subject tgs ON tgs.subject_id = s.id
WHERE tctss.ls_kind = 'test compound treatment'
AND rss.ls_kind = 'results'
AND bcsv.ls_kind = 'batch code'
AND (dsv.ls_kind = 'Dose' OR dsv.ls_kind = 'concentration'));

INSERT INTO analysis_group_value 
(id, code_value, ignored, ls_kind, ls_transaction, ls_type, ls_type_and_kind, public_data, recorded_by, recorded_date, analysis_state_id, deleted, concentration, conc_unit)
(SELECT value_pkseq.NEXTVAL, bcagv.code_value, bcagv.ignored, bcagv.ls_kind, bcagv.ls_transaction, bcagv.ls_type, bcagv.ls_type_and_kind, bcagv.public_data, bcagv.recorded_by, bcagv.recorded_date, rags.id, bcagv.deleted, dagv.numeric_value, dagv.unit_kind
FROM analysis_group ag
JOIN analysis_group_state tctags ON tctags.analysis_group_id = ag.id
JOIN analysis_group_state rags ON rags.analysis_group_id = ag.id
JOIN analysis_group_value bcagv ON bcagv.analysis_state_id = tctags.id
JOIN analysis_group_value dagv ON dagv.analysis_state_id = tctags.id
WHERE tctags.ls_kind = 'test compound treatment'
AND rags.ls_kind = 'results'
AND bcagv.ls_kind = 'batch code'
AND (dagv.ls_kind = 'Dose' OR dagv.ls_kind = 'concentration'));

UPDATE analysis_group_state ags SET ignored = 1
WHERE ags.id IN (SELECT tctags.id
FROM analysis_group ag
JOIN analysis_group_state tctags ON tctags.analysis_group_id = ag.id
JOIN analysis_group_state rags ON rags.analysis_group_id = ag.id
JOIN analysis_group_value bcagv ON bcagv.analysis_state_id = tctags.id
JOIN analysis_group_value dagv ON dagv.analysis_state_id = tctags.id
WHERE tctags.ls_kind = 'test compound treatment'
AND rags.ls_kind = 'results'
AND bcagv.ls_kind = 'batch code'
AND (dagv.ls_kind = 'Dose' OR dagv.ls_kind = 'concentration'));

