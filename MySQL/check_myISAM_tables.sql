select table_schema as database_name,
       table_name
from information_schema.tables tab
where engine = 'MyISAM'
      and table_type = 'BASE TABLE'
      and table_schema not in ('information_schema', 'sys',
                               'performance_schema','mysql')
      and table_schema = 'tax_manager'
order by table_schema,
         table_name;
