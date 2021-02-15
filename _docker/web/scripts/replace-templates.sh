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

    destinationFileContent=$sourceFileContent

    for toReplace in $(echo "$destinationFileContent" | grep -P -o '\$\{[A-Za-z0-9_]+(\}|\:\-.+?\})'); do
      withoutDefault=$(echo "$toReplace" | grep -P -o '\$\{[A-Za-z0-9_]+?\}')
      if [ -n "$withoutDefault" ]; then
        # without default value
        varName=${withoutDefault:2:-1}
        varValue=${!varName}
        if [ -n "$varValue" ]; then
          destinationFileContent="${destinationFileContent//\\\$\{$varName\}/$varValue}"
          destinationFileContent="${destinationFileContent//\$\{$varName\}/$varValue}"
        fi
      else
        # with default value
        withDefault=$(echo "$toReplace" | grep -P -o '\$\{[A-Za-z0-9_]+?\:\-')
        if [ -n "$withDefault" ]; then
          varName=${withDefault:2:-2}
          varValue=${!varName}
          defaultValue=${toReplace:${#varName}+4:-1}
          # check if env var is set
          if [ -n "$varValue" ]; then
            # write the env variable value
            destinationFileContent="${destinationFileContent//\\\$\{$varName\:\-$defaultValue\}/$varValue}"
            destinationFileContent="${destinationFileContent//\$\{$varName\:\-$defaultValue\}/$varValue}"
          else
            # write the default value
            destinationFileContent="${destinationFileContent//\\\$\{$varName\:\-$defaultValue\}/$defaultValue}"
            destinationFileContent="${destinationFileContent//\$\{$varName\:\-$defaultValue\}/$defaultValue}"
          fi
        fi
      fi
    done

    # write replaced content to destination file if content is different
    if [ "$sourceFileContent" != "$destinationFileContent" ]; then
      if [ -f "$destinationFile" ]; then
        destinationFileContentBefore=$(<"$destinationFile")
      else
        destinationFileContentBefore=""
      fi
      # only if destination file would be different to before
      if [ "$destinationFileContent" != "$destinationFileContentBefore" ]; then
        echo "$destinationFileContent" > "$destinationFile"
        echo "[INFO]: replace-templates.sh: replaced some content of $destinationFile with environment variables"
      fi
    fi
  else
    echo "[ERROR]: replace-templates.sh: could not find template file '$sourceFile'"
    exit 1
  fi
done