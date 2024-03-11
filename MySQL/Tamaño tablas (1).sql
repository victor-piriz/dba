SELECT
  TABLE_SCHEMA AS `Database`,
  TABLE_NAME AS `Table`,
  ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024 / 1024) AS `DATA + IDX Size (GB)`,
  ROUND((DATA_LENGTH) / 1024 / 1024 / 1024) AS `DATA Size (GB)`,
  ROUND((INDEX_LENGTH) / 1024 / 1024 / 1024) AS `IDX Size (GB)`,
  table_rows AS `Rows Count`
FROM
  information_schema.TABLES
-- WHERE
 -- TABLE_SCHEMA = "owl"
  -- and TABLE_NAME in ("dashboard_users")
ORDER BY
  (DATA_LENGTH + INDEX_LENGTH)
DESC limit 10;

