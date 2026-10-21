/*
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami

// Icon-only button. Its text is shown as a tooltip and read out by screen readers.
PC3.ToolButton {
    display: PC3.AbstractButton.IconOnly
    icon.width: Kirigami.Units.iconSizes.small
    icon.height: Kirigami.Units.iconSizes.small

    // A 36px square (two grid units), so the target is bigger than the icon.
    implicitWidth: Kirigami.Units.gridUnit * 2
    implicitHeight: implicitWidth

    // Enter and Return press it too, not only Space, as Enter launches in the grid.
    Keys.onReturnPressed: clicked()
    Keys.onEnterPressed: clicked()

    PC3.ToolTip.text: text
    PC3.ToolTip.visible: hovered
    PC3.ToolTip.delay: Kirigami.Units.toolTipDelay
}
