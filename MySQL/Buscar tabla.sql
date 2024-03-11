select table_schema as database_name,
    table_name
from information_schema.tables
where table_type = 'BASE TABLE'
    and table_name = 'table'
order by table_schema,
    table_name;