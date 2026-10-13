# Theming: design

Date: 2026-10-12. Status: draft for review.

## Goal

Let the user switch Tinycast's whole look to a built-in theme (Tron Legacy, Matrix, Synthwave,
Amber CRT) with its own colors, fonts, surfaces, glow and an animated backdrop, while the
Default theme stays pixel-identical to today's app.

Decisions already made:

- Themes are a curated, compiled-in set. No user-authored theme files.
- Every theme has a dark and a light variant and follows the existing System / Light / Dark setting.
- Backdrops are animated with SwiftUI `TimelineView` + `Canvas`. No Metal shaders.
- Every Tinycast-styled surface is themed: the palette, notes, HUDs, dialogs, menus, the quick
  action result, the camera panels and the AI chat window. The standard titled windows (Settings,
  About, Updates, Support, Onboarding and the command output window) stay native macOS.
- Themes may use bundled display fonts under the SIL Open Font License.

## Non-goals

- Theming the native titled windows listed above, system menus, or the menu-bar icon.
- Per-theme geometry: `Spacing`, `Radius`, `Size` and `InterfaceMetrics` stay shared.
- Themes changing behavior, motion timing, or layout.
- Editing `EdgeDissolve.swift` or `ThinScrollbar.swift`. The dissolve is a luminance mask and
  works unchanged; the scrollbar draws `Color.primary`, which follows the appearance.

## Relationship to existing invariants

`docs/ui.md` describes one look: a scrim over behind-window blur, no opaque fills, glass only on
floating controls. That remains the definition of the **Default** theme and its rules still bind
it. A non-Default theme is an explicit, documented exception: it may use opaque surfaces,
gradients, glow and a backdrop, but only through the mechanisms in this spec, never through ad
hoc styling in a view. Default Dark's values stay frozen, and `Tests/appearance-test.swift`
keeps pinning them.

## Architecture

### Model: `Features/Theming/Model/`

No AppKit or SwiftUI import, per the Model rule.

- `ThemeID`: `standard`, `tron`, `matrix`, `synthwave`, `amber`. `String` raw values, used as the
  persisted setting. A case is added in the PR that ships its theme, so the picker never lists a
  theme that does not exist yet.
- `ThemeDefinition`: plain values for one theme.
  - `ink` and `surface`: the two colors the alpha ramp is built from, per appearance. Every ramp
    token (`selection`, `textSecondary`, ...) is the theme's ink at the token's existing alpha
    stops, and every scrim-like token is the theme's surface at its stops. Default's ink is
    white over dark and black over light, which reproduces today's values exactly.
  - `roles`: accent, onAccent, primaryAction, destructive, success, warning, progress, link and
    highlight, each either a macOS system color or an RGBA pair.
  - `overrides`: per-token recipes for the few tokens a theme restates outright.
  - `fonts`: one `FontRole` per typography token. `FontRole` is `.system(design:)` or
    `.bundled(postScriptName:)`, plus the weight. Sizes stay those of the Default token, scaled
    by Dynamic Type via `relativeTo:`.
  - `surfaces`: a `SurfaceStyle` for each of `panel`, `overlay`, `control` (see below).
  - `backdrop`: a `BackdropKind` and its parameters (colors, intensity, speed, density).
  - `glow`: color pair and radius. Radius 0 means no glow.
- `ThemeCatalog.definition(for:)`: the five definitions. `standard`'s colors are the current
  literals, moved here unchanged.
- `ContrastPolicy`: WCAG relative-luminance contrast computed from `RGBA`, used by the test
  harness and nothing at runtime.

### Store: `ThemeStore`

`@Observable @MainActor final class ThemeStore`, one global instance (`ThemeStore.active`) that
`AppCore` drives: `start()` applies the stored theme and a settings track re-applies it.

- Holds `palette: ThemePalette`, the resolved SwiftUI `Color`s and `Font`s for the active theme.
  Resolution happens once per theme change, never per render.
- Reads `AppSettings.theme` and re-resolves when it changes.
- On change, calls `IconCache.invalidateStyled()`, because a tinted surface changes how icons
  are flattened.
- Bumps a `generation` counter per switch, so AppKit views that copied a color or font know to
  reapply it.

`Theme.Colors`, `Theme.Typography`, `Theme.Effects` and `Theme.Surfaces` read it through that
static handle. This is the same kind of
exception `IconCache` already has (see `docs/ui.md`): tokens are read from every list, menu and
popover, so a missed injection would be a silent staleness bug. `docs/architecture.md` records
the exception.

### Tokens

- `Theme.Colors.*` change from `static let` to `static var` that return
  `ThemeStore.active.palette.color(.<token>)`, and `Theme.Typography.*` resolve through the
  active theme's faces. Fonts reach most views through `InterfaceMetrics.Typography`, which reads
  the same faces, so Interface Size scaling and theme faces compose. Observation tracks the read inside each view's `body`, so
  views redraw on a theme switch without any change at the call site.
