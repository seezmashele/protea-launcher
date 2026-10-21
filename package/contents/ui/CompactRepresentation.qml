/*
    SPDX-FileCopyrightText: 2013 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later

    Adapted from Plasma's DefaultCompactRepresentation.qml.
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

// The panel button: Plasma's usual one, except that right-clicking it opens Protea's own
// menu with just Configure Launcher and Show Alternatives. Plasma's menu would also list
// the panel's items (Add Widgets, Enter Edit Mode, …), and an applet can't take them out.
Kirigami.Icon {
    id: root

    // Set by Plasma when it creates the button.
    property PlasmoidItem plasmoidItem

    readonly property QtObject configureAction: Plasmoid.internalAction("configure")

    // Opens the menu at position (in this item's coordinates), or beside the button when
    // there's none, e.g. when opened from the keyboard.
    function openContextMenu(position) {
        // Plasma works out whether Show Alternatives applies when this is emitted, as it is
        // before Plasma's own menu.
        Plasmoid.contextualActionsAboutToShow()
        if (!configureItem.visible && !alternativesItem.visible) {
            return
        }
        if (position) {
            contextMenu.open(position.x, position.y)
        } else {
            contextMenu.openRelative()
        }
    }

    Layout.minimumWidth: {
        switch (Plasmoid.formFactor) {
        case PlasmaCore.Types.Vertical:
            return 0
        case PlasmaCore.Types.Horizontal:
            return height
        default:
            return Kirigami.Units.gridUnit * 3
        }
    }

    Layout.minimumHeight: {
        switch (Plasmoid.formFactor) {
        case PlasmaCore.Types.Vertical:
            return width
        case PlasmaCore.Types.Horizontal:
            return 0
        default:
            return Kirigami.Units.gridUnit * 3
        }
    }

    source: Plasmoid.icon
    active: mouseArea.containsMouse

    activeFocusOnTab: true

    Keys.onPressed: event => {
        switch (event.key) {
        case Qt.Key_Space:
        case Qt.Key_Enter:
        case Qt.Key_Return:
        case Qt.Key_Select:
            Plasmoid.activated()
            event.accepted = true // BUG 481393: Prevent system tray from receiving the event
            break
        // Taken here, or the panel opens Plasma's menu for the Menu key.
        case Qt.Key_Menu:
            root.openContextMenu()
            event.accepted = true
            break
        case Qt.Key_F10:
            if (event.modifiers & Qt.ShiftModifier) {
                root.openContextMenu()
                event.accepted = true
            }
            break
        }
    }

    Accessible.name: Plasmoid.title
    Accessible.description: plasmoidItem.toolTipSubText ?? ""
    Accessible.role: Accessible.Button

    MouseArea {
        id: mouseArea

        property bool wasExpanded: false

        anchors.fill: parent
        hoverEnabled: true
        // Taking the right button keeps the press from reaching the panel, which would
        // open Plasma's menu.
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onPressed: mouse => {
            if (mouse.button === Qt.RightButton) {
                // On press, like Plasma's own menu.
                root.openContextMenu(Qt.point(mouse.x, mouse.y))
            } else {
                wasExpanded = root.plasmoidItem.expanded
            }
        }
        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
                root.plasmoidItem.expanded = !wasExpanded
            }
        }
    }

    PlasmaExtras.Menu {
        id: contextMenu

        visualParent: root
        // Where it opens from the keyboard: away from the panel's edge.
        placement: {
            switch (Plasmoid.location) {
            case PlasmaCore.Types.TopEdge:
                return PlasmaExtras.Menu.BottomPosedLeftAlignedPopup
            case PlasmaCore.Types.LeftEdge:
                return PlasmaExtras.Menu.RightPosedTopAlignedPopup
            case PlasmaCore.Types.RightEdge:
                return PlasmaExtras.Menu.LeftPosedTopAlignedPopup
            case PlasmaCore.Types.BottomEdge:
            default:
                return PlasmaExtras.Menu.TopPosedLeftAlignedPopup
            }
        }

        PlasmaExtras.MenuItem {
            id: configureItem
            text: i18nc("@action:inmenu", "Configure Launcher")
            icon: "configure"
            // Plasma leaves it out too when widgets are locked against changes.
            visible: root.configureAction?.enabled ?? false
            onClicked: root.configureAction.trigger()
        }

        // Plasma's own action, so the text and icon match Plasma's, and it shows only when
        // another launcher is installed and widgets aren't locked.
        PlasmaExtras.MenuItem {
            id: alternativesItem
            action: Plasmoid.internalAction("alternatives")
        }
    }

    // Keeps an auto-hiding panel shown while the menu is open, as Plasma does for its own.
    Binding {
        target: Plasmoid
        property: "status"
        value: PlasmaCore.Types.RequiresAttentionStatus
        when: contextMenu.status === PlasmaExtras.Menu.Open
    }
}
