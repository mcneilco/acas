CREATE OR REPLACE VIEW api_analysis_group_results_ld AS 
 (SELECT api_analysis_group_results.ag_id,
    api_analysis_group_results.ag_code_name,
    api_analysis_group_results.experiment_id,
    api_analysis_group_results.tested_lot,
    api_analysis_group_results.tested_conc,
    api_analysis_group_results.tested_conc_unit,
    api_analysis_group_results.agv_id,
    api_analysis_group_results.ls_type,
    api_analysis_group_results.ls_kind,
    api_analysis_group_results.operator_kind,
    api_analysis_group_results.numeric_value,
    api_analysis_group_results.uncertainty,
    api_analysis_group_results.unit_kind,
    CASE WHEN ls_type = 'inlineFileValue' THEN '<img src=' || '''' || (SELECT prop_value FROM application_setting WHERE prop_name = 'url_prefix') || (SELECT prop_value FROM application_setting WHERE prop_name = 'host_name') || ':' || (SELECT prop_value FROM application_setting WHERE prop_name = 'acas_port') || (SELECT prop_value FROM application_setting WHERE prop_name = 'datafiles_url') || string_value || '''' || ' style=''width: '||(SELECT prop_value FROM application_setting WHERE prop_name = 'img_width')||'; height: '||(SELECT prop_value FROM application_setting WHERE prop_name = 'img_height')||';'' />'
	 ELSE string_value
    END as string_value,
    api_analysis_group_results.clob_value,
    api_analysis_group_results.comments,
    api_analysis_group_results.recorded_date,
    api_analysis_group_results.public_data
   FROM api_analysis_group_results
  WHERE api_analysis_group_results.public_data = true AND ls_kind != 'curve id')
  UNION
  (SELECT ag_id,
    ag_code_name,
    experiment_id,
    tested_lot,
    tested_conc,
    tested_conc_unit,
    agv_id,
    ls_type,
    ls_kind,
    operator_kind,
    numeric_value,
    uncertainty,
    unit_kind,
    '<img src=' || '''' || (SELECT prop_value FROM application_setting WHERE prop_name = 'url_prefix') || (SELECT prop_value FROM application_setting WHERE prop_name = 'host_name') || ':' || (SELECT prop_value FROM application_setting WHERE prop_name = 'racas_port') || (SELECT prop_value FROM application_setting WHERE prop_name = 'curve_render_url') || string_value || '&ymax='|| (SELECT prop_value FROM application_setting WHERE prop_name = 'ymax') ||'&ymin=' || (SELECT prop_value FROM application_setting WHERE prop_name = 'ymin') || '''' || ' style=''width: '||(SELECT prop_value FROM application_setting WHERE prop_name = 'img_width')||'; height: '||(SELECT prop_value FROM application_setting WHERE prop_name = 'img_height')||';'' />' as string_value,
    clob_value,
    comments,
    recorded_date,
    public_data
   FROM api_aggregated_curves
  WHERE public_data = true
  )
  UNION
  (SELECT lot_props.lot_id as ag_id,
    lot_props.lot_corp_name as ag_code_name,
    -1 as experiment_id,
    lot_props.lot_corp_name as tested_lot,
    cast(NULL as double precision) as tested_conc,
    NULL as tested_conc_unit,
    lot_props.lot_id asagv_id,
    cast('stringValue' as character varying(64)) as ls_type,
    cast(lot_props.lot_property_name as character varying(64)) as ls_kind,
    cast(NULL as character varying(10)) as operator_kind,
    cast(NULL as numeric) as numeric_value,
    cast(NULL as numeric(38,18)) as uncertainty,
    cast(NULL as character varying(25)) as unit_kind,
    lot_property_value as string_value,
    NULL as clob_value,
    cast(NULL as character varying(512)) as comments,
    cast(NULL as date) as recorded_date,
    TRUE as public_data
    from (SELECT lot_corp_name, lot_id,
unnest(array[
'Lot Number', 'Parent Stereo Category', 'Parent Stereo Comment', 'Lot Chemist', 'Lot Synthesis Date', 'Notebook Page', 'Lot Amount', 'Lot Mol Weight', 'Lot Purity', 'Lot Purity Operator', 'Lot Purity Measured By', 'Lot Percent E.E.', 'Lot Melting Point', 'Lot Color', 'Lot Registration Date', 'Lot Comments', 'Lot Supplier', 'Lot Salt Name', 'Lot Physical State', 'Lot Analytical File', 'Lot Edit Page', 'Lot Corp Name'
]) as lot_property_name,
unnest(array[
lot_number, stereo_category, stereo_comment, chemist, lot_synthesis_date::date::character varying, notebook_page, amount::character varying, lot_mol_weight::character varying, purity::character varying, purity_operator, purity_measured_by, percent_ee::character varying, mp::character varying, color, lot_registration_date::date::character varying, lot_comments, supplier, salt_name, physical_state, analytical_file, lot_page_link, lot_corp_name
]) as lot_property_value
FROM compound.api_lot_properties) as lot_props);

ALTER TABLE api_analysis_group_results_ld
  OWNER TO acas;
GRANT ALL ON TABLE api_analysis_group_results_ld TO acas;
GRANT SELECT ON TABLE api_analysis_group_results_ld TO seurat;