-----------------------------
-- Run all of these as acas the acas user
-----------------------------
--TODO: make into proper ddl
--drop (ordered by dependency)
DROP VIEW api_system_statistics;
DROP VIEW API_SUBJECT_CONTAINER_RESULTS;
DROP VIEW API_SUBJECT_RESULTS;
drop view api_container_contents;
DROP VIEW api_curve_params;
DROP VIEW api_dose_response;
DROP VIEW API_HTS_TREATMENT_RESULTS;
DROP VIEW api_experiment_results;
DROP VIEW api_analysis_group_results;
DROP VIEW p_api_analysis_group_results;
DROP VIEW api_all_data;
DROP VIEW batch_code_experiment_links;
DROP VIEW api_protocol;
DROP VIEW api_experiment_approved;
DROP VIEW api_experiment;

--create
CREATE OR REPLACE VIEW api_protocol as
SELECT p.id AS protocol_id,
  p.code_name,
  p.recorded_by,
  p.recorded_date,
  p.short_description,
  pl.label_text || COALESCE(pv.string_value, '') AS label_text
FROM protocol p
JOIN protocol_label pl ON p.id=pl.protocol_id
LEFT JOIN protocol_state ps ON p.id = ps.protocol_id AND ps.ls_kind = 'name modifier'
LEFT JOIN protocol_value pv ON ps.id = pv.protocol_state_id AND pv.ls_kind = 'postfix'
WHERE p.ignored ='0'
AND pl.preferred='1'
AND pl.ignored  ='0';

CREATE OR REPLACE VIEW api_experiment
AS
  SELECT e.id AS id,
    e.code_name || '::' || el.label_text as experiment_name,
    e.code_name,
    el.label_text,
    e.Ls_Type_And_Kind as kind,
    e.recorded_by,
    e.recorded_date,
    e.short_description,
    e.protocol_id,
    --MAX( CASE ev.ls_kind WHEN 'analysis result html' THEN DBMS_LOB.substr(ev.clob_value, 3000) ELSE null END ) AS analysis_result_html,
    MAX( CASE ev.ls_kind WHEN 'analysis status' THEN ev.string_value ELSE null END ) AS analysis_status,
    MAX( CASE ev.ls_kind WHEN 'completion date' THEN ev.date_value ELSE null END ) AS completion_date,
    MAX( CASE ev.ls_kind WHEN 'notebook' THEN ev.string_value ELSE null END ) AS notebook,
    MAX( CASE ev.ls_kind WHEN 'notebook page' THEN ev.string_value ELSE null END ) AS notebook_page,
    MAX( CASE ev.ls_kind WHEN 'project' THEN ev.code_value ELSE null END ) AS project,
    MAX( CASE ev.ls_kind WHEN 'experiment status' THEN ev.code_value ELSE null END ) AS status,
    MAX( CASE ev.ls_kind WHEN 'scientist' THEN ev.string_value ELSE null END ) AS scientist,
    MAX( CASE ev.ls_kind WHEN 'hts format' THEN ev.string_value ELSE null END ) AS hts_format
  FROM experiment e
  JOIN experiment_label el
  ON e.id         =el.experiment_id
  JOIN experiment_state es
  ON e.id=es.experiment_id
  JOIN experiment_value ev
  ON Es.Id=Ev.Experiment_State_Id
  WHERE e.ignored ='0'
  AND el.preferred='1'
  AND el.ignored  ='0'
  AND ev.ignored = '0'
  AND es.ls_kind='experiment metadata' Group By E.Id, E.Code_Name, E.Ls_Type_And_Kind, E.Recorded_By, E.Recorded_Date, E.Short_Description, E.Protocol_Id, El.Label_Text;

CREATE OR REPLACE VIEW p_api_analysis_group_results AS 
SELECT ag.id AS ag_id, 
ag.code_name as ag_code_name,
eag.experiment_id AS experiment_id, 
agv2.code_value AS tested_lot, 
agv2.concentration AS tested_conc, 
CASE
  WHEN agv4.numeric_value IS NOT NULL AND agv2.concentration IS NOT NULL
		THEN agv2.conc_unit || ' and ' || agv4.numeric_value || ' ' || agv4.unit_kind
	WHEN agv4.numeric_value IS NOT NULL
		THEN agv4.numeric_value || ' ' || agv4.unit_kind
	ELSE agv2.conc_unit
END	
AS tested_conc_unit, 
agv.id AS agv_id,
agv.ls_type as ls_type,
CASE
    WHEN agv.ls_type = 'inlineFileValue'
    THEN agv.ls_type_and_kind
ELSE agv.ls_kind
END AS ls_kind,
agv.operator_kind, 
 CASE 
    WHEN agv.ls_kind like '%curve id' THEN null
    ELSE agv.numeric_value
  END as numeric_value,
agv.uncertainty, 
agv.unit_kind,
CASE
WHEN agv.ls_type = 'fileValue' 
THEN 
		('<A HREF="' || 
		(
			SELECT application_setting.prop_value
			FROM application_setting
        	WHERE application_setting.prop_name = 'BatchDocumentsURL'
        ) || 
        replace(agv.file_value, ' ', '%20') || 
        '">' || 
        agv.comments ||
	' (' ||
        agv.file_value ||
        ')' ||
        '</A>'
		)
