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

`Theme.Surfaces` exposes a `SurfaceStyle` for each of three roles: `panel` (the palette, notes, the
quick action result, the camera panels and both HUDs), `overlay` (menus, dialogs, callouts, the note
switcher and heading menu, and chat cards) and `control` (the action capsule, the menu circle and
pills). A style
is `.glass` (the call site's own glass, which is all Default uses), `.tintedGlass`, or `.solid` with a
fill, stroke and optional glow. Views never branch on the theme.

- `themedSurface(_ role:, in:glass:)` styles a view's background. Reduce Transparency turns tinted
  glass into a solid fill.
- `themedPanel(in:scrim:)` is a borderless window's body: scrim over glass in Default, fill, backdrop
  and scrim in a theme.

Only the `panel` role draws a backdrop. Extensions read `Theme.Surfaces` as data and draw their own
copy, per the extension rule in `AGENTS.md`.

## Backdrops

`PanelBackdrop` wraps a `Canvas` in a `TimelineView` at the backdrop's `frameRate` and draws through `BackdropRenderer`,
with one renderer per `BackdropKind` in `DesignSystem/Theming/Backdrops/`. A renderer is stateless:
every position is a pure function of time and a fixed integer hash, nothing is stored between frames,
and glyphs are resolved once as `Canvas` symbols. Renderers are plain enums that carry no actor isolation and take plain
per-appearance colors from `BackdropRenderer.color(_:dark:)`.

The timeline is paused when the window is hidden or occluded (`WindowOcclusionReader`), under
Reduce Motion (one still frame at time 0), and in Light when the backdrop's `lightIsStatic` is set.
The Settings picker draws the same still frame for each card.

## Backdrop budget

A backdrop runs only while the palette is showing. The hard requirement is zero CPU while hidden
(the timeline pauses on hide and occlusion). While visible the target is roughly 5% to 8% of one core
and under 8 MB of extra resident memory; each backdrop sets its own `frameRate` (Tron 30, Matrix 24, Synthwave 30, Amber 30, Ares 30).

Three kinds of figure appear below. The proxy columns come from `Tests/backdrop-performance.swift`,
which renders `BackdropRenderer.draw` through `ImageRenderer` at the 750x475 palette size for 300
frames. `ImageRenderer` rasterizes and reads back each frame and rebuilds the view every frame, so it
re-resolves `Canvas` symbols each time (the "symbols" row). That makes the proxy an upper bound and
not representative for symbol-heavy backdrops such as code rain. The hosted-window probe puts
`PanelBackdrop` in an `NSHostingView` window and reads process CPU over 8 seconds; it is noisy (the
machine ran at load average 10 to 12) and each figure is a single run. The `Live CPU open` and
`Live CPU hidden` columns come from `Scripts/measure-backdrop.sh` against the running app (10 second
runs, `TINYCAST_PROCESS=Tinycast` for the installed release build). The open figure is the whole
palette's cost, not the backdrop's alone; rows without a run say pending.

| Backdrop | Proxy ms/frame (mean, p95) | Proxy CPU at 30 fps | Hosted-window probe | Live CPU open | Live CPU hidden | RSS delta | Machine | Date |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Tron grid, dark | 0.60, 0.68 | 1.8% | 0.7% to 6.1% over 4 runs | 11.1% (whole palette) | 0.1% before, 0.3% after | about 0.3 MB | Apple M4 Max | 2026-10-12 |
| Tron grid, light | 0.59, 0.70 | 1.8% | 1.7% to 5.7% over 3 runs | pending | pending | pending | Apple M4 Max | 2026-10-12 |
| Synthwave sunset, dark | 0.62, 0.72 | 1.8% | not probed | pending | pending | pending | Apple M4 Max | 2026-10-12 |
| Synthwave sunset, light | 0.51, 0.57 | 1.5% | not probed | pending | pending | pending | Apple M4 Max | 2026-10-12 |
| Amber scanlines, dark | 1.15 to 1.52, 1.60 to 2.45 over 3 runs | 3.4% to 4.6% | not probed | pending | pending | pending | Apple M4 Max | 2026-10-12 |
| Amber scanlines, light (static) | 0.58 to 0.92, 0.65 to 1.17 over 3 runs, one frame drawn then the timeline pauses | 1.7% to 2.7%, not a running cost | not probed | pending | pending | pending | Apple M4 Max | 2026-10-12 |
| Ares light trails, dark | 0.61, 0.74 | 1.8% | not probed | pending | pending | pending | Apple M4 Max | 2026-10-12 |
| Ares light trails, light | 0.54, 0.65 | 1.6% | not probed | pending | pending | pending | Apple M4 Max | 2026-10-12 |
| Code rain, dark (24 fps) | 6.59, 7.19 (5.35 is symbol resolution) | 19.8%, not representative | 2.5% to 6.4% over 4 runs, at 20 fps and fewer glyphs | pending | pending | pending | Apple M4 Max | 2026-10-12 |
| Code rain, light (24 fps) | 6.44, 7.17 | 19.3%, not representative | 6.5% in 1 run (a second run read 0%, the timeline did not tick), at 20 fps and fewer glyphs | pending | pending | pending | Apple M4 Max | 2026-10-12 |

The code rain probe figures were taken at 20 fps with about half the columns raining and trails of 5 to
12 glyphs. The shipped setting is 24 fps with two thirds of the columns and trails of 6 to 15, which
draws more per frame and has not been probed; measure it with `Scripts/measure-backdrop.sh`.

Tron's live open figure is above the 5% to 8% target because it includes the rest of the palette;
it was accepted as is (Devon, 2026-10-12), since the palette is only open for a few seconds at a time
and CPU returns to idle once it closes. A rough
glyph count: 46 columns, two thirds raining, about 10 glyphs each, around 300 draws per frame.

## Fonts

Faces are bundled under `Tinycast/Resources/Fonts/` with their licenses, and registered by
`ATSApplicationFontsPath` in `Info.plist` (the folder is a reference in `project.yml` so the path
resolves). Typography tokens go through `ThemeFonts`, which returns the token's `base` font untouched
when the theme's face for that role (`display`, `body`, `mono`) equals Default's, and also when a
bundled family is not installed, so a missing font never produces a blank label. Custom faces use
`Font.custom(_:size:relativeTo:)` so Dynamic Type still scales them. IBM Plex Mono ships four static
files (Regular, Medium, SemiBold, Bold) under one family name; `appearance-test` checks that each weight
resolves to its own face.

## Adding a theme

Follow [adding-a-theme.md](adding-a-theme.md): the files to touch, a definition template, the
renderer rules, font steps, contrast tuning and the checks that need eyes.

