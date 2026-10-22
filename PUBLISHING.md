# Protea Launcher: Publishing

What's left before other people can download and use the launcher, in phases to do one at a time. Written 2026-10-22, at version 0.1.1 on Plasma 6.8.0. These phases are separate from the build phases in [PLAN.md](PLAN.md).

The launcher itself is ready: it works on Plasma 6.8, its keyboard handling, sizes and settings have been tested, and it looks right on Breeze Light, Breeze Dark and Protea Dark. What's left is one decision that can't be changed after release, some metadata, testing on setups other than the one it was built on, and the publishing itself.

## Phase 1: Identity

Decisions everything else uses. The ID is the one that can't change after release.

- [x] **Choose the permanent widget ID:** `org.proteadesktop.launcher` (was `dev.protea.launcher`), matching the Protea theme's `org.proteadesktop.*` IDs. Plasma keeps track of installs, updates and every panel's saved settings by this ID, so once it's released, changing it means everyone's panel loses the launcher and its settings. Like the theme's IDs, it implies owning `proteadesktop.org`.
- [x] The ID changed in:
  - `Id` in `package/metadata.json` (the scripts read it from there)
  - The uninstall command in `README.md`, and the mentions in `PLAN.md`
  - Your own panel: a panel saves each widget's settings under its applet number, and only the `plugin=` line names the ID. So the panel was moved over in place, with every setting and the hidden apps list kept: install the package under the new ID, stop plasmashell, change `plugin=dev.protea.launcher` to `plugin=org.proteadesktop.launcher` in `~/.config/plasma-org.kde.plasma.desktop-appletsrc`, start plasmashell, then remove the old package. The config from before is backed up in `~/.cache/protea-launcher/backups/20261022-125003/`
- [x] **Choose the public version number:** 1.0.0 (set in Phase 2)
- [x] **Choose where the source and bug reports will live:** the GitHub repo, for the metadata in Phase 2
  - Website: `https://github.com/seezmashele/protea-launcher`
  - Bug reports: `https://github.com/seezmashele/protea-launcher/issues`
  - **Note:** these links are temporary. Before publishing, the repo will move to a GitHub organization for all the Protea projects, so the Website and bug report links in `metadata.json` (and the README) need to point at the organization's repo instead

**Done when:** the ID is final and in use in your own panel, and the version and project page are decided.

## Phase 2: Metadata and licence headers

