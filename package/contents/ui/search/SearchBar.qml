/*
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

PlasmaExtras.SearchField {
    id: root

    // Fully rounded ends instead of the theme's corners. The theme draws the field from
    // an image with its corners built in, so in that case it's drawn here instead: filled
    // with the text colour at 10%, outlined only on hover and focus.
    property bool roundCorners: false

    // Down arrow: move into the grid below.
    signal downPressed()
    // Enter or Return. Used instead of accepted(), which the clear button sends too.
    signal enterPressed()

    Keys.onDownPressed: root.downPressed()
    Keys.onReturnPressed: root.enterPressed()
    Keys.onEnterPressed: root.enterPressed()

    // Hidden rather than replaced, so the padding the theme image gives the text,
    // search icon and clear button stays the same.
    Binding {
        target: root.background
        property: "opacity"
        value: 0
        when: root.roundCorners
    }

    Rectangle {
        visible: root.roundCorners
        anchors.fill: parent
        z: -1

        radius: height / 2
        // A shade lighter than what's behind it in a dark colour scheme, darker in a light one.
        color: Qt.alpha(Kirigami.Theme.textColor, 0.1)
        // No outline at rest, as Protea Dark draws its own fields.
        border.width: root.activeFocus || root.hovered ? 1 : 0
        border.color: root.activeFocus ? Kirigami.Theme.focusColor : Kirigami.Theme.hoverColor
    }
}
