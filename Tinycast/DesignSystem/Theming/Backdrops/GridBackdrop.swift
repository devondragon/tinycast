import SwiftUI

/// A perspective floor whose lines stream toward the viewer, with a few light traces riding them.
@MainActor
enum GridBackdrop {
    private static let rows = 14
    private static let columns = 12
    private static let traces = 3

    static func draw(
        _ backdrop: Backdrop, in context: inout GraphicsContext, size: CGSize, time: Double, dark: Bool,
        sunset: Bool
    ) {
        let horizon = size.height * (sunset ? 0.52 : 0.38)
        let floor = size.height - horizon
        let vanishing = CGPoint(x: size.width / 2, y: horizon)
        let line = ThemePalette.color(backdrop.primary)
        let accent = ThemePalette.color(backdrop.secondary)

        var horizontals = Path()
        let phase = (time * 0.35).truncatingRemainder(dividingBy: 1)
        for row in 0..<rows {
            let depth = (Double(row) + phase) / Double(rows)
            let y = horizon + floor * pow(depth, 2.2)
            horizontals.move(to: CGPoint(x: 0, y: y))
            horizontals.addLine(to: CGPoint(x: size.width, y: y))
        }
        context.stroke(horizontals, with: .color(line.opacity(0.35)), lineWidth: 1)

        var verticals = Path()
        let spread = size.width / Double(columns) * 1.6
        for column in -columns...columns {
            verticals.move(to: vanishing)
            verticals.addLine(to: CGPoint(x: vanishing.x + Double(column) * spread, y: size.height))
        }
        context.stroke(verticals, with: .color((sunset ? accent : line).opacity(0.28)), lineWidth: 1)

        guard !sunset else { return }
        for trace in 0..<traces {
            let column = BackdropRenderer.mix(trace * 31) % (columns * 2 + 1) - columns
            let end = CGPoint(x: vanishing.x + Double(column) * spread, y: size.height)
            let progress = (time * (0.18 + 0.07 * BackdropRenderer.unit(trace)) + BackdropRenderer.unit(trace * 7))
                .truncatingRemainder(dividingBy: 1)
            let head = point(from: vanishing, to: end, at: pow(progress, 1.6))
            let tail = point(from: vanishing, to: end, at: pow(max(progress - 0.08, 0), 1.6))
            var path = Path()
            path.move(to: tail)
            path.addLine(to: head)
            let color = trace == 0 ? accent : line
            context.stroke(path, with: .color(color.opacity(0.35)), lineWidth: 6)
            context.stroke(path, with: .color(color), lineWidth: 2)
        }
    }

    private static func point(from start: CGPoint, to end: CGPoint, at t: Double) -> CGPoint {
        CGPoint(x: start.x + (end.x - start.x) * t, y: start.y + (end.y - start.y) * t)
    }
}