- Each palette color is still built with `adaptive(dark:light:)`, so the System / Light / Dark
  setting keeps working inside every theme.
- New `Theme.Effects`: `glowColor`, `glowRadius`, `backdropIntensity`.
- New `Theme.Surfaces`: the three `SurfaceStyle` values, exposed as data so Extensions can render
  them with its own code.
- `searchFieldNSFont` and `chipNSFont` become computed too. Their AppKit owners, along with the
  note editor's `NSTextView` colors, subscribe with `Observations { ThemeStore.active.palette }`
  and reapply on change.

### Setting

- `AppSettings.theme: ThemeID`, default `.standard`, stored under the UserDefaults key
  `visualTheme`.
- `SettingsFileKey.visualTheme` as `appearance.visualTheme`, bound in `SettingsFileSchema`. The
  existing `appearance.theme` key already means System / Light / Dark and keeps that meaning.
  The existing picker labeled "Theme" is relabeled "Appearance". A theme grants no capability, so it is
  carried by settings backups.
- The General pane gets a Theme picker next to Appearance: a row of cards, each showing a still
  frame of that theme's backdrop and a sample row. Selecting one applies it live to any open
  palette, note or HUD.

## Surfaces

Every glass call site belongs to one of three roles:

| Role | Today | Used by |
|---|---|---|
| `panel` | `panelScrim` over `GlassEffectView`, then clip | palette root, notes window, quick action result, camera panels, both HUDs |
| `overlay` | `.glassEffect(.regular)` | popover menus, dialogs, note switcher and heading menu, shortcut callout, chat cards |
| `control` | `.frosted(in:)` | action capsule, menu circle, formatting bar, chat pills |

`SurfaceStyle` cases:

- `.glass`: today's recipe for that role, modifier for modifier.
- `.tintedGlass(ColorPair)`: `glassEffect(.regular.tint(...))`, interactive for `control`.
- `.solid(fill: ColorPair or gradient, stroke: ColorPair, glow: Bool)`: opaque or near-opaque
  fill, a hairline edge, and the theme glow when `glow` is true.

One modifier, `View.themedSurface(_ role:, in shape:)`, in `DesignSystem/`, replaces every call
site. `frosted(in:)` becomes `themedSurface(.control, in:)`. For Default it emits exactly
today's chain. Under Reduce Transparency, `.tintedGlass` renders as `.solid`.

Extensions keep their four glass call sites inside `Features/Extensions/`. They read
`Theme.Surfaces` and render it with their own `extensionSurface(_:in:)`, a deliberate duplicate
of `themedSurface` per the extension rule. Extensions get no backdrop and no glow of their own.

## Backdrops

Only the `panel` role draws a backdrop. Layer order, back to front: surface fill, backdrop at
`backdropIntensity`, the theme's `panelScrim`, content, then the clip (still last).

Each kind is one view in `DesignSystem/Theming/Backdrops/`:

- `GridBackdrop` (Tron): a perspective floor grid with a few light traces travelling along the
  lines and turning at right angles.
- `CodeRainBackdrop` (Matrix): columns of falling katakana and digits with a bright head and a
  fading tail.
- `SunsetBackdrop` (Synthwave): a banded sun above a horizon and a grid scrolling toward the
  viewer.
- `ScanlineBackdrop` (Amber): fixed scanlines, a slow vignette breathing, rare faint flicker.
  The light variant is paper grain without flicker.

Rules for every backdrop:

- `TimelineView(.animation(minimumInterval: 1.0 / frameRate, paused: ...))` around a `Canvas`; the
  frame rate is per backdrop (`Backdrop.frameRate`).
- Paused when the window is hidden or occluded (each backdrop watches its own window's
  `didChangeOcclusionStateNotification`), and under Reduce Motion, where it draws one still
  frame.
- Stateless per frame: every glyph, trace and column position is a pure function of time and a
  fixed integer hash, so nothing is stored or allocated between frames.
- Glyphs are resolved once as `Canvas` symbols and reused.
- Budget while the palette is visible: zero CPU while hidden (hard rule); roughly 5-8% of one core while visible
  (target, Devon 2026-10-12); under 8 MB extra resident memory. Measured with `Signposts` and the recipes in
  `docs/testing.md` before a backdrop is considered done.

## Glow

`Theme.Effects.glowRadius` is 0 in Default. When non-zero, glow is a `.shadow` on a stroked shape
in two places: the panel edge stroke and the selected-row fill. The search field has no outline
of its own to glow, so it only takes the theme's ink and display face. Text is never blurred. Today each of 14 lists computes its own selection and hover fill; they
move to one shared `RowHighlight` view, which is where the selection glow is drawn.

## Secondary text

Most secondary and tertiary text uses SwiftUI's hierarchical `.secondary` and `.tertiary`
styles, which derive from the current foreground style. The panel surface sets the foreground to
`Theme.Colors.textPrimary` for non-Default themes, so those 170 call sites follow the theme ink
without being edited. Default does not set it, so Default renders exactly as today.

