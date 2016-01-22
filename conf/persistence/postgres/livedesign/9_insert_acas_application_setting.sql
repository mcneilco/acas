--WARNING: DO NOT RUN THIS FILE WITHOUT FIRST INSERTING CORRECT HOSTNAMES
--DELETE FROM acas.application_setting;

INSERT INTO application_setting (id, comments, ignored, prop_name, prop_value, recorded_date, version)
VALUES (1, null, false, 'host_name', 'INSERT HOSTNAME HERE', DEFAULT, 0);
INSERT INTO application_setting (id, comments, ignored, prop_name, prop_value, recorded_date, version)
VALUES (2, null, false, 'url_prefix', 'http://', DEFAULT, 0);
INSERT INTO application_setting (id, comments, ignored, prop_name, prop_value, recorded_date, version)
VALUES (3, null, false, 'acas_port', '3000', DEFAULT, 0);
INSERT INTO application_setting (id, comments, ignored, prop_name, prop_value, recorded_date, version)
VALUES (4, null, false, 'datafiles_url', '/datafiles/', DEFAULT, 0);
INSERT INTO application_setting (id, comments, ignored, prop_name, prop_value, recorded_date, version)
VALUES (5, null, false, 'racas_port', '1080', DEFAULT, 0);
INSERT INTO application_setting (id, comments, ignored, prop_name, prop_value, recorded_date, version)
VALUES (6, null, false, 'curve_render_url', '/r-services-api/curve/render/dr?curveIds=', DEFAULT, 0);
INSERT INTO application_setting (id, comments, ignored, prop_name, prop_value, recorded_date, version)
VALUES (7, null, false, 'cmpdreg_port', '8080', DEFAULT, 0);
INSERT INTO application_setting (id, comments, ignored, prop_name, prop_value, recorded_date, version)
VALUES (8, null, false, 'cmpdreg_batch_url', '/cmpdreg/#lot/', DEFAULT, 0);
INSERT INTO application_setting (id, comments, ignored, prop_name, prop_value, recorded_date, version)
VALUES (9, null, false, 'cmpdreg_file_url', '/cmpdreg/MultipleFilePicker/', DEFAULT, 0);
INSERT INTO application_setting (id, comments, ignored, prop_name, prop_value, recorded_date, version)
VALUES (10, null, false, 'img_width', '100%', DEFAULT, 0);
INSERT INTO application_setting (id, comments, ignored, prop_name, prop_value, recorded_date, version)
VALUES (11, null, false, 'img_height', '100%', DEFAULT, 0);
INSERT INTO application_setting (id, comments, ignored, prop_name, prop_value, recorded_date, version)
VALUES (12, null, false, 'BatchDocumentsURL', 'http://INSERT HOST NAME HERE:3000/datafiles/', DEFAULT, 0);
INSERT INTO application_setting (id, comments, ignored, prop_name, prop_value, recorded_date, version)
VALUES (13, null, false, 'ld_host_name', 'INSERT LD HOSTNAME HERE', DEFAULT, 0);
INSERT INTO application_setting (id, comments, ignored, prop_name, prop_value, recorded_date, version)
VALUES (14, null, false, 'ld_url_prefix', 'https://', DEFAULT, 0);