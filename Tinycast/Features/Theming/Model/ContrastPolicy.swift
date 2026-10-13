import Foundation

/// WCAG contrast over the worst pixel text can sit on: surface, backdrop at full intensity, scrim.
enum ContrastPolicy {
    static func ratio(_ first: RGBA, _ second: RGBA) -> Double {
        let (a, b) = (luminance(first), luminance(second))
        return (max(a, b) + 0.05) / (min(a, b) + 0.05)
    }

    static func minimumTextContrast(_ theme: ThemeDefinition, dark: Bool, inkAlpha: Double) -> Double {
        backgrounds(theme, dark: dark)
            .map { ratio(over(theme.ink.value(dark: dark).with(alpha: inkAlpha), $0), $0) }
            .min() ?? 1
    }

    /// Each surface stop, alone and under each backdrop color, then under the panel scrim.
    private static func backgrounds(_ theme: ThemeDefinition, dark: Bool) -> [RGBA] {
        let bases: [RGBA]
        switch theme.surfaces.panel {
        case .solid(.color(let fill), _, _): bases = [fill.value(dark: dark)]
        case .solid(.verticalGradient(let top, let bottom), _, _):
            bases = [top.value(dark: dark), bottom.value(dark: dark)]
        case .glass, .tintedGlass: bases = [theme.surface.value(dark: dark)]
        }
        let intensity = theme.backdrop.intensity.value(dark: dark)
        let marks = theme.backdrop.kind == .none ? [] : theme.backdrop.colors.map { $0.value(dark: dark) }
        let scrimAlpha: Double
        if case .surface(let darkAlpha, let lightAlpha) = theme.recipe(for: .panelScrim) {
            scrimAlpha = dark ? darkAlpha : lightAlpha
        } else {
            scrimAlpha = 0
        }
        let scrim = theme.surface.value(dark: dark).with(alpha: scrimAlpha)
        return bases.flatMap { base in
            [base] + marks.map { over($0.with(alpha: $0.alpha * intensity), base) }
        }
        .map { over(scrim, $0) }
    }

    /// Source-over onto an opaque color.
    static func over(_ top: RGBA, _ bottom: RGBA) -> RGBA {
        let a = top.alpha
        return RGBA(
            top.red * a + bottom.red * (1 - a), top.green * a + bottom.green * (1 - a),
            top.blue * a + bottom.blue * (1 - a))
    }

    private static func luminance(_ color: RGBA) -> Double {
        func linear(_ c: Double) -> Double { c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4) }
        return 0.2126 * linear(color.red) + 0.7152 * linear(color.green) + 0.0722 * linear(color.blue)
    }
}
