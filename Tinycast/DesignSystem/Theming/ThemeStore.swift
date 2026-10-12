import Observation

/// The active theme; `Theme`'s tokens read it, so a switch repaints every view that used one.
@MainActor
@Observable
final class ThemeStore {
    /// Global like `IconCache.style`: a missed injection in a menu or list would be silent staleness.
    static var active = ThemeStore()

    private(set) var palette = ThemePalette(ThemeCatalog.standard)
    /// For AppKit views that copied a color or font: a new value means reapply.
    private(set) var generation = 0

    var id: ThemeID { palette.definition.id }

    @discardableResult
    func apply(_ id: ThemeID) -> Bool {
        guard id != self.id else { return false }
        palette = ThemePalette(ThemeCatalog.definition(for: id))
        generation &+= 1
        return true
    }
}
