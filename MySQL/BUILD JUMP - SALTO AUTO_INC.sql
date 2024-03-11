# CREATE SELECT MAX(ID)

mysql -h<endpoint> -u<user> -p  --batch -N -e"SELECT 
 CONCAT(\"SELECT '\",col.table_schema, \"','\",col.table_name,\"',\",\"MAX(\", col.column_name, \") FROM \", col.table_schema, \".\", col.table_name, \";\")
from information_schema.columns col
join information_schema.tables tab on tab.table_schema = col.table_schema
                  and tab.table_name = col.table_name
                  and tab.table_type = 'BASE TABLE'
where col.data_type in ('tinyint', 'smallint', 'mediumint',
            'int', 'bigint')
   and col.table_schema not in ('information_schema', 'sys',
                  'performance_schema', 'mysql','dba')
   and col.EXTRA = 'auto_increment'
order by col.table_schema,
     col.table_name,
     col.ordinal_position;" > max_ids.sql

# SELECT MAX(ID)
mysql -h<endpoint> -u<user> -p --batch -N < max_ids.sql | sed 's/\t/","/g;s/^/"/;s/$/"/;s/\n//g' > ids.sql
