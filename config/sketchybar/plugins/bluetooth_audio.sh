#!/usr/bin/env bash
# Shows a bluetooth icon (no label -- device names get long) when the
# current default audio output device is a Bluetooth device (AirPods,
# etc.), and hides itself otherwise.

TRANSPORT=$(system_profiler SPAudioDataType -json 2>/dev/null | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    for item in data['SPAudioDataType'][0]['_items']:
        if item.get('coreaudio_default_audio_output_device') == 'spaudio_yes':
            print(item.get('coreaudio_device_transport', ''))
            break
except Exception:
    pass
")

if [[ "$TRANSPORT" == "coreaudio_device_type_bluetooth" ]]; then
  # SF Symbols has no bluetooth glyph (Apple can't redistribute the
  # trademarked logo), so this one icon uses Hack Nerd Font instead
  # (nf-fa-bluetooth, verified present via fontTools).
  sketchybar --set "$NAME" drawing=on icon="$(printf '')" icon.font="Hack Nerd Font:Bold:20.0" label=""
else
  sketchybar --set "$NAME" drawing=off
fi
