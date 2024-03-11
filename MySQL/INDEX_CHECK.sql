mysql -h <host> -u<user> -p -e"
select index_schema,
   index_name,
   group_concat(column_name order by seq_in_index) as index_columns,
   index_type,
   case non_unique
    when 1 then 'Not Unique'
    else 'Unique'
    end as is_unique,
 table_name
from information_schema.statistics
where table_schema = 'astropay'
group by index_schema,
 index_name,
 index_type,
 non_unique,
 table_name
order by index_schema,
 index_name;" > indexes.sql

