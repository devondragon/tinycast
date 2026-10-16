import Foundation

extension ThemeCatalog {
    private static let synthPink = RGBAPair(dark: RGBA(hex: 0xFF3EA5), light: RGBA(hex: 0xD1007A))
    private static let synthCyan = RGBAPair(dark: RGBA(hex: 0x2DE2E6), light: RGBA(hex: 0x00838A))

    static let synthwave = ThemeDefinition(
        id: .synthwave,
        ink: RGBAPair(dark: RGBA(hex: 0xFCE7FF), light: RGBA(hex: 0x3A0D4A)),
        surface: RGBAPair(dark: RGBA(hex: 0x1A0B2E), light: RGBA(hex: 0xFFF0F8)),
        roles: ThemeRoles(
            accent: .rgba(synthPink),
            onAccent: .rgba(RGBAPair(dark: RGBA(hex: 0x1A0B2E), light: .gray(1))),
            primaryAction: .rgba(synthPink),
            destructive: .rgba(RGBAPair(dark: RGBA(hex: 0xFF6B6B), light: RGBA(hex: 0xC81E1E))),
            success: .rgba(synthCyan),
            warning: .rgba(RGBAPair(dark: RGBA(hex: 0xFFD319), light: RGBA(hex: 0x9A6B00))),
            progress: .rgba(synthCyan),
            link: .rgba(synthCyan),
            highlight: .rgba(RGBAPair(dark: RGBA(hex: 0xFFD319), light: RGBA(hex: 0xFFB000)))),
        overrides: [
            .windowSurface: .surface(dark: 1, light: 1),
            .terminalSurface: .surface(dark: 1, light: 1),
            .roomCardFill: .surface(dark: 0.94, light: 0.94),
            .chatText: .ink(dark: 1, light: 1),
            .syntaxKeyword: .fixed(.hex(dark: 0xFEDE5D, light: 0x8F5A00)),
            .syntaxString: .fixed(.hex(dark: 0xFF9C57, light: 0xA34700)),
            .syntaxNumber: .fixed(.hex(dark: 0xFA9C92, light: 0xB3261E)),
            .syntaxComment: .fixed(.hex(dark: 0xB7AFD5, light: 0x6E5A80)),
            .syntaxType: .fixed(.hex(dark: 0xFF8DDF, light: 0xA3005E)),
            .syntaxFunction: .fixed(.hex(dark: 0x36F9F6, light: 0x00707A)),
            .syntaxConstant: .fixed(.hex(dark: 0xFA9C92, light: 0xB3261E)),
            .syntaxAttribute: .fixed(.hex(dark: 0xC9B0FF, light: 0x6A2FA0)),
            .syntaxProperty: .fixed(.hex(dark: 0x72F1B8, light: 0x1F6E52)),
            .syntaxInserted: .fixed(.hex(dark: 0x72F1B8, light: 0x1E7448)),
            .syntaxDeleted: .fixed(.hex(dark: 0xFE989F, light: 0xC81E1E)),
        ],
        surfaces: ThemeSurfaces(
            panel: .solid(
                fill: .verticalGradient(
                    top: RGBAPair(dark: RGBA(hex: 0x1A0B2E), light: RGBA(hex: 0xFFF0F8)),
                    bottom: RGBAPair(dark: RGBA(hex: 0x2D0B3A), light: RGBA(hex: 0xFFE3D3))),
                stroke: RGBAPair(dark: RGBA(hex: 0xFF3EA5, alpha: 0.5), light: RGBA(hex: 0xD1007A, alpha: 0.4)),
                glows: true),
            overlay: .tintedGlass(
                RGBAPair(dark: RGBA(hex: 0x2D0B3A, alpha: 0.55), light: RGBA(hex: 0xFFE3F0, alpha: 0.5))),
            control: .tintedGlass(
                RGBAPair(dark: RGBA(hex: 0xFF3EA5, alpha: 0.30), light: RGBA(hex: 0xD1007A, alpha: 0.18)))),
        backdrop: Backdrop(
            kind: .sunsetGrid, primary: synthPink, secondary: synthCyan,
            tertiary: RGBAPair(dark: RGBA(hex: 0xFFD319), light: RGBA(hex: 0xFF9E3D)),
            intensity: .init(dark: 0.6, light: 0.35), speed: 1, frameRate: 30, lightIsStatic: false),
        glow: Glow(
            color: RGBAPair(dark: RGBA(hex: 0xFF3EA5, alpha: 0.8), light: RGBA(hex: 0xD1007A, alpha: 0.45)),
            radius: .init(dark: 8, light: 3)),
        faces: ThemeFaces(display: .bundled(.audiowide), body: .system(.rounded), mono: .system(.monospaced)))
}
