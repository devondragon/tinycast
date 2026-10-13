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
        let size = fixedSize ?? (NSFont.preferredFont(forTextStyle: style).pointSize * scale).rounded()
        let font: Font
        switch face {
        case .bundled(let bundled):
            guard isInstalled(bundled) else { return base }
            font =
                fixedSize == nil
                ? .custom(bundled.family, size: size, relativeTo: textStyle(style))
                : .custom(bundled.family, fixedSize: size)
        case .system(let design):
            font = .system(size: size, design: fontDesign(design))
        }
        return weight.map(font.weight) ?? font
    }

    static func nsFont(_ role: FontRole, base: NSFont) -> NSFont {
        let face = ThemeStore.active.palette.definition.faces.face(for: role)
        guard face != ThemeFaces.system.face(for: role) else { return base }
        switch face {
        case .bundled(let bundled):
            var attributes: [NSFontDescriptor.AttributeName: Any] = [.family: bundled.family]
            if let traits = base.fontDescriptor.object(forKey: .traits) as? [NSFontDescriptor.TraitKey: Any],
                let weight = traits[.weight]
            {
                attributes[.traits] = [NSFontDescriptor.TraitKey.weight: weight]
            }
            let descriptor = NSFontDescriptor(fontAttributes: attributes)
            guard let font = NSFont(descriptor: descriptor, size: base.pointSize),
                font.familyName == bundled.family
            else { return base }
            return font
        case .system(let design):
            guard let descriptor = base.fontDescriptor.withDesign(nsDesign(design)) else { return base }
            return NSFont(descriptor: descriptor, size: base.pointSize) ?? base
        }
    }

    private static func isInstalled(_ bundled: BundledFont) -> Bool {
        NSFontManager.shared.availableMembers(ofFontFamily: bundled.family) != nil
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
