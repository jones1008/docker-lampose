#!/bin/bash

wd=$(pwd)
cd "$wd"

sourceRoot=./_docker/web/templates

# loop over all Environment variables that start with "TEMPLATE_"
for templateVarName in "${!TEMPLATE@}"; do
  templateVarValue="${!templateVarName}"
  IFS=':' read -ra templateVarValues <<< "$templateVarValue"

  # get source and destination file
  sourceFile="$sourceRoot/${templateVarValues[0]}"
  if [ -f "$sourceFile" ]; then
    destinationFile=${templateVarValues[1]}

    # get file content into variable
    sourceFileContent=$(<"$sourceFile")

    # loop over all environment variables and replace all ${VAR} and \${VAR}-like occurrences
    envVars=$(compgen -e)
    destinationFileContent=$sourceFileContent
    for envVar in $envVars; do
      destinationFileContent="${destinationFileContent//\\\$\{$envVar\}/${!envVar}}"
      destinationFileContent="${destinationFileContent//\$\{$envVar\}/${!envVar}}"
    done

    # write replaced content to destination file if content is different
    if [ "$sourceFileContent" != "$destinationFileContent" ]; then
      echo "$destinationFileContent" > "$destinationFile"
      echo "[INFO]: replace-templates.sh: replaced some content of $destinationFile with environment variables"
    fi
  else
    echo "[ERROR]: replace-templates.sh: could not find template file '$sourceFile'"
    exit 1
  fi
done