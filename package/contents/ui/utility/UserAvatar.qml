/*
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import org.kde.kirigamiaddons.components as KirigamiComponents
import org.kde.coreaddons as KCoreAddons
import org.kde.kcmutils as KCM
import org.kde.config as KConfig

// Circular profile picture (or initials). Hovering shows the user's name;
// clicking opens the Users page in System Settings.
KirigamiComponents.AvatarButton {
    id: root

    visible: KConfig.KAuthorized.authorizeControlModule("kcm_users")

    name: user.fullName || user.loginName
    source: user.faceIconUrl
    // The picture URL briefly goes empty and back when it changes, so don't cache it.
    cache: false

    Accessible.description: i18nc("@info:tooltip", "Open user settings")

    onClicked: KCM.KCMLauncher.openSystemSettings("kcm_users")
    // Enter and Return press it too, not only Space, as Enter launches in the grid.
    Keys.onReturnPressed: clicked()
    Keys.onEnterPressed: clicked()

    KCoreAddons.KUser {
        id: user
    }
}
