CREATE OR REPLACE VIEW acas.api_protocol_ld AS
(SELECT * FROM api_protocol)
UNION
(SELECT -1 AS protocol_id,
cast('PROT-LOT_PROPERTIES' as character varying(255)) as code_name,
cast(NULL as character varying(255)) as recorded_by,
cast(NULL as timestamp without time zone) as recorded_date,
cast(NULL as character varying(1024)) as short_description,
cast('Lot Properties' as character varying(255)) as label_text
);

ALTER TABLE acas.api_protocol_ld
  OWNER TO acas;
GRANT ALL ON TABLE acas.api_protocol_ld TO acas;
GRANT SELECT ON TABLE acas.api_protocol_ld TO seurat;
