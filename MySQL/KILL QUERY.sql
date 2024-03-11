SET @v_info='L';    -- LEFT
SET @v_info='F';    -- FULL
SET @v_info='LR';   -- LEFT / RIGHT

SELECT 
    id AS ID,
    -- ,CONCAT('SELECT * FROM INFORMATION_SCHEMA.PROCESSLIST WHERE ID=',id,';') as CHECK_CONN
    CONCAT('CALL mysql.rds_kill(',id,');')     AS "HEADSHOT"
    ,user                                       AS "USER"
    ,db                                         AS "DATABASE"
    ,SUBSTRING_INDEX(host, ':', 1)              AS "HOST"
    ,sec_to_time(time)                          AS "TIME"
    ,command                                    AS "COMMAND"
    ,state                                      AS "STATE"
    ,CASE
        WHEN @v_info IN ('L','') THEN LEFT(info,40)
        WHEN @v_info='F' THEN info
        WHEN @v_info='LR' THEN concat(LEFT(info,60),'(...)',RIGHT(info,60))
    END                                         AS "QUERY"
    ,left(md5(info),10)                         AS "HASH"
FROM information_schema.PROCESSLIST
    WHERE 
        COMMAND <> 'Sleep' AND
        ID <> CONNECTION_ID()
        AND USER NOT LIKE '%rds%'
        AND USER NOT LIKE '%system%'
        AND USER NOT LIKE '%event_%'
        AND USER NOT LIKE '%dms%'
ORDER BY TIME DESC; 