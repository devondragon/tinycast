import AppKit

/// Keeps `IncreasedContrastFlag` current and repaints themed hairlines when the setting flips.
@MainActor
final class IncreaseContrastMonitor {
    private var token: NotificationToken?

    init() {
        IncreasedContrastFlag.set(NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast)
        let center = NSWorkspace.shared.notificationCenter
        let observer = center.addObserver(
            forName: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification, object: nil, queue: .main
        ) { _ in
            MainActor.assumeIsolated {
                IncreasedContrastFlag.set(NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast)
                ThemeStore.active.reload()
            }
        }
        token = NotificationToken(observer, center: center)
    }
}
