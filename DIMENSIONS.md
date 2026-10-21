# Protea Launcher: Dimensions and Spacing

Every size and gap used in the launcher popup, measured from the running code.

- **Measured:** 2026-10-22 on Plasma 6.8.0 (Qt 6.12, Frameworks 6.31): the real popup loaded offscreen with the installed Plasma modules and KDE's font settings. First measured 2026-10-04 on Plasma 6.7.
- **Settings:** the defaults: 6 columns × 4 rows, the **Cozy** size (44px icons in 108px tiles) without larger tiles, Round search bar corners, no dark header and footer.
- **Font:** Noto Sans 10pt (line height 17.7px). Label heights change with the system font. The Kirigami spacing units don't: they're fixed values.
- **Units:** logical pixels, before display scaling.
- **Not included:** the frame Plasma draws around the popup: 4px on every side with the Breeze theme. The window on screen is that much larger than the content sizes here. In a panel that isn't floating, Plasma also adds 1px between the popup and the panel (to the height for a top or bottom panel, the width for a side panel) for the separator line it draws there, and that pixel ends up in the app grid section: 449 tall instead of 448 under a bottom panel.

## At a glance

Content area: **696 × 562px** (696 × 554 with the dark header and footer). The popup has **12px padding** on every side and its three sections (search bar, app grid, utility bar) are **12px apart**, so the search bar and utility bar have 12px on all sides. The app grid spans the popup's full width and has one **24px gap** at each side of the tiles, with the scrollbar inside the right one, so the tiles are centred whether or not the scrollbar shows. Above the first row and below the last there's **8px** of empty space that scrolls with the tiles.

### Top to bottom

| From top | Height | What |
|---:|---:|---|
| 0 | 12 | Popup padding |
| 12 | 30 | Search bar |
| 42 | 12 | Section spacing |
| 54 | 8 | Empty space above the first row (scrolls with the tiles) |
| 62 | 432 | Tiles (4 rows × 108) |
| 494 | 8 | Empty space below the last row (scrolls with the tiles) |
| 502 | 12 | Section spacing |
| 514 | 36 | Utility bar |
| 550 | 12 | Popup padding |
| **562** | | **Total** |

Positions in the grid are at the top of the list. With the dark header and footer the popup's top and bottom padding drop to 8, because each band runs on into Plasma's 4px frame and so still has 12 above the search bar and below the utility bar. That takes 8 off the total: 554.

### Left to right

| Row | Left | Content | Right | Total |
|---|---:|---|---:|---:|
| Search bar | 12 | 672 | 12 | 696 |
| App grid | 24 | 648 tiles (6 × 108) | 24 (the scrollbar sits in it) | 696 |
| Utility bar | 12 | 672 | 12 | 696 |

The search box and the avatar start at 12 and the tiles at 24 (12 further in). On the right, the tiles end at 672, the search box and the power button end at 684, and the scrollbar slot runs from 678 to the popup's edge at 696, with its visible handle at 684–690: 12 from the tiles and 6 from the edge.

With the dark header and footer on, each bar is 680 wide, from 8 to 688: it reaches 4 into Plasma's frame on each side, as its band does, so it's 12 from the band's edges on all four sides.

### Size of the popup

The popup is always exactly its content size, which comes from the columns, rows and tile size. Its minimum and maximum size are both set to that size, so it can't be dragged to another size, and a size Plasma saved from earlier dragging is brought back to it. The one exception is the 1px Plasma adds for its separator line in a panel that isn't floating (see "Not included" above).

It only ends up smaller if Plasma has to shrink it to fit the screen (Plasma caps popups at 95% of the screen's width and height). Then the padding and section spacing stay fixed and the app grid shows as many columns as fit with at least 24 at each side, centred, and scrolls:

| Popup size | Popup padding | Section spacing | Grid |
|---|---:|---:|---|
| 500 × 450 (forced smaller by a small screen) | 12 | 12 | 4 columns, 34 at each side, scrolls |
| 696 × 562 (its size) | 12 | 12 | 6 × 4, 24 at each side |

## Popup

| Property | Value | Source |
|---|---|---|
| Content size | 696 × 562 (696 × 554 with the dark header and footer) | Worked out by the layout from the content: columns × rows of tiles, the padding around them, and the bars |
| Size limits | Minimum = maximum = content size, for both width and height | `Layout.minimum…`/`maximum…` bound to the implicit size; Plasma takes the popup's size limits from them, so it can't be dragged to another size |
| Padding (all four sides) | 12 (8 at the top and bottom with the dark header and footer) | `padding` = `sectionGap` = `Kirigami.Units.largeSpacing × 1.5`; the app grid has `Layout.leftMargin` and `Layout.rightMargin` of −12 to span the full width, and its own gap at each side instead |
| Section spacing | 12 | `spacing` = `sectionGap` |

## Search bar

| Property | Value | Source |
|---|---|---|
| Size | 672 × 30 (680 × 30 with the dark background) | Width fills the space inside the padding; height is `PlasmaExtras.SearchField`'s own |
| Position | x 12, y 12 (x 8, y 8 with the dark background) | Popup padding |
| Gap on every side | 12 | Padding on three sides, section spacing below; with the dark background, to the band's edges on all four sides |
| Corners | Fully round ends (Round, the default): radius 15, half the height; or the theme's (Default) | `searchBarRoundCorners` setting. Round draws the field itself, filled with the text colour at 10% and with no outline at rest (as Protea Dark draws its own fields), a 1px outline in the hover colour (the accent) at 50% on hover and in the focus colour while typing, and keeps the theme's padding, so only the corners and fill change |
| Placeholder text | "Search…" | Plasma's default |
| Dark background (optional, off by default) | A band from the popup's top, left and right edges (it reaches the 4px of Plasma's popup frame beyond the content) to the top of the grid. Turning it on takes the frame's 4px off the top padding (the footer's band takes another 4 off the bottom), and widens the search bar by 4 on each side, so it's 12 (`sectionGap`) from the band's edges on all four sides | `headerFooterDarkBackground` setting, which turns on the utility bar's band too; black at 25% opacity; top corners rounded with `Kirigami.Units.cornerRadius` (5) to match the popup |

