#!/usr/bin/env bash
# Maps an app name to its brand color, so per-workspace app icons in the
# sketchybar bar read as color instead of a uniform gray/white glyph.
# Usage: __app_color "$app_name"; result in $color_result (0xAARRGGBB).

__app_color() {
  color_result=0xffe2e8f0 # fallback: clear light slate gray for unlisted apps
  case "$1" in
    "WezTerm")
      color_result=0xffa78bfa # bright lavender purple
      ;;
    "Terminal"|"iTerm2")
      color_result=0xff4ade80 # bright terminal neon green
      ;;
    "Brave Browser"|"Brave Browser Beta"|"Brave Browser Nightly")
      color_result=0xffff6b4a # vibrant orange
      ;;
    "Safari"|"Safari Technology Preview")
      color_result=0xff60a5fa # bright sky blue
      ;;
    "Google Chrome"|"Google Chrome Canary"|"Microsoft Edge"|"Arc")
      color_result=0xff58a6ff # vibrant cyan blue
      ;;
    "Firefox"|"Firefox Developer Edition")
      color_result=0xffff7830 # bright flame orange
      ;;
    "Music")
      color_result=0xfffb5c73 # bright coral pink/red
      ;;
    "Spotify")
      color_result=0xff22c55e # vibrant spotify green
      ;;
    "Obsidian")
      color_result=0xffa855f7 # bright purple
      ;;
    "Notion")
      color_result=0xffffffff # crisp white
      ;;
    "Finder")
      color_result=0xff38bdf8 # bright cyan blue
      ;;
    "System Settings"|"System Preferences")
      color_result=0xffcbd5e1 # bright silver gray
      ;;
    "Visual Studio Code"|"Code"|"VSCodium")
      color_result=0xff38bdf8 # bright vscode cyan blue
      ;;
    "Xcode")
      color_result=0xff60a5fa # bright xcode blue
      ;;
    "Slack")
      color_result=0xffe879f9 # bright magenta/orchid (avoiding dark eggplant)
      ;;
    "Discord")
      color_result=0xff818cf8 # bright blurple / indigo
      ;;
    "Zoom"|"zoom.us")
      color_result=0xff60a5fa # bright zoom blue
      ;;
    "Mail")
      color_result=0xff70b8ff # bright mail blue
      ;;
    "Calendar")
      color_result=0xfffb7185 # bright rose red
      ;;
    "Messages")
      color_result=0xff4ade80 # bright message green
      ;;
    "Notes")
      color_result=0xfffde047 # bright notes yellow
      ;;
    "Reminders")
      color_result=0xfffb923c # bright reminders orange
      ;;
    "Figma")
      color_result=0xffff6434 # bright figma coral
      ;;
    "Docker"|"Docker Desktop")
      color_result=0xff38bdf8 # bright docker cyan
      ;;
    "1Password"|"1Password 7"|"1Password 8")
      color_result=0xff60a5fa # bright 1password blue
      ;;
    "Preview")
      color_result=0xff7dd3fc # bright preview light blue
      ;;
    "Activity Monitor")
      color_result=0xff67e8f9 # bright activity monitor cyan
      ;;
    "GitHub Desktop")
      color_result=0xffcbd5e1 # bright octocat silver (avoiding dark black/gray)
      ;;
  esac
}
