UPDATE treatment_group_value tgv1 SET (concentration, conc_unit) =
(SELECT dtgv.numeric_value, dtgv.unit_kind
FROM treatment_group tg
JOIN treatment_group_state tcttgs ON tcttgs.treatment_group_id = tg.id
JOIN treatment_group_value bctgv ON bctgv.treatment_state_id = tcttgs.id
JOIN treatment_group_value dtgv ON dtgv.treatment_state_id = tcttgs.id
WHERE tcttgs.ls_kind = 'treatment'
AND bctgv.ls_kind = 'batch code'
AND (dtgv.ls_kind = 'Dose' OR dtgv.ls_kind = 'concentration')
AND tgv1.id = bctgv.id)
WHERE EXISTS (
SELECT bctgv.id
FROM treatment_group tg
JOIN treatment_group_state tcttgs ON tcttgs.treatment_group_id = tg.id
JOIN treatment_group_value bctgv ON bctgv.treatment_state_id = tcttgs.id
JOIN treatment_group_value dtgv ON dtgv.treatment_state_id = tcttgs.id
WHERE tcttgs.ls_kind = 'treatment'
AND bctgv.ls_kind = 'batch code'
AND (dtgv.ls_kind = 'Dose' OR dtgv.ls_kind = 'concentration')
AND tgv1.id = bctgv.id);

UPDATE treatment_group_value tgv SET ignored = 1
WHERE tgv.id IN (SELECT dtgv.id
FROM treatment_group tg
JOIN treatment_group_state tcttgs ON tcttgs.treatment_group_id = tg.id
JOIN treatment_group_value bctgv ON bctgv.treatment_state_id = tcttgs.id
JOIN treatment_group_value dtgv ON dtgv.treatment_state_id = tcttgs.id
WHERE tcttgs.ls_kind = 'treatment'
AND bctgv.ls_kind = 'batch code'
AND (dtgv.ls_kind = 'Dose' OR dtgv.ls_kind = 'concentration'));

UPDATE subject_value sv1
SET (concentration, conc_unit) = 
(SELECT dsv.numeric_value, dsv.unit_kind
FROM subject s
JOIN subject_state tctss ON tctss.subject_id = s.id
JOIN subject_value bcsv ON bcsv.subject_state_id = tctss.id
JOIN subject_value dsv ON dsv.subject_state_id = tctss.id
JOIN treatmentgroup_subject tgs ON tgs.subject_id = s.id
WHERE tctss.ls_kind = 'treatment'
AND bcsv.ls_kind = 'batch code'
AND (dsv.ls_kind = 'Dose' OR dsv.ls_kind = 'concentration')
AND sv1.id = bcsv.id)
WHERE EXISTS
(SELECT bcsv.id
FROM subject s
JOIN subject_state tctss ON tctss.subject_id = s.id
JOIN subject_value bcsv ON bcsv.subject_state_id = tctss.id
JOIN subject_value dsv ON dsv.subject_state_id = tctss.id
WHERE tctss.ls_kind = 'treatment'
AND bcsv.ls_kind = 'batch code'
AND (dsv.ls_kind = 'Dose' OR dsv.ls_kind = 'concentration')
AND sv1.id = bcsv.id);

UPDATE subject_value sv SET ignored = 1
WHERE sv.id IN (SELECT dsv.id
FROM subject s
JOIN subject_state tctss ON tctss.subject_id = s.id
JOIN subject_value bcsv ON bcsv.subject_state_id = tctss.id
JOIN subject_value dsv ON dsv.subject_state_id = tctss.id
WHERE tctss.ls_kind = 'treatment'
AND bcsv.ls_kind = 'batch code'
AND (dsv.ls_kind = 'Dose' OR dsv.ls_kind = 'concentration'));