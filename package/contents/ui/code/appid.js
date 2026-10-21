/*
    SPDX-License-Identifier: GPL-2.0-or-later
*/

.pragma library

// An app's desktop file ID, e.g. "org.kde.dolphin.desktop", from Kicker's favoriteId role.
// That role gives "applications:org.kde.dolphin.desktop": in search results always, and in
// the A–Z list since Plasma 6.8 (before, the bare ID). Protea saves bare IDs, so saved
// settings work with either.
// Empty for anything that isn't a whole app: System Settings pages, session actions,
// commands ("exec://…") and app actions in search results
// ("applications:firefox.desktop?action=new-private-window").
function fromFavoriteId(favoriteId) {
    const id = String(favoriteId ?? "")
    const bareId = id.startsWith("applications:") ? id.slice("applications:".length) : id
    return bareId.endsWith(".desktop") ? bareId : ""
}
