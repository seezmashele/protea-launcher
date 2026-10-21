# Protea Launcher: Dimensions and Spacing

Every size and gap used in the launcher popup, measured from the running code.

- **Measured:** 2026-10-04, with the app grid sizes and the smaller tiles option, a 12px gap around and between the sections, a single 24px gap at each side of the app grid with the scrollbar inside the right one, scrolling space above and below the tiles, and the popup locked to its content size. Re-checked 2026-10-21 on Plasma 6.8.0 (Qt 6.12): every value unchanged.
- **Settings:** the defaults: 6 columns × 5 rows, the **Cozy** size (44px icons in 116px tiles) without smaller tiles, Round search bar corners, no dark backgrounds.
- **Font:** Noto Sans 10pt (line height 17.7px). Label heights change with the system font. The Kirigami spacing units don't: they're fixed values.
- **Units:** logical pixels, before display scaling.
- **Not included:** the frame Plasma draws around the popup: 4px on every side with the Breeze theme. The window on screen is that much larger than the content sizes here. In a panel that isn't floating, Plasma also adds 1px between the popup and the panel (to the height for a top or bottom panel, the width for a side panel) for the separator line it draws there, and that pixel ends up in the app grid section: 597 tall instead of 596 under a bottom panel.

## At a glance

Content area: **744 × 710px** (744 × 702 with the dark header and footer). The popup has **12px padding** on every side and its three sections (search bar, app grid, utility bar) are **12px apart**, so the search bar and utility bar have 12px on all sides. The app grid spans the popup's full width and has one **24px gap** at each side of the tiles, with the scrollbar inside the right one, so the tiles are centred whether or not the scrollbar shows. Above the first row and below the last there's **8px** of empty space that scrolls with the tiles.

### Top to bottom

| From top | Height | What |
|---:|---:|---|
| 0 | 12 | Popup padding |
| 12 | 30 | Search bar |
| 42 | 12 | Section spacing |
| 54 | 8 | Empty space above the first row (scrolls with the tiles) |
| 62 | 580 | Tiles (5 rows × 116) |
| 642 | 8 | Empty space below the last row (scrolls with the tiles) |
| 650 | 12 | Section spacing |
| 662 | 36 | Utility bar |
| 698 | 12 | Popup padding |
| **710** | | **Total** |

Positions in the grid are at the top of the list. With the dark header and footer the popup's top and bottom padding drop to 8, because each band runs on into Plasma's 4px frame and so still has 12 above the search bar and below the utility bar. That takes 8 off the total: 702.

### Left to right

| Row | Left | Content | Right | Total |
|---|---:|---|---:|---:|
| Search bar | 12 | 720 | 12 | 744 |
| App grid | 24 | 696 tiles (6 × 116) | 24 (the scrollbar sits in it) | 744 |
| Utility bar | 12 | 720 | 12 | 744 |

The search box and the avatar start at 12 and the tiles at 24 (12 further in). On the right, the tiles end at 720, the search box and the power button end at 732, and the scrollbar slot runs from 726 to the popup's edge at 744, with its visible handle at 732–738: 12 from the tiles and 6 from the edge.

With the dark header and footer on, each bar is 728 wide, from 8 to 736: it reaches 4 into Plasma's frame on each side, as its band does, so it's 12 from the band's edges on all four sides.

### Size of the popup

The popup is always exactly its content size, which comes from the columns, rows and tile size. Its minimum and maximum size are both set to that size, so it can't be dragged to another size, and a size Plasma saved from earlier dragging is brought back to it. The one exception is the 1px Plasma adds for its separator line in a panel that isn't floating (see "Not included" above).

