import AppKit
import SwiftUI

/// One theme resolved to SwiftUI colors, once per switch rather than per render.
@MainActor
struct ThemePalette {
    let definition: ThemeDefinition
    private let colors: [ColorToken: Color]

    init(_ definition: ThemeDefinition) {
        self.definition = definition
        colors = Dictionary(
            uniqueKeysWithValues: ColorToken.allCases.map {
                ($0, Self.resolve(definition.recipe(for: $0), token: $0, in: definition))
            })
    }

    func color(_ token: ColorToken) -> Color { colors[token]! }

    static func color(_ pair: RGBAPair) -> Color {
        Theme.Colors.adaptive(dark: nsColor(pair.dark), light: nsColor(pair.light))
    }

    private static func resolve(_ recipe: ColorRecipe, token: ColorToken, in theme: ThemeDefinition) -> Color {
        switch recipe {
        case .ink(let dark, let light):
            return tinted(theme.ink, dark: dark, light: light)
        case .surface(let dark, let light):
            return tinted(theme.surface, dark: dark, light: light)
        case .fixed(let pair):
            return pair.dark == pair.light ? Color(nsColor: nsColor(pair.dark)) : color(pair)
        case .role(let role, let dark, let light):
            switch theme.roles.color(for: role) {
            case .system(let system): return withAlpha(systemColor(system), dark: dark, light: light)
            case .rgba(let pair): return tinted(pair, dark: dark, light: light)
            }
        case .system(let system, let dark, let light):
            return withAlpha(systemColor(system), dark: dark, light: light)
        }
    }

    private static func tinted(_ pair: RGBAPair, dark: Double, light: Double) -> Color {
        Theme.Colors.adaptive(
            dark: nsColor(pair.dark.with(alpha: pair.dark.alpha * dark)),
            light: nsColor(pair.light.with(alpha: pair.light.alpha * light)))
    }

    /// Full alpha returns the system color itself, so Default's roles stay the exact same values.
    private static func withAlpha(_ color: Color, dark: Double, light: Double) -> Color {
        if dark == 1, light == 1 { return color }
        if dark == light { return color.opacity(dark) }
        let ns = NSColor(color)
        return Theme.Colors.adaptive(
            dark: ns.withAlphaComponent(dark), light: ns.withAlphaComponent(light))
    }

    private static func systemColor(_ system: SystemColor) -> Color {
        switch system {
        case .accent: .accentColor
        case .blue: .blue
        case .red: .red
        case .green: .green
        case .orange: .orange
        case .yellow: Color(nsColor: .systemYellow)
        case .link: Color(nsColor: .linkColor)
        case .windowBackground: Color(nsColor: .windowBackgroundColor)
        case .white: .white
        }
    }

    static func nsColor(_ value: RGBA) -> NSColor {
        NSColor(srgbRed: value.red, green: value.green, blue: value.blue, alpha: value.alpha)
    }
}
