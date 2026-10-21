# Protea Launcher: Plan

A simple grid-style app launcher for KDE Plasma 6 that replaces the default Application Launcher (Kickoff) in the panel.

- **Name:** Protea Launcher
- **Widget ID:** `dev.protea.launcher`
- **Target:** Plasma 6.8 (built on 6.7.5 on Fedora 44; updated on 6.8.0 on Arch). 6.7 should still work
- **Type:** QML-only plasmoid (no C++, no CMake), installed with `kpackagetool6`

## Layout

```
┌──────────────────────────────────────────────────┐
│  [ Search…                                    ]  │  search bar
├──────────────────────────────────────────────────┤
│   app    app    app    app    app    app         │
│   app    app    app    app    app    app         │  app grid (scrolls)
│   ...                                            │
├──────────────────────────────────────────────────┤
│  (o)                                [set] [pwr]  │  utility bar
└──────────────────────────────────────────────────┘
```

### Search bar (top)
- `PlasmaExtras.SearchField`. The grid has keyboard focus when the popup opens; typing anywhere goes into the search box, which then takes focus.
- Searches apps and settings pages only: `RunnerModel` with `runners: ["krunner_services", "krunner_systemsettings"]`.
- While there's text in the box, the grid shows results instead of all apps.

### App grid (middle)
- All installed apps in one A–Z list (no favorites, no categories).
- Fixed size of 6 columns × 5 rows by default (configurable). The popup sizes itself to fit the grid.
- Each tile is an icon plus a label of up to two lines.

### Utility bar (bottom)
- **Left:** a circular user avatar (`KirigamiComponents.AvatarButton`). The picture and name come from `KCoreAddons.KUser`. Hovering shows the user's name; clicking opens the Users settings page (`kcm_users`). It shows initials when no profile picture is set.
- **Right:** icon-only buttons, each with a hover tooltip: System Settings, and a Power button that opens a menu with the session actions below (changed after phase 5; they started as separate buttons):

| Item | Where | Icon | Action |
|---|---|---|---|
| System Settings | Bar | `applications-system-symbolic` | Opens System Settings |
| Power | Bar | `system-shutdown-symbolic` | Opens the power menu |
| Lock | Power menu | `system-lock-screen` | SystemModel `lock-screen` |
| Log Out | Power menu | `system-log-out` | SystemModel `logout` |
| Switch User | Power menu | `system-switch-user` | SystemModel `switch-user` |
| Sleep | Power menu | `system-suspend` | SystemModel `suspend` |
| Hibernate | Power menu, when supported | `system-suspend-hibernate` | SystemModel `hibernate` |
| Restart | Power menu | `system-reboot` | SystemModel `reboot` |
| Shut Down | Power menu | `system-shutdown` | SystemModel `shutdown` |

- Which buttons sit on the bar (`utilityButtons`) and what the power menu lists (`powerMenuActions`) are settings. The power actions go through Kicker's `SystemModel`, so they show Plasma's normal confirmation screen and hide actions the machine doesn't support.

## Folder structure

```
protea-launcher/
├── package/                          # the widget itself (only this folder gets installed)
│   ├── metadata.json                 # id, name, X-Plasma-Provides: org.kde.plasma.launchermenu
│   └── contents/
│       ├── config/
│       │   ├── main.xml              # settings: panel icon, search bar, columns, rows, grid size, hidden apps, utility bar
│       │   └── config.qml            # pages in the settings dialog
│       ├── icons/
│       │   └── protea.svg            # custom panel icon (phase 7)
│       └── ui/
│           ├── main.qml              # widget root: models, panel button, popup wiring
│           ├── CompactRepresentation.qml   # the panel button and its right-click menu
│           ├── FullRepresentation.qml   # the popup: stacks the three sections
│           ├── ConfigGeneral.qml     # General settings page (settings pages must sit at the ui/ root)
│           ├── ConfigUtilityBar.qml  # Utility Bar settings page
│           ├── ConfigHiddenApps.qml  # Hidden Apps settings page
│           ├── search/
│           │   └── SearchBar.qml
│           ├── grid/
│           │   ├── AppGrid.qml       # GridView: sizing, centering, keyboard nav
│           │   ├── AppTile.qml       # one cell: icon + label, hover/click/highlight
│           │   ├── ActionMenu.qml    # right-click menu on apps
│           │   └── VisibleAppsModel.qml # the A–Z list minus hidden apps
│           ├── utility/
│           │   ├── UtilityBar.qml    # avatar left, buttons right
│           │   ├── UserAvatar.qml    # circular avatar button
│           │   └── UtilityButton.qml # icon-only button with tooltip
│           └── code/
│               └── appid.js          # an app's desktop file ID from Kicker's favoriteId
├── scripts/
│   ├── preview.sh                    # open in plasmoidviewer as if in a bottom panel
│   ├── install.sh                    # install or update with kpackagetool6, restart plasmashell
│   ├── build.sh                      # zip package/ into protea-launcher.plasmoid
│   └── lint.sh                       # qmllint over every QML file in package/
├── .contextProperties.ini            # tells qmllint about Plasma's i18n functions
├── PLAN.md
├── DIMENSIONS.md                     # measured sizes and spacing of the popup
├── LICENSE                           # GPL-2.0-or-later (adapts Kickoff code)
├── README.md
└── .gitignore
```

