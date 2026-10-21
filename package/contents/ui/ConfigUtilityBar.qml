/*
    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.private.kicker as Kicker

// The Utility Bar settings page: the buttons on the bar, and for each session action
// whether it gets a button of its own, a place in the power menu, or both.
KCM.SimpleKCM {
    id: root

    // Plasma fills these from the widget's settings and saves them on Apply.
    property var cfg_utilityButtons: []
    property var cfg_powerMenuActions: []
    property var cfg_utilityButtonsDefault
    property var cfg_powerMenuActionsDefault

    // Plasma hands every setting to every page; this page doesn't use the others.
    property var cfg_icon
    property var cfg_iconDefault
    property var cfg_headerFooterDarkBackground
    property var cfg_headerFooterDarkBackgroundDefault
    property var cfg_searchBarRoundCorners
    property var cfg_searchBarRoundCornersDefault
    property var cfg_columns
    property var cfg_columnsDefault
    property var cfg_rows
    property var cfg_rowsDefault
    property var cfg_gridSize
    property var cfg_gridSizeDefault
    property var cfg_largerTiles
    property var cfg_largerTilesDefault
    property var cfg_hiddenApps
    property var cfg_hiddenAppsDefault

    // Session actions this system supports, with Plasma's names for them.
    readonly property Kicker.SystemModel systemModel: Kicker.SystemModel {}

    // The power menu's column only matters while the bar has the power menu button.
    readonly property bool powerMenuShown: includes(cfg_utilityButtons, "power")

    function includes(list, id) {
        return Array.from(list ?? []).includes(id)
    }

    // A copy of list with id added or removed.
    function withItem(list, id, add) {
        const rest = Array.from(list ?? []).filter(item => item !== id)
        return add ? rest.concat([id]) : rest
    }

    component ListCheckBox: QQC2.CheckBox {
        required property string itemId
        required property string listName

        checked: root.includes(root[listName], itemId)
        onToggled: root[listName] = root.withItem(root[listName], itemId, checked)
    }

    Kirigami.FormLayout {
        ColumnLayout {
            Kirigami.FormData.label: i18nc("@label", "Buttons:")
            Kirigami.FormData.labelAlignment: Qt.AlignTop
            spacing: 0

            ListCheckBox {
                text: i18nc("@option:check", "System Settings")
                itemId: "settings"
                listName: "cfg_utilityButtons"
            }
            ListCheckBox {
                text: i18nc("@option:check", "Power menu")
                itemId: "power"
                listName: "cfg_utilityButtons"
            }
        }

        // A table, one row per action: its name, then a box for each place it can go.
        // Each cell names its own row and column: Kicker fills the list of actions after
        // the page is built, and the Repeaters' cells would otherwise land at the end.
        GridLayout {
            Kirigami.FormData.label: i18nc("@label", "Session actions:")
            Kirigami.FormData.labelAlignment: Qt.AlignTop
            columns: 3
            columnSpacing: Kirigami.Units.largeSpacing * 2
            rowSpacing: 0

            QQC2.Label {
                Layout.row: 0
                Layout.column: 1
                Layout.alignment: Qt.AlignHCenter
                text: i18nc("@title:column a session action's own button on the utility bar", "Button")
            }
            QQC2.Label {
                Layout.row: 0
                Layout.column: 2
                Layout.alignment: Qt.AlignHCenter
                enabled: root.powerMenuShown
                text: i18nc("@title:column", "In power menu")
            }

            Repeater {
                model: root.systemModel
                delegate: QQC2.Label {
                    required property int index
                    required property var model
                    Layout.row: index + 1
                    Layout.column: 0
                    text: model.display
                }
            }
            Repeater {
                model: root.systemModel
                delegate: ListCheckBox {
                    required property int index
                    required property var model
                    Layout.row: index + 1
                    Layout.column: 1
                    Layout.alignment: Qt.AlignHCenter
                    Accessible.name: i18nc("@option:check %1 is a session action, e.g. Shut Down", "%1 button", model.display)
                    itemId: model.favoriteId
                    listName: "cfg_utilityButtons"
                }
            }
            Repeater {
                model: root.systemModel
                delegate: ListCheckBox {
                    required property int index
                    required property var model
                    Layout.row: index + 1
                    Layout.column: 2
                    Layout.alignment: Qt.AlignHCenter
                    enabled: root.powerMenuShown
                    Accessible.name: i18nc("@option:check %1 is a session action, e.g. Shut Down", "%1 in the power menu", model.display)
                    itemId: model.favoriteId
                    listName: "cfg_powerMenuActions"
                }
            }
        }

        QQC2.Label {
            Layout.maximumWidth: Kirigami.Units.gridUnit * 16
            text: i18nc("@info", "An action with Button ticked gets a button of its own on the bar, next to the power menu.")
            font: Kirigami.Theme.smallFont
            wrapMode: Text.Wrap
        }
    }
}
