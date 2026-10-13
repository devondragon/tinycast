import Foundation

/// The built-in looks; a case lands with the PR that ships its theme.
enum ThemeID: String, CaseIterable, Identifiable, Sendable {
    case standard
    case tron
    case matrix

    var id: String { rawValue }

    var title: String {
        switch self {
        case .standard: "Default"
        case .tron: "Tron Legacy"
        case .matrix: "Matrix"
        }
    }
}

/// A macOS color named rather than copied, so it follows the system accent and appearance.
enum SystemColor: Sendable {
    case accent, blue, red, green, orange, yellow, link, windowBackground, white
}

enum ThemeColor: Equatable, Sendable {
    case system(SystemColor)
    case rgba(RGBAPair)
}

enum ThemeRole: Sendable {
    case accent, onAccent, primaryAction, destructive, success, warning, progress, link, highlight
}

/// Stored, not a dictionary, so a theme missing a role does not compile.
struct ThemeRoles: Equatable, Sendable {
    let accent: ThemeColor
    let onAccent: ThemeColor
    let primaryAction: ThemeColor
    let destructive: ThemeColor
    let success: ThemeColor
    let warning: ThemeColor
    let progress: ThemeColor
    let link: ThemeColor
    let highlight: ThemeColor

    func color(for role: ThemeRole) -> ThemeColor {
        switch role {
        case .accent: accent
        case .onAccent: onAccent
        case .primaryAction: primaryAction
        case .destructive: destructive
        case .success: success
        case .warning: warning
        case .progress: progress
        case .link: link
        case .highlight: highlight
        }
    }
}

enum SurfaceRole: CaseIterable, Sendable {
    /// A borderless window's whole body: palette, note, HUD, quick action result, camera.
    case panel
    /// Something floating over a panel: menus, dialogs, callouts, chat cards.
    case overlay
    /// A floating control: the action capsule, the menu circle, pills.
    case control
}

enum SurfaceFill: Equatable, Sendable {
    case color(RGBAPair)
    case verticalGradient(top: RGBAPair, bottom: RGBAPair)
}

enum SurfaceStyle: Equatable, Sendable {
    /// The call site's own Liquid Glass, untouched.
    case glass
    case tintedGlass(RGBAPair)
    case solid(fill: SurfaceFill, stroke: RGBAPair, glows: Bool)
}

struct ThemeSurfaces: Equatable, Sendable {
    let panel: SurfaceStyle
    let overlay: SurfaceStyle
    let control: SurfaceStyle

    static let glass = ThemeSurfaces(panel: .glass, overlay: .glass, control: .glass)

    func style(for role: SurfaceRole) -> SurfaceStyle {
        switch role {
        case .panel: panel
        case .overlay: overlay
        case .control: control
        }
    }
}

enum BackdropKind: Sendable {
    case none, grid, codeRain, sunsetGrid, scanlines
}

struct Backdrop: Equatable, Sendable {
    let kind: BackdropKind
    let primary: RGBAPair
    let secondary: RGBAPair
    let tertiary: RGBAPair
    /// How strongly the backdrop shows through the scrim, per appearance.
    let intensity: RGBAPair.Scalar
    /// 1 is the backdrop's designed pace.
    let speed: Double
    /// Timeline frames per second while visible.
    let frameRate: Double
    /// Light variants that are texture rather than motion skip the timeline entirely.
    let lightIsStatic: Bool

    static let none = Backdrop(
        kind: .none, primary: .both(.gray(0)), secondary: .both(.gray(0)), tertiary: .both(.gray(0)),
        intensity: .init(dark: 0, light: 0), speed: 0, frameRate: 30, lightIsStatic: true)

    var colors: [RGBAPair] { [primary, secondary, tertiary] }
}

extension RGBAPair {
    /// A plain number per appearance, for intensities and radii.
    struct Scalar: Equatable, Sendable {
        let dark: Double
        let light: Double

        func value(dark isDark: Bool) -> Double { isDark ? dark : light }
    }
}

struct Glow: Equatable, Sendable {
    let color: RGBAPair
    let radius: RGBAPair.Scalar

    static let none = Glow(color: .both(.gray(0, alpha: 0)), radius: .init(dark: 0, light: 0))
}

enum FontRole: Sendable {
    /// Search field, titles, section headers, headings.
    case display
    /// Rows, menus, labels, captions.
    case body
    case mono
}

enum SystemDesign: Sendable {
    case standard, monospaced, rounded, serif
}

/// Every font Tinycast bundles, with the file it ships in and the license beside it.
enum BundledFont: CaseIterable, Sendable {
    case orbitron, exo2, shareTechMono, audiowide, vt323, ibmPlexMono

    var family: String {
        switch self {
        case .orbitron: "Orbitron"
        case .exo2: "Exo 2"
        case .shareTechMono: "Share Tech Mono"
        case .audiowide: "Audiowide"
        case .vt323: "VT323"
        case .ibmPlexMono: "IBM Plex Mono"
        }
    }

    var files: [String] {
        switch self {
        case .orbitron: ["Orbitron[wght].ttf"]
        case .exo2: ["Exo2[wght].ttf"]
        case .shareTechMono: ["ShareTechMono-Regular.ttf"]
        case .audiowide: ["Audiowide-Regular.ttf"]
        case .vt323: ["VT323-Regular.ttf"]
        case .ibmPlexMono:
            ["IBMPlexMono-Regular.ttf", "IBMPlexMono-Medium.ttf", "IBMPlexMono-SemiBold.ttf",
             "IBMPlexMono-Bold.ttf"]
        }
    }

    var license: String { "\(family.replacingOccurrences(of: " ", with: ""))-OFL.txt" }
}

enum FontFace: Equatable, Sendable {
    case system(SystemDesign)
    case bundled(BundledFont)
}

struct ThemeFaces: Equatable, Sendable {
    let display: FontFace
    let body: FontFace
    let mono: FontFace

    static let system = ThemeFaces(
        display: .system(.standard), body: .system(.standard), mono: .system(.monospaced))

    func face(for role: FontRole) -> FontFace {
        switch role {
        case .display: display
        case .body: body
        case .mono: mono
        }
    }
}

struct ThemeDefinition: Sendable {
    let id: ThemeID
    let ink: RGBAPair
    let surface: RGBAPair
    let roles: ThemeRoles
    let overrides: [ColorToken: ColorRecipe]
    let surfaces: ThemeSurfaces
    let backdrop: Backdrop
    let glow: Glow
    let faces: ThemeFaces

    func recipe(for token: ColorToken) -> ColorRecipe { overrides[token] ?? token.baseRecipe }

    /// The alpha an ink token is drawn at; tokens not on the ramp count as solid.
    func inkAlpha(_ token: ColorToken, dark: Bool) -> Double {
        guard case .ink(let darkAlpha, let lightAlpha) = recipe(for: token) else { return 1 }
        return dark ? darkAlpha : lightAlpha
    }
}
