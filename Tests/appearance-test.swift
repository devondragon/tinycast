import AppKit
import SwiftUI

/// Pins `AGENTS.md`: a token's dark branch is the literal the forced-dark build shipped.
@main
@MainActor
struct AppearanceTests {
    static var failures = 0
    static var passes = 0

    static func check(_ label: String, _ ok: Bool, _ detail: String = "") {
        if ok {
            passes += 1
        } else {
            failures += 1
            print("FAIL  \(label)\(detail.isEmpty ? "" : ": \(detail)")")
        }
    }

    /// Quantized to the 8 bits that reach the framebuffer: `CGFloat`s carry Float error.
    static func components(_ color: Color, _ name: NSAppearance.Name) -> [Int] {
        var out: [Int] = []
        NSAppearance(named: name)!.performAsCurrentDrawingAppearance {
            let ns = NSColor(color).usingColorSpace(.sRGB)!
            out = [ns.redComponent, ns.greenComponent, ns.blueComponent, ns.alphaComponent]
                .map { Int(($0 * 255).rounded()) }
        }
        return out
    }

    static func dark(_ label: String, _ token: Color, is expected: Color) {
        let actual = components(token, .darkAqua)
        let wanted = components(expected, .darkAqua)
        check("dark \(label)", actual == wanted, "\(actual) != \(wanted)")
    }

    /// A token that resolves identically in both never adapted at all.
    static func adapts(_ label: String, _ token: Color) {
        check(
            "\(label) adapts", components(token, .darkAqua) != components(token, .aqua),
            "light resolves identically to dark")
    }

