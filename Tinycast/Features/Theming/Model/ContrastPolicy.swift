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

    /// A code token over a card, on the worst pixel and on the bare window page.
    static func minimumCardContrast(_ color: RGBA, _ theme: ThemeDefinition, dark: Bool) -> Double {
        let card = theme.ink.value(dark: dark).with(alpha: theme.inkAlpha(.cardFill, dark: dark))
        return (backgrounds(theme, dark: dark) + [theme.surface.value(dark: dark)])
            .map { over(card, $0) }
            .map { ratio(over(color, $0), $0) }
            .min() ?? 1
    }

    /// CIE76 distance, enough to tell two token inks apart at a glance.
    static func distance(_ first: RGBA, _ second: RGBA) -> Double {
        let (a, b) = (lab(first), lab(second))
        return ((a.0 - b.0) * (a.0 - b.0) + (a.1 - b.1) * (a.1 - b.1) + (a.2 - b.2) * (a.2 - b.2)).squareRoot()
    }

    private static func lab(_ color: RGBA) -> (Double, Double, Double) {
        func linear(_ c: Double) -> Double { c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4) }
        let (r, g, b) = (linear(color.red), linear(color.green), linear(color.blue))
        let x = (0.4124 * r + 0.3576 * g + 0.1805 * b) / 0.95047
        let y = 0.2126 * r + 0.7152 * g + 0.0722 * b
        let z = (0.0193 * r + 0.1192 * g + 0.9505 * b) / 1.08883
        func f(_ t: Double) -> Double { t > 216.0 / 24389 ? pow(t, 1.0 / 3) : (24389.0 / 27 * t + 16) / 116 }
        return (116 * f(y) - 16, 500 * (f(x) - f(y)), 200 * (f(y) - f(z)))
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
