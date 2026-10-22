# Protea Launcher: KDE Store page

What to fill in when adding the launcher to the [KDE Store](https://store.kde.org). The description is plain text, as the store doesn't render Markdown; copy what's inside the box.

| Field | Value |
|---|---|
| Name | Protea Launcher |
| Category | Plasma 6 Extensions: the one Plasma's Get New Widgets dialog reads (`Categories=` in `/usr/share/knsrcfiles/plasmoids.knsrc`) |
| Licence | GPL-2.0-or-later (the store lists it as GPLv2 or later) |
| Version | 1.0.0 |
| File | `protea-launcher-1.0.0.plasmoid`, from `./scripts/build.sh` |
| Source | https://github.com/seezmashele/protea-launcher |

## Description

```
A simple grid-style app launcher for KDE Plasma 6.8 and later.

Protea replaces the Application Launcher with a compact popup in three parts: a search bar, a grid of your apps from A to Z, and a utility bar with your avatar, System Settings and a power menu.

Features:
- Start typing to search apps and System Settings pages; Enter launches the first result
- Choose the grid's columns and rows, and one of five icon sizes
- Full keyboard control: arrows, Home/End, Page Up/Down, Tab, Esc
- Right-click an app for its own actions (such as New Private Window), Add to Desktop, Pin to Task Manager, Edit Application and Hide
- Hide apps you never use; they still show up when you search
- Give any session action (Lock, Sleep, Shut Down, ...) a button of its own or a place in the power menu, or hide the avatar or the whole utility bar
- Follows your Plasma theme, light or dark. The screenshots show the Protea Dark theme

Installing:
Right-click the panel or desktop, choose Add or Manage Widgets..., then Get New > Download New Plasma Widgets, and search for "Protea".
To put it in place of the Application Launcher, right-click the launcher in your panel, choose Show Alternatives... and pick Protea Launcher. The Meta key opens it.

Requires KDE Plasma 6.8 or later.
Licence: GPL-2.0-or-later. Parts are adapted from KDE's Application Launcher (Kickoff).
Source code and bug reports: https://github.com/seezmashele/protea-launcher
```

## Screenshots

Upload in this order; the first is the one the store shows in listings. All are in [screenshots/](screenshots/).

1. `popup.png`: the popup with the default settings
2. `search.png`: a search under way, finding an app and System Settings pages
3. `settings-general.png`: the General settings page
4. `settings-utility-bar.png`: the Utility Bar settings page
5. `settings-hidden-apps.png`: the Hidden Apps settings page
