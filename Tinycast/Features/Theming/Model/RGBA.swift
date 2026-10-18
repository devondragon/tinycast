import Foundation

/// An sRGB color as plain numbers, so a theme can be stated and checked without AppKit.
struct RGBA: Equatable, Sendable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double

    init(_ red: Double, _ green: Double, _ blue: Double, alpha: Double = 1) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    /// `0xRRGGBB`, the form every theme states its colors in.
    init(hex: UInt32, alpha: Double = 1) {
        self.init(
            Double((hex >> 16) & 0xFF) / 255, Double((hex >> 8) & 0xFF) / 255,
            Double(hex & 0xFF) / 255, alpha: alpha)
    }

    static func gray(_ level: Double, alpha: Double = 1) -> RGBA {
        RGBA(level, level, level, alpha: alpha)
    }

    func with(alpha: Double) -> RGBA { RGBA(red, green, blue, alpha: alpha) }
}

/// One value per appearance: dark is the design, light its inversion.
struct RGBAPair: Equatable, Sendable {
    let dark: RGBA
    let light: RGBA

    static func both(_ value: RGBA) -> RGBAPair { RGBAPair(dark: value, light: value) }

    static func hex(dark: UInt32, light: UInt32) -> RGBAPair {
        RGBAPair(dark: RGBA(hex: dark), light: RGBA(hex: light))
    }

    func value(dark isDark: Bool) -> RGBA { isDark ? dark : light }
}

extension RGBAPair {
    /// Reduce Transparency asks for no see-through, so a tint is drawn at full alpha.
    var opaque: RGBAPair { RGBAPair(dark: dark.with(alpha: 1), light: light.with(alpha: 1)) }
}