WHEN agv.ls_type = 'inlineFileValue'
THEN agv.file_value
WHEN agv.ls_type = 'urlValue' 
THEN 
		('<A HREF="' || 
        replace(agv.url_value, ' ', '%20') || 
        '">' || 
        agv.comments ||
	' (' ||
        agv.url_value ||
        ')' ||
        '</A>'
		)
WHEN agv.ls_type = 'dateValue'
	THEN to_char(agv.date_value, 'yyyy-mm-dd')
WHEN agv.ls_type = 'codeValue'
	THEN agv.code_value
WHEN agv.ls_type = 'clobValue' 
	THEN DBMS_LOB.substr(agv.clob_value, 3000)
	ELSE COALESCE(agv.string_value,agv.comments)
END AS string_value,
agv.clob_value,
agv.comments, 
agv.recorded_date,
agv.public_data
FROM experiment e
JOIN experiment_analysisgroup eag on e.id=eag.experiment_id
JOIN analysis_GROUP ag ON eag.analysis_group_id = ag.id
JOIN analysis_GROUP_state ags ON ags.analysis_GROUP_id = ag.id
JOIN analysis_GROUP_value agv ON agv.analysis_state_id = ags.id AND agv.ls_kind <> 'batch code' AND agv.ls_kind <> 'time'
JOIN analysis_GROUP_value agv2 ON agv2.analysis_state_id = ags.id and agv2.ls_kind = 'batch code'
LEFT OUTER JOIN analysis_GROUP_value agv4 ON agv4.analysis_state_id = ags.id and agv4.ls_kind = 'time'
WHERE ag.ignored = '0' and
ags.ignored = '0' and
agv.ignored = '0' and
e.ignored = '0';

CREATE OR REPLACE VIEW api_experiment_approved
AS
SELECT * from api_experiment where status is null or status = 'approved';

CREATE OR REPLACE VIEW api_analysis_group_results AS 
SELECT *
FROM p_api_analysis_group_results
WHERE public_data='1';

CREATE OR REPLACE VIEW api_curve_params AS 
SELECT lsvalues0_.analysis_state_id AS stateId,
  lsvalues0_.id                     AS valueId,
  lsvalues0_.code_kind              AS codeKind,
  lsvalues0_.code_origin            AS codeOrigin,
  lsvalues0_.code_type              AS codeType,
  lsvalues0_.code_value             AS codeValue,
  lsvalues0_.comments               AS comments,
  lsvalues0_.conc_unit              AS concUnit,
  lsvalues0_.concentration          AS concentration,
  lsvalues0_.ls_kind                AS lsKind,
  lsvalues0_.ls_transaction         AS lsTransaction,
  lsvalues0_.ls_type                AS lsType,
  lsvalues0_.numeric_value          AS numericValue,
  lsvalues0_.operator_kind          AS operatorKind,
  lsvalues0_.operator_type          AS operatorType,
  lsvalues0_.public_data            AS publicData,
  lsvalues0_.recorded_by            AS recordedBy,
  lsvalues0_.recorded_date          AS recordedDate,
  lsvalues0_.string_value           AS stringValue,
  lsvalues0_.uncertainty            AS uncertainty,
  lsvalues0_.uncertainty_type       AS uncertaintyType,
  lsvalues0_.unit_kind              AS unitKind,
  lsvalues0_.unit_type              AS unitType,
  lsvalues0_.url_value              AS urlValue,
  lsvalues0_.version                AS version,
  analysisgr0_.string_value	     AS curveId,
  analysisgr0_.id	     AS curveValueId,
  pv1.numeric_value as curveDisplayMin,
  pv2.numeric_value as curveDisplayMax
FROM analysis_group_value analysisgr0_
INNER JOIN analysis_group_state analysisgr1_
ON analysisgr0_.analysis_state_id=analysisgr1_.id
INNER JOIN analysis_group analysisgr2_
ON analysisgr1_.analysis_group_id=analysisgr2_.id
INNER JOIN experiment_analysisgroup expt_ag_group
ON analysisgr2_.id=expt_ag_group.analysis_group_id
INNER JOIN experiment e
ON expt_ag_group.experiment_id=e.id
LEFT OUTER JOIN protocol_state ps
ON e.protocol_id=ps.protocol_id AND ps.ls_type = 'metadata' AND ps.ls_kind = 'screening assay'
LEFT OUTER JOIN protocol_value pv1 
ON ps.id=pv1.protocol_state_id AND pv1.ls_kind = 'curve display min'
LEFT OUTER JOIN protocol_value pv2
ON ps.id=pv2.protocol_state_id AND pv2.ls_kind = 'curve display max'
INNER JOIN analysis_group_value lsvalues0_
ON analysisgr1_.id=lsvalues0_.analysis_state_id
WHERE analysisgr0_.ls_type       ='stringValue'
AND analysisgr0_.ls_kind = 'curve id'
AND analysisgr0_.ignored= '0'
AND analysisgr1_.ignored= '0'
AND analysisgr2_.ignored= '0'
AND e.ignored = '0'
AND e.deleted = '0'
AND analysisgr1_.ls_type ='data'
AND analysisgr1_.ls_kind ='dose response'
AND lsvalues0_.ls_kind != 'curve id';

