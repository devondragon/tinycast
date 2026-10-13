import Observation

/// The active theme; `Theme`'s tokens read it, so a switch repaints every view that used one.
@MainActor
@Observable
final class ThemeStore {
    /// Global like `IconCache.style`: a missed injection in a menu or list would be silent staleness.
    static let active = ThemeStore()

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

    func reload() {
        palette = ThemePalette(palette.definition)
        generation &+= 1
    }
}

/// A value an AppKit host derives from the active theme, rebuilt on first use after a switch.
@MainActor
struct ThemeDerived<Value> {
    private let build: @MainActor () -> Value
    private var cached: (generation: Int, value: Value)?

    init(_ build: @escaping @MainActor () -> Value) {
        self.build = build
    }

    var value: Value {
        mutating get {
            let generation = ThemeStore.active.generation
            if let cached, cached.generation == generation { return cached.value }
            let value = build()
            cached = (generation, value)
            return value
        }
    }
}
