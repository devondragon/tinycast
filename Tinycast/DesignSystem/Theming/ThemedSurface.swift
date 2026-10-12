import SwiftUI

extension View {
    /// Default draws the call site's own glass, so the standard theme is untouched.
    func themedSurface(_ role: SurfaceRole, in shape: some Shape, glass: Glass = .regular) -> some View {
        modifier(ThemedSurfaceModifier(role: role, shape: shape, glass: glass))
    }

    /// A borderless window's body: scrim over glass in Default, fill and backdrop in a theme.
    func themedPanel(in shape: some Shape) -> some View {
        modifier(ThemedPanelModifier(shape: shape))
    }
}

private struct ThemedSurfaceModifier<S: Shape>: ViewModifier {
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
            content.background { SolidSurface(fill: .color(tint.opaque), stroke: nil, glows: false, shape: shape) }
        case .tintedGlass(let tint):
            content.glassEffect(
                (role == .control ? Glass.regular.interactive() : .regular).tint(ThemePalette.color(tint)),
                in: shape)
        case .solid(let fill, let stroke, let glows):
            content.background { SolidSurface(fill: fill, stroke: stroke, glows: glows, shape: shape) }
        }
    }
}

private struct ThemedPanelModifier<S: Shape>: ViewModifier {
    let shape: S

    @ViewBuilder
    func body(content: Content) -> some View {
        switch Theme.Surfaces.style(.panel) {
        case .glass:
            content
                .background(Theme.Colors.panelScrim)
                .background(GlassEffectView())
        case .tintedGlass(let tint):
            content
                .foregroundStyle(Theme.Colors.textPrimary)
                .background(Theme.Colors.panelScrim)
                .background(PanelBackdrop(backdrop: ThemeStore.active.palette.definition.backdrop))
                .background(ThemePalette.color(tint))
                .background(GlassEffectView())
        case .solid(let fill, let stroke, let glows):
            content
                .foregroundStyle(Theme.Colors.textPrimary)
                .background(Theme.Colors.panelScrim)
                .background(PanelBackdrop(backdrop: ThemeStore.active.palette.definition.backdrop))
                .background { SolidSurface(fill: fill, stroke: stroke, glows: glows, shape: shape) }
        }
    }
}

/// An opaque surface with a hairline edge; its glow sits inside the edge, since the window clips.
struct SolidSurface<S: Shape>: View {
    let fill: SurfaceFill
    let stroke: RGBAPair?
    let glows: Bool
    let shape: S
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast

    var body: some View {
        let radius = glows && contrast == .standard ? Theme.Effects.glowRadius(dark: colorScheme == .dark) : 0
        shape
            .fill(fillStyle)
            .overlay {
                if let stroke {
                    shape
                        .stroke(ThemePalette.color(stroke), lineWidth: 1)
                        .shadow(color: radius > 0 ? Theme.Effects.glowColor : .clear, radius: radius)
                }
            }
    }

    private var fillStyle: AnyShapeStyle {
        switch fill {
        case .color(let pair):
            AnyShapeStyle(ThemePalette.color(pair))
        case .verticalGradient(let top, let bottom):
            AnyShapeStyle(
                LinearGradient(
                    colors: [ThemePalette.color(top), ThemePalette.color(bottom)],
                    startPoint: .top, endPoint: .bottom))
        }
    }
}
