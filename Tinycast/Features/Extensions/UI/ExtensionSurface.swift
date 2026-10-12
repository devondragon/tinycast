import SwiftUI

/// The theme's surface, drawn here rather than through DesignSystem so extensions stay walled off.
extension View {
    func extensionSurface(_ role: SurfaceRole, in shape: some Shape, glass: Glass) -> some View {
        modifier(ExtensionSurfaceModifier(role: role, shape: shape, glass: glass))
    }
}

private struct ExtensionSurfaceModifier<S: Shape>: ViewModifier {
    let role: SurfaceRole
    let shape: S
    let glass: Glass
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    @ViewBuilder
    func body(content: Content) -> some View {
        switch Theme.Surfaces.style(role) {
        case .glass:
            content.glassEffect(glass, in: shape)
        case .tintedGlass(let tint) where reduceTransparency:
            content.background { shape.fill(ThemePalette.color(tint.opaque)) }
        case .tintedGlass(let tint):
            content.glassEffect(glass.tint(ThemePalette.color(tint)), in: shape)
        case .solid(.color(let fill), let stroke, _):
            content.background {
                shape.fill(ThemePalette.color(fill))
                    .overlay { shape.stroke(ThemePalette.color(stroke), lineWidth: 1) }
            }
        case .solid(.verticalGradient(let top, let bottom), let stroke, _):
            content.background {
                shape
                    .fill(
                        LinearGradient(
                            colors: [ThemePalette.color(top), ThemePalette.color(bottom)],
                            startPoint: .top, endPoint: .bottom)
                    )
                    .overlay { shape.stroke(ThemePalette.color(stroke), lineWidth: 1) }
            }
        }
    }
}
