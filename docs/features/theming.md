# Theming

## Invariants

- Default is today's look and Default Dark's literals are frozen.
- A view never styles itself for a theme; it reads tokens and `themedSurface`.
- Backdrops pause when hidden or under Reduce Motion, and stay inside the stated budget.

## How a theme is stated

A theme is one `ThemeDefinition` value in `Features/Theming/Model/` (no AppKit or SwiftUI there).
`ThemeID` names the built-in looks, and `ThemeCatalog.definition(for:)` returns the value. A
definition holds the ink and surface colors per appearance, the semantic roles (accent, destructive,
warning and so on), per-token `overrides`, the three surface styles, the backdrop, the glow and the
font faces. Every `Theme.Colors` token is a `ColorToken` case whose `baseRecipe` says how it derives
from those two colors, so one alpha table serves every theme:

| Recipe | Result |
| --- | --- |
| `.ink(dark:light:)` | The theme's ink at an alpha per appearance: the ramp. |
| `.surface(dark:light:)` | The theme's surface at an alpha: scrims, and ink drawn on solid ink. |
| `.role(_:dark:light:)` | A semantic role color at an alpha. |
| `.system(_:dark:light:)` | A named macOS color, so it follows the system accent. |
| `.fixed(_)` | A literal that never changes with the theme. |

A theme restates a token by putting a recipe in `overrides`; everything else keeps the base recipe.

## How a token resolves

`ThemeStore.active` holds the current `ThemePalette`. `Theme.Colors`, `Theme.Typography`,
`Theme.Effects` and `Theme.Surfaces` read it, and `ThemeStore` is `@Observable`, so a SwiftUI view that
read a token repaints on a switch. `AppSettings.theme` drives `apply(_:)`.

AppKit hosts and anything that copied a color or font cannot observe. They compare
`ThemeStore.generation`, which changes on every switch and on `reload()`, and reapply when it moves;
`ThemeDerived` caches a value per generation for that purpose.

Increase Contrast is handled by `IncreaseContrastMonitor`, owned by `AppCore`. It sets
`IncreasedContrastFlag` and calls `ThemeStore.active.reload()` when the system option changes.
`separator`, `border` and `cardStroke` are raised to a stop floor under Increase Contrast (or a
high-contrast appearance), because a hairline at the usual alpha disappears for those readers.

## Surfaces

`Theme.Surfaces` exposes a `SurfaceStyle` for each of three roles: `panel` (the palette and other
borderless windows), `overlay` (menus, dialogs, HUDs) and `control` (buttons, fields, cards). A style
is `.glass` (the call site's own glass, which is all Default uses), `.tintedGlass`, or `.solid` with a
fill, stroke and optional glow. Views never branch on the theme.

- `themedSurface(_ role:, in:glass:)` styles a view's background. Reduce Transparency turns tinted
  glass into a solid fill.
- `themedPanel(in:scrim:)` is a borderless window's body: scrim over glass in Default, fill, backdrop
  and scrim in a theme.

Only the `panel` role draws a backdrop. Extensions read `Theme.Surfaces` as data and draw their own
copy, per the extension rule in `AGENTS.md`.

## Backdrops

`PanelBackdrop` wraps a `Canvas` in a `TimelineView` at 30 fps and draws through `BackdropRenderer`,
with one renderer per `BackdropKind` in `DesignSystem/Theming/Backdrops/`. A renderer is stateless:
every position is a pure function of time and a fixed integer hash, nothing is stored between frames,
and glyphs are resolved once as `Canvas` symbols. Renderers are plain enums that carry no actor isolation and take plain
per-appearance colors from `ThemePalette.nsColor`.

The timeline is paused when the window is hidden or occluded (`WindowOcclusionReader`), under
Reduce Motion (one still frame at time 0), and in Light when the backdrop's `lightIsStatic` is set.
The Settings picker draws the same still frame for each card.

## Backdrop budget

While visible a backdrop must stay under 5% of one core and under 8 MB of extra resident memory, and
use no CPU while hidden. The proxy columns come from `Tests/backdrop-performance.swift`, which renders
`BackdropRenderer.draw` through `ImageRenderer` at the 750x475 palette size for 300 frames at 1/30 s
steps. `ImageRenderer` also rasterizes and reads back each frame (an empty canvas costs about 0.45 ms),
so the proxy is an upper bound on the draw cost. Proxy CPU is mean ms x 30 / 1000. The live columns come
from `Scripts/measure-backdrop.sh` against the running Debug app and are pending.

`ImageRenderer` rebuilds the view every frame, so a backdrop with `Canvas` symbols pays glyph resolution
each frame here, while the live `Canvas` resolves them once. The harness prints that cost as a separate
"symbols" row; the code rain row below lists the proxy with and without it.

| Backdrop | Proxy ms/frame (mean, p95) | Proxy CPU at 30 fps | Live CPU open | Live CPU hidden | RSS delta | Machine | Date |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Tron grid, dark | 0.52, 0.58 | 1.6% | pending | pending | pending | Apple M4 Max | 2026-10-12 |
| Tron grid, light | 0.48, 0.54 | 1.4% | pending | pending | pending | Apple M4 Max | 2026-10-12 |
| Code rain, dark (pitch 16) | 8.20, 8.72 (1.25 net of 6.95 symbols) | 24.6% (3.8% net) | pending | pending | pending | Apple M4 Max, load average 12 | 2026-10-12 |
| Code rain, light (pitch 16) | 8.14, 8.76 (1.19 net of 6.95 symbols) | 24.4% (3.6% net) | pending | pending | pending | Apple M4 Max, load average 12 | 2026-10-12 |

## Fonts

Faces are bundled under `Tinycast/Resources/Fonts/` with their licenses, and registered by
`ATSApplicationFontsPath` in `Info.plist` (the folder is a reference in `project.yml` so the path
resolves). Typography tokens go through `ThemeFonts`, which returns the token's `base` font untouched
when the theme's face for that role (`display`, `body`, `mono`) equals Default's, and also when a
bundled family is not installed, so a missing font never produces a blank label. Custom faces use
`Font.custom(_:size:relativeTo:)` so Dynamic Type still scales them.

## Adding a theme

1. Add a `ThemeID` case and its title.
2. Add `ThemeCatalog+Name.swift` with the `ThemeDefinition`, and return it from
   `ThemeCatalog.definition(for:)`.
3. If the backdrop kind is new, add a renderer under `DesignSystem/Theming/Backdrops/`: stateless,
   a plain enum with no actor isolation, plain per-appearance colors via `ThemePalette.nsColor`.
4. Add the value to the `appearance.visualTheme` row in [settings-file.md](settings-file.md).
5. Run `theme-test` (contrast against each surface) and `backdrop-performance` (draw cost), and fill
   the live columns of the budget table with `Scripts/measure-backdrop.sh`.

The Settings picker lists `ThemeID.allCases`, so a new theme appears there without further work.