CREATE OR REPLACE VIEW API_DOSE_RESPONSE
AS
SELECT /*+ FIRST_ROWS(1) */
	lsvalues9_.id        AS responseSubjectValueId,
  analysisgr2_.code_name	AS analysisGroupCode,
  lsvalues9_.recorded_by    AS recorded_by,
  lsvalues9_.ls_transaction AS lsTransaction,
  lsvalues9_.numeric_value  AS response,
  lsvalues9_.unit_kind      AS responseUnits,
  lsvalues9_.ls_kind        AS responseKind,
  lsvalues10_.concentration AS dose,
  lsvalues10_.conc_unit     AS doseUnits,
  lsvalues12_.code_value    AS algorithmFlagStatus,
  lsvalues13_.code_value    AS algorithmFlagObservation,
  lsvalues14_.code_value    AS algorithmFlagCause,
  lsvalues15_.string_value  AS algorithmFlagComment,
  lsvalues17_.code_value    AS preprocessFlagStatus,
  lsvalues18_.code_value    AS preprocessFlagObservation,
  lsvalues19_.code_value    AS preprocessFlagCause,
  lsstates11_.ls_kind       AS algorithmFlagLsKind,
  lsstates16_.ls_kind       AS preprocessFlagLsKind,
  lsstates21_.ls_kind       AS userFlagLsKind,
  lsvalues20_.string_value  AS preprocessFlagComment,
  lsvalues22_.code_value    AS userFlagStatus,
  lsvalues23_.code_value    AS userFlagObservation,
  lsvalues24_.code_value    AS userFlagCause,
  lsvalues25_.string_value  AS userFlagComment,
  analysisgr0_.string_value AS curveId,
  analysisgr0_.id	     AS curveValueId
FROM analysis_group_value analysisgr0_
INNER JOIN analysis_group_state analysisgr1_
ON analysisgr0_.analysis_state_id=analysisgr1_.id
INNER JOIN analysis_group analysisgr2_
ON analysisgr1_.analysis_group_id=analysisgr2_.id
INNER JOIN analysis_group analysisgr3_
ON analysisgr1_.analysis_group_id=analysisgr3_.id
INNER JOIN experiment_analysisgroup expt_ag_group
ON analysisgr2_.id=expt_ag_group.analysis_group_id
INNER JOIN experiment e
ON expt_ag_group.experiment_id=e.id
INNER JOIN analysisgroup_treatmentgroup treatmentg4_
ON analysisgr3_.id=treatmentg4_.analysis_group_id
INNER JOIN treatment_group treatmentg5_
ON treatmentg4_.treatment_group_id=treatmentg5_.id
INNER JOIN treatmentgroup_subject subjects6_
ON treatmentg5_.id=subjects6_.treatment_group_id
INNER JOIN subject subject7_
ON subjects6_.subject_id=subject7_.id
INNER JOIN subject_state lsstates8_
ON subject7_.id=lsstates8_.subject_id
INNER JOIN subject_value lsvalues9_
ON lsstates8_.id=lsvalues9_.subject_state_id
INNER JOIN subject_value lsvalues10_
ON lsstates8_.id=lsvalues10_.subject_state_id
LEFT OUTER JOIN subject_state lsstates11_
ON subject7_.id         =lsstates11_.subject_id
AND (lsstates11_.ls_kind='auto flag'
AND lsstates11_.ignored = '0')
LEFT OUTER JOIN subject_value lsvalues12_
ON lsstates11_.id       =lsvalues12_.subject_state_id
AND (lsvalues12_.ls_kind='flag status')
LEFT OUTER JOIN subject_value lsvalues13_
ON lsstates11_.id       =lsvalues13_.subject_state_id
AND (lsvalues13_.ls_kind='flag observation')
LEFT OUTER JOIN subject_value lsvalues14_
ON lsstates11_.id       =lsvalues14_.subject_state_id
AND (lsvalues14_.ls_kind='flag cause')
LEFT OUTER JOIN subject_value lsvalues15_
ON lsstates11_.id       =lsvalues15_.subject_state_id
AND (lsvalues15_.ls_kind='comment')
LEFT OUTER JOIN subject_state lsstates16_
ON subject7_.id         =lsstates16_.subject_id
AND (lsstates16_.ls_kind='preprocess flag'
AND lsstates16_.ignored = '0')
LEFT OUTER JOIN subject_value lsvalues17_
ON lsstates16_.id       =lsvalues17_.subject_state_id
AND (lsvalues17_.ls_kind='flag status')
LEFT OUTER JOIN subject_value lsvalues18_
ON lsstates16_.id       =lsvalues18_.subject_state_id
AND (lsvalues18_.ls_kind='flag observation')
LEFT OUTER JOIN subject_value lsvalues19_
ON lsstates16_.id       =lsvalues19_.subject_state_id
AND (lsvalues19_.ls_kind='flag cause')
LEFT OUTER JOIN subject_value lsvalues20_
ON lsstates16_.id       =lsvalues20_.subject_state_id
AND (lsvalues20_.ls_kind='comment')
LEFT OUTER JOIN subject_state lsstates21_
ON subject7_.id         =lsstates21_.subject_id
AND (lsstates21_.ls_kind='user flag'
AND lsstates21_.ignored = '0')
LEFT OUTER JOIN subject_value lsvalues22_
ON lsstates21_.id       =lsvalues22_.subject_state_id
AND (lsvalues22_.ls_kind='flag status')
LEFT OUTER JOIN subject_value lsvalues23_
ON lsstates21_.id       =lsvalues23_.subject_state_id
AND (lsvalues23_.ls_kind='flag observation')
LEFT OUTER JOIN subject_value lsvalues24_
ON lsstates21_.id       =lsvalues24_.subject_state_id
AND (lsvalues24_.ls_kind='flag cause')
LEFT OUTER JOIN subject_value lsvalues25_
ON lsstates21_.id               =lsvalues25_.subject_state_id
AND (lsvalues25_.ls_kind        ='comment')
WHERE lsstates8_.ls_type        ='data'
AND lsstates8_.ls_kind          ='results'
AND lsvalues9_.ls_type          ='numericValue'
AND lsvalues9_.ls_kind          ='efficacy'
AND lsvalues10_.ls_type         ='codeValue'
AND lsvalues10_.ls_kind         ='batch code'
AND analysisgr1_.ignored        = '0'
AND analysisgr0_.ls_type        ='stringValue'
AND analysisgr0_.ls_kind        ='curve id'
AND analysisgr0_.ignored        = '0'
AND analysisgr2_.ignored        = '0'
AND treatmentg5_.ignored        = '0'
AND subject7_.ignored           = '0'
AND e.ignored = '0'
AND e.deleted = '0'
AND analysisgr1_.ls_type ='data'
AND analysisgr1_.ls_kind ='dose response';