    static func main() {
        let c = Theme.Colors.self

        print("# dark branches are the shipped literals")
        dark("panelScrim", c.panelScrim, is: Color.black.opacity(0.4))
        dark("dialogDimming", c.dialogDimming, is: Color.black.opacity(0.34))
        dark("tooltipShadow", c.tooltipShadow, is: Color.black.opacity(0.18))
        dark("selection", c.selection, is: Color.white.opacity(0.10))
        dark("rowHover", c.rowHover, is: Color.white.opacity(0.05))
        dark("menuHover", c.menuHover, is: Color.white.opacity(0.10))
        dark("separator", c.separator, is: Color.white.opacity(0.10))
        dark("controlSurface", c.controlSurface, is: Color.white.opacity(0.10))
        dark("border", c.border, is: Color.white.opacity(0.20))
        dark("textSecondary", c.textSecondary, is: Color.white.opacity(0.60))
        dark("textTertiary", c.textTertiary, is: Color.white.opacity(0.40))
        dark("noteText", c.noteText, is: Color.white.opacity(0.90))
        dark("cardFill", c.cardFill, is: Color.white.opacity(0.05))
        dark("cardStroke", c.cardStroke, is: Color.white.opacity(0.10))
        dark("dropGuide", c.dropGuide, is: Color.white.opacity(0.35))
        dark("brand", c.brand, is: Color(red: 0.525, green: 0.231, blue: 1.0))

        print("# tokens that absorbed a literal duplicated across views")
        dark("iconPlaceholder", c.iconPlaceholder, is: Color.white.opacity(0.06))
        dark("sheen", c.sheen, is: Color.white.opacity(0.04))
        dark("textPrimary", c.textPrimary, is: Color.white)
        // VolumeHUDView draws white 0.85; textPrimary is alpha 1, so opacity must reproduce it.
        dark("textPrimary at 0.85", c.textPrimary.opacity(0.85), is: Color.white.opacity(0.85))

        print("# tokens that absorbed a system color from a view")
        dark("accent", c.accent, is: Color.accentColor)
        dark("onAccent", c.onAccent, is: Color.white)
        dark("link", c.link, is: Color(nsColor: .linkColor))

        print("# every surface token resolves per appearance")
        for (label, token) in [
            ("panelScrim", c.panelScrim), ("selection", c.selection), ("rowHover", c.rowHover),
            ("menuHover", c.menuHover), ("separator", c.separator),
            ("controlSurface", c.controlSurface), ("border", c.border),
            ("textPrimary", c.textPrimary), ("textSecondary", c.textSecondary),
            ("textTertiary", c.textTertiary), ("noteText", c.noteText), ("cardFill", c.cardFill),
            ("cardStroke", c.cardStroke), ("dropGuide", c.dropGuide),
            ("iconPlaceholder", c.iconPlaceholder), ("sheen", c.sheen)
        ] {
            adapts(label, token)
        }

        print("# the scrim inverts rather than ramping: it lightens the light surface")
        check("light scrim is white", components(c.panelScrim, .aqua)[0] == 255)
        check("dark scrim is black", components(c.panelScrim, .darkAqua)[0] == 0)

        print("# .system hands the choice back to AppKit")
        check("system is nil", AppAppearance.system.nsAppearance == nil)
        check("light is aqua", AppAppearance.light.nsAppearance?.isDark == false)
        check("dark is darkAqua", AppAppearance.dark.nsAppearance?.isDark == true)
        check("an unknown stored value is rejected", AppAppearance(rawValue: "sepia") == nil)

        print("# the store resolves Default from the catalog")
        let store = ThemeStore.active
        check("active theme is Default", store.id == .standard)
        check("re-applying Default is not a change", store.apply(.standard) == false)
        check("generation starts at zero", store.generation == 0)
        dark("palette selection", store.palette.color(.selection), is: Color.white.opacity(0.10))

        print("# a switch is visible to AppKit hosts")
        let before = ThemeStore.active.generation
        ThemeStore.active.apply(.standard)
        check("no-op apply keeps the generation", ThemeStore.active.generation == before)
        var builds = 0
        var derived = ThemeDerived { builds += 1 }
        derived.value
        derived.value
        check("a derived value is built once per generation", builds == 1, "built \(builds) times")

        print("# Default keeps the AppKit text faces")
        let text = InterfaceMetrics.standard.typography
        check("body text is the text style", text.textNSFont(.body) == .preferredFont(forTextStyle: .body))
        check(
            "headline text is the text style",
            text.textNSFont(.headline) == .preferredFont(forTextStyle: .headline))
        check(
            "a weighted text is the system face",
            text.textNSFont(.title2, weight: .semibold) == .systemFont(ofSize: 17, weight: .semibold))
        check(
            "monospaced text is the system mono face",
            text.textNSFont(.body, monospaced: true) == .monospacedSystemFont(ofSize: 13, weight: .regular))

        print("# a text style's implied weight reaches a themed face")
        let implied: [(NSFont.TextStyle, NSFont.Weight)] = [(.headline, .bold), (.caption2, .medium), (.body, .regular)]
        for (style, weight) in implied {
            let actual = ThemeFonts.impliedWeight(of: .preferredFont(forTextStyle: style))
            check("\(style.rawValue) implies \(weight.rawValue)", actual == weight, "got \(actual.rawValue)")
        }

        print("# Default keeps every surface on its own glass")
        for role in SurfaceRole.allCases {
            check("\(role) is glass", Theme.Surfaces.style(role) == .glass)
        }
        check("Default has no glow", Theme.Effects.glowRadius(dark: true) == 0)

        print("# a custom theme still adapts to Light and Dark")
        ThemeStore.active.apply(.tron)
        for token in [ColorToken.textPrimary, .selection, .panelScrim, .accent] {
            adapts("tron \(token)", ThemeStore.active.palette.color(token))
        }
        let plain = [NSAppearance(named: .aqua)!, NSAppearance(named: .darkAqua)!]
        let accessible = ["NSAppearanceNameAccessibilityAqua", "NSAppearanceNameAccessibilityDarkAqua"]
            .compactMap { NSAppearance(appearanceNamed: NSAppearance.Name($0), bundle: nil) }
        check("both accessibility appearances build", accessible.count == 2)
        check(
            "an accessibility appearance raises hairlines without the flag",
            accessible.allSatisfy { ThemePalette.raisesHairlines($0, increaseContrast: false) },
            accessible.map { "\($0.name.rawValue) \(String(describing: $0.bestMatch(from: [.aqua, .darkAqua, .accessibilityHighContrastAqua, .accessibilityHighContrastDarkAqua])))" }.joined(separator: "; "))
        let separator = Theme.Colors.separator
        nonisolated(unsafe) var offMain: CGFloat = 0
        nonisolated(unsafe) var ranOffMain = false
        let group = DispatchGroup()
        DispatchQueue.global().async(group: group) {
            ranOffMain = !Thread.isMainThread
            NSAppearance(named: .darkAqua)!.performAsCurrentDrawingAppearance {
                offMain = NSColor(separator).usingColorSpace(.sRGB)!.alphaComponent
            }
        }
        group.wait()
        check("the hairline probe ran off the main thread", ranOffMain)
        check("a themed hairline resolves off the main thread", offMain > 0)
        check(
            "the flag raises hairlines on a plain appearance",
            plain.allSatisfy { ThemePalette.raisesHairlines($0, increaseContrast: true) })
        check(
            "plain appearances do not raise hairlines",
            plain.allSatisfy { !ThemePalette.raisesHairlines($0, increaseContrast: false) })
        check(
            "tron ramp follows the theme ink",
            components(Theme.Colors.ramp(dark: 0.3, light: 0.2), .darkAqua)
                != components(Color.white.opacity(0.3), .darkAqua))
        ThemeStore.active.apply(.standard)
        check(
            "Default ramp is white over dark",
            components(Theme.Colors.ramp(dark: 0.3, light: 0.2), .darkAqua)
                == components(Color.white.opacity(0.3), .darkAqua))
        check(
            "Default ramp is black over light",
            components(Theme.Colors.ramp(dark: 0.3, light: 0.2), .aqua)
                == components(Color.black.opacity(0.2), .aqua))

        print("\n\(passes) passed, \(failures) failed")
        exit(failures == 0 ? 0 : 1)
    }
}
