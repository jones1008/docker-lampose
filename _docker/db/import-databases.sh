#!/bin/bash
set -e

cd /docker-entrypoint-initdb.d/sql

for sqlFile in *.sql;
do
  dbName=$(basename $sqlFile .sql)
  echo "import-script: creating database "$dbName
  /usr/bin/mysql -u root <<-EOF
    CREATE DATABASE IF NOT EXISTS $dbName;
    GRANT ALL PRIVILEGES ON $dbName.* TO root@localhost;
EOF
  echo "import-script: importing "$sqlFile" into database "$dbName
  /usr/bin/mysql -u root $dbName < ./$sqlFile
done;