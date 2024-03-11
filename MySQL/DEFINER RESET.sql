#MySQL
sed -r -i 's/DEFINER=`[^`]+`@`[^`]+`/DEFINER=CURRENT_USER/g' $dump_path