select
   ENGINE,
   TABLE_NAME,
   Round( DATA_LENGTH/1024/1024) as data_length ,
   round(INDEX_LENGTH/1024/1024) as index_length,
   round(DATA_FREE/ 1024/1024) as data_free
from information_schema.tables
where  DATA_FREE > 0;