- `kpackagetool6` installs the whole folder it's given. Keeping the widget in `package/` keeps git, scripts and docs out of the installed copy.
- `FullRepresentation.qml` loads the sections with `import "search"`, `import "grid"` and `import "utility"`.

## Backend

Kickoff's QML is compiled into `org.kde.plasma.kickoff.so`, but its data layer is the installed QML module `org.kde.plasma.private.kicker`, which Protea uses directly:

| Model | Used for |
|---|---|
| `RootModel` / `AppsModel` | The list of installed apps (flat, sorted A–Z) |
| `RunnerModel` | Search results |
| `SystemModel` | Lock, log out, sleep, restart, shut down |

**Risk:** this module is private, so a Plasma update can change it and break the launcher. Every third-party launcher has the same risk. Check after major Plasma upgrades.

**App IDs:** Protea identifies apps by desktop file ID (`org.kde.dolphin.desktop`), read from Kicker's `favoriteId` role through `code/appid.js`. Since Plasma 6.8 that role gives `applications:org.kde.dolphin.desktop` in the A–Z list too, as it always did in search results; `appid.js` takes either form, so saved settings didn't change.

## Reference: Kickoff's grid logic

Source: [plasma-desktop v6.8.0, `applets/kickoff`](https://invent.kde.org/plasma/plasma-desktop/-/tree/v6.8.0/applets/kickoff) (first written against v6.7.5; what's below hasn't changed since). The files that matter are `KickoffGridView.qml`, `KickoffGridDelegate.qml` and `AbstractKickoffItemDelegate.qml`.

- **Square cells:** the cell size comes from measuring a hidden tile (48px icon, two lines of label, padding), so it follows the font and theme.
- **Columns:** `columns = floor((width − 2 × gap) / cellWidth)`. The grid view is that many whole cells plus a 24px gap at each side (its own margins, as in Kickoff), centred; the scrollbar sits inside the right gap, so the tiles stay centred whether or not it shows.
- **Keyboard:** the GridView's built-in key handling is turned off and replaced with `Keys.onPressed`. Arrows, Home/End and PgUp/PgDn move; Enter launches; right-to-left layouts are handled.
- **Hover:** hovering sets `currentIndex`. Hover is ignored for 200ms after a key press or scroll, so a resting mouse doesn't steal the highlight.
- **Launch:** `view.model.trigger(index, "", null)`, then the popup closes. On close, the selection resets to the first app and the grid scrolls to the top.
- **Highlight:** `PlasmaExtras.Highlight` is drawn behind the current tile.

Not carried over: the sidebar and categories, favorites, Places, list views, page transitions, the avatar header, and pane swapping.

## Phases

Each phase ends with something that can be opened and checked before moving on.

### Phase 1: Skeleton
- [x] `git init`, `.gitignore`, `LICENSE`, `README.md`
- [x] `package/metadata.json`: `dev.protea.launcher`, "Protea Launcher", `X-Plasma-Provides: org.kde.plasma.launchermenu`
- [x] `main.qml`: panel button; Meta key toggles the popup (`activationTogglesExpanded`)
- [x] `FullRepresentation.qml`: three labelled placeholder blocks stacked top to bottom
- [x] `config/main.xml`: panel icon setting
- [x] `scripts/preview.sh`, `scripts/install.sh`

**Done when:** it opens in `plasmoidviewer` showing the three blocks, installs with the script, and shows up under Show Alternatives.

### Phase 2: App grid
- [x] All installed apps in one A–Z list
- [x] `grid/AppGrid.qml`: square cells, column snapping and centering, scrollbar, popup sized to columns × rows
- [x] `grid/AppTile.qml`: icon plus a two-line label, tooltip when the name is cut off, highlight follows the mouse
- [x] Clicking launches the app and closes the popup; reopening starts at the top
- [x] Settings: columns (6), rows (5), icon size

**Done when:** every app appears A–Z, clicking one launches it, and the popup is 6 × 5.

### Phase 3: Search bar
- [x] `search/SearchBar.qml` (focused on open at first; later changed so the grid takes focus and the search bar only becomes active once you start typing)
- [x] Search limited to apps and settings pages; the grid shows results while there's text
- [x] Typing anywhere goes into the search box
- [x] Enter launches the first result; Down moves into the grid; Up from the top row comes back; Esc clears, then closes
- [x] "No matches" message; the search clears when the popup closes

**Done when:** opening it, typing "fire" and pressing Enter launches Firefox.

### Phase 4: Utility bar
- [x] `utility/UserAvatar.qml`: circle avatar with name tooltip; opens Users settings
- [x] `utility/UtilityButton.qml`: icon-only button with tooltip
- [x] `utility/UtilityBar.qml`: avatar left; Settings, Lock, Log out, Sleep, Restart, Shut down right (later changed to System Settings and a Power menu holding the session actions)
- [x] Setting: which buttons appear

**Done when:** each button works. Log out, Restart and Shut down show a confirmation screen first, so they can be tested safely.

### Phase 5: Keyboard and daily use
- [x] The rest of Kickoff's keyboard handling: Home/End, PgUp/PgDn, Left/Right stopping at row edges, right-to-left layouts (arrows, Enter and scrolling to the selection came in phase 3)
- [x] Hover only moves the highlight when the mouse really moves, so typing or scrolling under a still mouse can't steal it (done in phase 3)
- [x] Tab moves search → grid → utility bar (avatar, then each button) and back to search; Enter presses utility buttons too; the grid highlight dims while keys act elsewhere
- [x] Replace Kickoff via right-click → Show Alternatives (done early)

**Done when:** it's the real launcher, the Meta key opens it, and anything can be launched without the mouse.

### Phase 6: Right-click menu
- [x] `grid/ActionMenu.qml`: the app's own actions (e.g. "New Private Window"), Add to Desktop, Pin to Task Manager (or Add to Panel when there's no task manager), recent files, Edit Application, Uninstall or Manage Add-Ons
- [x] Opens with right-click (on press), press-and-hold, the Menu key or Shift+F10; works on search results too
- [x] Added later: right-clicking free space in the popup (not a tile, the search bar or a button) opens a menu with just **Configure Launcher**
- [x] Added later: right-clicking the panel icon, or the Menu key or Shift+F10 on it, opens a menu with just **Configure Launcher** and **Show Alternatives…**. Plasma's own menu there also lists the panel's items (Add Widgets, Enter Edit Mode, …), and an applet can't take them out, so Protea has its own panel button (`CompactRepresentation.qml`, adapted from Plasma's default) that takes the right-click itself. Show Alternatives is Plasma's own action, shown only when another launcher is installed; an auto-hiding panel stays shown while the menu is open, as with Plasma's menu

