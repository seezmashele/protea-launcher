#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Open Protea Launcher in plasmoidviewer as if it sat in a bottom panel.
# QML errors are printed to this terminal. Click the icon to open the popup.
set -euo pipefail
cd "$(dirname "$0")/.."

# Without this, Qt sends messages to the systemd journal whenever stderr isn't a terminal.
export QT_FORCE_STDERR_LOGGING=1

exec plasmoidviewer --applet package --location bottomedge --formfactor horizontal "$@"
