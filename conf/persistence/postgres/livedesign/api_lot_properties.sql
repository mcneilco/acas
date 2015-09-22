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
lot.lot_mol_weight as lot_mol_weight, 
lot.purity as purity, 
operator.name as purity_operator, 
purity_measured_by.name as purity_measured_by, 
lot.percentee as percent_ee, 
lot.melting_point as mp, 
lot.color as color, 
date(lot.registration_date) as lot_registration_date, 
lot.comments as lot_comments, 
lot.supplier as supplier, 
api_salt_iso_salt.salt_name as salt_name, 
physical_state.name as physical_state, 
api_file_list.FILEREF as analytical_file, 
api_batch_cmpd_reg_links.lot_registration_atag as lot_page_link,
lot.corp_name as lot_corp_name
from 
parent_structure, 
parent, 
operator, 
stereo_category, 
lot left outer join physical_state on lot.physical_state=physical_state.id 
left outer join scientist on lot.chemist=scientist.id 
left outer join purity_measured_by on lot.purity_measured_by=purity_measured_by.id 
left outer join api_file_list on lot.id=api_file_list.lot_id 
left outer join api_batch_cmpd_reg_links on lot.id = api_batch_cmpd_reg_links.lot_id
,salt_form left outer join api_salt_iso_salt on salt_form.id=api_salt_iso_salt.salt_form 
 where 
lot.salt_form=salt_form.id and 
salt_form.parent=parent.id and 
parent.cd_id=parent_structure.cd_id and 
parent.stereo_category=stereo_category.id
);
GRANT SELECT ON compound.api_lot_properties TO acas, seurat;