**Done when:** right-clicking any tile shows that app's actions and they work.

### Phase 7: Settings page and packaging
- [x] `ConfigGeneral.qml`: panel icon picker, columns, rows, icon size, tile size, utility bar buttons and power menu items; later also optional dark backgrounds behind the search bar and utility bar (since combined into one setting), round search bar corners, and named sizes (Compact, Small, Cozy, Medium, Large) with a Use smaller tiles option in place of the number boxes
- [x] Custom protea panel icon in `icons/protea.svg` (monochrome, follows the panel's text colour; also the icon in Add Widgets)
- [x] `scripts/build.sh`: creates `protea-launcher-<version>.plasmoid`
- [x] Install, usage and settings instructions in `README.md`

**Done when:** every setting can be changed from the dialog, and the `.plasmoid` installs on a clean user account.

### Added later: Hidden apps
- [x] `hiddenApps` setting: desktop file IDs left out of the grid. Protea keeps its own list rather than Kicker's built-in `hiddenApplications`, so hiding filters the grid in place (`grid/VisibleAppsModel.qml`, a `KSortFilterProxyModel`) instead of reloading Kicker's list, and the scroll position and highlight stay put
- [x] **Hide** at the end of each app's menu, and **Unhide** for hidden apps, which still show up in search results; System Settings pages and app actions in search results (such as Firefox's New Private Window) get neither
- [x] **Hidden Apps** settings page (`ConfigHiddenApps.qml`): hidden apps A–Z with Unhide buttons, and apps uninstalled while hidden marked "Not installed"

