import SwiftUI

/// The theme's moving layer: stateless per frame, and paused whenever nobody can see it.
struct PanelBackdrop: View {
    let backdrop: Backdrop
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @State private var isVisible = false

    var body: some View {
        let dark = colorScheme == .dark
        let still = reduceMotion || (!dark && backdrop.lightIsStatic)
        if backdrop.kind != .none {
            TimelineView(.animation(minimumInterval: 1.0 / 30, paused: still || !isVisible)) { timeline in
                Canvas(rendersAsynchronously: true) { context, size in
                    // Wrapped to an hour so trig and Float math downstream keep their precision.
                    let time = still ? 0 : timeline.date.timeIntervalSinceReferenceDate
                        .truncatingRemainder(dividingBy: 3600) * backdrop.speed
                    BackdropRenderer.draw(backdrop, in: &context, size: size, time: time, dark: dark)
                } symbols: {
                    BackdropRenderer.symbols(for: backdrop, dark: dark)
                }
            }
            .opacity(backdrop.intensity.value(dark: dark))
            .background(WindowOcclusionReader { isVisible = $0 })
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }
}

/// One `draw` per kind; each lives in its own file and lands with its theme.
enum BackdropRenderer {
    static func draw(
        _ backdrop: Backdrop, in context: inout GraphicsContext, size: CGSize, time: Double, dark: Bool
    ) {
        switch backdrop.kind {
        case .grid: GridBackdrop.draw(backdrop, in: &context, size: size, time: time, dark: dark, sunset: false)
        case .codeRain: CodeRainBackdrop.draw(backdrop, in: &context, size: size, time: time)
        case .none, .sunsetGrid, .scanlines: break
        }
    }

    @ViewBuilder
    static func symbols(for backdrop: Backdrop, dark: Bool) -> some View {
        if backdrop.kind == .codeRain { CodeRainBackdrop.symbols(for: backdrop, dark: dark) }
    }

    /// A fixed integer hash, so every column and trace is a pure function of its index.
    static func mix(_ value: Int) -> Int {
        var x = UInt64(bitPattern: Int64(value)) &+ 0x9E37_79B9_7F4A_7C15
        x = (x ^ (x >> 30)) &* 0xBF58_476D_1CE4_E5B9
        x = (x ^ (x >> 27)) &* 0x94D0_49BB_1331_11EB
        return Int(truncatingIfNeeded: (x ^ (x >> 31)) & 0x7FFF_FFFF)
    }

    /// `mix` mapped to 0..<1.
    static func unit(_ value: Int) -> Double { Double(mix(value)) / Double(0x7FFF_FFFF) }
}
