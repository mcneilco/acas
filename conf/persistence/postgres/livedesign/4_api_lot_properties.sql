--DROP VIEW compound.api_lot_properties CASCADE;

CREATE OR REPLACE VIEW compound.api_lot_properties AS
(
select 
parent.corp_name as parent_corp_name, 
cast(lot.lot_number as character varying(20)) as lot_number, 
parent_structure.cd_id as cd_id, 
lot.id as lot_id, 
parent_structure.cd_formula as cd_formula, 
parent.common_name as common_name, 
parent_structure.cd_molweight as cd_molweight, 
stereo_category.name as stereo_category, 
parent.stereo_comment as stereo_comment, 
scientist.name as chemist, 
date(lot.synthesis_date) as lot_synthesis_date, 
lot.notebook_page as notebook_page, 
lot.amount as amount,
amount_unit.name as amount_units,
lot.lot_mol_weight as lot_mol_weight, 
lot.purity as purity, 
operator.name as purity_operator, 
purity_measured_by.name as purity_measured_by, 
lot.percentee as percent_ee, 
lot.melting_point as mp,
lot.boiling_point as bp, 
lot.color as color, 
date(lot.registration_date) as lot_registration_date, 
lot.comments as lot_comments, 
lot.supplier as supplier,
lot.supplierid as supplier_id,
lot.supplier_lot as supplier_lot, 
api_salt_iso_salt.salt_name as salt_name, 
api_salt_iso_salt.equivalents as salt_equivalents,
physical_state.name as physical_state, 
api_file_list_ld.FILEREF as analytical_file, 
api_batch_cmpd_reg_links_ld.lot_registration_atag as lot_page_link,
lot.corp_name as lot_corp_name,
bulk_load_file.file_name as file_name,
bulk_load_file.file_date as file_date,
lot.solution_amount as solution_amount,
solution_unit.name as solution_amount_units,
vendor.name as vendor,
lot.retain as retain,
retain_unit.name as retain_units,
lot.barcode as barcode,
project.name as project,
salt_form.cas_number as cas_number
from lot
JOIN salt_form ON lot.salt_form = salt_form.id
JOIN parent ON salt_form.parent = parent.id
JOIN parent_structure ON parent.cd_id = parent_structure.cd_id
JOIN stereo_category ON parent.stereo_category = stereo_category.id 
left outer join physical_state on lot.physical_state=physical_state.id 
left outer join scientist on lot.chemist=scientist.id 
left outer join purity_measured_by on lot.purity_measured_by=purity_measured_by.id
left outer join operator on lot.purity_operator=operator.id
left outer join bulk_load_file on lot.bulk_load_file=bulk_load_file.id 
left outer join api_file_list_ld on lot.id=api_file_list_ld.lot_id 
left outer join api_batch_cmpd_reg_links_ld on lot.id = api_batch_cmpd_reg_links_ld.lot_id
left outer join api_salt_iso_salt on salt_form.id=api_salt_iso_salt.salt_form 
left outer join unit amount_unit ON lot.amount_units = amount_unit.id
left outer join unit retain_unit ON lot.retain_units = retain_unit.id
left outer join solution_unit ON lot.solution_amount_units = solution_unit.id
left outer join project ON lot.project = project.id
left outer join vendor ON lot.vendor = vendor.id
);
ALTER TABLE compound.api_lot_properties OWNER TO compound_admin;
GRANT ALL ON TABLE compound.api_lot_properties TO compound_admin;
GRANT SELECT ON compound.api_lot_properties TO acas, seurat;