## Plasma 6.8 update

Protea was built on Plasma 6.7.5 (Fedora 44) and now runs on 6.8.0 (Arch, Qt 6.12, Frameworks 6.31). Comparing plasma-workspace, plasma-desktop and libplasma between v6.7.5 and v6.8.0 turned up one break and some tooling changes:

- **App IDs changed.** In the A–Z list, Kicker's `favoriteId` for an app used to be the bare desktop file ID (`org.kde.ark.desktop`). In 6.8 it's `applications:org.kde.ark.desktop`, the form search results already used (plasma-workspace commit c99f33d4, "applets/kicker: use better AppEntry id"). Protea saves bare IDs and compares them with `favoriteId`, so hidden apps are back in the grid, **Hide** saves the ID but the tile stays, and the Hidden Apps page marks every app "Not installed".
- **Unchanged:** every Kicker model, property and method Protea uses; the `krunner_services` and `krunner_systemsettings` runners; the session action IDs; popup sizing; the panel button's `plasmoidItem`; `PlasmaExtras.Menu`, `Highlight` and `SearchField`; the PC3 scrollbar. The Kickoff changes in 6.8 that touch code Protea adapted (highlight in the delegate, no item reuse, no preferred size, centring) had already shipped in 6.7.x. 6.8 drops X11, which Protea never used.
- **Tooling:** `plasmoidviewer` isn't installed on Arch yet. Plasma 6.8 dropped its `// qmllint disable unqualified` comments in favour of a `.contextProperties.ini` at the repo root, which qmllint reads since Qt 6.11.

### Phase 8: Tooling
- [x] `sudo pacman -S plasma-sdk`, for `plasmoidviewer`
- [x] `.contextProperties.ini` at the repo root naming Plasma's i18n functions (`i18n`, `i18nc`, `i18np`, `i18ncp`, `i18nd`, `i18ndc`, `xi18nc`), so qmllint knows them. qmllint finds it from any working directory
- [x] Remove the 12 `// qmllint disable unqualified` comments, including the file-wide ones in `ConfigGeneral.qml` and `ConfigHiddenApps.qml` and the "i18nc() is provided by Plasma at runtime." note above each. The two `missing-property` comments on `Qt.styleHints` in `AppGrid.qml` stay: qmllint 6.12 still flags those lines without them
- [x] `scripts/lint.sh`: runs qmllint (`/usr/lib/qt6/bin/qmllint` on Arch, which keeps it out of `PATH`) over every QML file in `package/`. The 15 warnings left are all `missing-property` on values qmllint can't type: the widget's settings (`Plasmoid.configuration.…`), the configure action (a plain `QObject`), and Kicker's `trigger()` on a proxy's source model

**Done when:** `./scripts/preview.sh` opens the popup, and `./scripts/lint.sh` reports no `unqualified` warnings.

