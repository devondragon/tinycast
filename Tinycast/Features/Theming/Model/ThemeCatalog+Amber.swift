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
            .chatText: .ink(dark: 1, light: 1),
            .syntaxKeyword: .fixed(.hex(dark: 0xFFE08A, light: 0x8F3300)),
            .syntaxString: .fixed(.hex(dark: 0xFF8C3A, light: 0x8A5A00)),
            .syntaxNumber: .fixed(.hex(dark: 0xFFD24D, light: 0x5E5A00)),
            .syntaxComment: .fixed(.hex(dark: 0xAF853F, light: 0x7A6440)),
            .syntaxType: .fixed(.hex(dark: 0xFFDCA8, light: 0x7A3A2A)),
            .syntaxFunction: .fixed(.hex(dark: 0xFFCC66, light: 0x5A3A00)),
            .syntaxConstant: .fixed(.hex(dark: 0xFF9E57, light: 0x9A4A10)),
            .syntaxAttribute: .fixed(.hex(dark: 0xE8A040, light: 0x7A4A1A)),
            .syntaxProperty: .fixed(.hex(dark: 0xF0B860, light: 0x4A3210)),
            .syntaxInserted: .fixed(.hex(dark: 0xC8E07A, light: 0x4D6B00)),
            .syntaxDeleted: .fixed(.hex(dark: 0xFF6A3D, light: 0xB3261E)),
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
