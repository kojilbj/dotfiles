#!/usr/bin/env bash

# Tint the icon with the Bluetooth brand color when the current default
# audio output device is a Bluetooth device (AirPods, etc.), so the volume
# icon itself doubles as a Bluetooth-audio indicator.
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
  COLOR="0xff0082fc"
else
  COLOR="0xffff5252"
fi

if [ "$SENDER" = "volume_change" ]; then
  VOLUME="$INFO"

  case "$VOLUME" in
    [6-9][0-9]|100)   ICON="􀊩" ;; # speaker.wave.3.fill
    [3-5][0-9])       ICON="􀊧" ;; # speaker.wave.2.fill
    [1-9]|[1-2][0-9]) ICON="􀊥" ;; # speaker.wave.1.fill
    *)                ICON="􀊣" ;; # speaker.slash.fill
  esac

  sketchybar --set "$NAME" icon="$ICON" label="$VOLUME%" icon.color="$COLOR"
else
  sketchybar --set "$NAME" icon.color="$COLOR"
fi
