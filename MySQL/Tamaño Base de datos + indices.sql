## TABLAS ##
SELECT
 TABLE_SCHEMA,
  sum( data_length + index_length ) / 1024 / 1024 "Tamaño en MB"
  FROM
  information_schema.TABLES GROUP BY table_schema limit 100;

## DATABASE ##
SELECT table_schema "DATABASE", 
CONVERT(SUM(data_length + index_length)/1048576, DECIMAL(12,2)) "SIZE (MB)" FROM information_schema.tables WHERE table_schema != "information_schema" GROUP BY table_schema;