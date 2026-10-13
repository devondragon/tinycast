import Foundation

extension ThemeCatalog {
    private static let matrixGreen = RGBAPair(dark: RGBA(hex: 0x00FF41), light: RGBA(hex: 0x00802B))

    static let matrix = ThemeDefinition(
        id: .matrix,
        ink: RGBAPair(dark: RGBA(hex: 0xB8FFC4), light: RGBA(hex: 0x0A3D12)),
        surface: RGBAPair(dark: RGBA(hex: 0x000300), light: RGBA(hex: 0xEEF7EE)),
        roles: ThemeRoles(
            accent: .rgba(matrixGreen),
            onAccent: .rgba(RGBAPair(dark: RGBA(hex: 0x000300), light: .gray(1))),
            primaryAction: .rgba(matrixGreen),
            destructive: .rgba(RGBAPair(dark: RGBA(hex: 0xFF5F56), light: RGBA(hex: 0xB91C1C))),
            success: .rgba(matrixGreen),
            warning: .rgba(RGBAPair(dark: RGBA(hex: 0xE6FF4F), light: RGBA(hex: 0x7A6A00))),
            progress: .rgba(matrixGreen),
            link: .rgba(matrixGreen),
            highlight: .rgba(matrixGreen)),
        overrides: [
            .windowSurface: .surface(dark: 1, light: 1),
            .terminalSurface: .surface(dark: 1, light: 1),
            .roomCardFill: .surface(dark: 0.94, light: 0.94),
        ],
        surfaces: ThemeSurfaces(
            panel: .solid(
                fill: .color(RGBAPair(dark: RGBA(hex: 0x000300), light: RGBA(hex: 0xEEF7EE))),
                stroke: RGBAPair(dark: RGBA(hex: 0x00FF41, alpha: 0.4), light: RGBA(hex: 0x00802B, alpha: 0.35)),
                glows: true),
            overlay: .solid(
                fill: .color(RGBAPair(dark: RGBA(hex: 0x020A04), light: RGBA(hex: 0xF6FBF6))),
                stroke: RGBAPair(dark: RGBA(hex: 0x00FF41, alpha: 0.35), light: RGBA(hex: 0x00802B, alpha: 0.3)),
                glows: true),
            control: .solid(
                fill: .color(RGBAPair(dark: RGBA(hex: 0x031206), light: RGBA(hex: 0xE3F1E3))),
                stroke: RGBAPair(dark: RGBA(hex: 0x00FF41, alpha: 0.5), light: RGBA(hex: 0x00802B, alpha: 0.4)),
                glows: false)),
        backdrop: Backdrop(
            kind: .codeRain, primary: matrixGreen,
            secondary: RGBAPair(dark: RGBA(hex: 0xB8FFC4), light: RGBA(hex: 0x0A3D12)),
            tertiary: RGBAPair(dark: RGBA(hex: 0x00802B), light: RGBA(hex: 0x6FBF7F)),
            intensity: .init(dark: 0.45, light: 0.18), speed: 1, frameRate: 24, lightIsStatic: false),
        glow: Glow(
            color: RGBAPair(dark: RGBA(hex: 0x00FF41, alpha: 0.7), light: RGBA(hex: 0x00802B, alpha: 0.4)),
            radius: .init(dark: 6, light: 2)),
        faces: ThemeFaces(
            display: .bundled(.shareTechMono), body: .bundled(.shareTechMono), mono: .bundled(.shareTechMono)))
}