- [x] **State the minimum: Plasma 6.8.** Search needs at least 6.7 (it uses Kicker's `RunnerModel.resultsPresent`, which first shipped in Plasma 6.7.0; on 6.0–6.6 search would break), but 6.8 is the version the launcher is tested on, so 6.8 is the stated minimum. Plasma doesn't stop the install on an older 6.x (it only checks the major version), so the requirement has to be written down:
  - `"X-Plasma-API-Minimum-Version": "6.8"` in `package/metadata.json`
  - "KDE Plasma 6.8 or later" in the README's Requirements
- [x] **Complete `package/metadata.json`.** Added the fields Kickoff has and Protea didn't, pointing at the project's page from Phase 1: `Authors`, `Website` and `BugReportUrl`. The links use the current repo for now (see the note in Phase 1)
  - **Note:** the author's email, `seez@example.com`, is a placeholder (`example.com` is reserved and never delivers mail). Replace it with a real address, or remove the `Email` line, before publishing
- [x] `Version` in `package/metadata.json` set to 1.0.0
- [x] **Licence headers.** Every file has an SPDX licence line. These got one in this phase:
  - `scripts/build.sh`, `scripts/install.sh`, `scripts/lint.sh`, `scripts/preview.sh`
  - `package/contents/config/main.xml`

  The GPL-2.0 licence file and the Kickoff credits in the adapted files are already in place.

**Done when:** `metadata.json` has the final ID, version, minimum Plasma version, authors and links; every file has a licence line; `./scripts/lint.sh` shows no new warnings.

## Phase 3: Test on other setups

Only one setup has been tried so far: a bottom panel that isn't floating, 100% scaling, English, mouse and keyboard. Install the build from Phase 2 with `./scripts/install.sh` and try:

- [x] A top panel, a left and a right panel: the popup, the power menu and the panel icon's menu all open away from the edge
- [x] A floating panel
- [x] On the desktop rather than in a panel: shows as the icon; the popup and the icon's menu open. Plasma places the popup above the icon and keeps it on screen, so near the top of the screen it covers the icon
- [x] Display scaling above 100%: 150% looks right. 200% on a 1920 × 1080 screen leaves only 960 × 540, so the popup is squeezed and the grid scrolls, as it should
- [x] A right-to-left layout: the popup mirrors (grid from the right, avatar on the right, buttons and scrollbar on the left), and the arrow keys move the right way. Tried with Qt's `-reverse`, not a real Arabic or Hebrew setup, so the search field's magnifier stayed on the left: Plasma's search field moves it by the keyboard's writing direction, which `-reverse` doesn't change
- [ ] A touch screen (press and hold opens an app's menu): no touch device to try it on. Untested in 1.0.0
- [x] A fresh setup, installing from the `.plasmoid` that `./scripts/build.sh` makes: it installs into an empty folder matching `package/` file for file, and runs with the default settings on stock Breeze

How these were checked (2026-10-22): a nested Plasma 6.8 session on a virtual 1920 × 1080 screen (`kwin_wayland --virtual`, a copy of the binary without its `cap_sys_nice`, which gets it killed otherwise), with its own D-Bus and empty config, data and cache folders, so it starts as a new user would. Panels were set up with Plasma's desktop scripting, the popup opened with `activateLauncherMenu`, clicks and keys sent through KWin's fake-input protocol, and screenshots taken with `spectacle`. None of this is kept in the repo.

Still to try by hand, on the real desktop:

- [ ] Move your own panel to the top, left and right, and make it floating
- [ ] Turn display scaling up in System Settings and open the popup
- [ ] A new user account, installing the `.plasmoid` through **Install Widget From Local File…**: untested for now, to be done later. The test session's empty config covered most of it: a fresh install from the `.plasmoid`, with default settings on stock Breeze

Fixed in this phase:

- **Show Alternatives… was always greyed out** in the panel icon's menu, so Protea couldn't be swapped back for another launcher from there. The menu item was given Plasma's `alternatives` action as its `action`. `PlasmaExtras.MenuItem` copies the action's enabled state back onto it when it's created, while Plasma still has the action hidden, and a hidden `QAction` reports itself disabled. That `setEnabled(false)` stuck after Plasma showed the action. The item now reads the action's text and visibility and triggers it, like Configure Launcher. Checked: the item is enabled and opens Plasma's Alternative Widgets list

**Done when:** every setup above works, and anything that didn't is fixed or written down as a known issue.

## Phase 4: Screenshots and description

Taken after Phase 3, so they show the launcher as it will ship. Keep them outside `package/` (a `screenshots/` folder, say), so they aren't installed with the widget.

- [x] The popup with the default settings: `screenshots/popup.png`
- [x] The popup with a search under way: `screenshots/search.png` ("brows", finding Google Chrome and three System Settings pages)
- [x] The settings pages: `screenshots/settings-general.png`, `settings-utility-bar.png`, `settings-hidden-apps.png`
- [x] A screenshot near the top of the README: `popup.png`, with a line saying the screenshots show Protea Dark
- [x] The blank square in Plasma's Alternative Widgets list. It wasn't a missing preview picture: that list, and Add Widgets, show each widget's icon, and Protea's didn't load. `metadata.json` gave it as `/contents/icons/protea.svg`, but Plasma looks up an icon starting with `/` inside the package's `contents/` folder, so it found nothing. It's `/icons/protea.svg` now, and shows in both. The panel icon was never affected: Protea sets that itself
- [x] A short description for the store page: in [STORE.md](STORE.md), with the store's other fields and the order to upload the screenshots in

How the screenshots were taken (2026-10-22): in the same kind of nested Plasma 6.8 session as Phase 3, on a 1920 × 1080 screen at 100%, with the Protea Dark theme copied from the installed files (its Teal accent, Plasma Style, Breeze Dark icons, and the Protea app style and window decoration), Plasma's default wallpaper, and a bottom panel. The grid hides the same apps as your own panel. The avatar shows its letter rather than a picture: the test copy of the launcher was changed for that, not the one in `package/`. The popup shots are cropped to the popup and the panel's corner; the settings shots to the window with 32 px around it. `popup.png` and `search.png` were retaken the same day after the popup's padding went from 12 to 8, and `settings-general.png` after Spacious layout replaced Use larger tiles and Larger padding. All three were retaken again when Medium became the default size.

**Done when:** the screenshots and the store description are ready to upload.

## Phase 5: Publish

The `.plasmoid` that `./scripts/build.sh` makes is a zip with `metadata.json` at its root, the format Plasma and the KDE Store expect; it installs cleanly into an empty folder (checked in Phase 11 of PLAN.md).

- [ ] `./scripts/build.sh`, and a last check of the `.plasmoid` it makes: install it, open the popup, search, launch an app
- [ ] **KDE Store** ([store.kde.org](https://store.kde.org)), the main route: create an account, then add the launcher to the **Plasma 6 Extensions** category (the one Plasma's own "Get New Widgets" dialog reads) with the `.plasmoid`, the screenshots, the description and the licence
- [ ] **The project's page:** a release with the `.plasmoid` attached, for people who'd rather install by hand (**Install Widget From Local File…**, or `kpackagetool6`; the README explains both)
- [ ] Check it the way other people will find it: right-click the panel or desktop → **Add or Manage Widgets…** → **Get New** → **Download New Plasma Widgets**, search for "Protea", and install it from there

**Done when:** the launcher can be found and installed from Plasma's Get New Widgets dialog, and downloaded from the project's page.

## Phase 6: Later, optional

- [ ] An AUR package for Arch users, installed system-wide into `/usr/share/plasma/plasmoids/` (the Protea theme's PKGBUILD is a model for it)
- [ ] The launcher as an option in the Protea theme's installer
- [ ] Translations. Every piece of text goes through `i18nc`, so the launcher can be translated, but there are no translation files yet; English only is normal for a first release

## Each release after the first

- [ ] Bump `Version` in `package/metadata.json`
- [ ] `./scripts/lint.sh`: no new warnings
- [ ] `./scripts/build.sh`
- [ ] Install the new `.plasmoid` and try it: open, search, launch, the settings pages
- [ ] Upload it to the KDE Store (people get it as an update in Get New Widgets) and attach it to a release on the project's page

## Worth knowing

**Plasma updates can break it.** Protea uses `org.kde.plasma.private.kicker`, Kickoff's private data module, as every third-party launcher does. Plasma 6.8 changed its app IDs and broke hidden apps, so re-test after each Plasma feature release, and release a fix if something broke.
