import Foundation

extension ThemeCatalog {
    private static let aresRed = RGBAPair(dark: RGBA(hex: 0xFF2D2D), light: RGBA(hex: 0xC4001A))

    static let ares = ThemeDefinition(
        id: .ares,
        ink: RGBAPair(dark: RGBA(hex: 0xFFE8E5), light: RGBA(hex: 0x2A0A0C)),
        surface: RGBAPair(dark: RGBA(hex: 0x070203), light: RGBA(hex: 0xF7EEEE)),
        roles: ThemeRoles(
            accent: .rgba(aresRed),
            onAccent: .rgba(RGBAPair(dark: RGBA(hex: 0x070203), light: .gray(1))),
            primaryAction: .rgba(aresRed),
            // Red is the accent, so destructive moves to orange to stay distinguishable.
            destructive: .rgba(RGBAPair(dark: RGBA(hex: 0xFF8C1A), light: RGBA(hex: 0xB34700))),
            success: .rgba(RGBAPair(dark: RGBA(hex: 0x5CFFB0), light: RGBA(hex: 0x047857))),
            warning: .rgba(RGBAPair(dark: RGBA(hex: 0xFFD23F), light: RGBA(hex: 0x9A6B00))),
            progress: .rgba(aresRed),
            link: .rgba(aresRed),
            highlight: .rgba(aresRed)),
        overrides: [
            .windowSurface: .surface(dark: 1, light: 1),
            .terminalSurface: .surface(dark: 1, light: 1),
            .roomCardFill: .surface(dark: 0.94, light: 0.94),
        ],
        surfaces: ThemeSurfaces(
            panel: .solid(
                fill: .color(RGBAPair(dark: RGBA(hex: 0x070203), light: RGBA(hex: 0xF7EEEE))),
                stroke: RGBAPair(dark: RGBA(hex: 0xFF2D2D, alpha: 0.6), light: RGBA(hex: 0xC4001A, alpha: 0.45)),
                glows: true),
            overlay: .solid(
                fill: .color(RGBAPair(dark: RGBA(hex: 0x120607), light: RGBA(hex: 0xFCF6F6))),
                stroke: RGBAPair(dark: RGBA(hex: 0xFF2D2D, alpha: 0.5), light: RGBA(hex: 0xC4001A, alpha: 0.35)),
                glows: true),
            control: .tintedGlass(
                RGBAPair(dark: RGBA(hex: 0xFF2D2D, alpha: 0.28), light: RGBA(hex: 0xC4001A, alpha: 0.18)))),
        backdrop: Backdrop(
            kind: .lightTrails, primary: aresRed,
            secondary: RGBAPair(dark: RGBA(hex: 0xFFE3DE), light: RGBA(hex: 0x5A0610)),
            tertiary: aresRed,
            intensity: .init(dark: 0.6, light: 0.35), speed: 1, frameRate: 30, lightIsStatic: false),
        glow: Glow(
            color: RGBAPair(dark: RGBA(hex: 0xFF2D2D, alpha: 0.85), light: RGBA(hex: 0xC4001A, alpha: 0.5)),
            radius: .init(dark: 9, light: 3)),
        faces: ThemeFaces(
            display: .bundled(.chakraPetch), body: .bundled(.chakraPetch), mono: .system(.monospaced)))
}
