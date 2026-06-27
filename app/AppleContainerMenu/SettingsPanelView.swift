import SwiftUI

/// Inline settings panel shown inside the popover (ADR 019). Kept in the popover
/// rather than a separate `Settings` window because opening one from an
/// `LSUIElement` menu-bar app on macOS 14 is unreliable (`SettingsLink`/
/// `openSettings` need a live render tree; legacy selectors throw on Sonoma).
struct SettingsPanelView: View {
    @AppStorage(AppSettings.autoRefreshEnabledKey)
    private var autoRefresh = AppSettings.defaultAutoRefreshEnabled
    @AppStorage(AppSettings.refreshIntervalKey)
    private var interval = AppSettings.defaultRefreshInterval

    /// Mirrors the live `SMAppService` registration; never persisted here.
    @State private var launchAtLogin = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.headline)

            Toggle("Launch at login", isOn: launchAtLoginBinding)

            Toggle("Auto-refresh while open", isOn: $autoRefresh)

            HStack {
                Text("Refresh interval")
                Spacer()
                Picker("Refresh interval", selection: $interval) {
                    ForEach(AppSettings.refreshIntervalChoices, id: \.self) { seconds in
                        Text("\(seconds)s").tag(seconds)
                    }
                }
                .labelsHidden()
                .fixedSize()
                .disabled(!autoRefresh)
            }

            Text("Appearance follows the system.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .onAppear { launchAtLogin = LaunchAtLogin.isEnabled }
    }

    /// Drives the toggle off the actual registration: set, then read back, so a
    /// failed register/unregister leaves the switch showing reality.
    private var launchAtLoginBinding: Binding<Bool> {
        Binding(
            get: { launchAtLogin },
            set: { newValue in
                LaunchAtLogin.set(newValue)
                launchAtLogin = LaunchAtLogin.isEnabled
            }
        )
    }
}
