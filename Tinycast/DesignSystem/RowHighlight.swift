import SwiftUI

/// Selection wins over hover; one view, so every list's highlight and glow stay identical.
struct RowHighlight: View {
    let selected: Bool
    let hovered: Bool
    let cornerRadius: CGFloat
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        let glow = selected && contrast == .standard ? Theme.Effects.glowRadius(dark: colorScheme == .dark) : 0
        shape
            .fill(selected ? Theme.Colors.selection : hovered ? Theme.Colors.rowHover : .clear)
            .overlay {
                if glow > 0 {
                    shape.stroke(Theme.Effects.glowColor.opacity(0.6), lineWidth: 1)
                        .shadow(color: Theme.Effects.glowColor, radius: glow / 2)
                }
            }
    }
}
