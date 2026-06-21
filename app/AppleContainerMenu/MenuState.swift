import Foundation

/// The full reachable space of "run the CLI and show the result" (ADR 005).
/// The view switches on exactly these six states; the fetch flow (ADR 006)
/// produces them.
enum MenuState {
    case loading
    case cliNotFound
    case serviceNotRunning
    case empty
    case populated([Container])
    case error(String)
}
