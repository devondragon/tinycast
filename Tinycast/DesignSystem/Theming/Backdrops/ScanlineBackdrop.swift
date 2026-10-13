import SwiftUI

/// Dark: phosphor glow, scanlines and a rare flicker. Light: still paper grain.
enum ScanlineBackdrop {
    private static let grain = 400

    static func draw(
        _ backdrop: Backdrop, in context: inout GraphicsContext, size: CGSize, time: Double, dark: Bool
    ) {
        guard dark else { return drawPaper(backdrop, in: &context, size: size) }
        let breath = 0.06 + 0.02 * sin(time * 0.5)
        let flicker = BackdropRenderer.mix(Int(time * 10)) % 97 == 0 ? 0.04 : 0
        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .radialGradient(
                Gradient(colors: [
                    BackdropRenderer.color(backdrop.primary, dark: true).opacity(breath + flicker), .clear,
                ]),
                center: CGPoint(x: size.width / 2, y: size.height / 2), startRadius: 0,
                endRadius: max(size.width, size.height) * 0.7))
        var lines = Path()
        var y: CGFloat = 0
        while y < size.height {
            lines.addRect(CGRect(x: 0, y: y, width: size.width, height: 1))
            y += 3
        }
        context.fill(lines, with: .color(BackdropRenderer.color(backdrop.secondary, dark: true).opacity(0.25)))
    }

    private static func drawPaper(_ backdrop: Backdrop, in context: inout GraphicsContext, size: CGSize) {
        var dots = Path()
        for index in 0..<grain {
            let x = BackdropRenderer.unit(index * 2) * size.width
            let y = BackdropRenderer.unit(index * 2 + 1) * size.height
            dots.addRect(CGRect(x: x, y: y, width: 1, height: 1))
        }
        context.fill(dots, with: .color(BackdropRenderer.color(backdrop.secondary, dark: false).opacity(0.12)))
    }
}