### Phase 9: Hidden apps with 6.8's app IDs
- [x] `ui/code/appid.js` (`.pragma library`, like Kickoff's `code/tools.js`, imported `as AppId`): `fromFavoriteId(favoriteId)` gives the bare desktop file ID for both forms (`org.kde.ark.desktop`, `applications:org.kde.ark.desktop`), and an empty string for everything else: System Settings pages, session actions, commands (`exec://…`) and app actions in search results (`applications:firefox.desktop?action=new-private-window`)
- [x] `grid/VisibleAppsModel.qml`: the filter compares `AppId.fromFavoriteId(favoriteId)` with the hidden list, so hidden apps leave the grid again
- [x] `ConfigHiddenApps.qml`: looks installed apps up by `AppId.fromFavoriteId(favoriteId)`, so hidden apps show their names and icons again
- [x] `grid/AppGrid.qml`: uses `AppId.fromFavoriteId()` in place of its own `appId()`
- [x] App actions in search results (such as Firefox's New Private Window) get neither Hide nor Unhide, like System Settings pages: hiding one would hide the whole app, which the tile doesn't say. Until now they offered Hide and saved an ID like `firefox.desktop?action=…` that never matches a tile
- [x] Saved settings keep bare desktop IDs, so existing `hiddenApps` lists keep working without conversion, and the launcher still works on 6.7
- [x] This file: `code/appid.js` in the folder structure (with Phase 8's `lint.sh` and `.contextProperties.ini`), the 6.8 ID change under Backend, and app actions under Hidden apps
- [x] Checked offscreen against the installed Kicker module (a `qml` test file, not kept): `fromFavoriteId()` gives the right result for all 8 forms above; with `qvidcap.desktop` and `org.kde.ark.desktop` hidden, the grid model shows 40 of 42 apps and neither of those; the Hidden Apps page names both, with their icons, and marks only an uninstalled ID "Not installed"

**Done when:** an app hidden before the update (e.g. `qvidcap.desktop`) is gone from the grid again; Hide and Unhide work from the grid and from search results; the Hidden Apps page lists hidden apps by name, and only uninstalled ones as "Not installed".

### Phase 10: Check everything on 6.8
Things only a running session shows. Most were checked offscreen: the real popup (`FullRepresentation.qml` and everything under it) loaded with the installed Plasma 6.8 modules, a stand-in `Plasmoid` object holding `main.xml`'s defaults, and KDE's platform theme so fonts match the desktop (Noto Sans 10pt), driven by Qt's test runner (in a small build with `QApplication`, as Plasma's menus are `QMenu`s). None of it is kept in the repo. Then the build was installed with `./scripts/install.sh` and opened in the real panel. What's left needs clicking in the real panel.
- [x] Popup size: 744 × 710 at the defaults, 4 less for each dark band (bands reach the popup's edges), and the minimum and maximum sizes are both the content size, so it can't be dragged to another size. All 10 size combinations match DIMENSIONS.md, as do 3 × 3 (396 × 478) and 12 × 4 (1440 × 594). In the real panel, your settings (6 × 4, Cozy, smaller tiles) give 696 wide as designed, and 1 px taller than the content; see the DIMENSIONS.md item below
- [x] The scrollbar's separator line stays hidden with Breeze: with Protea's code taken out, Breeze draws it at the slot's inner edge (x 726 of the content); with it, that column matches the background. The handle sits at 732–738 as documented. Protea Dark has no separator to hide
- [x] Keyboard (7 tests, all passing): the grid has focus on open; Left/Right stop at the row's ends; Down stops at the last row; Home/End go to the row's start and end, with Ctrl to the first and last app; PgDn/PgUp move 5 rows; Up from the top row goes to search and Down comes back; typing goes into search ("kat" finds Kate) and Down moves into the results; Esc clears the search and returns to the grid, then closes; "No matches" shows for nonsense; Tab goes search → grid → avatar → System Settings → Power → search, Shift+Tab goes back, and the grid highlight dims while a button has focus; reopening clears the search and starts at the first app, scrolled to the top
- [x] Enter and clicking launch the app and close the popup (checked by hand in the real panel; not automated, as it launches real apps). Phase 2's "Clicking launches…" and phase 3's "Enter launches…" are ticked now too
- [x] Right-click menus: tiles (app actions, Add to Desktop, Pin to Task Manager), free space (Configure Launcher), the panel icon (Configure Launcher, Show Alternatives…), checked by hand. Not tried: an auto-hiding panel staying shown while the panel icon's menu is open, as this panel doesn't auto-hide
- [x] The launcher shortcut opens and closes the popup in the real panel ("Activate Application Launcher", invoked over D-Bus; it's what the Meta key triggers)
- [x] Utility bar: the avatar opens Users, the gear opens System Settings, and the power menu lists the supported actions (Log Out, Restart and Shut Down show Plasma's confirmation first), checked by hand
- [x] Settings dialog: every setting applies, the icon picker works, and the Hidden Apps page Unhides, checked by hand
- [x] `journalctl --user -f -t plasmashell` shows no warnings from Protea's files while doing all of the above: nothing from Protea from the install through the hand checks
- [x] DIMENSIONS.md: every size matches on 6.8. One thing it didn't say, unchanged since 6.7: in a panel that isn't floating, Plasma makes the popup 1 px taller (wider beside a side panel) for the separator line it draws between the popup and the panel, and that pixel ends up in Protea's app grid section (597 tall instead of 596). Protea Dark hides that line. Added under "Not included" and "Size of the popup"

**Done when:** every item works, and anything that didn't is fixed or added here as its own item.

### Phase 11: Docs and release
- [x] This file: Target is Plasma 6.8 (built on 6.7.5, Fedora 44; updated on 6.8.0, Arch); the Kickoff reference points at v6.8.0 (the three files it names are still there, and none of what it describes changed); Dev setup uses `pacman` and the lint script
- [x] README: Requirements say Plasma 6.8 (6.7 should also work); Development gives `plasma-sdk` for Arch and Fedora and lists `./scripts/lint.sh`
- [x] `metadata.json`: Version 0.1.0 → 0.1.1
- [x] `./scripts/build.sh` builds `protea-launcher-0.1.1.plasmoid`
- [x] The `.plasmoid` installs with `kpackagetool6` into an empty folder (`--packageroot`) and upgrades the copy in the panel; both match `package/` file for file. The panel already runs this code (installed in Phase 10); plasmashell shows 0.1.1 from its next restart

**Done when:** the 0.1.1 `.plasmoid` installs with `kpackagetool6` and runs on 6.8, and the docs describe 6.8 and Arch.

## Added later: Search bar, header and footer, settings layout
- [x] The round search bar is filled with the text colour at 10%, as Protea Dark fills its own fields (it was the view background, darker than the popup), with no outline at rest, the hover colour (the accent) at 50% as its outline on hover, and the focus colour while it has focus
- [x] One setting for both dark bands: `headerFooterDarkBackground` ("Header and footer: Dark background", just under the panel icon in the settings) replaces `searchBarDarkBackground` and `utilityBarDarkBackground`. A popup that had only one band turns it off after updating, until the new box is ticked. Checked offscreen: off is 744 × 710, on is 744 × 702 with both bands, as before with both on
- [x] Settings rearranged over three pages. General: the panel icon, an Appearance section (Header and footer, Search bar corners) and the App Grid section, with columns × rows on one row ("Grid: [6] columns × [5] rows"). Utility Bar (`ConfigUtilityBar.qml`, new): the System Settings and Power menu buttons, then each session action once in a table with a Button column and an In power menu column, greyed out while the power menu button is off. Hidden Apps unchanged. No setting changed, so saved settings carry over. Checked offscreen: both pages load, and ticking boxes in either column saves the right list

## Later (out of scope)

- **Drag to rearrange apps in the grid.** The A–Z list can't be reordered, so this needs its own saved order: either a list of app IDs in the config, or `KAStatsFavoritesModel`, which already supports moving items (Kickoff's favorites grid uses it). To keep this possible, from phase 2 on `AppGrid.qml` gets its list of apps from one swappable `model` property and identifies tiles by app ID.
- **Dragging apps out to the desktop or panel.** This shares drag code with rearranging, so the two get built together.

## Dev setup

- `sudo pacman -S plasma-sdk` (`sudo dnf install plasma-sdk` on Fedora) provides `plasmoidviewer`, for testing the popup in its own window with QML errors shown in the terminal.
- Lint: `./scripts/lint.sh` runs qmllint over every QML file in `package/`. Plasma's i18n functions are declared for it in `.contextProperties.ini`; the warnings it still prints are listed under Phase 8.
- Install: `kpackagetool6 -t Plasma/Applet -i package/`. Update: `kpackagetool6 -t Plasma/Applet -u package/`, then restart plasmashell (`systemctl --user restart plasma-plasmashell`).
- Logs from the panel: `journalctl --user -f -t plasmashell`.
- Kickoff currently sits at the left end of the bottom panel. Protea takes whichever spot Kickoff is in when swapped through Show Alternatives, and can be moved in panel edit mode.

## License

Kickoff is GPL-2.0-or-later. Protea adapts its code, so it uses the same license, and adapted files keep the original license headers.
