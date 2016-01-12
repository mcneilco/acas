-- View: compound.application_paths_ld

-- DROP VIEW compound.application_paths_ld;

CREATE OR REPLACE VIEW compound.application_paths_ld AS 
 SELECT cmpd_reg_app_setting.id,
    cmpd_reg_app_setting.prop_name,
    (cmpd_reg_app_setting_pivot_full_path.full_path || '/'::text) || cmpd_reg_app_setting.prop_value::text AS path
   FROM ( SELECT cmpd_reg_app_setting_pivot.prefix,
            cmpd_reg_app_setting_pivot.host,
            cmpd_reg_app_setting_pivot.path,
            (((((cmpd_reg_app_setting_pivot.prefix || '://'::text) || cmpd_reg_app_setting_pivot.host))) || ':' || cmpd_reg_app_setting_pivot.port || '/'::text) || cmpd_reg_app_setting_pivot.path AS full_path
           FROM ( SELECT max(
                        CASE
                            WHEN cmpd_reg_app_setting_1.prop_name::text = 'prefix'::text THEN cmpd_reg_app_setting_1.prop_value
                            ELSE NULL::character varying
                        END::text) AS prefix,
                    max(
                        CASE
                            WHEN cmpd_reg_app_setting_1.prop_name::text = 'host'::text THEN cmpd_reg_app_setting_1.prop_value
                            ELSE NULL::character varying
                        END::text) AS host,
                    max(
                        CASE
                            WHEN cmpd_reg_app_setting_1.prop_name::text = 'port'::text THEN cmpd_reg_app_setting_1.prop_value
                            ELSE NULL::character varying
                        END::text) AS port,
                    max(
                        CASE
                            WHEN cmpd_reg_app_setting_1.prop_name::text = 'path'::text THEN cmpd_reg_app_setting_1.prop_value
                            ELSE NULL::character varying
                        END::text) AS path
                   FROM cmpd_reg_app_setting cmpd_reg_app_setting_1) cmpd_reg_app_setting_pivot) cmpd_reg_app_setting_pivot_full_path,
    cmpd_reg_app_setting
  WHERE cmpd_reg_app_setting.prop_name::text ~~ '%_path'::text;

ALTER TABLE compound.application_paths_ld
  OWNER TO compound_admin;
GRANT ALL ON TABLE compound.application_paths_ld TO compound_admin;
GRANT ALL ON TABLE compound.application_paths_ld TO compound;
GRANT SELECT ON TABLE compound.application_paths_ld TO seurat;
