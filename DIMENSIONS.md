# Protea Launcher: Dimensions and Spacing

Every size and gap used in the launcher popup, measured from the running code.

- **Measured:** 2026-10-22 on Plasma 6.8.0 (Qt 6.12, Frameworks 6.31): the real popup loaded offscreen with the installed Plasma modules and KDE's font settings. First measured 2026-10-04 on Plasma 6.7. The popup padding and section spacing went from 12 to 8 later on 2026-10-22, the default size from Cozy to Medium when Compact and Cozy were removed, every size's icon and tile 4 smaller after that, and then four sizes 6 apart (Compact 36 in 100 up to Large 54 in 118; Medium is 48 in 112 again); the values here are for 8 and Medium.
- **Settings:** the defaults: 6 columns × 4 rows, the **Medium** size (48px icons in 112px tiles), Round search bar corners, no dark header and footer.
- **Font:** Noto Sans 10pt (line height 17.7px). Label heights change with the system font. The Kirigami spacing units don't: they're fixed values.
- **Units:** logical pixels, before display scaling.
- **Not included:** the frame Plasma draws around the popup: 4px on every side with the Breeze theme. The window on screen is that much larger than the content sizes here. In a panel that isn't floating, Plasma also adds 1px between the popup and the panel (to the height for a top or bottom panel, the width for a side panel) for the separator line it draws there, and that pixel ends up in the app grid section: 465 tall instead of 464 under a bottom panel.

## At a glance

Content area: **720 × 562px** (720 × 554 with the dark header and footer). The popup has **8px padding** on every side and its three sections (search bar, app grid, utility bar) are **8px apart**, so the search bar and utility bar have 8px on all sides. The app grid spans the popup's full width and has one **24px gap** at each side of the tiles, with the scrollbar inside the right one, so the tiles are centred whether or not the scrollbar shows. Above the first row and below the last there's **8px** of empty space that scrolls with the tiles.

### Top to bottom

| From top | Height | What |
|---:|---:|---|
| 0 | 8 | Popup padding |
| 8 | 30 | Search bar |
| 38 | 8 | Section spacing |
| 46 | 8 | Empty space above the first row (scrolls with the tiles) |
| 54 | 448 | Tiles (4 rows × 112) |
| 502 | 8 | Empty space below the last row (scrolls with the tiles) |
| 510 | 8 | Section spacing |
| 518 | 36 | Utility bar |
| 554 | 8 | Popup padding |
| **562** | | **Total** |

Positions in the grid are at the top of the list. With the dark header and footer the popup's top and bottom padding drop to 4, because each band runs on into Plasma's 4px frame and so still has 8 above the search bar and below the utility bar. That takes 8 off the total: 554.

With the utility bar hidden (**Utility bar: Show** unticked) the bar and the section spacing above it are left out, so the popup is **518** tall (44 less). Under the grid there's then its own 8 below the last row and the 8 of padding, the same 16 as between the search bar and the first row. With the dark header and footer there's no footer band, so the bottom padding stays 8: **514**.

### Left to right

| Row | Left | Content | Right | Total |
|---|---:|---|---:|---:|
| Search bar | 8 | 704 | 8 | 720 |
| App grid | 24 | 672 tiles (6 × 112) | 24 (the scrollbar sits in it) | 720 |
| Utility bar | 8 | 704 | 8 | 720 |

The search box and the avatar start at 8 and the tiles at 24 (16 further in). On the right, the tiles end at 696, the search box and the power button end at 712, and the scrollbar slot runs from 702 to the popup's edge at 720, with its visible handle at 708–714: 12 from the tiles and 6 from the edge.

With the dark header and footer on, each bar is 712 wide, from 4 to 716: it reaches 4 into Plasma's frame on each side, as its band does, so it's 8 from the band's edges on all four sides.

### Size of the popup

The popup is always exactly its content size, which comes from the columns, rows and tile size. Its minimum and maximum size are both set to that size, so it can't be dragged to another size, and a size Plasma saved from earlier dragging is brought back to it. The one exception is the 1px Plasma adds for its separator line in a panel that isn't floating (see "Not included" above).

