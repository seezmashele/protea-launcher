/*
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import org.kde.kitemmodels as KItemModels

import "../code/appid.js" as AppId

// The A–Z app list without the hidden apps. Hiding or unhiding an app only removes or
// adds its tile, so the grid keeps its scroll position and selection.
KItemModels.KSortFilterProxyModel {
    id: root

    // IDs of the apps to leave out, e.g. "org.kde.dolphin.desktop".
    property list<string> hiddenApps

    // Launches the app at row, or runs one of its actions, like Kicker's own models.
    // Rows here skip the hidden apps, so they're mapped back to the app list's rows.
    function trigger(row: int, actionId: string, argument): bool {
        return sourceModel.trigger(mapToSource(index(row, 0)).row, actionId, argument)
    }

    // Each app's ID comes from Kicker's favoriteId role, which the callback reads through filterRole.
    filterRoleName: "favoriteId"
    filterRowCallback: (row, parent) => !hiddenApps.includes(AppId.fromFavoriteId(sourceModel.data(sourceModel.index(row, 0, parent), filterRole)))

    onHiddenAppsChanged: invalidateFilter()
}
