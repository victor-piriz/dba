SELECT 
    id AS ID
    -- ,CONCAT('SELECT * FROM INFORMATION_SCHEMA.PROCESSLIST WHERE ID=',id,';') as CHECK_CONN
    ,CONCAT('CALL mysql.rds_kill(',id,');') AS "SNIPER"
    ,user AS USER
    ,db AS "DATABASE"
    ,SUBSTRING_INDEX(host, ':', 1) AS "HOST"
    ,time AS TIME
    ,command AS COMMAND
    ,state AS STATE
    -- /*LEFT*/ ,LEFT(info,70) AS QUERY
    /*FULL*/ ,info AS QUERY_FULL
    -- /*LEFT & RIGHT*/ ,concat(LEFT(info,60),'...',RIGHT(info,60)) AS QUERY
    -- ,md5(info) E
FROM information_schema.PROCESSLIST
    WHERE 
        COMMAND <> 'Sleep'
        AND ID <> CONNECTION_ID()
        -- AND USER = 'app_finance_tools'
        -- AND SUBSTRING_INDEX(host, ':', 1) = ''
        AND USER NOT LIKE '%rds%'
        AND USER NOT LIKE '%system%'
        AND USER NOT LIKE '%event_%'
        AND USER NOT LIKE '%dms%'
ORDER BY TIME DESC; 