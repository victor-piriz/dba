SELECT
    pg_statio_user_tables.relname AS table_name,
    pg_size_pretty(pg_total_relation_size(pg_statio_user_tables.relid)) AS total_size,
    pg_size_pretty(pg_relation_size(pg_statio_user_tables.relid)) AS data_size,
    pg_size_pretty(pg_total_relation_size(pg_statio_user_tables.relid) - pg_relation_size(pg_statio_user_tables.relid)) AS index_size,
    pg_class.reltuples AS row_count
FROM
    pg_catalog.pg_statio_user_tables
JOIN
    pg_class ON pg_statio_user_tables.relid = pg_class.oid
ORDER BY
    pg_total_relation_size(pg_statio_user_tables.relid) DESC
LIMIT 10;