CREATE or REPLACE VIEW API_HTS_TREATMENT_RESULTS
AS
SELECT e.id as experiment_id,
tgv2.code_value AS tested_lot,
tgv2.concentration,
tgv2.conc_unit,
tgv.id AS tgv_id,
tgv.ls_kind as ls_kind,
tgv.operator_kind,
tgv.numeric_value,
tgv.uncertainty,
tgv.unit_kind,
tgv.string_value,
tgv.comments,
tgv.recorded_date,
tgv.public_data,
tgs.id AS state_id,
tgs.treatment_group_id
FROM experiment e
JOIN experiment_analysisgroup eag on e.id=eag.experiment_id
JOIN analysis_group ag ON ag.id = eag.analysis_group_id
LEFT OUTER JOIN analysis_group_state ags on ag.id = ags.ANALYSIS_GROUP_ID
JOIN analysisgroup_treatmentgroup agtg ON agtg.analysis_group_id = eag.analysis_group_id
JOIN treatment_group_state tgs ON tgs.treatment_group_id = agtg.treatment_group_id and tgs.ls_type_and_kind = 'data_results'
JOIN treatment_group_value tgv ON tgv.treatment_state_id = tgs.id and tgv.ls_kind != 'batch code'
JOIN treatment_group_value tgv2 ON tgv2.treatment_state_id = tgs.id and tgv2.ls_kind = 'batch code'
where (ags.ls_type_and_kind is null or ags.ls_type_and_kind != 'data_dose response')
and (ags.ignored is null or ags.ignored = '0')
and e.ignored = '0'
and ag.ignored = '0'
and tgs.ignored = '0'
and tgv.ignored = '0'
and tgv2.ignored = '0';

CREATE OR REPLACE VIEW api_container_contents
AS
  SELECT cntrst.id,
    cntrlbl2.label_text  AS barcode,
    cntrlbl.container_id AS well_id,
    cntrlbl.label_text   AS well_name,
    cntrv1.code_value    AS batch_code,
    cntrv2.numeric_value AS volume,
    cntrv2.string_value  AS volume_string,
    cntrv2.unit_kind     AS volume_unit,
    cntrv3.numeric_value AS concentration,
    cntrv3.string_value  AS concentration_string,
    cntrv3.unit_kind     AS concentration_unit
  FROM container cntr
  JOIN container_state cntrst
  ON cntr.id         = cntrst.container_id
  AND cntrst.ls_kind = 'test compound content'
  AND cntrst.ignored = '0'
  LEFT OUTER JOIN container_label cntrlbl
  ON cntr.id          = cntrlbl.container_id
  AND cntrlbl.ls_kind = 'well name'
  JOIN itx_container_container itxcc
  ON itxcc.second_container_id = cntr.id
  AND itxcc.ls_type            = 'has member'
  LEFT OUTER JOIN container_label cntrlbl2
  ON cntrlbl2.container_id = itxcc.first_container_id
  AND cntrlbl2.ls_kind     = 'plate barcode'
  LEFT OUTER JOIN container_value cntrv1
  ON cntrv1.container_state_id = cntrst.id
  AND cntrv1.ls_kind           = 'batch code'
  LEFT OUTER JOIN container_value cntrv2
  ON cntrv2.container_state_id = cntrst.id
  AND cntrv2.ls_kind           = 'volume'
  LEFT OUTER JOIN container_value cntrv3
  ON cntrv3.container_state_id = cntrst.id
  AND cntrv3.ls_kind           = 'concentration'
  GROUP BY cntrst.id,
    cntrlbl2.label_text,
    cntrlbl.label_text,
    cntrlbl.container_id,
    cntrv1.code_value,
    cntrv2.numeric_value,
    cntrv2.string_value,
    cntrv2.unit_kind,
    cntrv3.numeric_value,
    cntrv3.string_value,
    cntrv3.unit_kind;

-- If anyone is using this, it should be fixed to get the concentration correctly
CREATE OR REPLACE VIEW API_SUBJECT_RESULTS AS 
SELECT p.label_text AS protocol_name,
p.code_name AS protocol_code_name,
e.label_text AS experiment_name,
e.code_name AS experiment_code_name,
ag.code_name AS analysis_group_code_name,
tg.code_name AS treatment_group_code_name,
s.code_name AS subject_code_name,
case 
  when sv2.code_value is not null 
  then sv2.code_value
  else sv5.code_value
