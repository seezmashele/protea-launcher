/*
    SPDX-FileCopyrightText: 2011 Martin Gräßlin <mgraesslin@kde.org>
    SPDX-FileCopyrightText: 2012 Gregor Taetzner <gregor@freenet.de>
    SPDX-FileCopyrightText: 2014 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2015-2018 Eike Hein <hein@kde.org>
    SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
    SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later

    Adapted from Kickoff's KickoffGridDelegate.qml.
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import org.kde.plasma.components as PC3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

T.ItemDelegate {
    id: root

    required property int index
    required property var model

    property int iconSize: Kirigami.Units.iconSizes.large
    // Dimmed when keys don't act on the grid, e.g. while a utility button has focus.
    property bool highlightActive: true

    // Right-click or press-and-hold: show the item's action menu at that point.
    signal menuRequested(point position)

    implicitWidth: implicitContentWidth + leftPadding + rightPadding
    implicitHeight: implicitContentHeight + topPadding + bottomPadding

    padding: Kirigami.Units.largeSpacing
    spacing: Kirigami.Units.smallSpacing

    hoverEnabled: true
    // The grid takes keyboard focus as a whole, so Tab doesn't step through every tile.
    focusPolicy: Qt.NoFocus
    text: model.display

    Accessible.role: Accessible.Cell
    Accessible.description: model.description ?? ""

    contentItem: ColumnLayout {
        spacing: root.spacing

        Kirigami.Icon {
            // Bottom of its slot and the label at the top of its own, so any extra height
            // goes above and below them and they stay together in the middle.
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
            implicitWidth: root.iconSize
            implicitHeight: root.iconSize
            source: root.model.decoration
            animated: false
            // Draw at exactly iconSize; by default Kirigami rounds down to a standard size (42 → 32).
            roundToIconSize: false
        }

        PC3.Label {
            id: label
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            // Always reserve two lines so every tile is the same height.
            Layout.preferredHeight: lineCount === 1 ? implicitHeight * 2 : implicitHeight

            text: root.text
            textFormat: Text.PlainText
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignTop
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
        }
    }

    background: PlasmaExtras.Highlight {
        // Highlight sets its own width for ListViews (0 in a GridView), so fill the tile instead.
        anchors.fill: parent
        visible: root.GridView.isCurrentItem
        hovered: true
        pressed: root.down
        active: root.highlightActive
    }

    // Press-and-hold (mainly for touch screens) also opens the menu, and then no click follows.
    onPressAndHold: menuRequested(Qt.point(pressX, pressY))

    // Opens on press, like context menus elsewhere in KDE. A MouseArea, as in Kickoff, so the
    // tile takes the right-press for itself; left-clicks pass through to the tile.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onPressed: mouse => root.menuRequested(Qt.point(mouse.x, mouse.y))
    }

    PC3.ToolTip.text: root.text
    PC3.ToolTip.visible: hovered && label.truncated
    PC3.ToolTip.delay: Kirigami.Units.toolTipDelay
}
