\connect synaptic

  CREATE OR REPLACE VIEW public.V_SYN_SAMPLE_LOT as
  SELECT a.alternate_id,
    b.compound_id,
    a.alternate_id
    || '-'
    || b.lot_id AS tested_lot,
    a.sample_id
  FROM syn_sample a
  JOIN syn_compound_lot b
  ON a.sample_id = b.sample_id;

grant select on public.v_syn_sample_lot to acas;
ALTER USER acas SET search_path to acas, public;