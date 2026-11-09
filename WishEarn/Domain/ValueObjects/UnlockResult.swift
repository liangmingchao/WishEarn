import Foundation

enum UnlockResult: Equatable, Sendable {
    case notEligible
    case alreadyUnlocked
    case unlocked
}
