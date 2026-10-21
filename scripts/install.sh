#!/usr/bin/env bash
# Install Protea Launcher for the current user, or upgrade it if already installed.
# An upgrade restarts plasmashell, because it keeps the old QML loaded until then.
set -euo pipefail
cd "$(dirname "$0")/.."

id=$(sed -n 's/.*"Id": *"\([^"]*\)".*/\1/p' package/metadata.json)

if kpackagetool6 --type Plasma/Applet --list | grep -qx "$id"; then
    kpackagetool6 --type Plasma/Applet --upgrade package
    systemctl --user restart plasma-plasmashell
else
    kpackagetool6 --type Plasma/Applet --install package
fi
