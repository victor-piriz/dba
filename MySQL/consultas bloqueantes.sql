SELECT 
CONCAT(pl_locker.user,'@',SUBSTRING_INDEX(pl_locker.host,':',1)) AS "user [LOCKER]"
,pl_locker.db AS "db [LOCKER]"
,CONCAT('CALL mysql.rds_kill(',pl_locker.id,');') AS "SNIPER"
,pl_locker.id AS "id [LOCKER]"
,pl_locker.command as "command [LOCKER]"
,sec_to_time(pl_locker.time) AS "time [LOCKER]"
,locker_trx.trx_id AS "trx_id [LOCKER]"
,pl_locker.state AS "conn_state [LOCKER]"
,locker_trx.trx_state AS "trx_state [LOCKER]"
,locker_trx.trx_started AS "trx_started [LOCKER]"
,locker_trx.trx_query AS "trx_query [LOCKER]"
-- ,pl_locker.info
-- ----------------------------
,CONCAT(pl_waiting.user,'@',SUBSTRING_INDEX(pl_waiting.host,':',1)) AS "user [WAITING]"
,pl_waiting.db AS "db [WAITING]"
,pl_waiting.id AS "id [WAITING]"
,pl_waiting.command as "command [WAITING]"
,sec_to_time(pl_waiting.time) AS "time [WAITING]"
,waiting_trx.trx_id AS "trx_id [WAITING]"
,pl_waiting.state AS "conn_state [WAITING]"
,waiting_trx.trx_state AS "trx_state [WAITING]"
,waiting_trx.trx_started AS "trx_started [WAITING]"
,SEC_TO_TIME(NOW() - waiting_trx.trx_wait_started) AS "waiting_time[WAITING]"
,waiting_trx.trx_query AS "trx_query [WAITING]"
-- ,pl_waiting.info
-- ,info_lock_wainting.lock_mode AS "lock_mode [WAITING]"
-- ,info_lock_wainting.lock_type AS "lock_type [WAITING]"
FROM information_schema.innodb_trx waiting_trx
	INNER JOIN information_schema.innodb_lock_waits lw ON lw.requesting_trx_id = waiting_trx.trx_id and lw.requested_lock_id = waiting_trx.trx_requested_lock_id -- waiting_trx.trx_requested_lock_id NOT NULL
	INNER JOIN information_schema.innodb_trx locker_trx ON lw.blocking_trx_id = locker_trx.trx_id 
    INNER JOIN information_schema.innodb_locks info_lock_locker ON lw.blocking_trx_id = info_lock_locker.lock_trx_id
    INNER JOIN information_schema.innodb_locks info_lock_wainting ON lw.requesting_trx_id = info_lock_wainting.lock_trx_id and lw.requested_lock_id = info_lock_wainting.lock_id
    INNER JOIN information_schema.processlist pl_locker ON pl_locker.id = locker_trx.trx_mysql_thread_id 
    INNER JOIN information_schema.processlist pl_waiting ON pl_waiting.id = waiting_trx.trx_mysql_thread_id
ORDER BY NOW() - waiting_trx.trx_wait_started DESC;

## MySQL 8 VIEW ##
SELECT * FROM sys.schema_table_lock_waits order by waiting_query_secs desc limit 10 \G