UPDATE protocol_value SET code_value = string_value, string_value = null, code_origin = 'ACAS authors', ls_type = 'codeValue', ls_type_and_kind = 'codeValue_scientist' WHERE ls_kind = 'scientist';
UPDATE experiment_value SET code_value = string_value, string_value = null, code_origin = 'ACAS authors', ls_type = 'codeValue', ls_type_and_kind = 'codeValue_scientist' WHERE ls_kind = 'scientist';
UPDATE analysis_group_value SET code_value = string_value, string_value = null, code_origin = 'ACAS authors', ls_type = 'codeValue', ls_type_and_kind = 'codeValue_scientist' WHERE ls_kind = 'scientist';
UPDATE treatment_group_value SET code_value = string_value, string_value = null, code_origin = 'ACAS authors', ls_type = 'codeValue', ls_type_and_kind = 'codeValue_scientist' WHERE ls_kind = 'scientist';
UPDATE subject_value SET code_value = string_value, string_value = null, code_origin = 'ACAS authors', ls_type = 'codeValue', ls_type_and_kind = 'codeValue_scientist' WHERE ls_kind = 'scientist';
UPDATE ls_thing_value SET code_value = string_value, string_value = null, code_origin = 'ACAS authors', ls_type = 'codeValue', ls_type_and_kind = 'codeValue_scientist' WHERE ls_kind = 'scientist';

CREATE OR REPLACE VIEW api_experiment AS 
 SELECT e.id, 
    (e.code_name::text || '::'::text) || el.label_text::text AS experiment_name, 
    e.code_name, el.label_text, e.ls_type_and_kind AS kind, e.recorded_by, 
    e.recorded_date, e.short_description, e.protocol_id, 
    max(
        CASE ev.ls_kind
            WHEN 'analysis result html'::text THEN ev.clob_value
            ELSE NULL::text
        END) AS analysis_result_html, 
    max(
        CASE ev.ls_kind
            WHEN 'analysis status'::text THEN ev.string_value
            ELSE NULL::character varying
        END::text) AS analysis_status, 
    max(
        CASE ev.ls_kind
            WHEN 'completion date'::text THEN ev.date_value
            ELSE NULL::timestamp without time zone
        END) AS completion_date, 
    max(
        CASE ev.ls_kind
            WHEN 'notebook'::text THEN ev.string_value
            ELSE NULL::character varying
        END::text) AS notebook, 
    max(
        CASE ev.ls_kind
            WHEN 'notebook page'::text THEN ev.string_value
            ELSE NULL::character varying
        END::text) AS notebook_page, 
    max(
        CASE ev.ls_kind
            WHEN 'project'::text THEN ev.code_value
            ELSE NULL::character varying
        END::text) AS project, 
    max(
        CASE ev.ls_kind
            WHEN 'status'::text THEN ev.string_value
            ELSE NULL::character varying
        END::text) AS status, 
    max(
        CASE ev.ls_kind
            WHEN 'scientist'::text THEN ev.code_value
            ELSE NULL::character varying
        END::text) AS scientist
   FROM experiment e
   JOIN experiment_label el ON e.id = el.experiment_id
   JOIN experiment_state es ON e.id = es.experiment_id
   JOIN experiment_value ev ON es.id = ev.experiment_state_id
  WHERE e.ignored = false AND el.preferred = true AND el.ignored = false AND es.ls_kind::text = 'experiment metadata'::text
  GROUP BY e.id, e.code_name, e.ls_type_and_kind, e.recorded_by, e.recorded_date, e.short_description, e.protocol_id, el.label_text;

ALTER TABLE api_experiment
  OWNER TO acas;
GRANT ALL ON TABLE api_experiment TO acas;

UPDATE experiment_value
SET ls_type        = 'codeValue',
 ls_kind          = 'experiment status',
 ls_type_and_kind = 'codeValue_experiment status',
 code_value       = lower(string_value),
 string_value     = NULL
WHERE id          IN
 (SELECT ev.id
 FROM experiment_state es
 JOIN experiment_value ev
 ON es.id         = ev.EXPERIMENT_STATE_ID
 WHERE es.ls_type = 'metadata'
 AND es.ls_kind   = 'experiment metadata'
 AND ev.ls_type   = 'stringValue'
 AND ev.ls_kind   = 'status'
 );