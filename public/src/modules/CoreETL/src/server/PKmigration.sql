UPDATE subject_value sv set sv.numeric_value = 1 where sv.id in (
select sv.id from api_protocol p
join api_experiment e on p.protocol_id=e.protocol_id
join analysis_group ag on ag.experiment_id=e.id
join treatment_group tg on tg.analysis_group_id = ag.id
join subject s on s.treatment_group_id = tg.id
join subject_state ss on ss.subject_id = s.id
join subject_value sv on sv.subject_state_id = ss.id and sv.ls_kind ='Dose'
join subject_value sv2 on sv2.subject_state_id = ss.id and sv2.ls_kind = 'IV - Route'
where e.label_text like ('PK%')
and sv.recorded_by !='dlee'); -- update all of these to 1

UPDATE subject_value sv set sv.numeric_value = 10 where sv.id in (
select sv.id from api_protocol p
join api_experiment e on p.protocol_id=e.protocol_id
join analysis_group ag on ag.experiment_id=e.id
join treatment_group tg on tg.analysis_group_id = ag.id
join subject s on s.treatment_group_id = tg.id
join subject_state ss on ss.subject_id = s.id
join subject_value sv on sv.subject_state_id = ss.id and sv.ls_kind ='Dose'
join subject_value sv2 on sv2.subject_state_id = ss.id and sv2.ls_kind = 'PO - Route'
where e.label_text like ('PK%')
and sv.recorded_by !='dlee'); -- update all of these to 10

UPDATE subject_value sv set sv.numeric_value = 0.15 where sv.id in (
select sv.id from api_protocol p
join api_experiment e on p.protocol_id=e.protocol_id
join analysis_group ag on ag.experiment_id=e.id
join treatment_group tg on tg.analysis_group_id = ag.id
join subject s on s.treatment_group_id = tg.id
join subject_state ss on ss.subject_id = s.id
join subject_value sv on sv.subject_state_id = ss.id and sv.ls_kind ='Dose'
join subject_value sv2 on sv2.subject_state_id = ss.id and sv2.ls_kind = 'IV - Route'
where e.label_text like ('PK%')
and sv.recorded_by ='dlee'); -- update all of these to 0.15

UPDATE subject_value sv set sv.numeric_value = 1.5 where sv.id in (
select sv.id from api_protocol p
join api_experiment e on p.protocol_id=e.protocol_id
join analysis_group ag on ag.experiment_id=e.id
join treatment_group tg on tg.analysis_group_id = ag.id
join subject s on s.treatment_group_id = tg.id
join subject_state ss on ss.subject_id = s.id
join subject_value sv on sv.subject_state_id = ss.id and sv.ls_kind ='Dose'
join subject_value sv2 on sv2.subject_state_id = ss.id and sv2.ls_kind = 'PO - Route'
where e.label_text like ('PK%')
and sv.recorded_by ='dlee'); -- update all of these to 1.5



UPDATE treatment_value tv set tv.numeric_value = 1 where tv.id in (
select tv.id from api_protocol p
join api_experiment e on p.protocol_id=e.protocol_id
join analysis_group ag on ag.experiment_id=e.id
join treatment_group tg on tg.analysis_group_id = ag.id
join treatment_group_state ts on ts.treatment_group_id = tg.id
join treatment_group_value tv on tv.treatment_state_id = ts.id and tv.ls_kind ='Dose'
join treatment_group_value tv2 on tv2.treatment_state_id = ts.id and tv2.ls_kind = 'IV - Route'
where e.label_text like ('PK%')
and tv.recorded_by !='dlee'); -- update all of these to 1

UPDATE treatment_value tv set tv.numeric_value = 10 where tv.id in (
select tv.id from api_protocol p
join api_experiment e on p.protocol_id=e.protocol_id
join analysis_group ag on ag.experiment_id=e.id
join treatment_group tg on tg.analysis_group_id = ag.id
join treatment_group_state ts on ts.treatment_group_id = tg.id
join treatment_group_value tv on tv.treatment_state_id = ts.id and tv.ls_kind ='Dose'
join treatment_group_value tv2 on tv2.treatment_state_id = ts.id and tv2.ls_kind = 'PO - Route'
where e.label_text like ('PK%')
and tv.recorded_by !='dlee'); -- update all of these to 10

UPDATE treatment_value tv set tv.numeric_value = 1.5 where tv.id in (
select tv.id from api_protocol p
join api_experiment e on p.protocol_id=e.protocol_id
join analysis_group ag on ag.experiment_id=e.id
join treatment_group tg on tg.analysis_group_id = ag.id
join treatment_group_state ts on ts.treatment_group_id = tg.id
join treatment_group_value tv on tv.treatment_state_id = ts.id and tv.ls_kind ='Dose'
join treatment_group_value tv2 on tv2.treatment_state_id = ts.id and tv2.ls_kind = 'PO - Route'
where e.label_text like ('PK%')
and tv.recorded_by ='dlee'); -- update all of these to 1.5

UPDATE treatment_value tv set tv.numeric_value = 0.15 where tv.id in (
select tv.id from api_protocol p
join api_experiment e on p.protocol_id=e.protocol_id
join analysis_group ag on ag.experiment_id=e.id
join treatment_group tg on tg.analysis_group_id = ag.id
join treatment_group_state ts on ts.treatment_group_id = tg.id
join treatment_group_value tv on tv.treatment_state_id = ts.id and tv.ls_kind ='Dose'
join treatment_group_value tv2 on tv2.treatment_state_id = ts.id and tv2.ls_kind = 'IV - Route'
where e.label_text like ('PK%')
and tv.recorded_by ='dlee'); -- update all of these to 0.15