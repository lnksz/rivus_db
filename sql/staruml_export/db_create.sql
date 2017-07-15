-- Database: Rivus
-- Author: Havasi
CREATE DATABASE rivus
    WITH OWNER = postgres
        ENCODING = 'UTF8'
        TABLESPACE = pg_default
        CONNECTION LIMIT = -1;

COMMENT ON DATABASE rivus
    IS '# Entity Diagram of the rivus workflow
Inspired by the  worksheets  used for single project optimization.';