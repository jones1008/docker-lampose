#!/bin/bash
set -e

cd /docker-entrypoint-initdb.d/sql

for sqlFile in *.sql;
do
  if [ "$sqlFile" != "*.sql" ]; then
    dbName=$(basename "$sqlFile" .sql)
    echo "[INFO]: import-databases.sh: creating database $dbName"
    /usr/bin/mysql -u root <<-EOF
      CREATE DATABASE IF NOT EXISTS $dbName;
      GRANT ALL PRIVILEGES ON $dbName.* TO root@localhost;
EOF
    echo "[INFO]: import-databases.sh: importing $sqlFile into database $dbName ..."
    /usr/bin/mysql -u root "$dbName" < "./$sqlFile"
  else
    echo "[INFO]: import-databases.sh: no .sql files found to import"
  fi
done;