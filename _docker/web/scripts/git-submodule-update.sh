#!/bin/bash

if [ "$CONTAINS_GIT_SUBMODULES" != "false" ]; then
  if [ -f "./.gitmodules" ] || [ "$CONTAINS_GIT_SUBMODULES" = "true" ]; then
    echo "[INFO]: git-submodule-update.sh: trying to pull git submodule updates"
    git submodule update --init --recursive
  fi
fi