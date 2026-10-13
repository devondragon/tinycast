import AppKit
import SwiftUI

/// Renders the Tron grid offscreen at palette size; ImageRenderer adds rasterization, so it is an upper bound.
@main
@MainActor
enum BackdropPerformance {
    static let frames = 300
    static let step = 1.0 / 30

    static func main() {
        let backdrop = ThemeCatalog.tron.backdrop
        let size = CGSize(width: Theme.Size.panelWidth, height: Theme.Size.panelHeight)
        print("Tron grid, \(Int(size.width))x\(Int(size.height)), \(frames) frames at 1/30 s steps")
        let blankBytes = render(size: size) { _, _ in }
        let drawnBytes = render(size: size, draw: { context, time in
            BackdropRenderer.draw(backdrop, in: &context, size: size, time: time, dark: true)
        }, time: 1)
        precondition(!blankBytes.isEmpty && blankBytes != drawnBytes, "the backdrop drew nothing")
        print("check: drawn render differs from blank render")
        let blank = measure(size: size) { _, _ in }
        report("empty canvas", blank)
        for dark in [true, false] {
            let drawn = measure(size: size) { context, time in
                BackdropRenderer.draw(backdrop, in: &context, size: size, time: time, dark: dark)
            }
            report(dark ? "tron dark" : "tron light", drawn)
        }
    }

    static func render(
        size: CGSize, draw: @escaping (inout GraphicsContext, Double) -> Void, time: Double = 0
    ) -> Data {
        let view = Canvas { context, _ in draw(&context, time) }.frame(width: size.width, height: size.height)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2
        guard let image = renderer.cgImage else { return Data() }
        return (image.dataProvider?.data as Data?) ?? Data()
    }

    static func measure(size: CGSize, draw: @escaping (inout GraphicsContext, Double) -> Void) -> [Double] {
        var millis: [Double] = []
        for frame in 0..<frames {
            let start = ContinuousClock.now
            let bytes = render(size: size, draw: draw, time: Double(frame) * step)
            let elapsed = start.duration(to: .now).components
            precondition(!bytes.isEmpty, "ImageRenderer produced no image")
            millis.append(Double(elapsed.seconds) * 1_000 + Double(elapsed.attoseconds) / 1e15)
        }
        return millis
    }

    static func report(_ label: String, _ millis: [Double]) {
        let sorted = millis.sorted()
        let mean = millis.reduce(0, +) / Double(millis.count)
        let p95 = sorted[Int(Double(sorted.count - 1) * 0.95)]
        let cpu = mean * 30 / 1_000 * 100
        let line = String(format: "mean %6.2f ms  p95 %6.2f ms  implied CPU at 30 fps %5.1f%%", mean, p95, cpu)
        print("\(label.padding(toLength: 13, withPad: " ", startingAt: 0)) \(line)")
    }
}