end
AS tested_lot, 
sv3.numeric_value AS tested_conc, 
sv3.unit_kind AS tested_conc_unit,
sv4.numeric_value AS tested_time,
sv4.unit_kind AS tested_time_unit,
sv.id AS sv_id, 
sv.ls_kind as ls_kind, 
sv.operator_kind, 
sv.numeric_value as numeric_value,
sv.uncertainty, 
sv.unit_kind,
CASE
WHEN sv.ls_type = 'fileValue' 
	THEN 
		('<A HREF="' || 
		(
			SELECT application_setting.prop_value
			FROM application_setting
        	WHERE application_setting.prop_name = 'BatchDocumentsURL'
        ) || 
        replace(sv.file_value, ' ', '%20') || 
        '">' || 
        sv.comments ||
	' (' ||
        sv.file_value ||
        ')' ||
        '</A>'
		)
WHEN sv.ls_type = 'urlValue' 
	THEN 
		('<A HREF="' || 
        replace(sv.url_value, ' ', '%20') || 
        '">' || 
        sv.comments ||
	' (' ||
        sv.url_value ||
        ')' ||
        '</A>'
		)
WHEN sv.ls_type = 'dateValue'
	THEN to_char(sv.date_value, 'yyyy-mm-dd')
	ELSE sv.string_value
END AS string_value, 
sv.comments, 
sv.recorded_date,
sv.public_data,
ss.id AS state_id,
ss.ls_kind AS state_kind,
ss.ls_type AS state_type
FROM api_protocol p
JOIN api_experiment e ON e.protocol_id = p.protocol_id
JOIN experiment_analysisgroup eag ON eag.experiment_id = e.id
JOIN analysis_group ag ON ag.id = eag.analysis_group_id
JOIN analysisgroup_treatmentgroup agtg ON agtg.analysis_group_id = eag.analysis_group_id
JOIN treatment_group tg ON tg.id = agtg.treatment_group_id
JOIN treatmentgroup_subject tgs ON tgs.treatment_group_id=agtg.treatment_group_id
JOIN subject s ON s.id = tgs.subject_id
JOIN subject_state ss ON ss.subject_id = s.id
JOIN subject_value sv ON sv.subject_state_id = ss.id AND sv.ls_kind <> 'tested concentration' AND sv.ls_kind <> 'batch code' AND sv.ls_kind <> 'time'
LEFT OUTER JOIN subject_value sv2 ON sv2.subject_state_id = ss.id and sv2.ls_kind = 'batch code'
LEFT OUTER JOIN subject_value sv3 ON sv3.subject_state_id = ss.id and sv3.ls_kind = 'tested concentration'
LEFT OUTER JOIN subject_value sv4 ON sv4.subject_state_id = ss.id and sv4.ls_kind = 'time'
LEFT OUTER JOIN subject_state ss2 ON ss2.subject_id = s.id and ss2.ls_kind = 'treatment'
LEFT OUTER JOIN subject_value sv5 ON sv5.subject_state_id = ss2.id and sv5.ls_kind = 'batch code';


-- If anyone is using this, it should be fixed to get the concentration correctly
CREATE OR REPLACE VIEW API_SUBJECT_CONTAINER_RESULTS AS
SELECT p.label_text AS protocol_name,
p.code_name AS protocol_code_name,
e.label_text AS experiment_name,
e.code_name AS experiment_code_name,
ag.code_name AS analysis_group_code_name,
tg.code_name AS treatment_group_code_name,
s.code_name AS subject_code_name,
case
  when sv2.code_value is not null 
  then sv2.code_value
  else sv4.code_value
end
AS tested_lot,
sv3.numeric_value AS tested_conc, 
sv3.unit_kind AS tested_conc_unit,
NULL AS tested_time,
NULL AS tested_time_unit,
NULL AS sv_id, 
cv.ls_kind as ls_kind, 
cv.operator_kind, 
cv.numeric_value as numeric_value,
cv.uncertainty, 
cv.unit_kind,
CASE
WHEN cv.ls_type = 'fileValue' 
	THEN 
		('<A HREF="' || 
		(
			SELECT application_setting.prop_value
			FROM application_setting
        	WHERE application_setting.prop_name = 'BatchDocumentsURL'
        ) || 
        replace(cv.file_value, ' ', '%20') || 
        '">' || 
        cv.comments ||
	' (' ||
        cv.file_value ||
        ')' ||
        '</A>'
		)
WHEN cv.ls_type = 'urlValue' 
	THEN 
		('<A HREF="' || 
        replace(cv.url_value, ' ', '%20') || 
        '">' || 
        cv.comments ||
	' (' ||
        cv.url_value ||
        ')' ||
        '</A>'
		)
WHEN cv.ls_type = 'dateValue'
	THEN to_char(cv.date_value, 'yyyy-mm-dd')
	ELSE cv.string_value
