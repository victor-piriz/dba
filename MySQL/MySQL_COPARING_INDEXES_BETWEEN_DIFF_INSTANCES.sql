-- -------------------------------------------------------------------------------
-- COMAPRING INDEXES: DMS / REP2 / BI
-- -------------------------------------------------------------------------------

-- ----------------------------------
-- (1) EXPORTING INFO TO FILES
-- ----------------------------------
SET @ENVIRONMENT='DMS';                     -- 1   
-- SET @ENVIRONMENT='REPLICA2';             -- 2    
-- SET @ENVIRONMENT='REPLICA_BI';           -- 3    


### this is script.sql ###
SELECT
    @ENVIRONMENT as source,
    table_schema,
    table_name,
    CASE 
        WHEN INDEX_NAME = 'PRIMARY' THEN 'PRIMARY'
        WHEN INDEX_NAME <> 'PRIMARY' AND NON_UNIQUE = 0 THEN 'UNIQUE'
        WHEN INDEX_NAME <> 'PRIMARY' AND NON_UNIQUE <> 0 THEN 'KEY'
    END as index_type,
    index_name,
    group_concat(
        CASE
            WHEN SUB_PART IS NULL THEN COLUMN_NAME
            ELSE CONCAT(COLUMN_NAME,'(',SUB_PART,')')
        END
        order by SEQ_IN_INDEX) AS index_columns,
    CASE WHEN @ENVIRONMENT='DMS' THEN 1 ELSE 0 END AS "DMS" ,
    CASE WHEN @ENVIRONMENT='REPLICA2' THEN 1 ELSE 0 END AS "REPLICA2" ,
    CASE WHEN @ENVIRONMENT='REPLICA_BI' THEN 1 ELSE 0 END AS "REPLICA_BI"
FROM
    INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA NOT IN ('information_schema','alter','awsdms_control', 'dba', 'innodb', 'mysql', 'performance_schema', 'sys', 'tmp')
GROUP BY table_schema,table_name, index_type, index_name
ORDER BY table_schema,table_name,index_name;
### this is script.sql ###

mkdir /home/astropay/dumps/activities/20230303_COMPARING_INDEXES_DLDB
cd /home/astropay/dumps/activities/20230303_COMPARING_INDEXES_DLDB
vim script.sql 

export MYSQL_PWD=''
mysql -h<endpoint> -u<user> -p -s < script.sql > DMS.txt
mysql -h<endpoint> -u<user> -p -s < script.sql > REPLICA2.txt
mysql -h<endpoint> -u<user> -p -s < script.sql > REPLICA_BI.txt



-- ----------------------------------
-- (2) SED
-- ----------------------------------
sed -i "s/\t/||/g" DMS.txt
sed -i "s/\t/||/g" REPLICA2.txt
sed -i "s/\t/||/g" REPLICA_BI.txt



-- ----------------------------------
-- (3) WORK TABLE
-- ----------------------------------
CREATE DATABASE 20230303_indexes_dldb;
USE 20230303_indexes_dldb;
CREATE TABLE env_table_index (
    SOURCE varchar(32),
    TABLE_SCHEMA varchar(64),
    TABLE_NAME varchar(64),
    INDEX_TYPE varchar(64),
    INDEX_NAME varchar(64),
    INDEX_COLUMNS varchar(64),
    DMS INTEGER, -- RDS TO COMPARE 
    REPLICA2 INTEGER, -- RDS TO COMPARE
    REPLICA_BI INTEGER, -- RDS TO COMPARE
    PRIMARY KEY (SOURCE,TABLE_SCHEMA,TABLE_NAME,INDEX_TYPE,INDEX_NAME,INDEX_COLUMNS)
);

-- ----------------------------------
-- (4) LOADING WORK TABLE
-- ----------------------------------

LOAD DATA LOCAL INFILE '/home/astropay/dumps/activities/20230303_COMPARING_INDEXES_DLDB/DMS.txt' INTO TABLE 20230303_indexes_dldb.env_table_index FIELDS TERMINATED BY '||';
LOAD DATA LOCAL INFILE '/home/astropay/dumps/activities/20230303_COMPARING_INDEXES_DLDB/REPLICA2.txt' INTO TABLE 20230303_indexes_dldb.env_table_index FIELDS TERMINATED BY '||';
LOAD DATA LOCAL INFILE '/home/astropay/dumps/activities/20230303_COMPARING_INDEXES_DLDB/REPLICA_BI.txt' INTO TABLE 20230303_indexes_dldb.env_table_index FIELDS TERMINATED BY '||';

-- ----------------------------------
-- (5) MAGIC - EXECUTE with MySQL Client -e
-- ----------------------------------
SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    INDEX_TYPE,
    INDEX_NAME,
    INDEX_COLUMNS,
    CASE
        WHEN SUM(DMS) > 0 THEN 'YES'
        ELSE 'NO'
    END AS DMS,
    CASE
        WHEN SUM(REPLICA2) > 0 THEN 'YES'
        ELSE 'NO'
    END AS REPLICA2,
    CASE
        WHEN SUM(REPLICA_BI) > 0 THEN 'YES'
        ELSE 'NO'
    END AS REPLICA_BI
FROM 20230303_indexes_dldb.env_table_index
GROUP BY
    TABLE_SCHEMA,
    TABLE_NAME,
    INDEX_TYPE,
    INDEX_NAME,
    INDEX_COLUMNS;

SELECT 
    user AS USER,
    SUBSTRING_INDEX(host, ':', 1) AS HOST
    -- ,COUNT(*) AS "#"
FROM information_schema.PROCESSLIST
    WHERE
        ID <> CONNECTION_ID()
        AND USER NOT LIKE '%rds%'
        AND USER NOT LIKE '%system%'
        AND USER NOT LIKE '%event%'
    -- WHERE USER IN ('','')
    -- WHERE USER = ''
GROUP BY 1,2
ORDER BY 1,2;
