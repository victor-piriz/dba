### ONLINE ALTER FOR BIG TABLES WITH AUX TABLE + PROC + TRIGGERS

### NEW TABLE CREATION ### 

CREATE TABLE `db`.`table_new` (
...
) ENGINE=InnoDB AUTO_INCREMENT=621359613 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

########################################

### PROCEDURE DATA COPY ###

DELIMITER $$
DROP PROCEDURE IF EXISTS `dba`.`table_insert_data`;
CREATE PROCEDURE `dba`.`table_insert_data` ()
BEGIN
DECLARE pointer BIGINT DEFAULT 0;
DECLARE limitSize BIGINT DEFAULT 7000;
DECLARE maxID BIGINT;
SET pointer = 621481300;

SET maxID = 622000000;
WHILE pointer <= maxID DO
START TRANSACTION;
INSERT IGNORE INTO db.table_new
SELECT * FROM db.table 
WHERE table_id >= pointer and table_id < pointer + limitSize
ORDER BY table_id;
COMMIT;
DO SLEEP(2);
SET pointer = pointer + limitSize;
SELECT pointer;
END WHILE;
END$$
DELIMITER ;


########################################

### CREAR TRIGGER INSERT ###

DROP TRIGGER IF EXISTS `db`.`TG_table_insert_after`;
DELIMITER //
CREATE TRIGGER `db`.`TG_table_insert_after` AFTER INSERT ON `db`.`table`
  FOR EACH ROW
  BEGIN
    INSERT INTO `db`.`table_new`
      (
        `table_id`,
        `bin`,
        `table_holder`,
        `vault_token`,
        `cvault_token`,
        `hash`,
        `last_digits`,
        `expiration_month`,
        `expiration_year`,
        `country`,
        `brand`,
        `category`,
        `region`,
        `type`,
        `bank`
            )
    VALUES
      (
        NEW.table_id,
        NEW.bin,
        NEW.table_holder,
        NEW.vault_token,
        NEW.cvault_token,
        NEW.hash,
        NEW.last_digits,
        NEW.expiration_month,
        NEW.expiration_year,
        NEW.country,
        NEW.brand,
        NEW.category,
        NEW.region,
        NEW.type,
        NEW.bank
          );
  END;//
DELIMITER ;

########################################

### CREAR TRIGGER UPDATE ###

DROP TRIGGER IF EXISTS `db`.`TG_table_update_after`;
DELIMITER //
CREATE TRIGGER `db`.`TG_table_update_after` AFTER UPDATE ON `db`.`table`
  FOR EACH ROW
  BEGIN
    INSERT INTO `db`.`table_new`
      (
        `table_id`,
        `bin`,
        `table_holder`,
        `vault_token`,
        `cvault_token`,
        `hash`,
        `last_digits`,
        `expiration_month`,
        `expiration_year`,
        `country`,
        `brand`,
        `category`,
        `region`,
        `type`,
        `bank`
            )
    VALUES
      (
        NEW.table_id,
        NEW.bin,
        NEW.table_holder,
        NEW.vault_token,
        NEW.cvault_token,
        NEW.hash,
        NEW.last_digits,
        NEW.expiration_month,
        NEW.expiration_year,
        NEW.country,
        NEW.brand,
        NEW.category,
        NEW.region,
        NEW.type,
        NEW.bank
          )
    ON DUPLICATE KEY UPDATE
        `table_id`= NEW.table_id,
        `bin`= NEW.bin,
        `table_holder`= NEW.table_holder,
        `vault_token`= NEW.vault_token,
        `cvault_token`= NEW.cvault_token,
        `hash`= NEW.hash,
        `last_digits`= NEW.last_digits,
        `expiration_month`= NEW.expiration_month,
        `expiration_year`= NEW.expiration_year,
        `country`= NEW.country,
        `brand`= NEW.brand,
        `category`= NEW.category,
        `region`= NEW.region,
        `type`= NEW.type,
        `bank`= NEW.bank
    ;
  END;//
  DELIMITER ;
  
########################################

### CALL PROCEDURE ###

CALL `dba`.`table_insert_data` ();

########################################

### RENAME TABLE ###

RENAME TABLE `db`.`table` to `db`.`table_old`, `db`.`table_new` to `db`.`table`;

########################################

### ROLLBACK ###

-- RENAME TABLE `db`.`table` to `db`.`table_new`, `db`.`table_old` to `db`.`table`;

########################################

### CLEAN UP ###

DROP PROCEDURE IF EXISTS `dba`.`table_insert_data`;

DROP TRIGGER IF EXISTS `db`.`TG_table_insert_after`;

DROP TRIGGER IF EXISTS `db`.`TG_table_update_after`;

-- DROP TABLE `db`.`table_old`;

########################################

