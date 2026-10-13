import Foundation

enum ThemeCatalog {
    static func definition(for id: ThemeID) -> ThemeDefinition {
        switch id {
        case .standard: standard
        case .tron: tron
        case .matrix: matrix
        case .synthwave: synthwave
        }
    }

    /// Today's look: white ink over a dark scrim, black over a light one, system roles throughout.
    static let standard = ThemeDefinition(
        id: .standard,
        ink: RGBAPair(dark: .gray(1), light: .gray(0)),
        surface: RGBAPair(dark: .gray(0), light: .gray(1)),
        roles: ThemeRoles(
            accent: .system(.accent), onAccent: .system(.white), primaryAction: .system(.blue),
            destructive: .system(.red), success: .system(.green), warning: .system(.orange),
            progress: .system(.blue), link: .system(.link), highlight: .system(.yellow)),
        overrides: [:],
        surfaces: .glass,
        backdrop: .none,
        glow: .none,
        faces: .system)
}
