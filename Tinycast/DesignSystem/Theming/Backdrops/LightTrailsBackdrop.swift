import SwiftUI

/// A faint flat lattice crossed by light cycles that turn at right angles and leave fading ribbons.
enum LightTrailsBackdrop {
    private static let pitch: CGFloat = 48
    private static let cycles = 5
    /// Each lap is a fresh route; the idle tail of the lap spaces the cycles out.
    private static let lapPadding: CGFloat = 240

    static func draw(
        _ backdrop: Backdrop, in context: inout GraphicsContext, size: CGSize, time: Double, dark: Bool
    ) {
        let ribbon = BackdropRenderer.color(backdrop.primary, dark: dark)
        let core = BackdropRenderer.color(backdrop.secondary, dark: dark)

        var lattice = Path()
        var x = pitch
        while x < size.width {
            lattice.move(to: CGPoint(x: x, y: 0))
            lattice.addLine(to: CGPoint(x: x, y: size.height))
            x += pitch
        }
        var y = pitch
        while y < size.height {
            lattice.move(to: CGPoint(x: 0, y: y))
            lattice.addLine(to: CGPoint(x: size.width, y: y))
            y += pitch
        }
        context.stroke(lattice, with: .color(BackdropRenderer.color(backdrop.tertiary, dark: dark).opacity(0.12)), lineWidth: 1)

        for cycle in 0..<cycles {
            let trail = 160 + 160 * BackdropRenderer.unit(cycle * 5)
            let speed = 120 + 90 * BackdropRenderer.unit(cycle * 3)
            let lapLength = size.width + 2 * size.height + trail + lapPadding
            let travelled = time * speed + BackdropRenderer.unit(cycle * 17) * lapLength
            let lap = Int(travelled / lapLength)
            let distance = travelled - Double(lap) * lapLength
            let route = route(seed: cycle &* 7919 &+ lap, size: size, trail: trail)
            let length = routeLength(route)
            guard length > 0, distance - trail < length else { continue }
            let from = max(0, distance - trail) / length
            let to = min(distance, length) / length
            guard to > from else { continue }
            let full = Path { path in path.addLines(route) }
            let segment = full.trimmedPath(from: from, to: to)
            let tail = point(on: route, at: from * length)
            let head = point(on: route, at: to * length)
            let color = cycle == 0 ? core : ribbon
            context.stroke(segment, with: .color(color.opacity(0.25)), lineWidth: 7)
            context.stroke(
                segment,
                with: .linearGradient(Gradient(colors: [color.opacity(0), color]), startPoint: tail, endPoint: head),
                style: StrokeStyle(lineWidth: 2, lineJoin: .miter))
            context.fill(Path(CGRect(x: head.x - 2.5, y: head.y - 2.5, width: 5, height: 5)), with: .color(core))
        }
    }

    /// Enters off one edge on a lattice row, jogs to two other rows, and leaves past the far edge.
    private static func route(seed: Int, size: CGSize, trail: Double) -> [CGPoint] {
        let rows = max(1, Int(size.height / pitch))
        let columns = max(1, Int(size.width / pitch))
        let half = max(1, columns / 2)
        func pick(_ salt: Int, _ count: Int) -> CGFloat {
            CGFloat(1 + BackdropRenderer.mix(seed &* 13 &+ salt) % count) * pitch
        }
        func row(_ salt: Int) -> CGFloat { pick(salt, rows) }
        let firstTurn = pick(4, half)
        let secondTurn = firstTurn + pick(5, half)
        let points = [
            CGPoint(x: -10, y: row(1)), CGPoint(x: firstTurn, y: row(1)),
            CGPoint(x: firstTurn, y: row(2)), CGPoint(x: secondTurn, y: row(2)),
            CGPoint(x: secondTurn, y: row(3)), CGPoint(x: size.width + trail + 10, y: row(3)),
        ]
        guard BackdropRenderer.mix(seed &* 13 &+ 6) % 2 == 0 else { return points }
        return points.map { CGPoint(x: size.width - $0.x, y: $0.y) }
    }

    private static func routeLength(_ route: [CGPoint]) -> Double {
        zip(route, route.dropFirst()).reduce(0) { $0 + abs($1.1.x - $1.0.x) + abs($1.1.y - $1.0.y) }
    }

    private static func point(on route: [CGPoint], at distance: Double) -> CGPoint {
        var remaining = distance
        for (start, end) in zip(route, route.dropFirst()) {
            let leg = abs(end.x - start.x) + abs(end.y - start.y)
            if remaining <= leg, leg > 0 {
                let t = remaining / leg
                return CGPoint(x: start.x + (end.x - start.x) * t, y: start.y + (end.y - start.y) * t)
            }
            remaining -= leg
        }
        return route.last ?? .zero
    }
}