It only ends up smaller if Plasma has to shrink it to fit the screen (Plasma caps popups at 95% of the screen's width and height). Then the padding and section spacing stay fixed and the app grid shows as many columns as fit with at least 24 at each side, centred, and scrolls:

| Popup size | Popup padding | Section spacing | Grid |
|---|---:|---:|---|
| 500 × 450 (forced smaller by a small screen) | 12 | 12 | 3 columns, 76 at each side, scrolls |
| 744 × 710 (its size) | 12 | 12 | 6 × 5, 24 at each side |

## Popup

| Property | Value | Source |
|---|---|---|
| Content size | 744 × 710 (744 × 702 with the dark header and footer) | Worked out by the layout from the content: columns × rows of tiles, the padding around them, and the bars |
| Size limits | Minimum = maximum = content size, for both width and height | `Layout.minimum…`/`maximum…` bound to the implicit size; Plasma takes the popup's size limits from them, so it can't be dragged to another size |
| Padding (all four sides) | 12 (8 at the top and bottom with the dark header and footer) | `padding` = `sectionGap` = `Kirigami.Units.largeSpacing × 1.5`; the app grid has `Layout.leftMargin` and `Layout.rightMargin` of −12 to span the full width, and its own gap at each side instead |
| Section spacing | 12 | `spacing` = `sectionGap` |

## Search bar

| Property | Value | Source |
|---|---|---|
| Size | 720 × 30 (728 × 30 with the dark background) | Width fills the space inside the padding; height is `PlasmaExtras.SearchField`'s own |
| Position | x 12, y 12 (x 8, y 8 with the dark background) | Popup padding |
| Gap on every side | 12 | Padding on three sides, section spacing below; with the dark background, to the band's edges on all four sides |
| Corners | Fully round ends (Round, the default): radius 15, half the height; or the theme's (Default) | `searchBarRoundCorners` setting. Round draws the field itself, filled with the text colour at 10% and with no outline at rest (as Protea Dark draws its own fields), a 1px outline in the hover colour (the accent) at 50% on hover and in the focus colour while typing, and keeps the theme's padding, so only the corners and fill change |
| Placeholder text | "Search…" | Plasma's default |
| Dark background (optional, off by default) | A band from the popup's top, left and right edges (it reaches the 4px of Plasma's popup frame beyond the content) to the top of the grid. Turning it on takes the frame's 4px off the top padding (the footer's band takes another 4 off the bottom), and widens the search bar by 4 on each side, so it's 12 (`sectionGap`) from the band's edges on all four sides | `headerFooterDarkBackground` setting, which turns on the utility bar's band too; black at 25% opacity; top corners rounded with `Kirigami.Units.cornerRadius` (5) to match the popup |

## App grid

