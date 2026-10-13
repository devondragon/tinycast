import SwiftUI

/// One card per theme: its surface, ink and a still frame of its backdrop.
struct ThemePickerRow: View {
    @Environment(AppSettings.self) private var settings

    var body: some View {
        @Bindable var settings = settings
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            SettingsRowTitle(.generalAppearance, "Theme")
            ScrollView(.horizontal) {
                HStack(spacing: Theme.Spacing.lg) {
                    ForEach(ThemeID.allCases) { id in
                        ThemeCard(definition: ThemeCatalog.definition(for: id), isSelected: settings.theme == id) {
                            settings.theme = id
                        }
                    }
                }
                .padding(.vertical, Theme.Spacing.xs)
            }
            .scrollIndicators(.hidden)
        }
    }
}

private struct ThemeCard: View {
    let definition: ThemeDefinition
    let isSelected: Bool
    let select: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let dark = colorScheme == .dark
        let shape = RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
        Button(action: select) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                ZStack(alignment: .bottomLeading) {
                    shape.fill(ThemePalette.color(definition.surface))
                    if definition.backdrop.kind != .none {
                        Canvas { context, size in
                            BackdropRenderer.draw(definition.backdrop, in: &context, size: size, time: 0, dark: dark)
                        } symbols: {
                            BackdropRenderer.symbols(for: definition.backdrop, dark: dark)
                        }
                        .opacity(definition.backdrop.intensity.value(dark: dark))
                        .clipShape(shape)
                    }
                    Text("Aa")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(ThemePalette.color(definition.ink))
                        .padding(Theme.Spacing.md)
                }
                .frame(width: 112, height: 68)
                .overlay {
                    shape.stroke(
                        isSelected ? Color.accentColor : Color.secondary.opacity(0.3),
                        lineWidth: isSelected ? 2 : 1)
                }
                Text(definition.id.title).font(.caption)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(definition.id.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
