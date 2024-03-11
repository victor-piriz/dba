MYSQL_USER=
MYSQL_PASS=
MYSQL_ENDPOINT=

MYSQL_CONN="-h ${MYSQL_ENDPOINT} -u${MYSQL_USER} -p${MYSQL_PASS}"
MYSQLDUMP_OPTIONS="--routines --triggers --single-transaction --set-gtid-purged=off"
#
SQL="SELECT schema_name FROM information_schema.schemata WHERE schema_name NOT IN"
SQL="${SQL} ('mysql','information_schema','performance_schema','sys')"

DBLISTFILE=db_todump.txt
mysql ${MYSQL_CONN} -ANe"${SQL}" > ${DBLISTFILE}

DBLIST=""
for DB in `cat ${DBLISTFILE}` ; do DBLIST="${DBLIST} ${DB}" ; done

# mysqldump ${MYSQL_CONN} ${MYSQLDUMP_OPTIONS} --databases ${DBLIST} > alldb.sql
# mysqldump ${MYSQL_CONN} ${MYSQLDUMP_OPTIONS} --databases ${DBLIST} | gzip -c > alldb.sql.gz
