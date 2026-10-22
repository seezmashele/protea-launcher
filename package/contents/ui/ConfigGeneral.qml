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

KCM.SimpleKCM {
    id: root

    // Plasma fills these from the widget's settings and saves them on Apply.
    property string cfg_icon
    property alias cfg_headerFooterDarkBackground: headerFooterDarkBackground.checked
    property bool cfg_searchBarRoundCorners
    property alias cfg_columns: columns.value
    property alias cfg_rows: rows.value
    property string cfg_gridSize
    property alias cfg_largerTiles: largerTiles.checked

    // Plasma also passes each setting's default; these give it somewhere to go.
    property string cfg_iconDefault
    property bool cfg_headerFooterDarkBackgroundDefault
    property bool cfg_searchBarRoundCornersDefault
    property int cfg_columnsDefault
    property int cfg_rowsDefault
    property string cfg_gridSizeDefault
    property bool cfg_largerTilesDefault

    // Set on the Utility Bar and Hidden Apps pages; Plasma hands every setting to every page.
    property var cfg_showAvatar
    property var cfg_showAvatarDefault
    property var cfg_utilityButtons
    property var cfg_utilityButtonsDefault
    property var cfg_powerMenuActions
    property var cfg_powerMenuActionsDefault
    property var cfg_hiddenApps
    property var cfg_hiddenAppsDefault

    readonly property string defaultIcon: Qt.resolvedUrl("../icons/protea.svg").toString()

    // App grid sizes in order; the values are the popup's gridSizes keys.
    readonly property var gridSizeOptions: [
        { text: i18nc("@item:inlistbox app grid size", "Compact"), value: "compact" },
        { text: i18nc("@item:inlistbox app grid size", "Small"), value: "small" },
        { text: i18nc("@item:inlistbox app grid size", "Cozy"), value: "cozy" },
        { text: i18nc("@item:inlistbox app grid size", "Medium"), value: "medium" },
        { text: i18nc("@item:inlistbox app grid size", "Large"), value: "large" },
    ]

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
            Kirigami.FormData.label: i18nc("@title:group", "Appearance")
        }

        // Dark bands behind the search bar at the top and the utility bar at the bottom.
        QQC2.CheckBox {
            id: headerFooterDarkBackground
            Kirigami.FormData.label: i18nc("@label", "Header and footer:")
            text: i18nc("@option:check", "Dark background")
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18nc("@label:listbox", "Search bar corners:")
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

        // The grid's columns, with its rows on the line below: "6 columns", "4 rows".
        RowLayout {
            Kirigami.FormData.label: i18nc("@label", "Grid:")
            spacing: Kirigami.Units.smallSpacing

            QQC2.SpinBox {
                id: columns
                from: 3
                to: 12
                Accessible.name: i18nc("@label:spinbox", "Columns")
            }
            QQC2.Label {
                text: i18nc("@label:spinbox after the columns box, as in '6 columns'", "columns")
            }
        }

        RowLayout {
            spacing: Kirigami.Units.smallSpacing

            QQC2.SpinBox {
                id: rows
                from: 3
                to: 12
                Accessible.name: i18nc("@label:spinbox", "Rows")
            }
            QQC2.Label {
                text: i18nc("@label:spinbox after the rows box, as in '4 rows'", "rows")
            }
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
            id: largerTiles
            text: i18nc("@option:check", "Use larger tiles")
        }
    }
}
