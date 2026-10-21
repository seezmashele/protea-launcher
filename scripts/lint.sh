#!/usr/bin/env bash
# Check every QML file in package/ with qmllint, against the installed Qt and Plasma modules.
# Plasma's i18n functions are declared for it in .contextProperties.ini at the repo root.
set -euo pipefail
cd "$(dirname "$0")/.."

# Arch keeps qmllint out of PATH.
qmllint=$(command -v qmllint6 || command -v qmllint || echo /usr/lib/qt6/bin/qmllint)

mapfile -t files < <(find package -name '*.qml' | sort)
exec "$qmllint" "${files[@]}" "$@"
