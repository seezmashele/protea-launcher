# Protea Launcher

A simple grid-style app launcher for KDE Plasma 6. It replaces the default Application Launcher with a popup made of three parts: a search bar, a grid of apps, and a utility bar with your avatar, System Settings and a power menu.

See [PLAN.md](PLAN.md) for the design and how it was built, and [DIMENSIONS.md](DIMENSIONS.md) for every size and gap in the popup.

## Requirements

- KDE Plasma 6.8 (6.7 should also work)

## Install

1. Get `protea-launcher-<version>.plasmoid`, or build it yourself with `./scripts/build.sh`.
2. Right-click the panel or desktop and choose **Add or Manage Widgets…**. Then choose **Get New → Install Widget From Local File…** and pick the `.plasmoid` file.

   Or from a terminal:

   ```
   kpackagetool6 --type Plasma/Applet --install protea-launcher-<version>.plasmoid
   ```

3. To put it in place of the default launcher, right-click the Application Launcher in your panel, choose **Show Alternatives…** and pick **Protea Launcher**. You can also drag it from Add Widgets into a panel.

The Meta key opens Protea once it's in a panel.

**Update** to a newer `.plasmoid`:

```
kpackagetool6 --type Plasma/Applet --upgrade protea-launcher-<version>.plasmoid
systemctl --user restart plasma-plasmashell
```

**Uninstall:** switch back to the Application Launcher first (right-click Protea's panel icon, choose **Show Alternatives…** and pick **Application Launcher**). Then run:

```
kpackagetool6 --type Plasma/Applet --remove dev.protea.launcher
```

## Using it

- **Search:** start typing as soon as the popup opens. Search covers apps and System Settings pages. Press Enter to launch the first result.
- **Grid:** click an app to launch it, or use the keyboard:

  | Key | Action |
  |---|---|
  | Arrows | Move between apps (Up from the top row returns to search) |
  | Home / End | Start or end of the row; with Ctrl, the first or last app |
  | Page Up / Page Down | A screenful up or down |
  | Enter | Launch the selected app |
  | Tab / Shift+Tab | Move between search, grid, avatar and buttons |
  | Esc | Clear the search; press again to close |

- **App menu:** right-click an app, press and hold it, or press the Menu key or Shift+F10. The menu has the app's own actions (such as "New Private Window"), Add to Desktop, Pin to Task Manager, Edit Application and Hide.
- **Hiding apps:** choose **Hide** in an app's menu and its tile goes straight away. Hidden apps still show up when you search, and their menu there has **Unhide**. The **Hidden Apps** page in settings lists them all.
- **Utility bar:** click your avatar to open your user settings. The gear opens System Settings. The power button opens a menu with Lock, Log Out, Switch User, Sleep, Restart and Shut Down.

## Settings

Right-click any free space in the popup and choose **Configure Launcher**, the only item in that menu. Right-clicking Protea's panel icon has it too, next to **Show Alternatives…**. Those are the only two items there, so for the panel's own options (Add Widgets, Enter Edit Mode) right-click an empty spot on the panel. The popup sizes itself from the columns, rows and size settings; it can't be dragged to another size.

The settings are on three pages: **General** (panel icon, appearance and the app grid), **Utility Bar** (its buttons, and a table of session actions with a column for each place they can go: a button of their own, the power menu, or both) and **Hidden Apps**.

| Setting | Default |
|---|---|
| Panel icon | Protea's own icon; pick any icon or reset back to it |
| Header and footer background | Off; tick it for dark bands (black at 25% opacity) behind the search bar at the top and the utility bar at the bottom, running to the popup's edges |
| Search bar corners | Round (fully rounded ends, filled with the text colour at 10%); or Default, the theme's own search field |
| Columns × rows | 6 × 5 (3 to 12 each); the popup sizes itself to fit |
| Size | Cozy; also Compact, Small, Medium and Large. Each sets the icon size and its tile size |
| Use smaller tiles | Off; tick it for tiles 8 px smaller at whichever size is chosen |
| Buttons on the utility bar | System Settings and the power menu; any session action can also get its own button |
| Power menu items | Every session action the system supports |
| Hidden apps | None. The **Hidden Apps** page lists them, each with **Unhide** |

## Development

You'll need `plasma-sdk` for previewing: `sudo pacman -S plasma-sdk` on Arch, `sudo dnf install plasma-sdk` on Fedora.

| Command | What it does |
|---|---|
| `./scripts/preview.sh` | Opens the widget in a window, with QML errors printed to the terminal |
| `./scripts/install.sh` | Installs for the current user, or upgrades and restarts plasmashell |
| `./scripts/build.sh` | Builds `protea-launcher-<version>.plasmoid` from `package/` |
| `./scripts/lint.sh` | Checks every QML file in `package/` with qmllint |
| `systemctl --user restart plasma-plasmashell` | Restarts plasmashell by hand, e.g. after running `kpackagetool6 --upgrade` yourself |

## License

GPL-2.0-or-later. Parts are adapted from KDE's Application Launcher (Kickoff). See [LICENSE](LICENSE).
