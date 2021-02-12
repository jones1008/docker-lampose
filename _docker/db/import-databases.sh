#!/bin/bash

cd /docker-entrypoint-initdb.d/sql

prefix=DATABASE_

dbNamePrefix="${prefix}NAME_"
sqlFilePrefix="${prefix}FILE_"
userPrefix="${prefix}USER_"
passwordPrefix="${prefix}PASS_"

for dbNameVarName in "${!DATABASE_NAME_@}"; do
  dbName=${!dbNameVarName}

  suffix=${dbNameVarName#"$dbNamePrefix"}

  sqlFileVarName="${sqlFilePrefix}${suffix}"
  sqlFile="${!sqlFileVarName}"

  userVarName="${userPrefix}${suffix}"
  user="${!userVarName}"

  passwordVarName="${passwordPrefix}${suffix}"
  password=${!passwordVarName}

  if [ -f "$sqlFile" ]; then
    echo "[INFO]: import-databases.sh: creating database '$dbName' accessible by user '$user'"
    /usr/bin/mysql -u root <<-EOF
      CREATE DATABASE IF NOT EXISTS $dbName;
      GRANT ALL PRIVILEGES ON $dbName.* TO '$user'@'%' IDENTIFIED BY '$password';
EOF
    echo "[INFO]: import-databases.sh: importing '$sqlFile' into database '$dbName'..."
    /usr/bin/mysql -u root "$dbName" < "./$sqlFile"
  else
    echo "[ERROR]: import-databases.sh: file $sqlFile for import not found"
  fi
done