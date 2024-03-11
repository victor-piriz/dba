mysql -h <host> -u <user> -p -e "
select col.table_schema as database_name,
       col.table_name,
       col.column_name,
       col.COLUMN_TYPE
from information_schema.columns col
join information_schema.tables tab on tab.table_schema = col.table_schema
                                   and tab.table_name = col.table_name
                                   and tab.table_type = 'BASE TABLE'
where col.data_type in ('double')
      and col.table_schema not in ('information_schema', 'sys',
                                   'performance_schema', 'mysql')
order by col.table_schema,
         col.table_name,
         col.ordinal_position;" > double.txt
