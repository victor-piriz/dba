DROP FUNCTION IF EXISTS hash_string;

DELIMITER $$
CREATE function mamuschka_hash(col VARCHAR(50))
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
 DECLARE salt_aux VARCHAR(50);
 DECLARE salt VARCHAR(50);
 DECLARE hashedString VARCHAR(255);
 DECLARE hash_string VARCHAR(255);
 SET salt_aux = SUBSTRING(col, -4);
 SET salt = concat(salt_aux,salt_aux);
 SET hashedString = SHA2(concat(col,salt),512);
 SET hash_string = SHA2(concat(hashedString,salt),512);
 RETURN (hash_string);
END$$
DELIMITER ;
