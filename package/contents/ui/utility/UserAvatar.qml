/*
    SPDX-License-Identifier: GPL-2.0-or-later

    The picture's rounding, the letter's size and the focus ring are as in Kirigami Addons'
    AvatarButton.qml and Avatar.qml.
*/

import QtQuick
import QtQuick.Window
import QtQuick.Templates as T
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami
import org.kde.coreaddons as KCoreAddons
import org.kde.kcmutils as KCM
import org.kde.config as KConfig

// The user's profile picture in a circle or, without one, the first letter of their name
// on a circle filled like the search bar, with no outline. Hovering shows the user's name;
// clicking opens the Users page in System Settings.
T.AbstractButton {
    id: root

    readonly property string name: user.fullName || user.loginName
    // The letter shows until the picture has loaded, and whenever there's none.
    readonly property bool showPicture: picture.status === Image.Ready

    visible: KConfig.KAuthorized.authorizeControlModule("kcm_users")

    // The colour set the search bar uses, so the circle's fill matches it.
    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    implicitWidth: Kirigami.Units.iconSizes.medium
    implicitHeight: implicitWidth
    // Room around the circle for the focus ring, which is the background.
    padding: 1

    hoverEnabled: true
    text: name

    Accessible.role: Accessible.Button
    Accessible.description: i18nc("@info:tooltip", "Open user settings")

    contentItem: Item {
        Rectangle {
            anchors.fill: parent
            visible: !root.showPicture
            radius: width / 2
            color: Qt.alpha(Kirigami.Theme.textColor, 0.1)
        }

        Text {
            anchors.fill: parent
            visible: !root.showPicture
            // Array.from keeps a letter made of two UTF-16 units (such as many emoji) whole.
            text: (Array.from(root.name)[0] ?? "").toUpperCase()
            textFormat: Text.PlainText
            color: Kirigami.Theme.textColor
            font.pixelSize: {
                // Less padding as the circle gets tiny, so the letter stays readable.
                const padding = Math.max(0, Math.min(Kirigami.Units.largeSpacing, height - Kirigami.Units.largeSpacing * 2))
                return Math.round((height - padding) / 2)
            }
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Image {
            id: picture
            anchors.fill: parent
            visible: root.showPicture
            source: user.faceIconUrl
            // The picture URL briefly goes empty and back when it changes, so don't cache it.
            cache: false
            asynchronous: true
            fillMode: Image.PreserveAspectCrop
            mipmap: true
            sourceSize.width: width * Screen.devicePixelRatio
            sourceSize.height: height * Screen.devicePixelRatio
            layer.enabled: GraphicsInfo.api !== GraphicsInfo.Software
            layer.textureSize: Qt.size(width * Screen.devicePixelRatio, height * Screen.devicePixelRatio)
            layer.effect: Kirigami.ShadowedTexture {
                // The effect is the picture's size.
                radius: width / 2
            }
        }
    }

    // A 1px ring in the focus colour while it has keyboard focus or is pressed, in the
    // padding around the circle. Only a ring, as the circle's fill is see-through.
    background: Rectangle {
        radius: height / 2
        color: "transparent"
        border.width: 1
        border.color: Kirigami.Theme.focusColor
        visible: root.visualFocus || root.down
    }

    onClicked: KCM.KCMLauncher.openSystemSettings("kcm_users")
    // Enter and Return press it too, not only Space, as Enter launches in the grid.
    Keys.onReturnPressed: clicked()
    Keys.onEnterPressed: clicked()

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    PC3.ToolTip.text: text
    PC3.ToolTip.visible: hovered
    PC3.ToolTip.delay: Kirigami.Units.toolTipDelay

    KCoreAddons.KUser {
        id: user
    }
}