It only ends up smaller if Plasma has to shrink it to fit the screen (Plasma caps popups at 95% of the screen's width and height). Then the padding and section spacing stay fixed and the app grid shows as many columns as fit with at least 24 at each side, centred, and scrolls:

| Popup size | Popup padding | Section spacing | Grid |
|---|---:|---:|---|
| 500 × 450 (forced smaller by a small screen) | 8 | 8 | 4 columns, 26 at each side, scrolls |
| 720 × 562 (its size) | 8 | 8 | 6 × 4, 24 at each side |

## Popup

| Property | Value | Source |
|---|---|---|
| Content size | 720 × 562 (720 × 554 with the dark header and footer) | Worked out by the layout from the content: columns × rows of tiles, the padding around them, and the bars |
| Size limits | Minimum = maximum = content size, for both width and height | `Layout.minimum…`/`maximum…` bound to the implicit size; Plasma takes the popup's size limits from them, so it can't be dragged to another size |
| Padding (all four sides) | 8 (4 at the top and bottom with the dark header and footer) | `padding` = `sectionGap` = `Kirigami.Units.largeSpacing`; the app grid has `Layout.leftMargin` and `Layout.rightMargin` of −8 to span the full width, and its own gap at each side instead |
| Section spacing | 8 | `spacing` = `sectionGap` |

## Search bar

| Property | Value | Source |
|---|---|---|
| Size | 704 × 30 (712 × 30 with the dark background) | Width fills the space inside the padding; height is `PlasmaExtras.SearchField`'s own |
| Position | x 8, y 8 (x 4, y 4 with the dark background) | Popup padding |
| Gap on every side | 8 | Padding on three sides, section spacing below; with the dark background, to the band's edges on all four sides |
| Corners | Fully round ends (Round, the default): radius 15, half the height; or the theme's (Default) | `searchBarRoundCorners` setting. Round draws the field itself, filled with the text colour at 10% and with no outline at rest (as Protea Dark draws its own fields), a 1px outline in the hover colour (the accent) at 50% on hover and in the focus colour while typing, and keeps the theme's padding, so only the corners and fill change |
| Placeholder text | "Search…" | Plasma's default |
| Dark background (optional, off by default) | A band from the popup's top, left and right edges (it reaches the 4px of Plasma's popup frame beyond the content) to the top of the grid. Turning it on takes the frame's 4px off the top padding (the footer's band takes another 4 off the bottom), and widens the search bar by 4 on each side, so it's 8 (`sectionGap`) from the band's edges on all four sides | `headerFooterDarkBackground` setting, which turns on the utility bar's band too; black at 25% opacity; top corners rounded with `Kirigami.Units.cornerRadius` (5) to match the popup |

## App grid

