import Foundation
import ServiceManagement

/// Persisted user settings and their defaults (ADR 019). Stored in
/// `UserDefaults` and read by the SwiftUI panel via `@AppStorage` and by the
/// poll loop in `AppDelegate`. Keys are centralised here so both sides agree.
enum AppSettings {
    static let autoRefreshEnabledKey = "autoRefreshEnabled"
    static let refreshIntervalKey = "refreshIntervalSeconds"

    /// Off by default keeps the fetch-on-open behaviour (ADRs 009, 018) as the
    /// baseline; auto-refresh is strictly opt-in.
    static let defaultAutoRefreshEnabled = false
    static let defaultRefreshInterval = 5
    static let refreshIntervalChoices = [2, 5, 10, 30]
}

/// Launch-at-login backed by `SMAppService.mainApp` (ADR 019). The system
/// registration is the source of truth, not a persisted flag: `isEnabled` reads
/// it live so a denied or failed toggle self-corrects the UI rather than lying.
@MainActor
enum LaunchAtLogin {
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    /// Register or unregister the login item. On failure the registration is
    /// left as-is; the caller re-reads `isEnabled` to reflect what actually
    /// happened.
    static func set(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            // Intentionally swallowed: the UI re-reads `isEnabled` after this.
        }
    }
}
