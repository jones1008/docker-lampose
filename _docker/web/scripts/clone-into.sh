#!/bin/bash

wd=$(pwd)

# loop over all Environment variables that start with "CLONE_INTO_"
for cloneIntoVarName in "${!CLONE_INTO_@}"; do
  cloneIntoVarValue="${!cloneIntoVarName}"
  IFS=':' read -ra cloneIntoVarValues <<< "$cloneIntoVarValue"

  # get source and destination file
  destination="${cloneIntoVarValues[0]}"
  gitLink="https://${cloneIntoVarValues[1]}"
  branch="${cloneIntoVarValues[2]}"

  gitRoot=${gitLink//\//}
  source="/clone-into.sh/$gitRoot"

  # clone if: destination OR source doesn't exist OR is empty
  { [ ! -d "$source" ] || [ -z "$(ls -A "$source")" ] || [ ! -d "$destination" ] || [ -z "$(ls -A "$destination")" ]; } && clone=true || clone=false

  if [ "$clone" = true ]; then
    # clone into temporary folder
    echo "[INFO]: clone-into.sh: cloning content from $gitLink into $source..."
    rm -rf "$source"
    git clone --quiet "$gitLink" "$source"
  fi

  # switch to branch if specified and is not already on that branch
  cd "$source" || exit 1
  currentBranch=$(git rev-parse --abbrev-ref HEAD)
  if [ -n "$branch" ] && [ "$currentBranch" != "$branch" ]; then
    git checkout --quiet "$branch"
  fi

  # copy if it was cloned OR if there is a difference
  cd "$wd" || exit 1
  if [ "$clone" = true ] || diff -q -r "$source" "$destination" | grep -q "Only in $source"; then
    # move files into destination without overwriting existing files
    echo "[INFO]: clone-into.sh: copying files from $source to $destination (skip existing)..."
    mkdir -p "$destination"

    rsync -a --info=progress2 --ignore-existing "$source"/. "$destination" --exclude=".git"
#    numberOfFiles=$(find "$source" | wc -l)
#    rsync -ai --ignore-existing "$source"/. "$destination" --exclude=".git" | (pv --force --progress --bytes --interval 2 --size "$numberOfFiles" >/dev/null) | stdbuf -o0 tr '\r' '\n'

  fi
done

cd "$wd" || exit 1