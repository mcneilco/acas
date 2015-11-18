--WARNING: DO NOT RUN THIS FILE WITHOUT FIRST INSERTING CORRECT HOSTNAMES
--DELETE FROM cmpd_reg_app_setting;

INSERT INTO cmpd_reg_app_setting (id, comments, ignored, prop_name, prop_value, recorded_date, version)
VALUES (1, null, false, 'server_address', 'INSERT HOSTNAME HERE', DEFAULT, 0);
INSERT INTO cmpd_reg_app_setting (id, comments, ignored, prop_name, prop_value, recorded_date, version)
VALUES (2, null, false, 'prefix', 'http', DEFAULT, 0);
INSERT INTO cmpd_reg_app_setting (id, comments, ignored, prop_name, prop_value, recorded_date, version)
VALUES (3, null, false, 'host', 'INSERT HOSTNAME HERE', DEFAULT, 0);
INSERT INTO cmpd_reg_app_setting (id, comments, ignored, prop_name, prop_value, recorded_date, version)
VALUES (4, null, false, 'port', '8080', DEFAULT, 0);
INSERT INTO cmpd_reg_app_setting (id, comments, ignored, prop_name, prop_value, recorded_date, version)
VALUES (5, null, false, 'path', 'cmpdreg', DEFAULT, 0);
INSERT INTO cmpd_reg_app_setting (id, comments, ignored, prop_name, prop_value, recorded_date, version)
VALUES (6, null, false, 'file_path', 'MultipleFilePicker/', DEFAULT, 0);
INSERT INTO cmpd_reg_app_setting (id, comments, ignored, prop_name, prop_value, recorded_date, version)
VALUES (7, null, false, 'lot_path', '#lot', DEFAULT, 0);
INSERT INTO cmpd_reg_app_setting (id, comments, ignored, prop_name, prop_value, recorded_date, version)
VALUES (8, null, false, 'ld_prefix', 'https', DEFAULT, 0);
INSERT INTO cmpd_reg_app_setting (id, comments, ignored, prop_name, prop_value, recorded_date, version)
VALUES (9, null, false, 'ld_host', 'INSERT LD HOSTNAME HERE', DEFAULT, 0);