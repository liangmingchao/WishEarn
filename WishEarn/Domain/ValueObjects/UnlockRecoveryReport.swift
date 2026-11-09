import Foundation

struct UnlockRecoveryFailure: Equatable {
    let wishID: UUID
    let message: String
}

struct UnlockRecoveryReport: Equatable {
    var restoredWishIDs: [UUID] = []
    var newlyUnlockedWishIDs: [UUID] = []
    var missingEventWishIDs: [UUID] = []
    var orphanedEventWishIDs: [UUID] = []
    var failures: [UnlockRecoveryFailure] = []

    var isEmpty: Bool {
        restoredWishIDs.isEmpty
            && newlyUnlockedWishIDs.isEmpty
            && missingEventWishIDs.isEmpty
            && orphanedEventWishIDs.isEmpty
            && failures.isEmpty
    }
}
