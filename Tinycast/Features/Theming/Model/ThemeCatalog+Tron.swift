import Foundation

extension ThemeCatalog {
    private static let tronCyan = RGBAPair(dark: RGBA(hex: 0x6FE3FF), light: RGBA(hex: 0x0086B3))

    static let tron = ThemeDefinition(
        id: .tron,
        ink: RGBAPair(dark: RGBA(hex: 0xDFF6FF), light: RGBA(hex: 0x0B2633)),
        surface: RGBAPair(dark: RGBA(hex: 0x05080C), light: RGBA(hex: 0xEAF4F8)),
        roles: ThemeRoles(
            accent: .rgba(tronCyan),
            onAccent: .rgba(RGBAPair(dark: RGBA(hex: 0x05080C), light: .gray(1))),
            primaryAction: .rgba(tronCyan),
            destructive: .rgba(RGBAPair(dark: RGBA(hex: 0xFF9A3C), light: RGBA(hex: 0xC2410C))),
            success: .rgba(RGBAPair(dark: RGBA(hex: 0x7CFFCB), light: RGBA(hex: 0x047857))),
            warning: .rgba(RGBAPair(dark: RGBA(hex: 0xFFB86B), light: RGBA(hex: 0xB45309))),
            progress: .rgba(tronCyan),
            link: .rgba(tronCyan),
            highlight: .rgba(tronCyan)),
        overrides: [
            .windowSurface: .surface(dark: 1, light: 1),
            .terminalSurface: .surface(dark: 1, light: 1),
            .roomCardFill: .surface(dark: 0.94, light: 0.94),
            .chatText: .ink(dark: 1, light: 1),
            .syntaxKeyword: .fixed(.hex(dark: 0x6FE3FF, light: 0x006B8F)),
            .syntaxString: .fixed(.hex(dark: 0xFF9A3C, light: 0xA33A0A)),
            .syntaxNumber: .fixed(.hex(dark: 0xFFE08A, light: 0x7A5200)),
            .syntaxComment: .fixed(.hex(dark: 0x8FA8B7, light: 0x526C79)),
            .syntaxType: .fixed(.hex(dark: 0x7CFFCB, light: 0x04694C)),
            .syntaxFunction: .fixed(.hex(dark: 0xB8EEFF, light: 0x0B4F66)),
            .syntaxConstant: .fixed(.hex(dark: 0xFFB86B, light: 0x8F3A0E)),
            .syntaxAttribute: .fixed(.hex(dark: 0xFFC48A, light: 0x8A4A1A)),
            .syntaxProperty: .fixed(.hex(dark: 0x9FD8F0, light: 0x2C6E85)),
            .syntaxInserted: .fixed(.hex(dark: 0x7CFFCB, light: 0x04694C)),
            .syntaxDeleted: .fixed(.hex(dark: 0xFF7E5E, light: 0xB3261E)),
        ],
        surfaces: ThemeSurfaces(
            panel: .solid(
                fill: .color(RGBAPair(dark: RGBA(hex: 0x05080C), light: RGBA(hex: 0xEAF4F8))),
                stroke: RGBAPair(dark: RGBA(hex: 0x6FE3FF, alpha: 0.55), light: RGBA(hex: 0x0086B3, alpha: 0.45)),
                glows: true),
            overlay: .solid(
                fill: .color(RGBAPair(dark: RGBA(hex: 0x0A1118), light: RGBA(hex: 0xF4FAFC))),
                stroke: RGBAPair(dark: RGBA(hex: 0x6FE3FF, alpha: 0.45), light: RGBA(hex: 0x0086B3, alpha: 0.35)),
                glows: true),
            control: .tintedGlass(
                RGBAPair(dark: RGBA(hex: 0x6FE3FF, alpha: 0.25), light: RGBA(hex: 0x0086B3, alpha: 0.18)))),
        backdrop: Backdrop(
            kind: .grid, primary: tronCyan,
            secondary: RGBAPair(dark: RGBA(hex: 0xFF9A3C), light: RGBA(hex: 0xC2410C)),
            tertiary: tronCyan,
            intensity: .init(dark: 0.55, light: 0.35), speed: 1, frameRate: 30, lightIsStatic: false),
        glow: Glow(
            color: RGBAPair(dark: RGBA(hex: 0x6FE3FF, alpha: 0.8), light: RGBA(hex: 0x0086B3, alpha: 0.5)),
            radius: .init(dark: 8, light: 3)),
        faces: ThemeFaces(display: .bundled(.orbitron), body: .bundled(.exo2), mono: .system(.monospaced)))
}
