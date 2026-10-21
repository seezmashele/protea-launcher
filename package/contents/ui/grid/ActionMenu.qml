/*
    SPDX-FileCopyrightText: 2013 Aurélien Gâteau <agateau@kde.org>
    SPDX-FileCopyrightText: 2013-2015 Eike Hein <hein@kde.org>
    SPDX-FileCopyrightText: 2017 Ivan Cukic <ivan.cukic@kde.org>
    SPDX-FileCopyrightText: 2022 ivan tkachenko <me@ratijas.tk>

    SPDX-License-Identifier: GPL-2.0-or-later

    Adapted from Kickoff's ActionMenu.qml.
*/

pragma ComponentBehavior: Bound

import QtQuick
import org.kde.plasma.extras as PlasmaExtras

// Right-click menu for a grid item, built from Kicker's actionList role: the app's own
// actions (e.g. "New Private Window"), Add to Desktop, Pin to Task Manager or Add to Panel,
// recent files, Edit Application, and so on. AppGrid adds Hide or Unhide at the end.
Item {
    id: root

    // The model and row the menu acts on, and that row's actionList.
    property var model: null
    property int row: -1
    property var actions: []

    // Emitted after an action ran. closePopup is false for actions such as
    // "Add to Desktop", after which the launcher stays open.
    signal actionTriggered(bool closePopup)
    // Emitted instead for Protea's own actions (IDs starting "protea:"), which Kicker doesn't know.
    signal ownActionTriggered(string actionId, var argument)

    // Opens next to visualParent: at position (in its coordinates) if given, else below it.
    function open(visualParent: Item, position) {
        menu.visualParent = visualParent
        if (position) {
            menu.open(position.x, position.y)
        } else {
            menu.openRelative()
        }
    }

    visible: false

    // A QMenu underneath, so it looks like every other KDE menu.
    PlasmaExtras.Menu {
        id: menu
        placement: PlasmaExtras.Menu.BottomPosedLeftAlignedPopup
    }

    Instantiator {
        model: root.actions

        delegate: PlasmaExtras.MenuItem {
            required property var modelData

            text: modelData.text ?? ""
            icon: modelData.icon ?? null
            separator: modelData.type === "separator"
            section: modelData.type === "title"
            enabled: modelData.type !== "title" && (modelData.enabled ?? true)
            checkable: modelData.checkable ?? false
            checked: modelData.checked ?? false

            onClicked: {
                if (String(modelData.actionId).startsWith("protea:")) {
                    root.ownActionTriggered(modelData.actionId, modelData.actionArgument)
                } else {
                    root.actionTriggered(root.model.trigger(root.row, modelData.actionId, modelData.actionArgument))
                }
            }
        }

        onObjectAdded: (index, object) => menu.addMenuItem(object)
        onObjectRemoved: (index, object) => menu.removeMenuItem(object)
    }
}
