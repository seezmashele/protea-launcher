/*
    SPDX-FileCopyrightText: 2015 Eike Hein <hein@kde.org>
    SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later

    Adapted from Kickoff's KickoffGridView.qml.
*/

pragma ComponentBehavior: Bound

import QtQuick
import org.kde.plasma.components as PC3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

import "../code/appid.js" as AppId

FocusScope {
    id: root

    // Any Kicker model, or one with the same roles and trigger() (VisibleAppsModel): tiles
    // read its display/decoration roles and launch with trigger().
    property alias model: view.model

    // Columns × rows set the grid's implicit size; a wider grid fits more columns.
    property int columns: 6
    property int rows: 5
    property int iconSize: Kirigami.Units.iconSizes.large
    // Width and height of each tile; 0 fits the tile to its icon and label.
    property int tileSize: 0

    // Space between the section's sides and the tiles, the same on both sides. The
    // scrollbar sits inside the right one, so it doesn't move the tiles.
    property real horizontalPadding: Kirigami.Units.largeSpacing * 3
    // Empty space above the first row and below the last. It scrolls with the tiles, so
    // they start and end this far from the section's edges but can scroll through it.
    property real scrollPadding: Kirigami.Units.largeSpacing

    // Message shown over the grid, e.g. "No matches", while placeholderShown is true.
    property string placeholderText
    property bool placeholderShown: false

    // Whether the highlight is drawn at full strength, i.e. keys act on the grid.
    property bool highlightActive: true

    // IDs of the hidden apps: their menus offer Unhide instead of Hide.
    property list<string> hiddenApps

    readonly property bool rightToLeft: view.effectiveLayoutDirection === Qt.RightToLeft

    // Square cells of tileSize, but never smaller than a tile with a two-line label.
    readonly property int cellSize: Math.max(tileSize, Math.ceil(sizer.implicitHeight))

    // Emitted after an app launched or a menu action ran that should close the popup.
    signal launched()
    signal upFromTopRow()
    // Hide or Unhide chosen in an app's menu.
    signal hideRequested(string appId)
    signal unhideRequested(string appId)

    // Back to the first item, scrolled to the top.
    function reset() {
        view.currentIndex = view.count > 0 ? 0 : -1
        view.positionViewAtBeginning()
        pointer.lastPosition = Qt.point(NaN, NaN)
    }

    function launch(row) {
        if (model && model.trigger(row, "", null)) {
            launched()
        }
    }

    function launchCurrent() {
        if (view.currentIndex >= 0) {
            launch(view.currentIndex)
        }
    }

    // Shows a tile's action menu at position (in the tile's coordinates), or below
    // the tile when no position is given, e.g. when opened from the keyboard.
    function openActionMenu(tile, position) {
        if (!tile) {
            return
        }
        const actions = (tile.model.hasActionList ?? false) ? Array.from(tile.model.actionList) : []
        // Only whole apps can be hidden: not System Settings pages or app actions.
        const id = AppId.fromFavoriteId(tile.model.favoriteId)
        if (id !== "") {
            if (actions.length > 0 && actions[actions.length - 1].type !== "separator") {
                actions.push({ type: "separator" })
            }
            actions.push(hiddenApps.includes(id)
                ? { text: i18nc("@action:inmenu", "Unhide"), icon: "view-visible", actionId: "protea:unhide", actionArgument: id }
                : { text: i18nc("@action:inmenu", "Hide"), icon: "hint", actionId: "protea:hide", actionArgument: id })
        }
        if (actions.length === 0) {
            return
        }
        view.currentIndex = tile.index
        actionMenu.model = view.model
        actionMenu.row = tile.index
        actionMenu.actions = actions
        actionMenu.open(tile, position)
    }

    implicitWidth: horizontalPadding + columns * cellSize + horizontalPadding
    implicitHeight: scrollPadding + rows * cellSize + scrollPadding

    // Never shown; only measured.
    AppTile {
        id: sizer
        visible: false
        enabled: false
        index: -1
        model: ({ display: "Sizer", decoration: "" })
        iconSize: root.iconSize
    }

    GridView {
        id: view

        // As many columns as fit with horizontalPadding at each side.
        readonly property int columnsShown: Math.max(1, Math.floor((root.width - 2 * root.horizontalPadding) / cellWidth))

        // The columns plus the gaps beside them, centred in the section. The gaps are the
        // view's margins, as in Kickoff, so the wheel and dragging scroll from them too.
        // At the designed size the view is the whole section.
        width: columnsShown * cellWidth + leftMargin + rightMargin
        height: root.height
        x: Math.round((root.width - width) / 2)
        leftMargin: root.horizontalPadding
        rightMargin: root.horizontalPadding
        flickableDirection: Flickable.VerticalFlick

        cellWidth: root.cellSize
        cellHeight: root.cellSize

        focus: true
        activeFocusOnTab: true
        clip: true
        pixelAligned: true
        boundsBehavior: Flickable.StopAtBounds
        highlightFollowsCurrentItem: false
        currentIndex: count > 0 ? 0 : -1

        // Search results arrive after the grid has been reset to an empty model.
        onCountChanged: {
            if (currentIndex < 0 && count > 0) {
                currentIndex = 0
            }
        }

        header: Item {
            width: view.columnsShown * view.cellWidth
            height: root.scrollPadding
        }
        footer: Item {
            width: view.columnsShown * view.cellWidth
            height: root.scrollPadding
        }

        delegate: AppTile {
            id: tile
            width: view.cellWidth
            height: view.cellHeight
            iconSize: root.iconSize
            highlightActive: root.highlightActive

            onClicked: root.launch(index)
            onMenuRequested: position => root.openActionMenu(tile, position)
        }

        // Keyboard navigation as in Kickoff, which follows the WAI-ARIA grid pattern.
        // GridView's own is off so moves stop at the grid's edges and the view can
        // scroll to the selection (it only does that itself when a highlight item follows it).
        keyNavigationEnabled: false

        Keys.onPressed: event => {
            if (count === 0) {
                if (event.key === Qt.Key_Up) {
                    root.upFromTopRow()
                    event.accepted = true
                }
                return
            }

            const columns = columnsShown
            const column = currentIndex % columns
            const atLeft = column === (root.rightToLeft ? columns - 1 : 0)
            const atRight = column === (root.rightToLeft ? 0 : columns - 1)
            const atTop = currentIndex < columns
            const atBottom = currentIndex >= count - columns // nothing directly below
            const pageSize = Math.max(1, Math.floor(height / cellHeight)) * columns
            const withCtrl = event.modifiers & Qt.ControlModifier

            // The Menu key or Shift+F10 opens the selected item's action menu.
            if (event.key === Qt.Key_Menu || (event.key === Qt.Key_F10 && (event.modifiers & Qt.ShiftModifier))) {
                root.openActionMenu(currentItem)
                event.accepted = true
                return
            }

            switch (event.key) {
            case Qt.Key_Return:
            case Qt.Key_Enter:
                root.launchCurrent()
                event.accepted = true
                return
            case Qt.Key_Up:
                if (atTop) {
                    root.upFromTopRow()
                    event.accepted = true
                    return
                }
                moveCurrentIndexUp()
                break
            case Qt.Key_Down:
                if (!atBottom) {
                    moveCurrentIndexDown()
                }
                break
            case Qt.Key_Left:
                if (!atLeft) {
                    moveCurrentIndexLeft()
                }
                break
            case Qt.Key_Right:
                if (!atRight) {
                    moveCurrentIndexRight()
                }
                break
            case Qt.Key_Home: // start of the row; with Ctrl, the first item
                currentIndex = withCtrl ? 0 : currentIndex - column
                break
            case Qt.Key_End: // end of the row; with Ctrl, the last item
                currentIndex = withCtrl ? count - 1 : Math.min(currentIndex - column + columns - 1, count - 1)
                break
            case Qt.Key_PageUp: // a page up in the same column, stopping at the top row
                currentIndex = Math.max(currentIndex - pageSize, column)
                break
            case Qt.Key_PageDown: { // a page down in the same column, stopping at its last item
                let target = currentIndex + pageSize
                while (target >= count) {
                    target -= columns
                }
                currentIndex = Math.max(target, currentIndex)
                break
            }
            default:
                return // not a navigation key: typing goes on to the search box
            }
            showCurrent(columns)
            event.accepted = true
        }

        // Scrolls the selection into view; in the first or last row, all the way to the
        // top or bottom, so the empty space above or below the tiles shows too.
        function showCurrent(columns) {
            if (currentIndex < columns) {
                positionViewAtBeginning()
            } else if (currentIndex >= count - (count % columns || columns)) {
                positionViewAtEnd()
            } else {
                positionViewAtIndex(currentIndex, GridView.Contain)
            }
        }

        // The highlight follows real pointer movement only, so it doesn't jump when
        // results change or the grid scrolls under a mouse that isn't moving.
        HoverHandler {
            id: pointer

            // Scene coordinates: unlike point.position, they don't change when the
            // grid scrolls under the mouse.
            property point lastPosition: Qt.point(NaN, NaN)

            onPointChanged: {
                const position = point.scenePosition
                const moved = position.x !== lastPosition.x || position.y !== lastPosition.y
                const firstEvent = isNaN(lastPosition.x)
                lastPosition = position
                if (!hovered || !moved || firstEvent) {
                    return
                }
                const inContent = view.contentItem.mapFromItem(null, position.x, position.y)
                const index = view.indexAt(inContent.x, inContent.y)
                if (index >= 0) {
                    view.currentIndex = index
                }
            }
        }

        // In the right-hand gap, at the section's edge, over the view.
        PC3.ScrollBar.vertical: PC3.ScrollBar {
            id: scrollBar
            parent: root
            z: 1
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right

            // Plasma's scrollbar draws a faint 1px separator along its inner edge when the
            // theme asks for one (Breeze does), with no setting to turn it off. It's the
            // scrollbar's only Rectangle, so hide it here. If Plasma ever builds its
            // scrollbar differently, the line simply comes back.
            Component.onCompleted: {
                for (const child of children) {
                    if (child.radius !== undefined && child.border !== undefined) {
                        child.visible = false
                    }
                }
            }
        }

        // Plasma's standard scroll speed instead of GridView's own.
        Kirigami.WheelHandler {
            target: view
            filterMouseEvents: true
            horizontalStepSize: 20 * Qt.styleHints.wheelScrollLines // qmllint disable missing-property
            verticalStepSize: 20 * Qt.styleHints.wheelScrollLines // qmllint disable missing-property
        }
    }

    ActionMenu {
        id: actionMenu
        onActionTriggered: closePopup => {
            if (closePopup) {
                root.launched()
            }
        }
        onOwnActionTriggered: (actionId, argument) => {
            if (actionId === "protea:hide") {
                root.hideRequested(argument)
            } else if (actionId === "protea:unhide") {
                root.unhideRequested(argument)
            }
        }
    }

    PlasmaExtras.PlaceholderMessage {
        anchors.centerIn: parent
        width: parent.width - Kirigami.Units.gridUnit * 4

        iconName: "edit-none"
        text: root.placeholderText

        // Fades in, and goes at once, so it never lingers over results. The text stays
        // the same throughout, so the icon never shows without it.
        visible: root.placeholderShown
        opacity: root.placeholderShown ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutCubic
            }
        }
    }
}
