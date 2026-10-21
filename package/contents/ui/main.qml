/*
    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.private.kicker as Kicker

PlasmoidItem {
    id: protea

    // Flat A–Z list of every installed app. RootModel replaces it with a new
    // object whenever apps are installed or removed, so it's re-fetched on refreshed().
    property Kicker.AppsModel appsModel: null

    Kicker.RootModel {
        id: rootModel

        appletInterface: protea
        appNameFormat: 0 // name only: "Firefox", not "Firefox (Web Browser)"

        // Row 0 becomes the flat "All Applications" model; everything else is turned off.
        showAllApps: true
        showAllAppsCategorized: false
        showRecentApps: false
        showRecentDocs: false
        showPowerSession: false
        showFavoritesPlaceholder: false
        showRootSeparator: false

        onRefreshed: protea.appsModel = modelForRow(0)
    }

    // Search results. The popup sets the query from the search bar.
    Kicker.RunnerModel {
        id: runnerModel

        appletInterface: protea
        // Apps and System Settings pages only, merged into a single list.
        runners: ["krunner_services", "krunner_systemsettings"]
        mergeResults: true
    }

    // The chosen icon, or Protea's own.
    Plasmoid.icon: Plasmoid.configuration.icon || Qt.resolvedUrl("../icons/protea.svg").toString()

    // Always show the panel button, even on the desktop; the grid lives in the popup.
    preferredRepresentation: compactRepresentation
    // Plasma's usual button, but with Protea's own right-click menu.
    compactRepresentation: CompactRepresentation {}
    fullRepresentation: FullRepresentation {
        appsModel: protea.appsModel
        searchModel: runnerModel
        expanded: protea.expanded
        configureAction: Plasmoid.internalAction("configure")
        onAppLaunched: protea.expanded = false
        onCloseRequested: protea.expanded = false
    }

    // Lets the launcher's global shortcut (and the Meta key) open and close the popup.
    activationTogglesExpanded: true
}
