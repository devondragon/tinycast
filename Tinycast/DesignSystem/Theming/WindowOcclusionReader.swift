import AppKit
import SwiftUI

/// Reports whether this view's window is on screen, so animation can stop when it is not.
struct WindowOcclusionReader: NSViewRepresentable {
    let onChange: (Bool) -> Void

    func makeNSView(context: Context) -> ReaderView {
        let view = ReaderView()
        view.onChange = onChange
        return view
    }

    func updateNSView(_ nsView: ReaderView, context: Context) {
        nsView.onChange = onChange
    }

    final class ReaderView: NSView {
        var onChange: (Bool) -> Void = { _ in }
        private var token: NotificationToken?

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            token = nil
            guard let window else { return onChange(false) }
            // The typed `addObserver(of:for:)` message for occlusion needs macOS 27.
            let center = NotificationCenter.default
            token = NotificationToken(
                center.addObserver(
                    forName: NSWindow.didChangeOcclusionStateNotification, object: window, queue: .main
                ) { [weak self] _ in
                    MainActor.assumeIsolated { self?.report() }
                },
                center: center)
            report()
        }

        private func report() { onChange(window?.occlusionState.contains(.visible) ?? false) }
    }
}
