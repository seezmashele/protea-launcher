/*
    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.private.kicker as Kicker
import org.kde.kirigami as Kirigami

// User avatar on the left; System Settings and the power menu on the right.
RowLayout {
    id: root

    // Whether the avatar is shown. The buttons stay on the right without it.
    property bool showAvatar: true
    // Buttons on the bar: "settings", "power" (opens the power menu), and any
    // SystemModel action ids, such as "lock-screen", to give them buttons of their own.
    property list<string> buttons
    // Session actions in the power menu: SystemModel action ids such as "shutdown".
    property list<string> powerMenuActions

    // Emitted after any button or menu item is used, so the popup can close.
    signal triggered()

    // Gap between the buttons. (The filler between the avatar and the buttons takes up the rest.)
    spacing: Kirigami.Units.largeSpacing

    UserAvatar {
        visible: root.showAvatar
        Layout.preferredWidth: Kirigami.Units.iconSizes.medium
        Layout.preferredHeight: Kirigami.Units.iconSizes.medium
        onClicked: root.triggered()
    }

    Item {
        Layout.fillWidth: true
    }

    // The buttons use "-symbolic" (monochrome) icon names, which keep one style at any
    // size: some icon themes, Papirus for one, switch to full-colour icons from 32px.
    // The gear is "applications-system-symbolic", the one that's a gear in both Breeze
    // and Papirus ("configure-symbolic" is sliders in Breeze).
    UtilityButton {
        visible: root.buttons.includes("settings") && settingsApp.count > 0
        text: i18nc("@action:button", "System Settings")
        icon.name: "applications-system-symbolic"
        onClicked: {
            settingsApp.trigger(0, "", null)
            root.triggered()
        }
    }

    // Session actions with buttons of their own, if any are listed in `buttons`.
    Repeater {
        model: systemModel

        delegate: UtilityButton {
            required property int index
            required property var model

            visible: root.buttons.includes(model.favoriteId)
            text: model.display
            icon.name: model.decoration + "-symbolic"
            onClicked: {
                systemModel.trigger(index, "", null)
                root.triggered()
            }
        }
    }

    UtilityButton {
        id: powerButton

        function openPowerMenu() {
            if (powerMenu.status !== PlasmaExtras.Menu.Open) {
                powerMenu.openRelative()
            }
        }

        visible: root.buttons.includes("power")
        text: i18nc("@action:button opens a menu", "Power")
        icon.name: "system-shutdown-symbolic"
        Accessible.role: Accessible.ButtonMenu

        // Looks pressed while the menu is open.
        down: powerMenu.status === PlasmaExtras.Menu.Open || pressed

        // Opens on press, like other menu buttons; clicked() covers Enter and Return.
        onPressed: openPowerMenu()
        onClicked: openPowerMenu()
    }

    // Lock, log out, sleep, restart, shut down, … in Plasma's usual order.
    // Only actions the system supports are listed.
    Kicker.SystemModel {
        id: systemModel
    }

    PlasmaExtras.Menu {
        id: powerMenu

        visualParent: powerButton
        // Opens away from the panel, where there's room, as Kickoff's menu does.
        placement: {
            switch (Plasmoid.location) {
            case PlasmaCore.Types.LeftEdge:
            case PlasmaCore.Types.RightEdge:
            case PlasmaCore.Types.TopEdge:
                return PlasmaExtras.Menu.BottomPosedRightAlignedPopup
            case PlasmaCore.Types.BottomEdge:
            default:
                return PlasmaExtras.Menu.TopPosedRightAlignedPopup
            }
        }
    }

    Instantiator {
        model: systemModel

        delegate: PlasmaExtras.MenuItem {
            required property int index
            required property var model

            visible: root.powerMenuActions.includes(model.favoriteId)
            text: model.display
            icon: model.decoration
            onClicked: {
                systemModel.trigger(index, "", null)
                root.triggered()
            }
        }

        onObjectAdded: (index, object) => powerMenu.addMenuItem(object)
        onObjectRemoved: (index, object) => powerMenu.removeMenuItem(object)
    }

    // Launches System Settings the same way the grid launches apps.
    Kicker.SimpleFavoritesModel {
        id: settingsApp
        favorites: ["systemsettings.desktop"]
    }
}
