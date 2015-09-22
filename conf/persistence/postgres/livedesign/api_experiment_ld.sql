CREATE OR REPLACE VIEW api_experiment_ld AS
(SELECT * FROM api_experiment)
UNION
(SELECT -1 AS id,
cast('EXPT-LOT_PROPERTIES::Lot Properties' as text) as experiment_name,
cast('EXPT-LOT_PROPERTIES' as character varying(255)) as code_name,
cast('Lot Properties' as character varying(255)) as label_text,
cast(NULL as character varying(255)) as kind,
cast(NULL as character varying(255)) as recorded_by,
cast(NULL as timestamp without time zone) as recorded_date,
cast(NULL as character varying(1024)) as short_description,
-1 as protocol_id,
cast(NULL as text) as analysis_result_html,
cast(NULL as text) as analysis_status,
cast(NULL as timestamp without time zone) as completion_date,
cast(NULL as text) as notebook,
cast(NULL as text) as notebook_page,
cast(NULL as text) as project,
cast(NULL as text) as status,
cast(NULL as text) as scientist,
cast(NULL as text) as hts_format
);

ALTER TABLE api_experiment_ld
  OWNER TO acas;
GRANT ALL ON TABLE api_experiment_ld TO acas;
GRANT SELECT ON TABLE api_experiment_ld TO seurat;
