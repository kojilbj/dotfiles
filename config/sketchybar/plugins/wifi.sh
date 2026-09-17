#!/usr/bin/env bash

DEVICE="en0"
STATE_FILE="/tmp/sketchybar_wifi_prev"

if networksetup -getairportpower "$DEVICE" | grep -q ": Off"; then
  sketchybar --set "$NAME" icon='􀙈' label="" # wifi.slash
  rm -f "$STATE_FILE"
  exit 0
elif route -n get default 2>/dev/null | grep -q "gateway: 172.20.10.1"; then
  ICON='􀉤' # personalhotspot
else
  ICON='􀙇' # wifi
fi

# Upload/download throughput, from the delta of the interface's cumulative
# byte counters between runs (persisted in a state file, since each run is
# a fresh process with no memory of the last one).
if [[ -f "$STATE_FILE" ]]; then
  read -r PREV_IN PREV_OUT PREV_TIME < "$STATE_FILE"
fi

read -r IBYTES OBYTES <<<"$(netstat -ibn -I "$DEVICE" | awk -v dev="$DEVICE" '$1==dev {print $7, $10; exit}')"
NOW=$(date +%s)
echo "$IBYTES $OBYTES $NOW" >"$STATE_FILE"

LABEL=""
if [[ -n "$PREV_TIME" && -n "$IBYTES" && "$NOW" -gt "$PREV_TIME" ]]; then
  DT=$((NOW - PREV_TIME))
  UP_KBPS=$(awk -v b="$((OBYTES - PREV_OUT))" -v dt="$DT" 'BEGIN{printf "%5.1f", (b/dt)/1024}')
  DOWN_KBPS=$(awk -v b="$((IBYTES - PREV_IN))" -v dt="$DT" 'BEGIN{printf "%5.1f", (b/dt)/1024}')
  LABEL="↑${UP_KBPS}KB/s ↓${DOWN_KBPS}KB/s"
fi

sketchybar --set "$NAME" icon="$ICON" label="$LABEL"
