AWS CLI RDS
## SOLO FILTRA POR ENGINE
for instance_id in $(aws rds describe-db-instances --query aws rds describe-db-instances --query "DBInstances[?Engine=='mysql'].DBInstanceIdentifier" --output text); do /
  aws rds describe-db-instances --db-instance-identifier $instance_id /
done

## CON FILTROS
for instance_id in $(aws rds describe-db-instances --query "DBInstances[?Engine=='mysql'].DBInstanceIdentifier" --output text); do
  aws rds describe-db-instances --db-instance-identifier $instance_id \
    --query "DBInstances[0].[DBInstanceIdentifier, PreferredMaintenanceWindow, AutoMinorVersionUpgrade]" \
    --output text
done

