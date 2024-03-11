MYSQL_USER=
MYSQL_ENDPOINT=
USER_TO_KILL=
FILE=kill_$USER_TO_KILL

MYSQL_CONN="-h ${MYSQL_ENDPOINT} -u${MYSQL_USER} -p"
SQL="select concat('CALL mysql.rds_kill','(',id,')', ';') from information_schema.processlist where user='${USER_TO_KILL}';"

mysql ${MYSQL_CONN} -Ne "${SQL}" > $FILE
mysql ${MYSQL_CONN} < $FILE
