MYSQL_USER=admin
MYSQL_ENDPOINT=eu1-payments-sbox-sandboxdb.ciy3udq0jwbu.eu-west-1.rds.amazonaws.com
USER_TO_KILL=glopez
FILE=kill_$USER_TO_KILL

MYSQL_CONN="-h ${MYSQL_ENDPOINT} -u${MYSQL_USER} -p"
SQL="select concat('CALL mysql.rds_kill','(',id,')', ';') from information_schema.processlist where user='${USER_TO_KILL}';"

mysql ${MYSQL_CONN} -Ne "${SQL}" > $FILE
mysql ${MYSQL_CONN} < $FILE