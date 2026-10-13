import SwiftUI

/// Falling columns of half-width katakana and digits; each column's pace and offset is a hash.
enum CodeRainBackdrop {
    static let glyphs = Array("ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ0123456789").map(String.init)
    private static let pitch: CGFloat = 16
    /// Two tags per glyph: the bright head and the body.
    private static let headTagOffset = 1000

    static func draw(_ backdrop: Backdrop, in context: inout GraphicsContext, size: CGSize, time: Double) {
        let columns = Int(size.width / pitch)
        for column in 0..<columns {
            let speed = 40 + Double(BackdropRenderer.mix(column) % 60)
            let length = 8 + BackdropRenderer.mix(column * 7) % 16
            let span = size.height + CGFloat(length) * pitch
            let head = (time * speed + BackdropRenderer.unit(column * 13) * span)
                .truncatingRemainder(dividingBy: span)
            for step in 0..<length {
                let y = head - CGFloat(step) * pitch
                guard y > -pitch, y < size.height + pitch else { continue }
                let flicker = BackdropRenderer.mix(column &* 7919 &+ step &+ Int(time * 6))
                let tag = flicker % glyphs.count + (step == 0 ? headTagOffset : 0)
                guard let symbol = context.resolveSymbol(id: tag) else { continue }
                context.opacity = step == 0 ? 1 : 1 - Double(step) / Double(length)
                context.draw(symbol, at: CGPoint(x: CGFloat(column) * pitch + pitch / 2, y: y))
            }
        }
        context.opacity = 1
    }

    @ViewBuilder
    static func symbols(for backdrop: Backdrop, dark: Bool) -> some View {
        let body = color(backdrop.primary, dark: dark)
        let head = color(backdrop.secondary, dark: dark)
        ForEach(Array(glyphs.indices) + glyphs.indices.map { $0 + headTagOffset }, id: \.self) { tag in
            let isHead = tag >= headTagOffset
            Text(glyphs[tag % headTagOffset])
                .font(.system(size: 13, weight: isHead ? .bold : .regular, design: .monospaced))
                .foregroundStyle(isHead ? head : body)
                .tag(tag)
        }
    }

    private static func color(_ pair: RGBAPair, dark: Bool) -> Color {
        Color(nsColor: ThemePalette.nsColor(dark ? pair.dark : pair.light))
    }
}
