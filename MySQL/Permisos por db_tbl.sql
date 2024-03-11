SELECT
    A.user AS "USER",
    A.host AS "HOST",
    A.db AS "DB",
    A.tb AS "TABLE",
    CASE 
        WHEN 
            (SUM(CASE 
            WHEN A.user_table_select_grant = 'SELECT' THEN 1
            ELSE 0
            END)) > 0 THEN 'YES'
        ELSE 'NO'
    END  AS "SELECT",
    CASE 
        WHEN 
            (SUM(CASE 
            WHEN A.user_table_non_select_grant = 'INSERT' THEN 1
            ELSE 0
            END)) > 0 THEN 'YES'
        ELSE 'NO'
    END  AS "INSERT",
    CASE 
        WHEN 
            (SUM(CASE 
            WHEN A.user_table_non_select_grant = 'UPDATE' THEN 1
            ELSE 0
            END)) > 0 THEN 'YES'
        ELSE 'NO'
    END  AS "UPDATE",
    CASE 
        WHEN 
            (SUM(CASE 
            WHEN A.user_table_non_select_grant = 'DELETE' THEN 1
            ELSE 0
            END)) > 0 THEN 'YES'
        ELSE 'NO'
    END  AS "DELETE",
    CASE 
        WHEN 
            (SUM(CASE 
            WHEN A.user_table_non_select_grant NOT IN ('INSERT','UPDATE','DELETE') THEN 1
            ELSE 0
    END)) > 0 THEN 'YES'
        ELSE 'NO'
    END  AS "OTHER",
    CONCAT_WS(
        ',',
        GROUP_CONCAT(A.user_table_select_grant),
        CONCAT(GROUP_CONCAT(A.user_table_non_select_grant ORDER BY A.user_table_non_select_grant))
    ) as PRIV_LIST
FROM 
(SELECT 
        u.user,
        u.host,
        tp.TABLE_SCHEMA as db,
        tp.TABLE_NAME as tb,
        UPPER(
            CASE 
                WHEN tp.PRIVILEGE_TYPE='SELECT' THEN 'SELECT'
                ELSE NULL
            END) user_table_select_grant,
        UPPER(
            CASE 
                WHEN tp.PRIVILEGE_TYPE='SELECT' THEN NULL
                ELSE tp.PRIVILEGE_TYPE
            END) user_table_non_select_grant,
        tp.PRIVILEGE_TYPE as priv
FROM information_schema.table_privileges tp
        inner join mysql.user u on concat('\'',user,'\'@\'',host,'\'') = tp.grantee
        WHERE tp.TABLE_SCHEMA = 'tax_manager'
)A
GROUP BY 
    A.user,
    A.host,
    A.db,
    A.tb
ORDER BY 
    A.user,
    A.db,
    A.tb;



