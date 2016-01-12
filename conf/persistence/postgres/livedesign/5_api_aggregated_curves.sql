CREATE OR REPLACE VIEW acas.api_aggregated_curves as
SELECT max(ag_id) as ag_id,
	cast(max(ag_code_name) as character varying(255)) as ag_code_name,
	max(experiment_id) as experiment_id,
	tested_lot,
	max(tested_conc) as tested_conc,
	cast(max(tested_conc_unit) as character varying(255)) as tested_conc_unit,
	max(agv_id) as agv_id,
	ls_type,
	ls_kind,
	cast(max(operator_kind) as character varying(10)) as operator_kind,
	max(numeric_value) as numeric_value,
	cast(max(uncertainty) as numeric(38,18)) as uncertainty,
	cast(max(unit_kind) as character varying(25)) as unit_kind,
	cast(array_to_string(array_agg(string_value),',') as character varying) as string_value,
	max(clob_value) as clob_value,
	cast(max(comments) as character varying(512)) as comments,
	max(aagr.recorded_date) as recorded_date,
	bool_or(public_data) as public_data
 FROM api_analysis_group_results aagr
 JOIN api_experiment e ON aagr.experiment_id = e.id
 WHERE ls_kind = 'curve id'
 GROUP BY tested_lot, e.protocol_id, ls_type, ls_kind;

ALTER TABLE acas.api_aggregated_curves
  OWNER TO acas;
GRANT ALL ON TABLE acas.api_aggregated_curves TO acas;
GRANT SELECT ON TABLE acas.api_aggregated_curves TO seurat;