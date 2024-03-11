## CREATE USER
CREATE USER 'user'@'%' IDENTIFIED BY 'password';
GRANT SELECT ON `db`.`tb` TO 'user'@'%';

## RESET PASSWORD
SET PASSWORD FOR 'user'@'%' = 'password';
FLUSH PRIVILEGES;
