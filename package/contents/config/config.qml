/*
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import org.kde.plasma.configuration as PlasmaConfig

PlasmaConfig.ConfigModel {
    PlasmaConfig.ConfigCategory {
        name: i18nc("@title:group for configuration dialog page", "General")
        icon: "preferences-desktop-plasma"
        source: "ConfigGeneral.qml"
    }
    PlasmaConfig.ConfigCategory {
        name: i18nc("@title:group for configuration dialog page", "Utility Bar")
        icon: "configure-toolbars"
        source: "ConfigUtilityBar.qml"
    }
    PlasmaConfig.ConfigCategory {
        name: i18nc("@title:group for configuration dialog page", "Hidden Apps")
        icon: "hint"
        source: "ConfigHiddenApps.qml"
    }
}
