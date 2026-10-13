import Foundation

extension ThemeCatalog {
    private static let amberInk = RGBAPair(dark: RGBA(hex: 0xFFB000), light: RGBA(hex: 0x3B2500))
    private static let amberAccent = RGBAPair(dark: RGBA(hex: 0xFFCC66), light: RGBA(hex: 0xB36B00))

    static let amber = ThemeDefinition(
        id: .amber,
        ink: amberInk,
        surface: RGBAPair(dark: RGBA(hex: 0x0E0800), light: RGBA(hex: 0xF6EEDC)),
        roles: ThemeRoles(
            accent: .rgba(amberAccent),
            onAccent: .rgba(RGBAPair(dark: RGBA(hex: 0x0E0800), light: .gray(1))),
            primaryAction: .rgba(amberAccent),
            destructive: .rgba(RGBAPair(dark: RGBA(hex: 0xFF6A3D), light: RGBA(hex: 0xA3360F))),
            success: .rgba(RGBAPair(dark: RGBA(hex: 0xC8E07A), light: RGBA(hex: 0x4D6B00))),
            warning: .rgba(RGBAPair(dark: RGBA(hex: 0xFFE08A), light: RGBA(hex: 0x8A5A00))),
            progress: .rgba(amberAccent),
            link: .rgba(RGBAPair(dark: RGBA(hex: 0xFFCC66), light: RGBA(hex: 0x8A4F00))),
            highlight: .rgba(RGBAPair(dark: RGBA(hex: 0xFFCC66), light: RGBA(hex: 0xE8B04A)))),
        overrides: [
            .windowSurface: .surface(dark: 1, light: 1),
            .terminalSurface: .surface(dark: 1, light: 1),
            .roomCardFill: .surface(dark: 0.94, light: 0.94),
        ],
        surfaces: ThemeSurfaces(
            panel: .solid(
                fill: .color(RGBAPair(dark: RGBA(hex: 0x0E0800), light: RGBA(hex: 0xF6EEDC))),
                stroke: RGBAPair(dark: RGBA(hex: 0xFFB000, alpha: 0.35), light: RGBA(hex: 0x3B2500, alpha: 0.25)),
                glows: true),
            overlay: .solid(
                fill: .color(RGBAPair(dark: RGBA(hex: 0x140C00), light: RGBA(hex: 0xFBF5E8))),
                stroke: RGBAPair(dark: RGBA(hex: 0xFFB000, alpha: 0.3), light: RGBA(hex: 0x3B2500, alpha: 0.2)),
                glows: true),
            control: .solid(
                fill: .color(RGBAPair(dark: RGBA(hex: 0x1E1200), light: RGBA(hex: 0xEFE3C8))),
                stroke: RGBAPair(dark: RGBA(hex: 0xFFB000, alpha: 0.4), light: RGBA(hex: 0x3B2500, alpha: 0.3)),
                glows: false)),
        backdrop: Backdrop(
            kind: .scanlines, primary: amberInk,
            secondary: RGBAPair(dark: .gray(0), light: RGBA(hex: 0x3B2500)),
            tertiary: amberAccent,
            intensity: .init(dark: 0.4, light: 0.3), speed: 1, frameRate: 30, lightIsStatic: true),
        glow: Glow(
            color: RGBAPair(dark: RGBA(hex: 0xFFB000, alpha: 0.6), light: .gray(0, alpha: 0)),
            radius: .init(dark: 4, light: 0)),
        faces: ThemeFaces(display: .bundled(.vt323), body: .bundled(.ibmPlexMono), mono: .bundled(.ibmPlexMono)))
}
