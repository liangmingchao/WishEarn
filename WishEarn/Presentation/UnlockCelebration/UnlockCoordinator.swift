import Foundation
import Observation

struct UnlockPresentation: Identifiable {
    let id = UUID()
    let wish: Wish
    let conditionCount: Int
    let imageData: Data?
}

@MainActor
@Observable
final class UnlockCoordinator: UnlockEventPublishing {
    private let wishRepository: WishRepository
    private let conditionRepository: ConditionRepository
    private let imageStorage: ImageStorageService
    private let lifecycleService: WishLifecycleServicing

    private(set) var presentation: UnlockPresentation?
    var error: AppError?

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
        do {
            guard let wish = try wishRepository.fetch(id: wishID) else {
                return
            }
            let conditions = try conditionRepository.fetchConditions(wishID: wishID)

            var imageData: Data?
            if let imagePath = wish.imagePath {
                do {
                    imageData = try imageStorage.loadImageData(at: imagePath)
                } catch {
                    // 图片读取失败时庆祝页使用占位图。
                    imageData = nil
                }
            }

            presentation = UnlockPresentation(
                wish: wish,
                conditionCount: conditions.count,
                imageData: imageData
            )
        } catch {
            self.error = AppError.wrap(error)
        }
    }

    func claim() {
        guard let presentation else { return }

        do {
            try lifecycleService.complete(wishID: presentation.wish.id)
            self.presentation = nil
        } catch {
            self.error = AppError.wrap(error)
        }
    }

    func dismiss() {
        presentation = nil
    }
}
