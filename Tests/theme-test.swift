import Foundation

/// Pins the theme catalog: every theme is complete, Default is today's look, and text stays legible.
@main
struct ThemeTests {
    nonisolated(unsafe) static var failures = 0
    nonisolated(unsafe) static var passes = 0

    static func check(_ label: String, _ ok: Bool, _ detail: String = "") {
        if ok {
            passes += 1
        } else {
            failures += 1
            print("FAIL  \(label)\(detail.isEmpty ? "" : ": \(detail)")")
        }
    }

    static func main() {
        print("# color maths")
        check("hex parses", RGBA(hex: 0xFF8000) == RGBA(1, 128.0 / 255, 0))
        check("black on white is 21:1", abs(ContrastPolicy.ratio(.gray(0), .gray(1)) - 21) < 0.01)
        check("a color on itself is 1:1", abs(ContrastPolicy.ratio(.gray(0.5), .gray(0.5)) - 1) < 0.001)

        print("# every theme is stated")
        for id in ThemeID.allCases {
            check("\(id) definition carries its id", ThemeCatalog.definition(for: id).id == id)
        }

        print("# Default is today's look")
        let standard = ThemeCatalog.standard
        check("ink is white over black", standard.ink == RGBAPair(dark: .gray(1), light: .gray(0)))
        check("surface is black under white", standard.surface == RGBAPair(dark: .gray(0), light: .gray(1)))
        check("no overrides", standard.overrides.isEmpty)
        check("every surface is glass", SurfaceRole.allCases.allSatisfy { standard.surfaces.style(for: $0) == .glass })
        check("no backdrop", standard.backdrop.kind == .none)
        check("no glow", standard.glow == .none)
        check("system faces", standard.faces == .system)

        print("# a stored value from a newer build falls back")
        check("unknown theme id is rejected", ThemeID(rawValue: "vaporwave") == nil)
        check("Default's stored spelling is stable", ThemeID.standard.rawValue == "standard")

        print("# custom themes are opaque and legible")
        for id in ThemeID.allCases where id != .standard {
            let theme = ThemeCatalog.definition(for: id)
            if case .solid = theme.surfaces.panel {} else { check("\(id) panel is solid", false) }
            for dark in [true, false] {
                let mode = dark ? "dark" : "light"
                let primary = ContrastPolicy.minimumTextContrast(
                    theme, dark: dark, inkAlpha: theme.inkAlpha(.textPrimary, dark: dark))
                let secondary = ContrastPolicy.minimumTextContrast(
                    theme, dark: dark, inkAlpha: theme.inkAlpha(.textSecondary, dark: dark))
                check("\(id) \(mode) primary text ≥ 4.5", primary >= 4.5, String(format: "%.2f", primary))
                check("\(id) \(mode) secondary text ≥ 3", secondary >= 3, String(format: "%.2f", secondary))
            }
        }

        print("# every bundled font ships with its file and license")
        let fonts = URL(fileURLWithPath: "Tinycast/Resources/Fonts")
        for font in BundledFont.allCases {
            for file in font.files {
                check("\(file) is bundled", FileManager.default.fileExists(atPath: fonts.appending(path: file).path))
            }
            check("\(font.license) is bundled",
                  FileManager.default.fileExists(atPath: fonts.appending(path: "Licenses/\(font.license)").path))
        }

        print("\n\(passes) passed, \(failures) failed")
        exit(failures == 0 ? 0 : 1)
    }
}
