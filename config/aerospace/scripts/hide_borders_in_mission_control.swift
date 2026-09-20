#!/usr/bin/env swift
import CoreGraphics
import Foundation

// JankyBorders (github.com/FelixKratz/JankyBorders) draws its border as a
// separate overlay window anchored to each bordered window's absolute
// on-screen frame. Mission Control's zoom-out/grid animation only knows
// about real application windows, so it never moves or hides borders'
// overlay windows: they stay frozen at their original position/size,
// floating on top of the shrunk thumbnails, until Mission Control closes.
//
// There is no built-in borders flag for this (checked `man borders` on
// v1.9.0: style/active_color/inactive_color/background_color/width/hidpi/
// ax_focus/blacklist/whitelist — nothing Mission-Control-related), and no
// public NSDistributedNotification reliably fires on MC enter/exit either
// (sniffed all distributed notifications while toggling MC: none). So this
// polls CGWindowListCopyWindowInfo for the window Mission Control itself
// draws (owner "WindowManager", name "ExposeShieldWindow") and toggles
// borders fully transparent for exactly as long as that window exists.
// Checked this doesn't also fire on plain Dock auto-hide reveal, which
// creates a different, non-unique full-screen "Dock"-owned window.
//
// Launched via aerospace.toml's after-startup-command, alongside borders
// and sketchybar themselves.

let bordersPath = "/opt/homebrew/bin/borders"
let activeColor = "0xff5c8df6" // keep in sync with aerospace.toml's after-startup-command
let inactiveColor = "0xff494d64"
let hiddenColor = "0x00000000"
let pollInterval: TimeInterval = 0.08

func missionControlActive() -> Bool {
    guard let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] else {
        return false
    }
    for w in list {
        if (w[kCGWindowOwnerName as String] as? String) == "WindowManager",
           (w[kCGWindowName as String] as? String) == "ExposeShieldWindow" {
            return true
        }
    }
    return false
}

func setBorders(active: String, inactive: String) {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: bordersPath)
    task.arguments = ["active_color=\(active)", "inactive_color=\(inactive)"]
    task.terminationHandler = { _ in } // reap asynchronously, don't leave a zombie
    try? task.run()
}

var hidden = false
while true {
    let active = missionControlActive()
    if active != hidden {
        hidden = active
        if hidden {
            setBorders(active: hiddenColor, inactive: hiddenColor)
        } else {
            setBorders(active: activeColor, inactive: inactiveColor)
        }
    }
    Thread.sleep(forTimeInterval: pollInterval)
}
