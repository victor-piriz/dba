#!/bin/bash

# MySQL connection details
MYSQL_USER=""
MYSQL_PASSWORD=""
MYSQL_HOST=""

while true; do
    # Run the MySQL query to get the count of active connections
    count=$(mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" -e "SELECT COUNT(id) FROM information_schema.PROCESSLIST WHERE COMMAND <> 'Sleep';" | tail -n 1)
    
    # Execute SHOW ENGINE INNODB STATUS and capture the output
    INNODB_STATUS=$(mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" -D "$MYSQL_DATABASE" -e "SHOW ENGINE INNODB STATUS\G")
    
    # Split the captured INNODB_STATUS and get the data to compare
    curr_deadlock_time=$(echo "$INNODB_STATUS" | sed -n '/LATEST DETECTED DEADLOCK/,${/^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\} [0-9]\{14\}/ {s/^\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\} [0-9]\{14\}\).*/\1/p;q}}')
    curr_hash=$(echo -n "$curr_deadlock_time" | openssl sha256 -binary | openssl base64)
    curr_trx_id_1=$(echo "$INNODB_STATUS" | sed -n '/(1) TRANSACTION:/{n; s/.*TRANSACTION \([0-9]\+\).*/\1/p}')
    curr_trx_id_2=$(echo "$INNODB_STATUS" | sed -n '/(2) TRANSACTION:/{n; s/.*TRANSACTION \([0-9]\+\).*/\1/p}')
    curr_trx_ids=$curr_trx_id_1$curr_trx_id_2
    last_trx_ids=$(mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" -D "$MYSQL_DATABASE" -N -e "SELECT CONCAT(1_TRX_ID,2_TRX_ID) FROM dba.innodb_status_capture_part ORDER BY id DESC LIMIT 1")
    last_hast=$(mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" -D "$MYSQL_DATABASE" -N -e "SELECT hash FROM dba.innodb_status_capture_part ORDER BY id DESC LIMIT 1")

    # Check condition to trigger the capture script 
    if [ "$curr_hash" != "$last_hash" ] && [ "$count" -gt 1 ] && [ "$curr_trx_ids" != "$last_trx_ids" ]; then
        # Call the capture script
        /mnt/genesis-victor/capture_innodb_status.sh
    fi

    # Wait
    sleep 10
done