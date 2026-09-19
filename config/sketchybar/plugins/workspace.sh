#!/usr/bin/env bash

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$PLUGIN_DIR/icon_map.sh"
source "$PLUGIN_DIR/app_color.sh"

WORKSPACE_APP_SLOTS=3

if [ -n "$FOCUSED_WORKSPACE" ]; then
  FOCUSED="$FOCUSED_WORKSPACE"
else
  FOCUSED=$(aerospace list-workspaces --focused 2>/dev/null) || {
    BREW_PREFIX="${HOMEBREW_PREFIX:-$(brew --prefix 2>/dev/null)}"
    FOCUSED=$("$BREW_PREFIX/bin/aerospace" list-workspaces --focused 2>/dev/null)
  }
fi

if [ -z "$FOCUSED" ]; then
  exit 0
fi

SID=${NAME#workspace.}

if [ "$FOCUSED" = "$SID" ]; then
  LABEL_COLOR=0xffffffff
else
  LABEL_COLOR=0x60ffffff
fi
sketchybar --set "$NAME" label.color="$LABEL_COLOR"

# Show one colored app-font glyph per distinct app currently on this
# workspace, in its own slot, so each app keeps its own brand color instead
# of everything sharing one field's tint.
apps=$(aerospace list-windows --workspace "$SID" --format "%{app-name}" 2>/dev/null | sort -u)

slot=0
while IFS= read -r app; do
  [ -z "$app" ] && continue
  slot=$((slot + 1))
  if [ "$slot" -gt "$WORKSPACE_APP_SLOTS" ]; then
    break
  fi
  __icon_map "$app"
  __app_color "$app"
  ICON_ALPHA="$color_result"
  if [ "$FOCUSED" != "$SID" ]; then
    # Dim unfocused workspaces' icons a bit, same spirit as the number label.
    ICON_ALPHA="0xb0${color_result#0xff}"
  fi
  sketchybar --set "workspace.$SID.app$slot" icon.drawing=on icon="$icon_result" icon.color="$ICON_ALPHA"
done <<< "$apps"

# Hide any unused slots left over from a previous, busier state.
while [ "$slot" -lt "$WORKSPACE_APP_SLOTS" ]; do
  slot=$((slot + 1))
  sketchybar --set "workspace.$SID.app$slot" icon.drawing=off
done
