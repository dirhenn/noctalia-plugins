# Quickshell Overview for Hyprland

<div align="center">

A standalone workspace overview module for Hyprland using Quickshell - shows all workspaces with live window previews, drag-and-drop support, and Super+Tab keybind.

![Quickshell](https://img.shields.io/badge/Quickshell-0.2.0-blue?style=flat-square)
![Hyprland](https://img.shields.io/badge/Hyprland-Compatible-purple?style=flat-square)
![Qt6](https://img.shields.io/badge/Qt-6-green?style=flat-square)
![License](https://img.shields.io/badge/License-GPL-orange?style=flat-square)

</div>


## ✨ Features

- 🖼️ Visual workspace overview showing all workspaces and windows
- 🎯 Click windows to focus them
- 🖱️ Middle-click windows to close them  
- 🔄 Drag and drop windows between workspaces
- ⌨️ Keyboard navigation (Arrow keys, vim keys, number shortcuts)
- 💡 Hover tooltips showing window information
- 🎨 Material Design 3 theming
- ⚡ Smooth animations and transitions

## 📦 Installation

### Prerequisites

- **Hyprland** compositor
- **Quickshell** ([installation guide](https://quickshell.org/docs/v0.1.0/guide/install-setup/))
- **Qt 6** with modules: QtQuick, QtQuick.Controls

### Setup
``

1. **Add keybind** to your Hyprland config (`~/.config/hypr/hyprland.conf`):
   ```conf
   bind = Super, TAB, exec, qs -c noctalia-shell ipc call plugin:hypr-overview toggle
   ```

## 🎮 Usage

| Action | Description |
|--------|-------------|
| **Super + Tab** | Toggle the overview |
| **Arrow Keys** | Navigate between workspaces |
| **h / j / k / l** | Vim-style navigation (left/down/up/right) |
| **1-9, 0** | Jump to Nth workspace in current group (0 = 10th) |
| **Escape / Enter** | Close the overview |
| **Click workspace** | Switch to that workspace |
| **Click window** | Focus that window |
| **Middle-click window** | Close that window |
| **Drag window** | Move window to different workspace (single monitor only)|

---

### Workspace Grid

Edit `~/.config/quickshell/overview/common/Config.qml`:

```qml
property QtObject overview: QtObject {
    property int rows: 2        // Number of workspace rows
    property int columns: 5     // Number of workspace columns (10 total workspaces)
    property real scale: 0.16   // Overview scale factor (0.1-0.3, smaller = more compact)
    property bool enable: true
}
```

**Common adjustments:**
- **Too small?** Increase `scale` (try 0.20 or 0.25)
- **Too big?** Decrease `scale` (try 0.12 or 0.14)
- **More workspaces?** Change `rows` and `columns` (e.g., 3 rows × 4 columns = 12 workspaces)

### Position

Edit `~/.config/quickshell/overview/modules/overview/Overview.qml` (line ~111):

```qml
anchors {
    horizontalCenter: parent.horizontalCenter
    top: parent.top
    topMargin: 100  // Change this value to move up/down
}
```

### Theme & Colors

Edit `~/.config/quickshell/overview/common/Appearance.qml` to customize:
- Colors (m3colors and colors objects)
- Font families and sizes  
- Animation curves and durations
- Border radius values

---

## 📋 Requirements

- **Hyprland** compositor (tested on latest versions)
- **Quickshell** (Qt6-based shell framework)
- **Qt 6** with the following modules:
  - QtQuick
  - QtQuick.Controls
  - QtQuick.Layouts
  - Quickshell.Wayland
  - Quickshell.Hyprland

## 🚫 Removed Features (from original illogical-impulse)

The following features were removed to make it standalone:

- App search functionality
- Emoji picker
- Clipboard history integration
- Search widget
- Integration with the full illogical-impulse shell ecosystem

## 🎯 IPC Commands

```bash
# Toggle overview
qs -c noctalia-shell ipc call plugin:hypr-overview toggle

# Open overview
qs -c noctalia-shell ipc call plugin:hypr-overviewopen

# Close overview  
qs -c noctalia-shell ipc call plugin:hypr-overview close
```

## 🐛 Known Issues

- Potential crashes during rapid window state changes due to Wayland screencopy buffer management
- Some keybinds and drag are bound to single monitor
- Color Palette not syncing with Noctalia environment

##  Credits

Extracted from the overview feature in [illogical-impulse](https://github.com/end-4/dots-hyprland) by [end-4](https://github.com/end-4).

Adapted as a standalone component for Hyprland + Quickshell users who want just the overview functionality by Shanu-Kumawat.

Ported to Noctalia-Shell as plugin by Dirhenn.

---

