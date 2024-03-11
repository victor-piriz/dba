#PostgreSQL
sed -i 's/OWNER TO "owner_to_replace"/OWNER TO "dbadmin"/g' $dump_path