| Property | Value | Source |
|---|---|---|
| Section size | 744 × 596 | The popup's full width; tiles + the gap at each side |
| Position | x 0, y 54 | Popup padding, search bar and section spacing above it |
| Gap at each side | 24 between the section's edge and the tiles, the same on both sides (`horizontalPadding`, `Kirigami.Units.largeSpacing × 3`). It's the grid view's own margin, as in Kickoff, so the wheel and dragging scroll the grid from the gaps too | The scrollbar sits inside the right gap, so it doesn't change where the tiles are |
| Scrolling space | 8 of empty space above the first row and below the last, which scrolls with the tiles, so they can move through it (`scrollPadding`, the grid's header and footer; `Kirigami.Units.largeSpacing`) | Arrowing into the first or last row scrolls all the way to the top or bottom, so the space shows |
| Cell | 116 × 116, square | The size's tile (or smaller tile); never smaller than a tile's icon and two-line label need |
| Columns × rows | 6 × 5 | `columns`, `rows` settings |
| Tile area | 696 × 580 at x 24, y 62 (at the top of the list) | columns × cell, rows × cell |
| Scrollbar | 18-wide slot at the popup's right edge, inside the 24 gap, the full height of the section, 6 clear of the tiles; the visible handle is 6 wide, with 6 of the slot's own padding on each side, so it sits 6 from the popup's edge and 12 from the last column of tiles. The 1px separator Breeze asks Plasma to draw along the slot's inner edge is hidden | Plasma scrollbar style; it takes no space of its own |
| Horizontal position of tiles | Centred in the section: 24 at each side at the designed size, more if Plasma squeezes the popup and a column no longer fits | The grid view is the columns plus both gaps, centred |
| Scroll step | 60px per wheel notch | 20 × system wheel lines (3) |
| "No matches" message | 672 wide (section width − 72), centered | Section width − 4 × `gridUnit` |

## Tiles

Sizes for the default Cozy size; see [App grid sizes](#app-grid-sizes) for the others.

| Property | Value | Source |
|---|---|---|
| Size | 116 × 116 | One grid cell (the size's tile) |
| Padding | 8 on all sides | `Kirigami.Units.largeSpacing` |
| Icon | 44 × 44, 17 below the tile's top edge | The size's icon; drawn at exactly that size (`roundToIconSize: false`) |
| Icon-to-label gap | 4 | `Kirigami.Units.smallSpacing` |
| Label | 100 × 36, up to 2 lines, 15 above the tile's bottom edge | Tile width − padding; always reserves 2 lines |
| Spare height | 16, shared above the icon and below the label (9 / 7) | Whatever the tile has beyond its content; the layout gives a little more to the larger icon slot |
| Label overflow | Wraps, then ends in "…" | Full name shown in a tooltip |
| Highlight | 116 × 116, fills the tile | Plasma theme's view-item highlight |

Content needs 8 + 44 + 4 + 36 + 8 = 100, so the tile is its set size: max(116, 100) = **116**.

## Utility bar

| Property | Value | Source |
|---|---|---|
| Size | 720 × 36 (728 × 36 with the dark background) | Width fills the space inside the padding; height is the buttons' |
| Position | x 12, y 662 (x 8 with the dark background) | Everything above it plus section spacing |
| Gap on every side | 12 | Section spacing above, padding on the other three sides; with the dark background, to the band's edges on all four sides |
| Gap between buttons | 8 | `Kirigami.Units.largeSpacing` |
| Avatar | 32 × 32 circle, at the left edge, vertically centered | `Kirigami.Units.iconSizes.medium` |
| Buttons | 36 × 36 each (System Settings, Power), at the right edge | `Kirigami.Units.gridUnit × 2`; fixed, so the target is bigger than the icon |
| Button icon | 16 × 16, monochrome, centered | `Kirigami.Units.iconSizes.small`; `-symbolic` icon names |
| Button group | 80 wide (2 buttons, 1 gap of 8) | 2 × 36 + 8 |
| Power menu | Opens above the power button, right edges aligned (below it when the panel is at the top or a side) | Plasma's native menu (`PlasmaExtras.Menu`) |
| Dark background (optional, off by default) | A band from the bottom of the grid to the popup's left, right and bottom edges (it reaches the 4px of Plasma's popup frame beyond the content). Turning it on takes the frame's 4px off the bottom padding (with the header's 4 off the top, the popup is 744 × 702), and widens the bar by 4 on each side, so it's 12 (`sectionGap`) from the band's edges on all four sides | `headerFooterDarkBackground` setting, shared with the search bar's band; black at 25% opacity; bottom corners rounded with `Kirigami.Units.cornerRadius` (5) to match the popup |

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
| `cornerRadius` | 5 | Outer corners of the optional dark search bar and utility bar backgrounds |

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

The app grid's **Size** setting picks one of five sizes, each an icon size and a tile size. **Use smaller tiles** swaps in a tile 8 smaller for whichever size is chosen. Every combination leaves room for the icon and a two-line name: a tile needs 8 + icon + 4 + 36 (two lines) + 8.

| Size | Icon | Tile | Smaller tile | Tile needs |
|---|---:|---:|---:|---:|
| Compact | 36 | 108 | 100 | 92 |
| Small | 40 | 112 | 104 | 96 |
| Cozy (default) | 44 | 116 | 108 | 100 |
| Medium | 48 | 120 | 112 | 104 |
| Large | 56 | 128 | 120 | 112 |

| Size | Label width | Icon from top / label from bottom | Popup content at 6 × 5 |
|---|---:|---|---:|
| Compact | 92 | 16 / 16 | 696 × 670 |
| Compact, smaller tiles | 84 | 12 / 12 | 648 × 630 |
| Small | 96 | 16 / 16 | 720 × 690 |
| Small, smaller tiles | 88 | 12 / 12 | 672 × 650 |
| Cozy (default) | 100 | 17 / 15 | 744 × 710 |
| Cozy, smaller tiles | 92 | 12 / 12 | 696 × 670 |
| Medium | 104 | 17 / 15 | 768 × 730 |
| Medium, smaller tiles | 96 | 13 / 11 | 720 × 690 |
| Large | 112 | 18 / 14 | 816 × 770 |
| Large, smaller tiles | 104 | 13 / 11 | 768 × 730 |

- Width = columns × tile + 48: the 24 gap at each side of the grid.
- Height = rows × tile + 130: 62 above the tiles (12 + 30 + 12 + 8) and 68 below them (8 + 12 + 36 + 12). 8 less with the dark header and footer.

## Where it's set

| Value | File |
|---|---|
| Popup padding and section spacing (`sectionGap`), the app grid sizes (`gridSizes`), the size lock, the grid spanning the full width, the optional dark search bar and utility bar backgrounds | [FullRepresentation.qml](package/contents/ui/FullRepresentation.qml) |
| The gap at each side of the grid, the scrolling space above and below the tiles, cell size, columns/rows, scrollbar, "No matches" | [grid/AppGrid.qml](package/contents/ui/grid/AppGrid.qml) |
| Tile padding, icon/label layout, highlight | [grid/AppTile.qml](package/contents/ui/grid/AppTile.qml) |
| Round search bar corners | [search/SearchBar.qml](package/contents/ui/search/SearchBar.qml) |
| Avatar size, gap between buttons, button icon names, power menu | [utility/UtilityBar.qml](package/contents/ui/utility/UtilityBar.qml) |
| Button size, button icon size | [utility/UtilityButton.qml](package/contents/ui/utility/UtilityButton.qml) |
| Defaults for columns, rows, size, smaller tiles, dark backgrounds, search bar corners | [config/main.xml](package/contents/config/main.xml) |
