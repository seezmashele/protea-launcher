/*
    SPDX-License-Identifier: GPL-2.0-or-later

    The icon button is adapted from Kickoff's ConfigGeneral.qml.
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.iconthemes as KIconThemes
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.private.kicker as Kicker

KCM.SimpleKCM {
    id: root

    // Plasma fills these from the widget's settings and saves them on Apply.
    property string cfg_icon
    property alias cfg_columns: columns.value
    property alias cfg_rows: rows.value
    property string cfg_gridSize
    property alias cfg_smallerTiles: smallerTiles.checked
    property var cfg_utilityButtons: []
    property var cfg_powerMenuActions: []
    property alias cfg_utilityBarDarkBackground: darkBackground.checked
    property bool cfg_searchBarRoundCorners
    property alias cfg_searchBarDarkBackground: searchBarDarkBackground.checked

    // Plasma also passes each setting's default; these give it somewhere to go.
    property string cfg_iconDefault
    property int cfg_columnsDefault
    property int cfg_rowsDefault
    property string cfg_gridSizeDefault
    property bool cfg_smallerTilesDefault
    property var cfg_utilityButtonsDefault
    property var cfg_powerMenuActionsDefault
    property bool cfg_utilityBarDarkBackgroundDefault
    property bool cfg_searchBarRoundCornersDefault
    property bool cfg_searchBarDarkBackgroundDefault

    // Set on the Hidden Apps page; Plasma hands every setting to every page.
    property var cfg_hiddenApps
    property var cfg_hiddenAppsDefault

    readonly property string defaultIcon: Qt.resolvedUrl("../icons/protea.svg").toString()

    // Session actions this system supports, with Plasma's names for them.
    readonly property Kicker.SystemModel systemModel: Kicker.SystemModel {}

    // App grid sizes in order; the values are the popup's gridSizes keys.
    readonly property var gridSizeOptions: [
        { text: i18nc("@item:inlistbox app grid size", "Compact"), value: "compact" },
        { text: i18nc("@item:inlistbox app grid size", "Small"), value: "small" },
        { text: i18nc("@item:inlistbox app grid size", "Cozy"), value: "cozy" },
        { text: i18nc("@item:inlistbox app grid size", "Medium"), value: "medium" },
        { text: i18nc("@item:inlistbox app grid size", "Large"), value: "large" },
    ]

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
        QQC2.Button {
            id: iconButton

            Kirigami.FormData.label: i18nc("@label", "Panel icon:")

            implicitWidth: Kirigami.Units.iconSizes.large + Kirigami.Units.largeSpacing * 2
            implicitHeight: implicitWidth

            Accessible.name: i18nc("@action:button", "Change the panel icon")
            // Described rather than given the ButtonMenu role, which makes the style draw
            // a menu arrow on top of the icon.
            Accessible.description: i18nc("@info:whatsthis", "Opens a menu to choose an icon or reset to Protea's icon")

            contentItem: Item {
                Kirigami.Icon {
                    anchors.centerIn: parent
                    width: Kirigami.Units.iconSizes.large
                    height: width
                    source: root.cfg_icon || root.defaultIcon
                }
            }

            onPressed: iconMenu.opened ? iconMenu.close() : iconMenu.open()

            KIconThemes.IconDialog {
                id: iconDialog
                onAccepted: root.cfg_icon = iconName
            }

            QQC2.Menu {
                id: iconMenu

                // Below the button
                y: parent.height

                QQC2.MenuItem {
                    text: i18nc("@item:inmenu Open icon chooser dialog", "Choose…")
                    icon.name: "document-open-folder"
                    onClicked: iconDialog.open()
                }
                QQC2.MenuItem {
                    text: i18nc("@item:inmenu", "Reset to Protea's Icon")
                    icon.name: "edit-clear"
                    enabled: root.cfg_icon !== ""
                    onClicked: root.cfg_icon = ""
                }
            }
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18nc("@title:group", "Search Bar")
        }

        QQC2.CheckBox {
            id: searchBarDarkBackground
            Kirigami.FormData.label: i18nc("@label", "Background:")
            text: i18nc("@option:check", "Dark")
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18nc("@label:listbox", "Corners:")
            model: [
                i18nc("@item:inlistbox search bar corners", "Default"),
                i18nc("@item:inlistbox search bar corners", "Round"),
            ]
            currentIndex: root.cfg_searchBarRoundCorners ? 1 : 0
            onActivated: root.cfg_searchBarRoundCorners = currentIndex === 1
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18nc("@title:group", "App Grid")
        }

        QQC2.SpinBox {
            id: columns
            Kirigami.FormData.label: i18nc("@label:spinbox", "Columns:")
            from: 3
            to: 12
        }

        QQC2.SpinBox {
            id: rows
            Kirigami.FormData.label: i18nc("@label:spinbox", "Rows:")
            from: 3
            to: 12
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18nc("@label:listbox", "Size:")
            model: root.gridSizeOptions
            textRole: "text"
            valueRole: "value"
            currentIndex: root.gridSizeOptions.findIndex(option => option.value === root.cfg_gridSize)
            onActivated: root.cfg_gridSize = currentValue
        }

        QQC2.CheckBox {
            id: smallerTiles
            text: i18nc("@option:check", "Use smaller tiles")
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18nc("@title:group", "Utility Bar")
        }

        QQC2.CheckBox {
            id: darkBackground
            Kirigami.FormData.label: i18nc("@label", "Background:")
            text: i18nc("@option:check", "Dark")
        }

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
            Repeater {
                model: root.systemModel
                delegate: ListCheckBox {
                    required property var model
                    text: model.display
                    itemId: model.favoriteId
                    listName: "cfg_utilityButtons"
                }
            }
            QQC2.Label {
                Layout.maximumWidth: Kirigami.Units.gridUnit * 16
                text: i18nc("@info", "A session action ticked here gets a button of its own, next to the power menu.")
                font: Kirigami.Theme.smallFont
                wrapMode: Text.Wrap
            }
        }

        ColumnLayout {
            Kirigami.FormData.label: i18nc("@label", "Power menu:")
            Kirigami.FormData.labelAlignment: Qt.AlignTop
            spacing: 0

            Repeater {
                model: root.systemModel
                delegate: ListCheckBox {
                    required property var model
                    text: model.display
                    itemId: model.favoriteId
                    listName: "cfg_powerMenuActions"
                }
            }
        }
    }
}
