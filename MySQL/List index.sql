mysql -h<endpoint> -u<user> -p --batch -e"
select index_schema AS DB_NAME,
   table_name AS TBL_NAME,
   index_name AS INDEX_NAME,
   group_concat(column_name order by seq_in_index) as INDEX_COLUMNS,
   index_type as INDEX_TYPE,
   case non_unique when 1 then 'not unique' else 'unique' end as is_unique
from information_schema.statistics
where table_schema not in ('information_schema', 'mysql',
   'performance_schema', 'sys')
group by index_schema,
 index_name,
 index_type,
 non_unique,
 table_name
order by index_schema,
 index_name;" > index_file.sql
