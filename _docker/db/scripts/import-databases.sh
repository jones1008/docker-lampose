#!/bin/bash

cd /sql-files || exit 1

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
    (pv --force --progress --bytes --interval 3 --name "Importing $sqlFile" "$sqlFile" | mysql -u root "$dbName" --init-command="SET autocommit=0;") 2>&1 | stdbuf -o0 tr '\r' '\n' | stdbuf -o0 sed -E "s/100%$/100%\nWriting database\.\.\. \(This may take a while\)/g"
  else
    echo "[ERROR]: import-databases.sh: file $sqlFile for import not found"
  fi
done