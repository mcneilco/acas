SELECT
  swi.conc,
  swi.result,
  swi.result_type,
  swi.result_flag,
  swi.result_stddev,
  swi.observation_id
FROM syn_well_info swi
where observation_id in (OBSERVATIONIDS)
