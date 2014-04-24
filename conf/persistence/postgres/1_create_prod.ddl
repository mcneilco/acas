--
-- Create PROD Database
--

\connect postgres

SET standard_conforming_strings = off;
SET escape_string_warning = 'off';

--
-- Database creation
--

DROP DATABASE prod;
CREATE DATABASE prod
  WITH ENCODING='UTF8'
       OWNER=postgres
       CONNECTION LIMIT=-1;
COMMENT ON DATABASE prod
  IS 'production database';
