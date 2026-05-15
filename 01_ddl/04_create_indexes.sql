SELECT name FROM sys.schemas WHERE name IN ('raw','curated','governance');
SELECT HAS_PERMS_BY_NAME('curated', 'SCHEMA', 'CREATE TABLE') AS PuedoCrearEnCurated;