## Fonts

Bundled under `Tinycast/Resources/Fonts/`, each with its `OFL.txt`, and registered through
`ATSApplicationFontsPath` in `Info.plist`. Typography tokens use `Font.custom(_:size:relativeTo:)`
so Dynamic Type still scales them.

| Theme | Display (search field, titles, section headers) | Body and rows | Code |
|---|---|---|---|
| Default | SF Pro (unchanged) | SF Pro | SF Mono |
| Tron | Orbitron | Exo 2 | SF Mono |
| Matrix | Share Tech Mono | Share Tech Mono | Share Tech Mono |
| Synthwave | Audiowide | SF Pro Rounded | SF Mono |
| Amber | VT323 | IBM Plex Mono | IBM Plex Mono |

A missing or failed font falls back to the Default role for that token, never to a blank label.

## The themes

Hex values are starting points, tuned by eye during implementation over light and dark wallpaper.

**Tron Legacy.** Dark: surface `#05080C`, ink `#DFF6FF`, accent cyan `#6FE3FF`, warning and
destructive orange `#FF9A3C`, glow cyan radius 8. Light: surface `#EAF4F8`, ink `#0B2633`, accent
`#0086B3`, glow radius 3. Panel and overlay `.solid` with glow, control `.tintedGlass` cyan.
Backdrop: grid.

**Matrix.** Dark: surface `#000300`, ink `#B8FFC4`, accent `#00FF41`, glow green radius 6.
Light: surface `#EEF7EE`, ink `#0A3D12`, accent `#00802B`, rain at low intensity. All three roles
`.solid`. Backdrop: code rain.

**Synthwave.** Dark: surface gradient `#1A0B2E` to `#2D0B3A`, ink `#FCE7FF`, accent pink
`#FF3EA5`, secondary cyan `#2DE2E6`, glow pink radius 8. Light: gradient `#FFF0F8` to `#FFE3D3`,
ink `#3A0D4A`, accent `#D1007A`. Panel `.solid` gradient, overlay and control `.tintedGlass`.
Backdrop: sunset grid.

**Amber CRT.** Dark: surface `#0E0800`, ink `#FFB000`, accent `#FFCC66`, glow amber radius 4.
Light: paper `#F6EEDC`, ink `#3B2500`, accent `#B36B00`, no glow. All roles `.solid`. Backdrop:
scanlines.

## Accessibility

- Every theme, in both variants, must give `textPrimary` at least 4.5:1 and `textSecondary` at
  least 3:1 against its surface composited with the backdrop at full intensity. The harness
  enforces this.
- Reduce Motion: still backdrop. Reduce Transparency: no tinted glass. Increase Contrast: glow
  off and `separator` and `border` raised to the `textTertiary` stop.
- Theme cards in Settings carry an accessibility label with the theme name.

## Testing

- Extend `Tests/appearance-test.swift`: Default's dark values still equal the shipped literals
  with the store active, and every Default surface role resolves to `.glass`.
- New `Tests/theme-test.swift`: every `ThemeID` has a definition with every token filled; the
  contrast rules above hold for all themes and variants; every bundled font named in a
  definition has a file in `Resources/Fonts/` and a license next to it; the settings round trip
  for `theme` works.
- Backdrop performance measured per backdrop and recorded in the PR.
- Visual sign-off by Devon for each theme, over a light and a dark wallpaper, in both variants.
- The standard definition of done in `docs/testing.md` applies to every PR.

## Delivery

Each step is its own PR, and the first three change nothing visible.

1. Token consolidation: move the roughly 70 non-hierarchical color and font literals on themed
   surfaces (system orange, red, green, accent and white; text-style fonts; AppKit link colors
   and fonts) into `Theme` tokens.
2. Theme model, `ThemeStore`, computed tokens, the setting and schema key, with Default only.
3. Surface roles: `themedSurface`, call-site migration, the Extensions copy.
4. Font bundling and typography roles.
5. Tron: palette, grid backdrop, glow, and the Settings picker. First visible change.
6. Matrix. 7. Synthwave. 8. Amber CRT.

Each PR updates the docs it makes wrong: `docs/ui.md` (themes as the documented exception,
`themedSurface`), `docs/architecture.md` (`ThemeStore` and its static handle),
`docs/features/settings-file.md`, and a new `docs/features/theming.md` that opens with these
invariants:

- Default is today's look and Default Dark's literals are frozen.
- A view never styles itself for a theme; it reads tokens and `themedSurface`.
- Backdrops pause when hidden or under Reduce Motion, and stay inside the stated budget.

## Risks

- Upstream syncs: steps 1 to 3 touch many files and will conflict with upstream changes in the
  same views. Landing them quickly, one after another, keeps the conflict window short. Offering
  them upstream would remove the problem.
- Display fonts change text widths; fixed-width menus and the search field may need per-font
  checks during visual sign-off.
- A busy backdrop can hurt readability even when contrast passes; `backdropIntensity` per theme
  and variant is the control for that.
