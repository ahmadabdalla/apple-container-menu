@testable import AppleContainerMenu

/// Test-only sugar for asserting on `MenuState` cases. `MenuState` is
/// intentionally not `Equatable` in production (the `.populated` payload and
/// `.error` string are not value-compared anywhere), so the tests pattern-match
/// here instead of forcing conformance onto the app.
extension MenuState {
    var isCLINotFound: Bool { if case .cliNotFound = self { true } else { false } }
    var isServiceNotRunning: Bool { if case .serviceNotRunning = self { true } else { false } }
    var isEmpty: Bool { if case .empty = self { true } else { false } }

    /// The containers when `.populated`, else nil.
    var containers: [Container]? { if case .populated(let value) = self { value } else { nil } }

    /// The message when `.error`, else nil.
    var errorMessage: String? { if case .error(let message) = self { message } else { nil } }
}
