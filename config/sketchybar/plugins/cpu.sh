#!/usr/bin/env bash

# top's first sample is skewed by its own startup, so read the second one.
# Zero-padded (not space-padded) to a fixed 4 characters ("08.9", "12.5",
# "99.9"), so the label is always the same width regardless of value --
# leading spaces can't be trusted to reserve real width in every font, so
# unlike digits they don't reliably keep the pill (and its distance from
# the notch) constant.
CPU=$(top -l 2 -n 0 | awk '/CPU usage/ {usage = $3 + $5} END {printf "%04.1f", usage}')
sketchybar --set "$NAME" label="$CPU%"
