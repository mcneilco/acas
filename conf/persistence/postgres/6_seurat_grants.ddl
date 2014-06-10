\connect prod


ALTER USER seurat SET search_path to seurat, acas;
GRANT USAGE ON SCHEMA acas to seurat;
GRANT SELECT ON ALL TABLES in SCHEMA acas to seurat;