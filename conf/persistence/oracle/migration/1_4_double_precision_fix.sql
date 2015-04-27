
ALTER TABLE analysis_group_value
ALTER COLUMN numeric_value TYPE double precision,
ALTER COLUMN uncertainty TYPE double precision;


ALTER TABLE container_value
ALTER COLUMN numeric_value TYPE double precision,
ALTER COLUMN uncertainty TYPE double precision;


ALTER TABLE experiment_value
ALTER COLUMN numeric_value TYPE double precision,
ALTER COLUMN uncertainty TYPE double precision;


ALTER TABLE itx_container_container_value
ALTER COLUMN numeric_value TYPE double precision,
ALTER COLUMN uncertainty TYPE double precision;


ALTER TABLE itx_protocol_protocol_value
ALTER COLUMN numeric_value TYPE double precision,
ALTER COLUMN uncertainty TYPE double precision;


ALTER TABLE itx_subject_container_value
ALTER COLUMN numeric_value TYPE double precision,
ALTER COLUMN uncertainty TYPE double precision;


ALTER TABLE ls_thing_value
ALTER COLUMN numeric_value TYPE double precision,
ALTER COLUMN uncertainty TYPE double precision;


ALTER TABLE protocol_value
ALTER COLUMN numeric_value TYPE double precision,
ALTER COLUMN uncertainty TYPE double precision;


ALTER TABLE subject_value
ALTER COLUMN numeric_value TYPE double precision,
ALTER COLUMN uncertainty TYPE double precision;


ALTER TABLE treatment_group_value
ALTER COLUMN numeric_value TYPE double precision,
ALTER COLUMN uncertainty TYPE double precision;