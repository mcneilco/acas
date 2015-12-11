-- View: compound.api_file_list_ld

-- DROP VIEW compound.api_file_list_ld;

CREATE OR REPLACE VIEW compound.api_file_list_ld AS 
 SELECT file_list.id AS file_id,
    lot.corp_name AS lot_corp_name,
    lot.id AS lot_id,
    file_list.name,
    file_list.description,
    (((((('<A HREF="'::text || application_paths_ld.path) || replace(file_list.url::text, ' '::text, '%20'::text)) || '" target="_blank">'::text) || file_list.name::text) || ' ('::text) || file_list.description::text) || ')</A>'::text AS fileref
   FROM application_paths_ld,
    lot
     JOIN file_list ON lot.id = file_list.lot
  WHERE application_paths_ld.prop_name::text = 'file_path'::text;

ALTER TABLE compound.api_file_list_ld
  OWNER TO compound_admin;
GRANT ALL ON TABLE compound.api_file_list_ld TO compound_admin;
GRANT SELECT ON TABLE compound.api_file_list_ld TO seurat;
GRANT ALL ON TABLE compound.api_file_list_ld TO acas;
