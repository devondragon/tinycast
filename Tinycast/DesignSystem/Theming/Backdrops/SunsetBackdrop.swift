import SwiftUI

/// A banded sun sitting on the horizon above the streaming floor.
enum SunsetBackdrop {
    private static let bands = 6

    static func draw(
        _ backdrop: Backdrop, in context: inout GraphicsContext, size: CGSize, time: Double, dark: Bool
    ) {
        let horizon = size.height * 0.52
        let radius = size.height * 0.28
        let center = CGPoint(x: size.width / 2, y: horizon)
        let disc = Path(
            ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
        let top = BackdropRenderer.color(backdrop.tertiary, dark: dark)
        let bottom = BackdropRenderer.color(backdrop.primary, dark: dark)
        context.drawLayer { layer in
            layer.clip(to: Path(CGRect(x: 0, y: 0, width: size.width, height: horizon)))
            layer.fill(
                disc,
                with: .linearGradient(
                    Gradient(colors: [top, bottom]),
                    startPoint: CGPoint(x: center.x, y: center.y - radius), endPoint: center))
            layer.blendMode = .destinationOut
            let spacing = radius / Double(bands)
            let top = center.y - radius * 0.55
            let drift = (time * 6).truncatingRemainder(dividingBy: spacing)
            for band in 0..<bands {
                let y = top + Double(band) * spacing + drift
                let height = max(0, (y - top) * 1.2 / spacing)
                layer.fill(Path(CGRect(x: 0, y: y, width: size.width, height: height)), with: .color(.black))
            }
        }
        GridBackdrop.draw(backdrop, in: &context, size: size, time: time * 1.6, dark: dark, sunset: true)
    }
}
