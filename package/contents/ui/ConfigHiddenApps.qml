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

import "code/appid.js" as AppId

// The Hidden Apps settings page: the apps left out of the grid, each with an Unhide button.
KCM.ScrollViewKCM {
    id: root

    // Plasma fills this from the widget's settings and saves it on Apply.
    property var cfg_hiddenApps: []
    property var cfg_hiddenAppsDefault: []

    // Plasma hands every setting to every page; this page doesn't use the others.
    property var cfg_icon
    property var cfg_iconDefault
    property var cfg_columns
    property var cfg_columnsDefault
    property var cfg_rows
    property var cfg_rowsDefault
    property var cfg_gridSize
    property var cfg_gridSizeDefault
    property var cfg_spaciousLayout
    property var cfg_spaciousLayoutDefault
    property var cfg_showUtilityBar
    property var cfg_showUtilityBarDefault
    property var cfg_showAvatar
    property var cfg_showAvatarDefault
    property var cfg_utilityButtons
    property var cfg_utilityButtonsDefault
    property var cfg_powerMenuActions
    property var cfg_powerMenuActionsDefault
    property var cfg_headerFooterDarkBackground
    property var cfg_headerFooterDarkBackgroundDefault
    property var cfg_searchBarRoundCorners
    property var cfg_searchBarRoundCornersDefault

    // Name and icon of every installed app by ID, once Kicker's app list has loaded.
    property var installedApps: null

    // The hidden apps A–Z. An app uninstalled while hidden shows its ID and a generic icon.
    readonly property var entries: !installedApps ? [] : Array.from(cfg_hiddenApps ?? [])
        .map(id => {
            const app = installedApps[id]
            return {
                id: id,
                name: app?.name ?? id,
                icon: app?.icon ?? "application-x-executable",
                installed: app !== undefined,
            }
        })
        .sort((a, b) => a.name.localeCompare(b.name))

    function unhide(id: string) {
        cfg_hiddenApps = Array.from(cfg_hiddenApps).filter(hidden => hidden !== id)
    }

    function updateInstalledApps() {
        const apps = {}
        for (let i = 0; i < appList.count; i++) {
            const app = appList.objectAt(i)?.model
            const id = AppId.fromFavoriteId(app?.favoriteId)
            if (id !== "") {
                apps[id] = { name: app.display, icon: app.decoration }
            }
        }
        installedApps = apps
    }

    // The same A–Z list as the grid's, with nothing left out.
    Kicker.RootModel {
        appNameFormat: 0 // name only, as in the grid
        showAllApps: true
        showAllAppsCategorized: false
        showRecentApps: false
        showRecentDocs: false
        showPowerSession: false
        showFavoritesPlaceholder: false
        showRootSeparator: false

        onRefreshed: appList.model = modelForRow(0)
    }

    // Gives access to each app's ID, name and icon. They're read once the list has settled:
    // while Kicker loads it, a row can briefly have no data.
    Instantiator {
        id: appList

        delegate: QtObject {
            required property var model
        }

        onObjectAdded: Qt.callLater(root.updateInstalledApps)
        onObjectRemoved: Qt.callLater(root.updateInstalledApps)
    }

    header: QQC2.Label {
        text: i18nc("@info", "Hidden apps are left out of the app grid. They still show up when you search.")
        wrapMode: Text.Wrap
        bottomPadding: Kirigami.Units.largeSpacing
    }

    view: ListView {
        id: list

        model: root.entries

        delegate: QQC2.Control {
            id: entry

            required property var modelData

            width: ListView.view.width
            padding: Kirigami.Units.largeSpacing

            contentItem: RowLayout {
                spacing: Kirigami.Units.largeSpacing

                Kirigami.Icon {
                    implicitWidth: Kirigami.Units.iconSizes.medium
                    implicitHeight: Kirigami.Units.iconSizes.medium
                    source: entry.modelData.icon
                    animated: false
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    QQC2.Label {
                        Layout.fillWidth: true
                        text: entry.modelData.name
                        elide: Text.ElideRight
                    }
                    QQC2.Label {
                        Layout.fillWidth: true
                        visible: !entry.modelData.installed
                        text: i18nc("@info:status", "Not installed")
                        font: Kirigami.Theme.smallFont
                        color: Kirigami.Theme.disabledTextColor
                        elide: Text.ElideRight
                    }
                }

                QQC2.Button {
                    text: i18nc("@action:button", "Unhide")
                    icon.name: "view-visible"
                    Accessible.name: i18nc("@action:button", "Unhide %1", entry.modelData.name)
                    onClicked: root.unhide(entry.modelData.id)
                }
            }
        }

        Kirigami.PlaceholderMessage {
            anchors.centerIn: parent
            width: parent.width - Kirigami.Units.gridUnit * 4
            visible: root.installedApps !== null && list.count === 0
            icon.name: "hint"
            text: i18nc("@info:placeholder", "No hidden apps")
            explanation: i18nc("@info:usagetip", "To hide an app, right-click it in the launcher and choose Hide.")
        }
    }
}