## App grid

| Property | Value | Source |
|---|---|---|
| Section size | 696 × 448 | The popup's full width; tiles + the gap at each side |
| Position | x 0, y 54 | Popup padding, search bar and section spacing above it |
| Gap at each side | 24 between the section's edge and the tiles, the same on both sides (`horizontalPadding`, `Kirigami.Units.largeSpacing × 3`). It's the grid view's own margin, as in Kickoff, so the wheel and dragging scroll the grid from the gaps too | The scrollbar sits inside the right gap, so it doesn't change where the tiles are |
| Scrolling space | 8 of empty space above the first row and below the last, which scrolls with the tiles, so they can move through it (`scrollPadding`, the grid's header and footer; `Kirigami.Units.largeSpacing`) | Arrowing into the first or last row scrolls all the way to the top or bottom, so the space shows |
| Cell | 108 × 108, square | The size's tile (or larger tile); never smaller than a tile's icon and two-line label need |
| Columns × rows | 6 × 4 | `columns`, `rows` settings |
| Tile area | 648 × 432 at x 24, y 62 (at the top of the list) | columns × cell, rows × cell |
| Scrollbar | 18-wide slot at the popup's right edge, inside the 24 gap, the full height of the section, 6 clear of the tiles; the visible handle is 6 wide, with 6 of the slot's own padding on each side, so it sits 6 from the popup's edge and 12 from the last column of tiles. The 1px separator Breeze asks Plasma to draw along the slot's inner edge is hidden | Plasma scrollbar style; it takes no space of its own |
| Horizontal position of tiles | Centred in the section: 24 at each side at the designed size, more if Plasma squeezes the popup and a column no longer fits | The grid view is the columns plus both gaps, centred |
| Scroll step | 60px per wheel notch | 20 × system wheel lines (3) |
| "No matches" message | 624 wide (section width − 72), centered | Section width − 4 × `gridUnit` |

## Tiles

Sizes for the default Cozy size; see [App grid sizes](#app-grid-sizes) for the others.

| Property | Value | Source |
|---|---|---|
| Size | 108 × 108 | One grid cell (the size's tile) |
| Padding | 8 on all sides | `Kirigami.Units.largeSpacing` |
| Icon | 44 × 44, 12 below the tile's top edge, centred | The size's icon; drawn at exactly that size (`roundToIconSize: false`) |
| Icon-to-label gap | 4 | `Kirigami.Units.smallSpacing` |
| Label | 92 × 36, up to 2 lines, 12 above the tile's bottom edge | Tile width − padding; always reserves 2 lines |
| Spare height | 8, shared above the icon and below the label (4 / 4) | Whatever the tile has beyond its content; at some sizes the layout gives a pixel or two more to the larger icon slot |
| Label overflow | Wraps, then ends in "…" | Full name shown in a tooltip |
| Highlight | 108 × 108, fills the tile | Plasma theme's view-item highlight |

Content needs 8 + 44 + 4 + 36 + 8 = 100, so the tile is its set size: max(108, 100) = **108**.

## Utility bar

| Property | Value | Source |
|---|---|---|
| Size | 672 × 36 (680 × 36 with the dark background) | Width fills the space inside the padding; height is the buttons' |
| Position | x 12, y 514 (x 8, y 510 with the dark header and footer) | Everything above it plus section spacing |
| Gap on every side | 12 | Section spacing above, padding on the other three sides; with the dark background, to the band's edges on all four sides |
| Gap between buttons | 8 | `Kirigami.Units.largeSpacing` |
| Avatar | 32 × 32, at the left edge, vertically centered (x 12, y 516): a 30 × 30 circle inside 1 of padding, which holds the 1px focus ring. Without a profile picture the circle is filled with the text colour at 10% (as the search bar) with no outline, and shows the name's first letter, 11px | `Kirigami.Units.iconSizes.medium`; [utility/UserAvatar.qml](package/contents/ui/utility/UserAvatar.qml) |
| Buttons | 36 × 36 each (System Settings at x 604, Power at x 648), at the right edge | `Kirigami.Units.gridUnit × 2`; fixed, so the target is bigger than the icon |
| Button icon | 16 × 16, monochrome, centered | `Kirigami.Units.iconSizes.small`; `-symbolic` icon names |
| Button group | 80 wide (2 buttons, 1 gap of 8) | 2 × 36 + 8 |
| Power menu | Opens above the power button, right edges aligned (below it when the panel is at the top or a side) | Plasma's native menu (`PlasmaExtras.Menu`) |
| Dark background (optional, off by default) | A band from the bottom of the grid to the popup's left, right and bottom edges (it reaches the 4px of Plasma's popup frame beyond the content). Turning it on takes the frame's 4px off the bottom padding (with the header's 4 off the top, the popup is 696 × 554), and widens the bar by 4 on each side, so it's 12 (`sectionGap`) from the band's edges on all four sides | `headerFooterDarkBackground` setting, shared with the search bar's band; black at 25% opacity; bottom corners rounded with `Kirigami.Units.cornerRadius` (5) to match the popup |

## Kirigami units in use

All fixed values in Kirigami 6; Plasma only changes the animation durations.

| Unit | Value | Used for |
|---|---:|---|
| `smallSpacing` | 4 | Icon-to-label gap in tiles |
| `largeSpacing` | 8 | The scrolling space above and below the tiles, tile padding, gap between utility buttons |
| `largeSpacing × 1.5` | 12 | Popup padding and section spacing (`sectionGap`) |
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

The app grid's **Size** setting picks one of five sizes, each an icon size and a tile size. **Use larger tiles** swaps in a tile 8 larger for whichever size is chosen. Every combination leaves room for the icon and a two-line name: a tile needs 8 + icon + 4 + 36 (two lines) + 8, and the tile is 8 more than that (16 more with larger tiles).

| Size | Icon | Tile | Larger tile | Tile needs |
|---|---:|---:|---:|---:|
| Compact | 36 | 100 | 108 | 92 |
| Small | 40 | 104 | 112 | 96 |
| Cozy (default) | 44 | 108 | 116 | 100 |
| Medium | 48 | 112 | 120 | 104 |
| Large | 56 | 120 | 128 | 112 |

| Size | Label width | Icon from top / label from bottom | Popup content at 6 × 4 |
|---|---:|---|---:|
| Compact | 84 | 12 / 12 | 648 × 530 |
| Compact, larger tiles | 92 | 16 / 16 | 696 × 562 |
| Small | 88 | 12 / 12 | 672 × 546 |
| Small, larger tiles | 96 | 16 / 16 | 720 × 578 |
| Cozy (default) | 92 | 12 / 12 | 696 × 562 |
| Cozy, larger tiles | 100 | 17 / 15 | 744 × 594 |
| Medium | 96 | 13 / 11 | 720 × 578 |
| Medium, larger tiles | 104 | 17 / 15 | 768 × 610 |
| Large | 104 | 13 / 11 | 768 × 610 |
| Large, larger tiles | 112 | 18 / 14 | 816 × 642 |

- Width = columns × tile + 48: the 24 gap at each side of the grid.
- Height = rows × tile + 130: 62 above the tiles (12 + 30 + 12 + 8) and 68 below them (8 + 12 + 36 + 12). 8 less with the dark header and footer.

## Where it's set

| Value | File |
|---|---|
| Popup padding and section spacing (`sectionGap`), the app grid sizes (`gridSizes`), the size lock, the grid spanning the full width, the optional dark header and footer bands | [FullRepresentation.qml](package/contents/ui/FullRepresentation.qml) |
| The gap at each side of the grid, the scrolling space above and below the tiles, cell size, columns/rows, scrollbar, "No matches" | [grid/AppGrid.qml](package/contents/ui/grid/AppGrid.qml) |
| Tile padding, icon/label layout, highlight | [grid/AppTile.qml](package/contents/ui/grid/AppTile.qml) |
| Round search bar corners | [search/SearchBar.qml](package/contents/ui/search/SearchBar.qml) |
| Avatar size, gap between buttons, button icon names, power menu | [utility/UtilityBar.qml](package/contents/ui/utility/UtilityBar.qml) |
| Button size, button icon size | [utility/UtilityButton.qml](package/contents/ui/utility/UtilityButton.qml) |
| Defaults for columns, rows, size, larger tiles, dark header and footer, search bar corners | [config/main.xml](package/contents/config/main.xml) |
