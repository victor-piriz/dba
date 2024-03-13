SELECT
    pg_statio_user_tables.relname AS table_name,
    pg_total_relation_size(pg_statio_user_tables.relid) / (1024 * 1024) AS total_size_mb,
    pg_relation_size(pg_statio_user_tables.relid) / (1024 * 1024) AS data_size_mb,
    (pg_total_relation_size(pg_statio_user_tables.relid) - pg_relation_size(pg_statio_user_tables.relid)) / (1024 * 1024) AS index_size_mb,
    to_char(pg_class.reltuples, '999,999,999') AS row_count
FROM
    pg_catalog.pg_statio_user_tables
JOIN
    pg_class ON pg_statio_user_tables.relid = pg_class.oid
ORDER BY
    pg_total_relation_size(pg_statio_user_tables.relid) DESC;
