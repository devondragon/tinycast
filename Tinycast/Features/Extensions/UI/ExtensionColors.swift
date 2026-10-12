import SwiftUI

/// Here, not in `Theme`: a third-party screen may never force a change on a launcher one.
@MainActor
enum ExtensionColors {
    /// The Settings card's own surface, so a form field is the same material as the app's.
    static var fieldFill: Color { Theme.Colors.ramp(dark: 0.05, light: 0.04) }
    static var fieldStroke: Color { Theme.Colors.ramp(dark: 0.20, light: 0.18) }
    /// A checkbox's own edge, brighter than a field's: it is the control, not a container.
    static var checkboxStroke: Color { Theme.Colors.ramp(dark: 0.26, light: 0.30) }
    /// Fainter than a list row, since a grid tiles many of them.
    static var gridItemFill: Color { Theme.Colors.ramp(dark: 0.03, light: 0.035) }
    static var detailCardFill: Color { Theme.Colors.ramp(dark: 0.05, light: 0.04) }
}
