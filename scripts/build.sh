#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Build protea-launcher-<version>.plasmoid from package/: a zip with metadata.json at
# its root, as "Install Widget From Local File…" and kpackagetool6 expect.
set -euo pipefail
cd "$(dirname "$0")/.."

version=$(sed -n 's/.*"Version": *"\([^"]*\)".*/\1/p' package/metadata.json)
out="protea-launcher-$version.plasmoid"

rm -f "$out"
(cd package && zip -qr -X "../$out" . -x '*~' '.*')
echo "Built $out"
