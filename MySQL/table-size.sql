-- Definí el schema a inspeccionar antes de ejecutar.
SET @schema_name = 'your_schema';

-- Tablas más grandes del schema, con datos e índices en MiB.
SELECT
  table_schema AS `database`,
  table_name AS `table`,
  ROUND(data_length / 1024 / 1024, 2) AS `data_mib`,
  ROUND(index_length / 1024 / 1024, 2) AS `index_mib`,
  ROUND((data_length + index_length) / 1024 / 1024, 2) AS `total_mib`,
  table_rows AS `rows_count`
FROM information_schema.tables
WHERE table_schema = @schema_name
ORDER BY (data_length + index_length) DESC
LIMIT 25;
