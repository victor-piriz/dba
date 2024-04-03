#!/bin/bash

# MySQL connection details
MYSQL_USER=""
MYSQL_PASSWORD=""
MYSQL_HOST=""
MYSQL_DATABASE="dba"

# Execute SHOW ENGINE INNODB STATUS and capture the output
INNODB_STATUS=$(mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" -D "$MYSQL_DATABASE" -e "SHOW ENGINE INNODB STATUS\G")

# Split the captured INNODB_STATUS 
transaction_id_1=$(echo "$INNODB_STATUS" | sed -n '/(1) TRANSACTION:/{n; s/.*TRANSACTION \([0-9]\+\).*/\1/p}')
transaction_info_1=$(echo "$INNODB_STATUS" | sed -n '/\*\*\* (1) TRANSACTION:/,/^\*\*\*/p' | sed '$d' | sed '1d' | sed "s/'/''/g")
htl_info_1=$(echo "$INNODB_STATUS" | sed -n '/\*\*\* (1) HOLDS THE LOCK(S):/,/^\*\*\*/p' | sed '$d' | sed '1d' | sed "s/'/''/g")
transaction_id_2=$(echo "$INNODB_STATUS" | sed -n '/(1) TRANSACTION:/{n; s/.*TRANSACTION \([0-9]\+\).*/\1/p}')
waiting4_info_1=$(echo "$INNODB_STATUS" | sed -n '/\*\*\* (1) WAITING FOR THIS LOCK TO BE GRANTED:/,/^\*\*\*/p' | sed '$d' | sed '1d' | sed "s/'/''/g")
transaction_info_2=$(echo "$INNODB_STATUS" | sed -n '/\*\*\* (2) TRANSACTION:/,/^\*\*\*/p' | sed '$d' | sed '1d' | sed "s/'/''/g")
htl_info_2=$(echo "$INNODB_STATUS" | sed -n '/\*\*\* (2) HOLDS THE LOCK(S):/,/^\*\*\*/p' | sed '$d' | sed '1d' | sed "s/'/''/g")
waiting4_info_2=$(echo "$INNODB_STATUS" | sed -n '/\*\*\* (2) WAITING FOR THIS LOCK TO BE GRANTED:/,/^\*\*\*/p' | sed '$d' | sed '1d' | sed "s/'/''/g")
rollback_info=$(echo "$INNODB_STATUS" | sed -n 's/^.*WE ROLL BACK TRANSACTION (\([0-9]\+\)).*$/\1/p')
deadlock_fulltime=$(echo "$INNODB_STATUS" | sed -n '/LATEST DETECTED DEADLOCK/,${/^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\} [0-9]\{14\}/ {s/^\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\} [0-9]\{14\}\).*/\1/p;q}}')
hashed_deadlock_time=$(echo -n "$deadlock_fulltime" | openssl sha256 -binary | openssl base64)
deadlock_time=$(echo "$deadlock_fulltime" | sed 's/\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}\).*/\1/')

# MySQL insert
mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h "$MYSQL_HOST" -D "$MYSQL_DATABASE" -e "INSERT INTO innodb_status_capture_part (timestamp, 1_TRX_ID, 1_TRX_INFO, 1_TRX_HTL, 1_TRX_WAITING_FOR, 2_TRX_ID, 2_TRX_INFO, 2_TRX_HTL, 2_TRX_WAITING_FOR, ROLLBACK_TRX, HASH) VALUES ('$deadlock_time', '$transaction_id_1', '$transaction_info_1', '$htl_info_1', '$waiting4_info_1', '$transaction_id_2', '$transaction_info_2', '$htl_info_2', '$waiting4_info_2', '$rollback_info', '$hashed_deadlock_time')"
