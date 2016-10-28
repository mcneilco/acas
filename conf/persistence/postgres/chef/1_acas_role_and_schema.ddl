--
-- ACAS
--

\connect postgres

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET escape_string_warning = 'off';

--
-- Roles
--

DROP ROLE acas;
CREATE ROLE acas LOGIN PASSWORD 'acas'
   VALID UNTIL 'infinity';
COMMENT ON ROLE "acas" IS 'ACAS User';

\connect synaptic

SET standard_conforming_strings = off;
SET escape_string_warning = 'off';

--
-- ACAS SCHEMA
--

DROP SCHEMA acas;
CREATE SCHEMA acas
       AUTHORIZATION acas;
COMMENT ON SCHEMA acas IS 'ACAS Schema';

GRANT ALL ON SCHEMA acas TO postgres;
ALTER USER acas SET search_path to acas;