| Property | Value | Source |
|---|---|---|
| Section size | 720 × 464 | The popup's full width; tiles + the gap at each side |
| Position | x 0, y 46 | Popup padding, search bar and section spacing above it |
| Gap at each side | 24 between the section's edge and the tiles, the same on both sides (`horizontalPadding`, `Kirigami.Units.largeSpacing × 3`). It's the grid view's own margin, as in Kickoff, so the wheel and dragging scroll the grid from the gaps too | The scrollbar sits inside the right gap, so it doesn't change where the tiles are |
| Scrolling space | 8 of empty space above the first row and below the last, which scrolls with the tiles, so they can move through it (`scrollPadding`, the grid's header and footer; `Kirigami.Units.largeSpacing`) | Arrowing into the first or last row scrolls all the way to the top or bottom, so the space shows |
| Cell | 112 × 112, square | The size's tile; never smaller than a tile's icon and two-line label need |
| Columns × rows | 6 × 4 | `columns`, `rows` settings |
| Tile area | 672 × 448 at x 24, y 54 (at the top of the list) | columns × cell, rows × cell |
| Scrollbar | 18-wide slot at the popup's right edge, inside the 24 gap, the full height of the section, 6 clear of the tiles; the visible handle is 6 wide, with 6 of the slot's own padding on each side, so it sits 6 from the popup's edge and 12 from the last column of tiles. The 1px separator Breeze asks Plasma to draw along the slot's inner edge is hidden | Plasma scrollbar style; it takes no space of its own |
| Horizontal position of tiles | Centred in the section: 24 at each side at the designed size, more if Plasma squeezes the popup and a column no longer fits | The grid view is the columns plus both gaps, centred |
| Scroll step | 60px per wheel notch | 20 × system wheel lines (3) |
| "No matches" message | 648 wide (section width − 72), centered | Section width − 4 × `gridUnit` |

## Tiles

Sizes for the default Medium size; see [App grid sizes](#app-grid-sizes) for the others.

| Property | Value | Source |
|---|---|---|
| Size | 112 × 112 | One grid cell (the size's tile) |
| Padding | 8 on all sides | `Kirigami.Units.largeSpacing` |
| Icon | 48 × 48, 13 below the tile's top edge, centred | The size's icon; drawn at exactly that size (`roundToIconSize: false`) |
| Icon-to-label gap | 4 | `Kirigami.Units.smallSpacing` |
| Label | 96 × 36, up to 2 lines, 11 above the tile's bottom edge | Tile width − padding; always reserves 2 lines |
| Spare height | 8, shared above the icon and below the label (5 / 3) | Whatever the tile has beyond its content; at some sizes the layout gives a pixel or two more to the larger icon slot |
| Label overflow | Wraps, then ends in "…" | Full name shown in a tooltip |
| Highlight | 112 × 112, fills the tile | Plasma theme's view-item highlight |

Content needs 8 + 48 + 4 + 36 + 8 = 104, so the tile is its set size: max(112, 104) = **112**.

## Utility bar

| Property | Value | Source |
|---|---|---|
| Size | 704 × 36 (712 × 36 with the dark background) | Width fills the space inside the padding; height is the buttons' |
| Position | x 8, y 518 (x 4, y 514 with the dark header and footer) | Everything above it plus section spacing |
| Gap on every side | 8 | Section spacing above, padding on the other three sides; with the dark background, to the band's edges on all four sides |
| Gap between buttons | 8 | `Kirigami.Units.largeSpacing` |
| Avatar | 32 × 32, at the left edge, vertically centered (x 8, y 520): a 30 × 30 circle inside 1 of padding, which holds the 1px focus ring. Without a profile picture the circle is filled with the text colour at 10% (as the search bar) with no outline, and shows the name's first letter, 11px. With **User avatar** unticked it's left out and nothing else moves: the bar's height comes from the buttons | `Kirigami.Units.iconSizes.medium`; `showAvatar` setting; [utility/UserAvatar.qml](package/contents/ui/utility/UserAvatar.qml) |
| Buttons | 36 × 36 each (System Settings at x 632, Power at x 676), at the right edge | `Kirigami.Units.gridUnit × 2`; fixed, so the target is bigger than the icon |
| Button icon | 16 × 16, monochrome, centered | `Kirigami.Units.iconSizes.small`; `-symbolic` icon names |
| Button group | 80 wide (2 buttons, 1 gap of 8) | 2 × 36 + 8 |
| Power menu | Opens above the power button, right edges aligned (below it when the panel is at the top or a side) | Plasma's native menu (`PlasmaExtras.Menu`) |
| Hidden (optional, shown by default) | Left out with the section spacing above it; the popup is 44 shorter (518, or 514 with the dark header). No footer band | `showUtilityBar` setting |
| Dark background (optional, off by default) | A band from the bottom of the grid to the popup's left, right and bottom edges (it reaches the 4px of Plasma's popup frame beyond the content). Turning it on takes the frame's 4px off the bottom padding (with the header's 4 off the top, the popup is 720 × 554), and widens the bar by 4 on each side, so it's 8 (`sectionGap`) from the band's edges on all four sides | `headerFooterDarkBackground` setting, shared with the search bar's band; black at 25% opacity; bottom corners rounded with `Kirigami.Units.cornerRadius` (5) to match the popup |

## Kirigami units in use

All fixed values in Kirigami 6; Plasma only changes the animation durations.

| Unit | Value | Used for |
|---|---:|---|
| `smallSpacing` | 4 | Icon-to-label gap in tiles |
| `largeSpacing` | 8 | Popup padding and section spacing (`sectionGap`), the scrolling space above and below the tiles, tile padding, gap between utility buttons |
| `largeSpacing × 3` | 24 | The gap at each side of the app grid |
| `gridUnit` | 18 | Utility button size (× 2); "No matches" message inset (× 4) |
| `iconSizes.small` | 16 | Utility button icons |
| `iconSizes.medium` | 32 | Avatar |
| `cornerRadius` | 5 | Outer corners of the optional dark header and footer bands |

`mediumSpacing` (6) is the only spacing unit not in use. App icon and tile sizes come from the app grid sizes rather than units.

## Timing

| What | Duration | Source |
|---|---:|---|
| Tooltip delay | 700ms | `Kirigami.Units.toolTipDelay` |
| Switch to search results | When the first results arrive | All apps stay in the grid from the first keystroke until then (or until "No matches" is ready), so the grid never goes blank while a search loads |
| "No matches" wait | 200ms | `Kirigami.Units.longDuration`: a search has to have finished without results for this long before it shows; then it stays while further keystrokes still find nothing |
| "No matches" fade-in | 200ms | `Kirigami.Units.longDuration`; it goes at once when matches appear or the search is cleared |
| Search debounce | 10ms | Kicker's search model |

## App grid sizes

The app grid's **Size** setting picks one of four sizes, each 6 larger than the one before in both icon and tile, each an icon size and a tile size. Every size leaves room for the icon and a two-line name: a tile needs 8 + icon + 4 + 36 (two lines) + 8, and the tile is 8 more than that.

| Size | Icon | Tile | Tile needs |
|---|---:|---:|---:|
| Compact | 36 | 100 | 92 |
| Small | 42 | 106 | 98 |
| Medium (default) | 48 | 112 | 104 |
| Large | 54 | 118 | 110 |

| Size | Label width | Icon from top / label from bottom | Popup content at 6 × 4 |
|---|---:|---|---:|
| Compact | 84 | 12 / 12 | 648 × 514 |
| Small | 90 | 12 / 12 | 684 × 538 |
| Medium (default) | 96 | 13 / 11 | 720 × 562 |
| Large | 102 | 13 / 11 | 756 × 586 |

- Width = columns × tile + 48: the 24 gap at each side of the grid.
- Height = rows × tile + 114: 54 above the tiles (8 + 30 + 8 + 8) and 60 below them (8 + 8 + 36 + 8). 8 less with the dark header and footer.

## Where it's set

| Value | File |
|---|---|
| Popup padding and section spacing (`sectionGap`), the app grid sizes (`gridSizes`), the size lock, the grid spanning the full width, the optional dark header and footer bands | [FullRepresentation.qml](package/contents/ui/FullRepresentation.qml) |
| The gap at each side of the grid, the scrolling space above and below the tiles, cell size, columns/rows, scrollbar, "No matches" | [grid/AppGrid.qml](package/contents/ui/grid/AppGrid.qml) |
| Tile padding, icon/label layout, highlight | [grid/AppTile.qml](package/contents/ui/grid/AppTile.qml) |
| Round search bar corners | [search/SearchBar.qml](package/contents/ui/search/SearchBar.qml) |
| Avatar size, gap between buttons, button icon names, power menu | [utility/UtilityBar.qml](package/contents/ui/utility/UtilityBar.qml) |
| Button size, button icon size | [utility/UtilityButton.qml](package/contents/ui/utility/UtilityButton.qml) |
| Defaults for columns, rows, size, dark header and footer, search bar corners | [config/main.xml](package/contents/config/main.xml) |
