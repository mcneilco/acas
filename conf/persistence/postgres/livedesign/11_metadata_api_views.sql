CREATE OR REPLACE VIEW acas.api_protocol_metadata AS 
SELECT p.id AS protocol_id,
    p.code_name,
	pv1.clob_value as protocol_comments,
	pv2.string_value as protocol_notebook,
	dv1.label_text as protocol_status
   FROM protocol p
	 LEFT JOIN protocol_state ps2 on p.id = ps2.protocol_id AND ps2.ls_kind::text = 'protocol metadata' AND ps2.ls_type::text = 'metadata'
	 LEFT JOIN protocol_value pv1 on ps2.id = pv1.protocol_state_id AND pv1.ls_kind::text = 'protocol comments' AND pv1.ls_type::text = 'clobValue'
	 LEFT JOIN protocol_value pv2 on ps2.id = pv2.protocol_state_id AND pv2.ls_kind::text = 'notebook' AND pv2.ls_type::text = 'stringValue'
	 LEFT JOIN protocol_value pv3 on ps2.id = pv3.protocol_state_id AND pv3.ls_kind::text = 'protocol status' AND pv3.ls_type::text = 'codeValue' AND pv3.code_type = 'protocol' and pv3.code_kind = 'status' and pv3.code_origin = 'ACAS DDICT'
	 LEFT JOIN ddict_value dv1 on pv3.code_value = dv1.short_name AND dv1.ls_type::text = 'protocol' AND dv1.ls_kind::text = 'status'
  WHERE p.ignored = false;

ALTER TABLE acas.api_protocol_metadata
  OWNER TO acas;
GRANT ALL ON TABLE acas.api_protocol_metadata TO acas;
GRANT SELECT ON TABLE acas.api_protocol_metadata TO seurat;


CREATE OR REPLACE VIEW acas.api_experiment_metadata AS 
SELECT e.id AS experiment_id,
    e.code_name,
	ev1.clob_value as comments,
	ev2.string_value as notebook,
	dv1.label_text as status
   FROM experiment e
	 JOIN experiment_state es1 on e.id = es1.experiment_id AND es1.ls_kind::text = 'experiment metadata' AND es1.ls_type::text = 'metadata'
	 LEFT JOIN experiment_value ev1 on es1.id = ev1.experiment_state_id AND ev1.ls_kind::text = 'experiment comments' AND ev1.ls_type::text = 'clobValue'
	 LEFT JOIN experiment_value ev2 on es1.id = ev2.experiment_state_id AND ev2.ls_kind::text = 'notebook' AND ev2.ls_type::text = 'stringValue'
	 LEFT JOIN experiment_value ev3 on es1.id = ev3.experiment_state_id AND ev3.ls_kind::text = 'experiment status' AND ev3.ls_type::text = 'codeValue' AND ev3.code_type = 'experiment' and ev3.code_kind = 'status' and ev3.code_origin = 'ACAS DDICT'
	 LEFT JOIN ddict_value dv1 on ev3.code_value = dv1.short_name AND dv1.ls_type::text = 'experiment' AND dv1.ls_kind::text = 'status'
  WHERE e.ignored = false;

ALTER TABLE acas.api_experiment_metadata
  OWNER TO acas;
GRANT ALL ON TABLE acas.api_experiment_metadata TO acas;
GRANT SELECT ON TABLE acas.api_experiment_metadata TO seurat;


CREATE OR REPLACE VIEW compound.parent_alias_common_name AS 
select * from parent_alias
where ls_type = 'other name' and ls_kind = 'common_name';

ALTER TABLE compound.parent_alias_common_name
  OWNER TO compound_admin;
GRANT ALL ON TABLE compound.parent_alias_common_name TO compound_admin;
GRANT SELECT ON TABLE compound.parent_alias_common_name TO seurat;



CREATE OR REPLACE VIEW compound.vw_lot_appearance AS 
select lot.id, lot.color || ' ' || ps.name as appearance 
from lot 
LEFT OUTER join physical_state ps on lot.physical_state = ps.id;

ALTER TABLE compound.vw_lot_appearance
  OWNER TO compound_admin;
GRANT ALL ON TABLE compound.vw_lot_appearance TO compound_admin;
GRANT SELECT ON TABLE compound.vw_lot_appearance TO seurat;

