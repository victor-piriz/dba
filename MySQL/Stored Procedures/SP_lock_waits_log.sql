# CREATE DBA DATABASE
CREATE DATABASE `dba_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 */ /*!80016 DEFAULT ENCRYPTION='N' */;

# CREATE COLLECTOR LOG TABLE
CREATE TABLE `dba_db`.`lock_waits_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP,
  `waiting_trx_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `waiting_pid` int DEFAULT NULL,
  `waiting_query` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `blocking_trx_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `blocking_pid` int DEFAULT NULL,
  `blocking_query` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `idx_timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


# CREATE STATEMENTS HISTORY LOG TABLE
CREATE TABLE `dba_db`.`log_lock_statements_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP,
  `blocking_pid` bigint unsigned DEFAULT NULL,
  `THREAD_ID` bigint unsigned DEFAULT NULL,
  `TIMER_WAIT` bigint unsigned DEFAULT NULL,
  `LOCK_TIME` bigint unsigned DEFAULT NULL,
  `SQL_TEXT` longtext COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `idx_block_pid_timestamp` (`blocking_pid`,`timestamp`),
  KEY `idx_thread_id_block_pid` (`THREAD_ID`,`blocking_pid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


# CREATE EVENT LOCK WAITS LOG TRACKER DEPURATOR
DROP EVENT IF EXISTS `dba_db`.`lock_waits_log_depurator`;

DELIMITER $$
CREATE EVENT `dba_db`.`lock_waits_log_depurator`
ON SCHEDULE EVERY 1 DAY STARTS CONCAT(CURDATE(), ' 00:00:00') -- Set the time for the depurator event to run
ON COMPLETION PRESERVE ENABLE 
DO
BEGIN
  SIGNAL SQLSTATE '01000' SET MESSAGE_TEXT = 'lock_waits_log_depurator started';
  DELETE FROM `dba_db`.`lock_waits_log` WHERE `timestamp` < DATE_SUB(NOW(), INTERVAL 2 DAY);
  SIGNAL SQLSTATE '01000' SET MESSAGE_TEXT = 'lock_waits_log_depurator finished';
END $$
DELIMITER ;


# CREATE LOCK WAITS LOG PROCEDURE 
DROP PROCEDURE IF EXISTS `dba_db`.`lock_waits_log`;

DELIMITER $$

CREATE PROCEDURE `dba_db`.`lock_waits_log`()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE var_waiting_trx_id VARCHAR(50);
    DECLARE var_waiting_pid BIGINT;
    DECLARE var_waiting_query LONGTEXT;
    DECLARE var_blocking_trx_id VARCHAR(50);
    DECLARE var_blocking_pid BIGINT;
    DECLARE var_blocking_query LONGTEXT;
    DECLARE var_thread_id BIGINT;
    DECLARE var_sql_text LONGTEXT;

    DECLARE cur CURSOR FOR 
		SELECT 
  		`r`.`trx_id` AS `waiting_trx_id`,
  		`r`.`trx_mysql_thread_id` AS `waiting_pid`,
  		`r`.`trx_query` AS `waiting_query`,
  		`b`.`trx_id` AS `blocking_trx_id`,
  		`b`.`trx_mysql_thread_id` AS `blocking_pid`,
  		`b`.`trx_query`AS `blocking_query`
		FROM ((`performance_schema`.`data_lock_waits` `w`
		JOIN `information_schema`.`INNODB_TRX` `b` ON((`b`.`trx_id` = CAST(`w`.`BLOCKING_ENGINE_TRANSACTION_ID` AS CHAR CHARSET utf8mb4))))
		JOIN `information_schema`.`INNODB_TRX` `r` ON((`r`.`trx_id` = CAST(`w`.`REQUESTING_ENGINE_TRANSACTION_ID` AS CHAR CHARSET utf8mb4))))
		ORDER BY `r`.`trx_wait_started`;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO var_waiting_trx_id, var_waiting_pid, var_waiting_query, var_blocking_trx_id, var_blocking_pid, var_blocking_query;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Check if blocking_query is null
        IF var_blocking_query IS NULL THEN
            -- Get THREAD_ID from performance_schema.threads using blocking_pid
            SELECT THREAD_ID INTO var_thread_id
            FROM performance_schema.threads
            WHERE PROCESSLIST_ID = var_blocking_pid;

            -- Get SQL_TEXT from performance_schema.events_statements_current using THREAD_ID
            SELECT SQL_TEXT INTO var_sql_text
            FROM performance_schema.events_statements_current
            WHERE THREAD_ID = var_thread_id;

            -- Concatenate "IDLE - " and the SQL_TEXT
            SET var_blocking_query = CONCAT('IDLE - ', var_sql_text);
            
            -- Add thread history log
            INSERT INTO `dba_db`.`log_lock_statements_history` (TIMESTAMP, blocking_pid, THREAD_ID, TIMER_WAIT, LOCK_TIME, SQL_TEXT) 
				SELECT NOW(), var_blocking_pid, THREAD_ID, TIMER_WAIT, LOCK_TIME, SQL_TEXT FROM performance_schema.events_statements_history WHERE THREAD_ID = var_thread_id ORDER BY EVENT_ID; 
        END IF;

        -- Insert the results into the log table
        INSERT INTO `dba_db`.`lock_waits_log` (timestamp, waiting_trx_id, waiting_pid, waiting_query, blocking_trx_id, blocking_pid, blocking_query)
        VALUES (NOW(), var_waiting_trx_id, var_waiting_pid, var_waiting_query, var_blocking_trx_id, var_blocking_pid, var_blocking_query);
    END LOOP;

    CLOSE cur;
END $$

DELIMITER ;


# CREATE EVENT LOCK WAITS EVENT DEPURATOR
DROP EVENT IF EXISTS `dba_db`.`lock_waits_log_every_5_seconds`;

DELIMITER $$
CREATE EVENT `dba_db`.`lock_waits_log_every_5_seconds`
ON SCHEDULE EVERY 5 SECOND STARTS NOW() -- Set the periodicity for the stored procedure to run
ON COMPLETION PRESERVE ENABLE 
DO
BEGIN
  SIGNAL SQLSTATE '01000' SET MESSAGE_TEXT = 'log_lock_waits_event started';
  CALL `dba_db`.`lock_waits_log`();
  SIGNAL SQLSTATE '01000' SET MESSAGE_TEXT = 'log_lock_waits_event finished';
END $$
DELIMITER ;

CALL `dba_db`.`lock_waits_log`();