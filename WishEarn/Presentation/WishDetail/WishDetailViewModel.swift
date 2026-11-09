import Foundation
import Observation

@MainActor
@Observable
final class WishDetailViewModel {
    private let wishRepository: WishRepository
    private let conditionLifecycleService: ConditionLifecycleServicing
    private let wishProgressService: WishProgressService
    private let lifecycleService: WishLifecycleServicing
    private let imageStorage: ImageStorageService

    private(set) var wish: Wish
    private(set) var conditions: [Condition] = []
    private(set) var progress: WishProgress?
    private(set) var imageData: Data?
    private(set) var isLoading = false
    private(set) var error: AppError?
    var actionError: AppError?

    init(
        wish: Wish,
        wishRepository: WishRepository,
        conditionLifecycleService: ConditionLifecycleServicing,
        wishProgressService: WishProgressService,
        lifecycleService: WishLifecycleServicing,
        imageStorage: ImageStorageService
    ) {
        self.wish = wish
        self.wishRepository = wishRepository
        self.conditionLifecycleService = conditionLifecycleService
        self.wishProgressService = wishProgressService
        self.lifecycleService = lifecycleService
        self.imageStorage = imageStorage
    }

    var nextSortOrder: Int {
        (conditions.map(\.sortOrder).max() ?? -1) + 1
    }

    func load() {
        isLoading = true
        error = nil

        defer { isLoading = false }

        do {
            if let refreshed = try wishRepository.fetch(id: wish.id) {
                wish = refreshed
            }

            let loadedProgress = try wishProgressService.progress(for: wish)
            progress = loadedProgress
            conditions = loadedProgress.conditions.map(\.condition)

            if let imagePath = wish.imagePath {
                do {
                    imageData = try imageStorage.loadImageData(at: imagePath)
                } catch {
                    // 图片读取失败时显示占位图，不影响详情加载。
                    imageData = nil
                }
            } else {
                imageData = nil
            }
        } catch {
            self.error = AppError.wrap(error)
        }
    }

    func deleteCondition(_ condition: Condition) {
        do {
            try conditionLifecycleService.delete(conditionID: condition.id)
            load()
        } catch {
            actionError = AppError.wrap(error)
        }
    }

    func moveConditions(from source: IndexSet, to destination: Int) {
        var reordered = conditions
        reordered.move(fromOffsets: source, toOffset: destination)

        do {
            try conditionLifecycleService.reorder(reordered)
            let loadedProgress = try wishProgressService.progress(for: wish)
            progress = loadedProgress
            conditions = loadedProgress.conditions.map(\.condition)
        } catch {
            actionError = AppError.wrap(error)
        }
    }

    func snapshot(for condition: Condition) -> ProgressSnapshot? {
        progress?.conditions.first { $0.condition.id == condition.id }?.snapshot
    }

    func completeWish() {
        do {
            try lifecycleService.complete(wishID: wish.id)
            load()
        } catch {
            actionError = AppError.wrap(error)
        }
    }
}
