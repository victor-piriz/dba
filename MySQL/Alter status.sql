## UPDATE performance_schema.setup_consumers SET ENABLED = 'YES' WHERE NAME = 'events_stages_current';
## UPDATE performance_schema.setup_instruments SET ENABLED = 'YES' WHERE NAME LIKE 'stage/innodb/alter%';

select
    p.ID as "connection id",
    SUBSTRING_INDEX(p.info,' ', 3) as "command",
    IFNULL(100*(ev.WORK_COMPLETED/ev.WORK_ESTIMATED),0.00) as "%done",  
    sec_to_time(p.time) AS "elapsed time", 
    DATE_SUB(NOW(), INTERVAL p.time SECOND) "start",
    NOW() AS "now",
    CASE 
        WHEN 100*(ev.WORK_COMPLETED/ev.WORK_ESTIMATED) IS NULL THEN NULL
        ELSE DATE_ADD(DATE_SUB(NOW(),INTERVAL p.time SECOND),INTERVAL (100*(p.time/ifnull(100*(ev.WORK_COMPLETED/ev.WORK_ESTIMATED),0.00))) SECOND) 
    END AS "estimated end"
from information_schema.processlist p 
left join performance_schema.threads t on t.PROCESSLIST_ID = p.id 
left join performance_schema.events_stages_current ev on ev.THREAD_ID = t.THREAD_ID
where lower(p.info) LIKE 'alter%' \G