END AS string_value, 
cv.comments, 
cv.recorded_date,
cv.public_data,
cs.id AS state_id,
cs.ls_kind AS state_kind,
cs.ls_type AS state_type
FROM api_protocol p
JOIN api_experiment e ON e.protocol_id = p.protocol_id
JOIN experiment_analysisgroup eag ON eag.experiment_id = e.id
JOIN analysis_group ag ON ag.id = eag.analysis_group_id
JOIN analysisgroup_treatmentgroup agtg ON agtg.analysis_group_id = eag.analysis_group_id
JOIN treatment_group tg ON tg.id = agtg.treatment_group_id
JOIN treatmentgroup_subject tgs ON tgs.treatment_group_id=agtg.treatment_group_id
JOIN subject s ON s.id = tgs.subject_id
JOIN subject_state ss ON ss.subject_id = s.id
JOIN itx_subject_container isc ON isc.subject_id=s.id
JOIN container c ON c.id = isc.container_id
JOIN container_state cs ON cs.container_id = c.id
JOIN container_value cv ON cv.container_state_id = cs.id
LEFT OUTER JOIN subject_value sv2 ON sv2.subject_state_id = ss.id and sv2.ls_kind = 'batch code'
LEFT OUTER JOIN subject_value sv3 ON sv3.subject_state_id = ss.id and sv3.ls_kind = 'tested concentration'
LEFT OUTER JOIN subject_state ss2 ON ss2.subject_id = s.id and ss2.ls_kind = 'treatment'
LEFT OUTER JOIN subject_value sv4 ON sv4.subject_state_id = ss2.id and sv4.ls_kind = 'batch code'
UNION select * from api_subject_results;

CREATE OR REPLACE VIEW API_ALL_DATA as
  SELECT p.label_text as protocol_name,
e.label_text as experiment_name,
e.completion_date,
e.project,
e.scientist,
e.recorded_date as e_recorded_date,
ag.id AS ag_id,
agv2.code_value AS ag_tested_lot,
agv2.concentration AS ag_tested_conc, 
agv2.conc_unit AS ag_tested_conc_unit, 
agv.id AS agv_id, 
agv.ls_kind as ag_value_kind, 
agv.operator_kind as ag_operator, 
 CASE 
    WHEN agv.ls_kind like '%curve id' THEN null
    ELSE agv.numeric_value
  END as ag_numeric_value,
agv.uncertainty as ag_uncertainty, 
agv.unit_kind as ag_unit,
CASE
WHEN agv.ls_type = 'fileValue' 
THEN 
		('<A HREF="' || 
		(
			SELECT application_setting.prop_value
			FROM application_setting
        	WHERE application_setting.prop_name = 'BatchDocumentsURL'
        ) || 
        replace(agv.file_value, ' ', '%20') || 
        '">' || 
        agv.comments ||
	' (' ||
        agv.file_value ||
        ')' ||
        '</A>'
		)
WHEN agv.ls_type = 'urlValue' 
THEN 
		('<A HREF="' || 
        replace(agv.url_value, ' ', '%20') || 
        '">' || 
        agv.comments ||
	' (' ||
        agv.url_value ||
        ')' ||
        '</A>'
		)
ELSE agv.string_value
END AS ag_string_value, 
agv.comments as ag_comments, 
agv.recorded_date as ag_recorded_date,
agv.public_data as ag_public_data,

tg.id AS tg_id,
case 
when tgv2.code_value is not null 
then tgv2.code_value
else tgv5.code_value
end
AS tg_tested_lot, 
case 
when tgv2.code_value is not null 
then tgv2.concentration
else tgv5.concentration
end
AS tg_tested_conc,
case 
when tgv2.code_value is not null 
then tgv2.conc_unit
else tgv5.conc_unit
end
AS tg_tested_conc_unit,
tgv4.numeric_value AS tg_tested_time,
tgv4.unit_kind AS tg_tested_time_unit,
tgv.id AS tgv_id,
tgv.ls_kind as tg_value_kind,
tgv.operator_kind as tg_operator,
tgv.numeric_value as tg_numeric_value,
tgv.uncertainty as tg_uncertainty, 
tgv.unit_kind as tg_unit,
CASE
WHEN tgv.ls_type = 'fileValue' 
THEN 
		('<A HREF="' || 
		(
			SELECT application_setting.prop_value
			FROM application_setting
      	WHERE application_setting.prop_name = 'BatchDocumentsURL'
      ) || 
      replace(tgv.file_value, ' ', '%20') || 
      '">' || 
      tgv.comments ||
	' (' ||
      tgv.file_value ||
      ')' ||
      '</A>'
		)
WHEN tgv.ls_type = 'urlValue' 
THEN 
		('<A HREF="' || 
      replace(tgv.url_value, ' ', '%20') || 
      '">' || 
      tgv.comments ||
	' (' ||
      tgv.url_value ||
      ')' ||
      '</A>'
		)
WHEN tgv.ls_type = 'dateValue'
THEN to_char(tgv.date_value, 'yyyy-mm-dd')
ELSE tgv.string_value
END AS tg_string_value,
tgv.comments as tg_comments, 
tgv.recorded_date as tg_recorded_date,
tgv.public_data as tg_public_data,
tgs.id AS tg_state_id,
tgs.ls_kind AS tg_state_kind,
tgs.ls_type AS tg_state_type,
s.id as s_id,
case 
  when sv2.code_value is not null 
  then sv2.code_value
  else sv5.code_value
end
AS s_tested_lot, 
case 
  when sv2.code_value is not null 
  then sv2.concentration
  else sv5.concentration
end
AS s_tested_conc, 
case 
  when sv2.code_value is not null 
  then sv2.conc_unit
  else sv5.conc_unit
