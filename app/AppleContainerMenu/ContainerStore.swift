import Foundation
import Observation

/// Holds the last-known fetch result and refreshes it asynchronously (ADRs 009,
/// 012). The popover always has something to render synchronously; the UI never
/// blocks on the CLI. `@Observable` lets the SwiftUI popover track `state` and
/// update in place under a live fetch (ADR 018), which the old `NSMenu` snapshot
/// could not.
@MainActor
@Observable
final class ContainerStore {
    private(set) var state: MenuState = .loading

    @ObservationIgnored private let cli = ContainerCLI()
    @ObservationIgnored private var currentRefresh: Task<Void, Never>?

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
            // A refresh cancelled before it starts should not spawn the CLI;
            // every menu open triggers one, so cancellations are common.
            if Task.isCancelled { return }
            let newState = await self.cli.fetch()
            if Task.isCancelled { return }
            self.state = newState
        }
    }
}
