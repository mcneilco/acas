\connect prod


ALTER USER seurat SET search_path to seurat, acas;
GRANT USAGE ON SCHEMA acas to seurat;
GRANT SELECT ON ALL TABLES in SCHEMA acas to seurat;

--TODO not sure if grant select on all tables handles this so I am leaving it here for now --bb
--GRANT SELECT on api_protocol TO seurat;
--GRANT SELECT on api_experiment TO seurat;
--GRANT SELECT on api_analysis_group_results TO seurat;
--GRANT SELECT on p_api_analysis_group_results TO seurat;
--GRANT select on api_curve_params to seurat;
--GRANT SELECT on api_dose_response TO seurat;