end
AS s_tested_conc_unit,
sv4.numeric_value AS s_tested_time,
sv4.unit_kind AS s_tested_time_unit,
sv.id AS sv_id, 
sv.ls_kind as s_value_kind, 
sv.operator_kind as s_operator, 
sv.numeric_value as s_numeric_value,
sv.uncertainty as s_uncertainty, 
sv.unit_kind as s_unit,
CASE
WHEN sv.ls_type = 'fileValue' 
THEN 
		('<A HREF="' || 
		(
			SELECT application_setting.prop_value
			FROM application_setting
        	WHERE application_setting.prop_name = 'BatchDocumentsURL'
        ) || 
        replace(sv.file_value, ' ', '%20') || 
        '">' || 
        sv.comments ||
	' (' ||
        sv.file_value ||
        ')' ||
        '</A>'
		)
WHEN sv.ls_type = 'urlValue' 
THEN 
		('<A HREF="' || 
        replace(sv.url_value, ' ', '%20') || 
        '">' || 
        sv.comments ||
	' (' ||
        sv.url_value ||
        ')' ||
        '</A>'
		)
WHEN sv.ls_type = 'dateValue'
THEN to_char(sv.date_value, 'yyyy-mm-dd')
ELSE sv.string_value
END AS s_string_value, 
sv.comments as s_comments, 
sv.recorded_date as s_recorded_date,
sv.public_data as s_public_data,
ss.id AS s_state_id,
ss.ls_kind AS s_state_kind,
ss.ls_type AS s_state_type,

isc.ls_type AS itx_subject_container_type,
isc.ls_kind AS itx_subject_container_kind,

c.id as c_id, 
cv.id AS cv_id, 
cv.ls_kind as c_value_kind, 
cv.operator_kind as c_operator, 
cv.numeric_value as c_numeric_value,
cv.uncertainty as c_uncertainty, 
cv.unit_kind as c_unit,
CASE
WHEN cv.ls_type = 'fileValue' 
THEN 
		('<A HREF="' || 
		(
			SELECT application_setting.prop_value
			FROM application_setting
        	WHERE application_setting.prop_name = 'BatchDocumentsURL'
        ) || 
        replace(cv.file_value, ' ', '%20') || 
        '">' || 
        cv.comments ||
	' (' ||
        cv.file_value ||
        ')' ||
        '</A>'
		)
WHEN cv.ls_type = 'urlValue' 
THEN 
		('<A HREF="' || 
        replace(cv.url_value, ' ', '%20') || 
        '">' || 
        cv.comments ||
	' (' ||
        cv.url_value ||
        ')' ||
        '</A>'
		)
WHEN cv.ls_type = 'dateValue'
  THEN to_char(cv.date_value, 'yyyy-mm-dd')
WHEN cv.ls_type = 'codeValue'
  THEN cv.code_value
ELSE cv.string_value
END AS c_string_value, 
cv.comments as c_comments, 
cv.recorded_date as c_recorded_date,
cv.public_data as c_public_data,
cs.id AS c_state_id,
cs.ls_kind AS c_state_kind,
cs.ls_type AS c_state_type

FROM api_protocol p
JOIN api_experiment e on e.protocol_id = p.protocol_id
JOIN experiment_analysisgroup eag ON eag.experiment_id = e.id
JOIN analysis_group ag ON ag.id = eag.analysis_group_id
JOIN analysisgroup_treatmentgroup agtg ON agtg.analysis_group_id = ag.id
JOIN treatment_group tg ON tg.id = agtg.treatment_group_id
JOIN treatmentgroup_subject tgsmm ON tgsmm.treatment_group_id = tg.id
JOIN subject s ON s.id = tgsmm.subject_id
LEFT OUTER JOIN analysis_GROUP_state ags ON ags.analysis_GROUP_id = ag.id AND ags.ignored = '0'
LEFT OUTER JOIN analysis_GROUP_value agv ON agv.analysis_state_id = ags.id AND agv.ls_kind <> 'batch code' AND agv.ignored = '0'
LEFT OUTER JOIN analysis_GROUP_value agv2 ON agv2.analysis_state_id = ags.id and agv2.ls_kind = 'batch code' AND agv2.ignored = '0'
LEFT OUTER JOIN treatment_group_state tgs ON tgs.treatment_group_id = tg.id AND tgs.ignored = '0'
LEFT OUTER JOIN treatment_group_value tgv ON tgv.treatment_state_id = tgs.id AND tgv.ls_kind <> 'batch code' AND tgv.ls_kind <> 'time' AND tgv.ignored = '0'
LEFT OUTER JOIN treatment_group_value tgv2 ON tgv2.treatment_state_id = tgs.id and tgv2.ls_kind = 'batch code' AND tgv2.ignored = '0'
LEFT OUTER JOIN treatment_group_value tgv4 ON tgv4.treatment_state_id = tgs.id and tgv4.ls_kind = 'time' AND tgv4.ignored = '0'
LEFT OUTER JOIN treatment_group_state tgs2 ON tgs2.treatment_group_id = tg.id and tgs2.ls_kind = 'treatment' AND tgs2.ignored = '0'
LEFT OUTER JOIN treatment_group_value tgv5 ON tgv5.treatment_state_id = tgs2.id and tgv5.ls_kind = 'batch code' AND tgv5.ignored = '0'
LEFT OUTER JOIN subject_state ss ON ss.subject_id = s.id AND ss.ignored = '0'
LEFT OUTER JOIN subject_value sv ON sv.subject_state_id = ss.id AND sv.ls_kind <> 'batch code' AND sv.ls_kind <> 'time' AND sv.ignored = '0'
LEFT OUTER JOIN subject_value sv2 ON sv2.subject_state_id = ss.id and sv2.ls_kind = 'batch code' AND sv2.ignored = '0'
LEFT OUTER JOIN subject_value sv4 ON sv4.subject_state_id = ss.id and sv4.ls_kind = 'time' AND sv4.ignored = '0'
LEFT OUTER JOIN subject_state ss2 ON ss2.subject_id = s.id and ss2.ls_kind = 'treatment' AND ss2.ignored = '0'
LEFT OUTER JOIN subject_value sv5 ON sv5.subject_state_id = ss2.id and sv5.ls_kind = 'batch code' AND sv5.ignored = '0'
LEFT OUTER JOIN itx_subject_container isc ON isc.subject_id=s.id AND isc.ignored = '0'
LEFT OUTER JOIN container c ON c.id = isc.container_id AND c.ignored = '0'
LEFT OUTER JOIN container_state cs ON cs.container_id = c.id AND cs.ignored = '0'
LEFT OUTER JOIN container_value cv ON cv.container_state_id = cs.id AND cv.ignored = '0'
where ag.ignored = '0'
and tg.ignored = '0'
and s.ignored = '0';

