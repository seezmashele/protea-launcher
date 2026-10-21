/*
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

PlasmaExtras.SearchField {
    id: root

    // Fully rounded ends instead of the theme's corners. The theme draws the field from
    // an image with its corners built in, so in that case it's drawn here instead, with
    // the colours the theme image uses: view background, frame, hover and focus.
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
        // The theme's frame colour: the background mixed towards the text colour by the
        // frame contrast, a plain RGB mix like the theme image's.
        readonly property color frameColor: {
            const background = Kirigami.Theme.backgroundColor
            const text = Kirigami.Theme.textColor
            const contrast = Kirigami.Theme.frameContrast
            return Qt.rgba(background.r + (text.r - background.r) * contrast,
                           background.g + (text.g - background.g) * contrast,
                           background.b + (text.b - background.b) * contrast, 1)
        }

        visible: root.roundCorners
        anchors.fill: parent
        z: -1

        radius: height / 2
        color: Kirigami.Theme.backgroundColor
        border.width: 1
        border.color: root.activeFocus ? Kirigami.Theme.focusColor
            : root.hovered ? Kirigami.Theme.hoverColor
            : frameColor
    }
}
