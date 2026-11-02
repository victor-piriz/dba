-- Tamaño de las bases de datos de usuario en MiB.
SELECT
  table_schema AS `database`,
  ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS `size_mib`
FROM information_schema.tables
WHERE table_schema NOT IN ('information_schema', 'mysql', 'performance_schema', 'sys')
GROUP BY table_schema
ORDER BY SUM(data_length + index_length) DESC;
