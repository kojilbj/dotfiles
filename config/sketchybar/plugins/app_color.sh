#!/usr/bin/env bash
# Maps an app name to its brand color, so per-workspace app icons in the
# sketchybar bar read as color instead of a uniform gray/white glyph.
# Usage: __app_color "$app_name"; result in $color_result (0xAARRGGBB).

__app_color() {
  color_result=0xffcccccc # fallback: light gray, for apps not listed below
  case "$1" in
    "WezTerm")
      color_result=0xff8250df
      ;;
    "Terminal"|"iTerm2")
      color_result=0xff2ecc71
      ;;
    "Brave Browser")
      color_result=0xfffb542b
      ;;
    "Safari"|"Safari Technology Preview")
      color_result=0xff006cff
      ;;
    "Google Chrome"|"Google Chrome Canary"|"Microsoft Edge"|"Arc")
      color_result=0xff4285f4
      ;;
    "Firefox"|"Firefox Developer Edition")
      color_result=0xffff6611
      ;;
    "Music")
      color_result=0xfffa2d48
      ;;
    "Spotify")
      color_result=0xff1ed760
      ;;
    "Obsidian")
      color_result=0xff7c3aed
      ;;
    "Notion")
      color_result=0xffffffff
      ;;
    "Finder")
      color_result=0xff1e88e5
      ;;
    "System Settings"|"System Preferences")
      color_result=0xff8e8e93
      ;;
    "Visual Studio Code"|"Code"|"VSCodium")
      color_result=0xff007acc
      ;;
    "Xcode")
      color_result=0xff147efb
      ;;
    "Slack")
      color_result=0xff4a154b
      ;;
    "Discord")
      color_result=0xff5865f2
      ;;
    "Zoom"|"zoom.us")
      color_result=0xff2d8cff
      ;;
    "Mail")
      color_result=0xff4dabff
      ;;
    "Calendar")
      color_result=0xfffc3d39
      ;;
    "Messages")
      color_result=0xff2fd058
      ;;
    "Notes")
      color_result=0xffffcc02
      ;;
    "Reminders")
      color_result=0xffff9500
      ;;
    "Figma")
      color_result=0xfff24e1e
      ;;
    "Docker"|"Docker Desktop")
      color_result=0xff2496ed
      ;;
    "1Password"|"1Password 7"|"1Password 8")
      color_result=0xff1a8cff
      ;;
    "Preview")
      color_result=0xff58b3ff
      ;;
    "Activity Monitor")
      color_result=0xff5ac8fa
      ;;
    "GitHub Desktop")
      color_result=0xff24292e
      ;;
    "Brave Browser Beta"|"Brave Browser Nightly")
      color_result=0xfffb542b
      ;;
  esac
}
