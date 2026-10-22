/*
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import org.kde.plasma.plasmoid
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.private.kicker as Kicker
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg

import "search"
import "grid"
import "utility"

T.Control {
    id: root

    property Kicker.AppsModel appsModel
    property Kicker.RunnerModel searchModel
    property bool expanded
    // Opens the launcher's settings; the only item in the menu on the popup's free space.
    property QtObject configureAction

    readonly property bool searching: searchBar.text.length > 0

    // Whether there's a search and it has found nothing (so far).
    readonly property bool noMatches: searching && !searchModel.resultsPresent
    // Whether "No matches" shows. It appears once a search has finished without results and
    // stayed that way for a moment, so it doesn't flash up between keystrokes. Then it stays
    // while each further keystroke's search runs, and goes as soon as there are matches.
    property bool noMatchesShown: false

    // Whether the grid shows search results rather than all apps. From the first keystroke
    // it keeps showing all apps until that search has results, or "No matches" is ready, so
    // the grid never goes blank while the first results load. It stays on the results until
    // the search is cleared.
    property bool showResults: false
    readonly property bool searchHasResults: searching && searchModel.resultsPresent

    onSearchHasResultsChanged: {
        if (searchHasResults) {
            showResults = true
        }
    }
    onNoMatchesShownChanged: {
        if (noMatchesShown) {
            showResults = true
        }
    }
    onSearchingChanged: {
        if (!searching) {
            showResults = false
        }
    }
    // Back to the first item whenever the grid switches between all apps and results.
    onShowResultsChanged: appGrid.reset()

    signal appLaunched()
    signal closeRequested()

    // Exactly as big as the content: the grid's columns × rows of tiles with the padding
    // around them, and the bars. Plasma takes the popup's size limits from these, so with
    // the minimum and maximum the same, the popup can't be dragged to another size, and a
    // size Plasma saved earlier is brought back to this one.
    Layout.minimumWidth: implicitWidth
    Layout.maximumWidth: implicitWidth
    Layout.minimumHeight: implicitHeight
    Layout.maximumHeight: implicitHeight
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight

    implicitWidth: implicitContentWidth + leftPadding + rightPadding
    implicitHeight: implicitContentHeight + topPadding + bottomPadding

    // The same gap between the popup's edges and the sections, and between the sections:
    // the space around the header and footer.
    readonly property real sectionGap: Kirigami.Units.largeSpacing

    // Whether the header and footer (the search bar and utility bar) sit in dark bands.
    readonly property bool darkHeaderFooter: Plasmoid.configuration.headerFooterDarkBackground
    // Fill of those bands.
    readonly property color darkBandColor: Qt.rgba(0, 0, 0, 0.25)

    // Whether the utility bar is shown. Without it the grid's own space below the last row
    // and the bottom padding are all that's under the grid, matching the space above it.
    readonly property bool utilityBarShown: Plasmoid.configuration.showUtilityBar

    // Apps left out of the grid (they still show up in search), by desktop file ID.
    readonly property list<string> hiddenApps: Plasmoid.configuration.hiddenApps

    // Icon size and tile size for each app grid size (the gridSize setting).
    readonly property var gridSizes: ({
        compact: { iconSize: 36, tileSize: 100 },
        small: { iconSize: 42, tileSize: 106 },
        medium: { iconSize: 48, tileSize: 112 },
        large: { iconSize: 54, tileSize: 118 },
    })
    readonly property var gridSize: gridSizes[Plasmoid.configuration.gridSize] ?? gridSizes.medium

    padding: sectionGap
    // With a dark background a bar sits in a band that runs to the popup's edge, which is
    // popupFrame's margin beyond this item; take that off the padding on that side so the
    // band has the same space on both sides of the bar. With no utility bar there's no
    // band at the bottom, so the bottom padding stays as it is.
    topPadding: darkHeaderFooter ? sectionGap - popupFrame.topMargin : sectionGap
    bottomPadding: darkHeaderFooter && utilityBarShown ? sectionGap - popupFrame.bottomMargin : sectionGap

    onExpandedChanged: {
        if (expanded) {
            // The grid takes keyboard focus, so the search bar isn't highlighted until
            // the user starts typing (see Keys.onPressed below).
            appGrid.forceActiveFocus()
        } else {
            searchBar.clear()
            appGrid.reset()
        }
    }

    // Typing while the grid has focus goes into the search box, which then takes focus.
    Keys.onPressed: event => {
        const printable = event.text.trim() !== "" && event.text >= " "
        const withShortcutModifier = event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier)
        if (printable && !withShortcutModifier) {
            searchBar.text += event.text
            searchBar.forceActiveFocus()
            event.accepted = true
        }
    }

    // Esc clears the search (focus goes back to the grid), then closes the popup.
    Keys.onEscapePressed: {
        if (root.searching) {
            searchBar.clear()
            appGrid.forceActiveFocus()
        } else {
            root.closeRequested()
        }
    }

    // Plasma's popup frame, drawn around this item. Its margins are the space between
    // this item and the popup's visible edge.
    KSvg.FrameSvgItem {
        id: popupFrame

        // Rounded: the theme's margins can come out a hair under a whole pixel.
        readonly property real leftMargin: Math.round(margins.left - Math.max(inset.left, 0))
        readonly property real rightMargin: Math.round(margins.right - Math.max(inset.right, 0))
        readonly property real topMargin: Math.round(margins.top - Math.max(inset.top, 0))
        readonly property real bottomMargin: Math.round(margins.bottom - Math.max(inset.bottom, 0))

        imagePath: "dialogs/background"
        visible: false
    }

    // Optional dark background behind the search bar: a band from the popup's top, left
    // and right edges to the top of the grid, rounded to match the popup.
    Rectangle {
        id: searchBarBackground

        visible: root.darkHeaderFooter
        z: -1
        x: -popupFrame.leftMargin
        y: -popupFrame.topMargin
        width: root.width + popupFrame.leftMargin + popupFrame.rightMargin
        height: popupFrame.topMargin + root.topPadding + searchBar.y + searchBar.height + root.sectionGap
        topLeftRadius: Kirigami.Units.cornerRadius
        topRightRadius: Kirigami.Units.cornerRadius
        color: root.darkBandColor
    }

    // Optional dark background behind the utility bar: a band from the bottom of the
    // grid to the popup's left, right and bottom edges, rounded to match the popup.
    Rectangle {
        id: utilityBarBackground

        visible: root.darkHeaderFooter && root.utilityBarShown
        z: -1
        x: -popupFrame.leftMargin
        y: root.topPadding + utilityBar.y - root.sectionGap
        width: root.width + popupFrame.leftMargin + popupFrame.rightMargin
        height: root.height - y + popupFrame.bottomMargin
        bottomLeftRadius: Kirigami.Units.cornerRadius
        bottomRightRadius: Kirigami.Units.cornerRadius
        color: root.darkBandColor
    }

    // The control (tile, search bar, button, scrollbar…) under a point in the content, if any.
    function controlAt(position: point): Item {
        let item = contentItem
        while (item) {
            const child = item.childAt(position.x, position.y)
            if (!child || child instanceof T.Control) {
                return child
            }
            position = item.mapToItem(child, position)
            item = child
        }
        return null
    }

    // Right-clicking free space in the popup opens a menu with just Configure Launcher.
    // Controls don't take right-clicks, so they reach this area too: they're left to
    // themselves (tiles open their own menu).
    MouseArea {
        anchors.fill: parent
        z: -1
        acceptedButtons: Qt.RightButton

        onPressed: mouse => {
            if (!root.configureAction?.enabled || root.controlAt(mapToItem(root.contentItem, mouse.x, mouse.y))) {
                mouse.accepted = false
                return
            }
            // On press, like other KDE context menus.
            contextMenu.open(mouse.x, mouse.y)
        }
    }

    PlasmaExtras.Menu {
        id: contextMenu
        visualParent: root

        PlasmaExtras.MenuItem {
            text: i18nc("@action:inmenu", "Configure Launcher")
            icon: "configure"
            onClicked: {
                root.configureAction.trigger()
                root.closeRequested()
            }
        }
    }

    Binding {
        target: root.searchModel
        property: "query"
        value: searchBar.text
    }

    onNoMatchesChanged: {
        if (!noMatches) {
            noMatchesShown = false
        }
    }
    Timer {
        interval: Kirigami.Units.longDuration
        running: root.noMatches && !root.searchModel.querying && !root.noMatchesShown
        onTriggered: root.noMatchesShown = true
    }

    // What the grid shows when not searching.
    VisibleAppsModel {
        id: visibleApps
        sourceModel: root.appsModel
        hiddenApps: root.hiddenApps
    }

    contentItem: ColumnLayout {
        spacing: root.sectionGap

        SearchBar {
            id: searchBar
            Layout.fillWidth: true
            // In the dark band, reach into Plasma's frame at the sides as the band does, so
            // the bar is sectionGap from the band's edges on all four sides.
            Layout.leftMargin: root.darkHeaderFooter ? -popupFrame.leftMargin : 0
            Layout.rightMargin: root.darkHeaderFooter ? -popupFrame.rightMargin : 0

            roundCorners: Plasmoid.configuration.searchBarRoundCorners

            // While the first results load, the grid still shows all apps: leave it be, and
            // don't let Enter launch whichever app is highlighted there.
            onTextChanged: {
                if (root.showResults) {
                    appGrid.reset()
                }
            }
            onEnterPressed: {
                if (!root.searching || root.showResults) {
                    appGrid.launchCurrent()
                }
            }
            onDownPressed: appGrid.forceActiveFocus()
        }

        AppGrid {
            id: appGrid
            Layout.fillWidth: true
            Layout.fillHeight: true
            // The popup's full width: the grid has its own gap at each side, with the
            // scrollbar in the right one. The search bar and utility bar keep the padding.
            Layout.leftMargin: -root.leftPadding
            Layout.rightMargin: -root.rightPadding

            // The merged results model exists once the first search has run.
            model: root.showResults
                ? (root.searchModel.count > 0 ? root.searchModel.modelForRow(0) : null)
                : visibleApps
            placeholderText: i18nc("@info:status", "No matches")
            placeholderShown: root.noMatchesShown

            columns: Plasmoid.configuration.columns
            rows: Plasmoid.configuration.rows
            iconSize: root.gridSize.iconSize
            tileSize: root.gridSize.tileSize
            // Enter in the search box launches the selected tile too.
            highlightActive: activeFocus || searchBar.activeFocus
            hiddenApps: root.hiddenApps

            onLaunched: root.appLaunched()
            onUpFromTopRow: searchBar.forceActiveFocus()
            // Saved straight away; the grid follows the setting, so the tile goes or comes back.
            onHideRequested: appId => Plasmoid.configuration.hiddenApps = Array.from(root.hiddenApps).filter(id => id !== appId).concat([appId])
            onUnhideRequested: appId => Plasmoid.configuration.hiddenApps = Array.from(root.hiddenApps).filter(id => id !== appId)
        }

        // Hidden, the layout leaves out the bar and the section gap above it.
        UtilityBar {
            id: utilityBar
            visible: root.utilityBarShown
            Layout.fillWidth: true
            // As the search bar: sectionGap from the dark band's edges on all four sides.
            Layout.leftMargin: root.darkHeaderFooter ? -popupFrame.leftMargin : 0
            Layout.rightMargin: root.darkHeaderFooter ? -popupFrame.rightMargin : 0

            showAvatar: Plasmoid.configuration.showAvatar
            buttons: Plasmoid.configuration.utilityButtons
            powerMenuActions: Plasmoid.configuration.powerMenuActions

            onTriggered: root.closeRequested()
        }
    }
}
