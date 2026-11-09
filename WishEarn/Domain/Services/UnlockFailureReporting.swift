import Foundation

@MainActor
protocol UnlockFailureReporting {
    func reportUnlockFailure(_ error: Error, wishID: UUID)
}
