SELECT
    t.TABLE_SCHEMA,t.TABLE_NAME,INDEX_NAME,CARDINALITY,
    TABLE_ROWS, CARDINALITY/TABLE_ROWS AS SELECTIVITY
FROM
    information_schema.TABLES t,
(
  SELECT table_schema,table_name,index_name,cardinality
  FROM information_schema.STATISTICS
  WHERE (table_schema,table_name,index_name,seq_in_index) IN (
  SELECT table_schema,table_name,index_name,MAX(seq_in_index)
  FROM information_schema.STATISTICS
  GROUP BY table_schema , table_name , index_name )
) s
WHERE
    t.table_schema = s.table_schema
        AND t.table_name = s.table_name AND t.table_rows != 0
        AND t.table_schema NOT IN ( 'mysql','performance_schema','information_schema','sys')
        -- AND t.table_name='table'     -- PARA TABLA ESPECIFICA
        -- AND t.table_schema = 'db'    -- PARA DB ESPECIFICA
        and index_name!='PRIMARY'
        and CARDINALITY/TABLE_ROWS <=0.2
ORDER BY SELECTIVITY;
