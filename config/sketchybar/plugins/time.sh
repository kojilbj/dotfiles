#!/usr/bin/env bash

TIME=$(date '+%H:%M:%S')
sketchybar --set "$NAME" label="$TIME"

if [[ $TIME == 00:00:0? ]]; then
  sketchybar --trigger date_boundary
fi
