import Foundation

/// One background run's outcome, held until its waiter arrives; a run can settle first.
struct ExtensionRunSettlement {
    private enum State {
        case pending
        case waiting(CheckedContinuation<Bool, Never>)
        case settled(Bool)
        case delivered
    }

    private var state = State.pending

    /// The first outcome wins; a timeout or abort arriving after it changes nothing.
    mutating func settle(_ result: Bool) {
        switch state {
        case .pending:
            state = .settled(result)
        case .waiting(let continuation):
            state = .delivered
            continuation.resume(returning: result)
        case .settled, .delivered:
            break
        }
    }

    mutating func wait(_ continuation: CheckedContinuation<Bool, Never>) {
        switch state {
        case .pending:
            state = .waiting(continuation)
        case .settled(let result):
            state = .delivered
            continuation.resume(returning: result)
        case .waiting, .delivered:
            continuation.resume(returning: false)
        }
    }
}
