#!/bin/bash

cd /sql-files

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
    mysql -u root <<-EOF
      CREATE DATABASE IF NOT EXISTS \`$dbName\`;
      GRANT ALL PRIVILEGES ON \`$dbName\`.* TO \`$user\`@'%' IDENTIFIED BY '$password';
EOF
    echo "[INFO]: import-databases.sh: importing '$sqlFile' into database '$dbName'..."

    # output line by line progress of import
    pv --numeric "$sqlFile" | mysql -u root "$dbName" --init-command="SET autocommit=0;"
  else
    echo "[ERROR]: import-databases.sh: file $sqlFile for import not found"
  fi
done