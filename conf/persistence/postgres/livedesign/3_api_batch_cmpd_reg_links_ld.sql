-- View: compound.api_batch_cmpd_reg_links_ld

-- DROP VIEW compound.api_batch_cmpd_reg_links_ld;

CREATE OR REPLACE VIEW compound.api_batch_cmpd_reg_links_ld AS 
 SELECT lot.corp_name AS lot_corp_name,
    lot.id AS lot_id,
    ((((('<A HREF="'::text || application_paths_ld.path) || '/'::text) || replace(lot.corp_name::text, ' '::text, '%20'::text)) || '" target="_blank">'::text) || lot.corp_name::text) || '</A>'::text AS lot_registration_atag,
    (application_paths_ld.path || '/'::text) || replace(lot.corp_name::text, ' '::text, '%20'::text) AS lot_registration_url
   FROM lot,
    application_paths_ld
  WHERE application_paths_ld.prop_name::text = 'lot_path'::text;

ALTER TABLE compound.api_batch_cmpd_reg_links_ld
  OWNER TO compound_admin;
GRANT ALL ON TABLE compound.api_batch_cmpd_reg_links_ld TO compound_admin;
GRANT SELECT ON TABLE compound.api_batch_cmpd_reg_links_ld TO seurat;
GRANT ALL ON TABLE compound.api_batch_cmpd_reg_links_ld TO acas;
