SELECT
  dose AS "conc",
  response AS "result",
  responseunits AS "result_type",
  userflagobservation as "result_flag",
  null as "result_stddev",
  curvevalueid as "observation_id"
FROM api_dose_response
where curvevalueid in (CURVEIDS)
