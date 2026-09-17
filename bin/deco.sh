#!/usr/bin/env bash
# Opens a new WezTerm tab split into btop (left), tty-clock (top right),
# and cmatrix (bottom right). Requires an already-running WezTerm GUI.
set -euo pipefail

left_pane="$(wezterm cli spawn -- btop)"
right_top_pane="$(wezterm cli split-pane --pane-id "$left_pane" --right --percent 35 -- tty-clock -c -C 6)"
wezterm cli split-pane --pane-id "$right_top_pane" --bottom --percent 60 -- cmatrix -b
