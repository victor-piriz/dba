mysql -h$RDS -u$USER -p --database $DB --execute="LOAD DATA LOCAL INFILE '$INPUT_FILE'
 INTO TABLE $TABLE
 FIELDS TERMINATED BY ','
 OPTIONALLY ENCLOSED BY '\"'
 LINES TERMINATED BY '\n'  IGNORE 1 LINES
 ( @vCOL_1, @vCOL_2, @vCOL_3, @vCOL_4, @VCOL_5
  SET COL_0 = NULL, COL_1 = @vCOL_1 = , COL_2 = NULLIF(@vCOL_2,'NULL'), COL_3 = @vCOL_3, COL_6 = CURRENT_TIMESTAMP;
 SHOW WARNINGS"