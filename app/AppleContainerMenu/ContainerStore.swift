import Foundation

/// Holds the last-known fetch result and refreshes it asynchronously (ADRs 009,
/// 012). The menu always has something to render synchronously; the UI never
/// blocks on the CLI.
@MainActor
final class ContainerStore: ObservableObject {
    @Published private(set) var state: MenuState = .loading

    private let cli = ContainerCLI()
    private var currentRefresh: Task<Void, Never>?

    init() {
        // Warm the cache at launch so later opens render data, not "Checking..."
        refresh()
    }

    /// Kick an async fetch and update the cached state. Trigger-agnostic: the
    /// caller (launch, manual Refresh, or a future open hook) does not change.
    /// A newer refresh cancels an in-flight one so a slow earlier fetch cannot
    /// overwrite a fresher result.
    func refresh() {
        currentRefresh?.cancel()
        currentRefresh = Task { [weak self] in
            guard let self else { return }
            let newState = await self.cli.fetch()
            if Task.isCancelled { return }
            self.state = newState
        }
    }
}
