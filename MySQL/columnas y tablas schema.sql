SELECT TABLE_NAME,`COLUMN_NAME`,COLUMN_TYPE
FROM `INFORMATION_SCHEMA`.`COLUMNS`
WHERE `TABLE_SCHEMA`='log' order by table_name;
