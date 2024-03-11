SELECT
  TABLE_SCHEMA AS `Database`,
  TABLE_NAME AS `Table`,
  ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024) AS `DATA + IDX Size (MB)`,
  ROUND((DATA_LENGTH) / 1024 / 1024) AS `DATA Size (MB)`,
  ROUND((INDEX_LENGTH) / 1024 / 1024) AS `IDX Size (MB)`,
  table_rows AS `Rows Count`
FROM
  information_schema.TABLES
 WHERE
   TABLE_SCHEMA in ("sd_farmacity")
   and TABLE_NAME in ("wf_data_collection")
ORDER BY
  (DATA_LENGTH + INDEX_LENGTH)
DESC limit 10;

########

SET @v_schema= 'gm';
SET @v_table = 'transaction';
source /home/astropay/dumps/DBATeam/scripts/sql/LIST_TABLE_METADATA.sql


