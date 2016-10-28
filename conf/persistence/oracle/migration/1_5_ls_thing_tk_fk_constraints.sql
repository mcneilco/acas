ALTER TABLE ls_thing
  ADD CONSTRAINT ls_thing_tk_fk FOREIGN KEY (ls_type_and_kind)
      REFERENCES thing_kind (ls_type_and_kind) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE ls_thing_state
  ADD CONSTRAINT ls_thing_state_tk_fk FOREIGN KEY (ls_type_and_kind)
      REFERENCES state_kind (ls_type_and_kind) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE ls_thing_value
  ADD CONSTRAINT ls_thing_value_tk_fk FOREIGN KEY (ls_type_and_kind)
      REFERENCES value_kind (ls_type_and_kind) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;
      
ALTER TABLE itx_ls_thing_ls_thing
  ADD CONSTRAINT itx_ls_thing_ls_thing_tk_fk FOREIGN KEY (ls_type_and_kind)
  	  REFERENCES interaction_kind (ls_type_and_kind) MATCH SIMPLE
  	  ON UPDATE NO ACTION ON DELETE NO ACTION;