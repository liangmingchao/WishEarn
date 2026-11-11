import Foundation
import Observation

struct UnlockPresentation: Identifiable {
    let id = UUID()
    let wish: Wish
    /// Count at presentation time, not a persisted unlock-time snapshot.
    let requiredConditionCount: Int
    let imageData: Data?
}

@MainActor
@Observable
final class UnlockCoordinator: UnlockEventPublishing, UnlockFailureReporting {
    private let wishRepository: WishRepository
    private let conditionRepository: ConditionRepository
    private let imageStorage: ImageStorageService
    private let lifecycleService: WishLifecycleServicing

    private(set) var presentation: UnlockPresentation?
    /// Keeps the celebration on screen after a successful claim so the view
    /// can show an explicit "reward claimed" confirmation before dismissing.
    private(set) var claimedWishID: UUID?
    var error: AppError?

    var isClaimed: Bool {
        guard let presentation else { return false }
        return claimedWishID == presentation.wish.id
    }

    init(
        wishRepository: WishRepository,
        conditionRepository: ConditionRepository,
        imageStorage: ImageStorageService,
        lifecycleService: WishLifecycleServicing
    ) {
        self.wishRepository = wishRepository
        self.conditionRepository = conditionRepository
        self.imageStorage = imageStorage
        self.lifecycleService = lifecycleService
    }

    func publishUnlock(wishID: UUID) {
        guard presentation == nil else { return }

        do {
            guard let wish = try wishRepository.fetch(id: wishID) else {
                return
            }
            let conditions = try conditionRepository.fetchConditions(wishID: wishID)
            let requiredConditionCount = conditions.filter(\.isRequired).count

            var imageData: Data?
            if let imagePath = wish.imagePath {
                do {
                    imageData = try imageStorage.loadImageData(at: imagePath)
                } catch {
                    // 图片读取失败时庆祝页使用占位图。
                    imageData = nil
                }
            }

            claimedWishID = nil
            presentation = UnlockPresentation(
                wish: wish,
                requiredConditionCount: requiredConditionCount,
                imageData: imageData
            )
        } catch {
            self.error = AppError.wrap(error)
        }
    }

    /// Completes the wish but keeps the celebration visible for the claimed
    /// confirmation. Returns whether the reward was successfully claimed.
    @discardableResult
    func claim() -> Bool {
        guard let presentation else { return false }
        if claimedWishID == presentation.wish.id {
            return true
        }

        do {
            try lifecycleService.complete(wishID: presentation.wish.id)
            claimedWishID = presentation.wish.id
            return true
        } catch {
            self.error = AppError.wrap(error)
            return false
        }
    }

    func dismiss() {
        presentation = nil
        claimedWishID = nil
    }

    func reportUnlockFailure(_ error: Error, wishID: UUID) {
        self.error = AppError.wrap(error)
    }
}
