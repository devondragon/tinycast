import AppKit
import SwiftUI

/// A token's font in the active theme's face; a face equal to Default's returns `base` untouched.
@MainActor
enum ThemeFonts {
    /// `fixedSize` pins the size for a font an `NSFont` twin measures, so the two always agree.
    static func font(
        _ role: FontRole, base: Font, style: NSFont.TextStyle, weight: Font.Weight? = nil,
        scale: CGFloat = 1, fixedSize: CGFloat? = nil
    ) -> Font {
        let face = ThemeStore.active.palette.definition.faces.face(for: role)
        guard face != ThemeFaces.system.face(for: role) else { return base }
        if case .bundled(let bundled) = face, !isInstalled(bundled) { return base }
        let key = FontKey(role: role, style: style, weight: weight, scale: scale, fixedSize: fixedSize)
        let cache = currentCache()
        if let font = cache.fonts[key] { return font }
        let preferred = NSFont.preferredFont(forTextStyle: style)
        let size = fixedSize ?? (preferred.pointSize * scale).rounded()
        let font: Font
        switch face {
        case .bundled(let bundled):
            font =
                fixedSize == nil
                ? .custom(bundled.family, size: size, relativeTo: textStyle(style))
                : .custom(bundled.family, fixedSize: size)
        case .system(let design):
            font = .system(size: size, design: fontDesign(design))
        }
        let resolved = font.weight(weight ?? fontWeight(impliedWeight(of: preferred)))
        cache.fonts[key] = resolved
        return resolved
    }

    static func nsFont(_ role: FontRole, base: NSFont) -> NSFont {
        let face = ThemeStore.active.palette.definition.faces.face(for: role)
        guard face != ThemeFaces.system.face(for: role) else { return base }
        let key = NSFontKey(role: role, base: base)
        let cache = currentCache()
        if let font = cache.nsFonts[key] { return font }
        let resolved = resolveNSFont(face, base: base)
        cache.nsFonts[key] = resolved
        return resolved
    }

    private static func resolveNSFont(_ face: FontFace, base: NSFont) -> NSFont {
        switch face {
        case .bundled(let bundled):
            let descriptor = NSFontDescriptor(fontAttributes: [
                .family: bundled.family,
                .traits: [NSFontDescriptor.TraitKey.weight: impliedWeight(of: base).rawValue]
            ])
            guard let font = NSFont(descriptor: descriptor, size: base.pointSize),
                font.familyName == bundled.family
            else { return base }
            return font
        case .system(let design):
            guard let descriptor = base.fontDescriptor.withDesign(nsDesign(design)) else { return base }
            return NSFont(descriptor: descriptor, size: base.pointSize) ?? base
        }
    }

    /// A text style's weight lives on SF's `wght` axis: `.caption2` is Medium with a zero trait.
    static func impliedWeight(of font: NSFont) -> NSFont.Weight {
        let variation = CTFontCopyVariation(font) as? [NSNumber: NSNumber]
        if let axis = variation?[NSNumber(value: wghtAxis)]?.doubleValue {
            return axisWeights.min { abs($0.axis - axis) < abs($1.axis - axis) }?.weight ?? .regular
        }
        let traits = font.fontDescriptor.object(forKey: .traits) as? [NSFontDescriptor.TraitKey: Any]
        return NSFont.Weight((traits?[.weight] as? NSNumber)?.doubleValue ?? 0)
    }

    private static let wghtAxis: UInt32 = 0x7767_6874

    private static let axisWeights: [(axis: Double, weight: NSFont.Weight)] = [
        (100, .ultraLight), (200, .thin), (300, .light), (400, .regular), (510, .medium),
        (590, .semibold), (700, .bold), (800, .heavy), (900, .black)
    ]

    private static func fontWeight(_ weight: NSFont.Weight) -> Font.Weight {
        let weights: [(NSFont.Weight, Font.Weight)] = [
            (.ultraLight, .ultraLight), (.thin, .thin), (.light, .light), (.regular, .regular),
            (.medium, .medium), (.semibold, .semibold), (.bold, .bold), (.heavy, .heavy), (.black, .black)
        ]
        return weights.min { abs($0.0.rawValue - weight.rawValue) < abs($1.0.rawValue - weight.rawValue) }?.1
            ?? .regular
    }

    private struct FontKey: Hashable {
        let role: FontRole
        let style: NSFont.TextStyle
        let weight: Font.Weight?
        let scale: CGFloat
        let fixedSize: CGFloat?
    }

    private struct NSFontKey: Hashable {
        let role: FontRole
        let base: NSFont
    }

    private final class Cache {
        let generation: Int
        var fonts: [FontKey: Font] = [:]
        var nsFonts: [NSFontKey: NSFont] = [:]

        init(generation: Int) {
            self.generation = generation
        }
    }

    private static var cache = Cache(generation: -1)

    /// Resolution runs once per theme switch: token reads happen per row, per render.
    private static func currentCache() -> Cache {
        let generation = ThemeStore.active.generation
        if cache.generation != generation { cache = Cache(generation: generation) }
        return cache
    }

    /// Only a hit is remembered: a font registered later must still be found.
    private static var installed: Set<BundledFont> = []

    private static func isInstalled(_ bundled: BundledFont) -> Bool {
        if installed.contains(bundled) { return true }
        guard NSFontManager.shared.availableMembers(ofFontFamily: bundled.family) != nil else { return false }
        installed.insert(bundled)
        return true
    }

    private static func textStyle(_ style: NSFont.TextStyle) -> Font.TextStyle {
        switch style {
        case .largeTitle: .largeTitle
        case .title1: .title
        case .title2: .title2
        case .title3: .title3
        case .headline: .headline
        case .subheadline: .subheadline
        case .callout: .callout
        case .footnote: .footnote
        case .caption1: .caption
        case .caption2: .caption2
        default: .body
        }
    }

    private static func fontDesign(_ design: SystemDesign) -> Font.Design {
        switch design {
        case .standard: .default
        case .monospaced: .monospaced
        case .rounded: .rounded
        case .serif: .serif
        }
    }

    private static func nsDesign(_ design: SystemDesign) -> NSFontDescriptor.SystemDesign {
        switch design {
        case .standard: .default
        case .monospaced: .monospaced
        case .rounded: .rounded
        case .serif: .serif
        }
    }
}