CREATE OR REPLACE VIEW api_experiment_results
as
select exp.code_name as expt_code_name, aagr.* from api_analysis_group_results aagr
join experiment exp on aagr.experiment_id = exp.id;

CREATE OR REPLACE VIEW batch_code_experiment_links AS
select agv.code_value as batch_code,
    ('<A HREF="' ||
    (
        SELECT application_setting.prop_value
        FROM application_setting
        WHERE application_setting.prop_name = 'batch_code_experiment_url'
    ) ||
    replace(e.code_name, ' ', '%20') ||
    '">' ||
    p.label_text ||
    '::' ||
    e.experiment_name ||
' (' ||
    to_char(e.RECORDED_DATE, 'yyyy-mm-dd') ||
    ')' ||
    '</A>'
    ) as experiment_code_link
FROM api_protocol p
join api_experiment e on p.PROTOCOL_ID = e.PROTOCOL_ID
JOIN experiment_analysisgroup eag ON eag.experiment_id = e.id
JOIN analysis_GROUP ag ON ag.id = eag.analysis_group_id
JOIN analysis_GROUP_state ags ON ags.analysis_GROUP_id = ag.id
JOIN analysis_GROUP_value agv ON agv.analysis_state_id = ags.id AND agv.ls_kind = 'batch code';

CREATE OR REPLACE VIEW api_system_statistics AS
SELECT
	api_protocol.code_name AS protocol_code,
	api_protocol.label_text AS protocol_name,
	api_experiment.code_name AS experiment_code,
	api_experiment.label_text AS experiment_name,
	api_experiment.recorded_date AS experiment_date,
	COUNT(DISTINCT api_analysis_group_results.ag_id) AS analysis_groups,
	COUNT(DISTINCT api_subject_results.subject_code_name) AS subjects,
	COUNT(DISTINCT api_subject_results.sv_id) AS raw_data_points
FROM api_protocol
	LEFT JOIN api_experiment
		ON api_protocol.protocol_id = api_experiment.protocol_id
	LEFT JOIN api_analysis_group_results
		ON api_experiment.id = api_analysis_group_results.experiment_id
	LEFT JOIN api_subject_results
		ON api_analysis_group_results.ag_code_name = api_subject_results.analysis_group_code_name
GROUP BY
	api_protocol.code_name,
	api_experiment.recorded_date,
	api_protocol.label_text,
	api_experiment.code_name,
	api_experiment.label_text;

--grants
GRANT SELECT on api_protocol TO seurat;
GRANT SELECT on api_experiment TO seurat;
GRANT SELECT on api_analysis_group_results TO seurat;
GRANT SELECT on p_api_analysis_group_results TO seurat;
GRANT select on api_curve_params to seurat;
GRANT SELECT on api_dose_response TO seurat;
grant select on API_HTS_TREATMENT_RESULTS to seurat;

-----------------------------
-- Run all of these as seurat
-----------------------------

CREATE OR REPLACE SYNONYM "SEURAT"."API_PROTOCOL" FOR "ACAS"."API_PROTOCOL";
CREATE OR REPLACE SYNONYM "SEURAT"."API_EXPERIMENT" FOR "ACAS"."API_EXPERIMENT";
--CREATE OR REPLACE SYNONYM "SEURAT"."API_ANALYSIS_GROUP_RESULTS" FOR "ACAS"."API_ANALYSIS_GROUP_RESULTS";
CREATE OR REPLACE SYNONYM "SEURAT"."P_API_ANALYSIS_GROUP_RESULTS" FOR "ACAS"."P_API_ANALYSIS_GROUP_RESULTS";
CREATE OR REPLACE SYNONYM "SEURAT"."API_CURVE_PARAMS" FOR "ACAS"."API_CURVE_PARAMS";
CREATE OR REPLACE SYNONYM "SEURAT"."API_DOSE_RESPONSE" FOR "ACAS"."API_DOSE_RESPONSE";
CREATE OR REPLACE SYNONYM "SEURAT"."API_ALL_DATA" FOR "ACAS"."API_ALL_DATA";