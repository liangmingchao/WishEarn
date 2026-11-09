import Foundation
import Observation

@MainActor
@Observable
final class AchievementsViewModel {
    private let wishRepository: WishRepository
    private let wishProgressService: WishProgressService
    private let progressRepository: ProgressRepository
    private let imageStorage: ImageStorageService

    private(set) var unlockedWishes: [Wish] = []
    private(set) var completedWishes: [Wish] = []
    private(set) var completedConditionCount = 0
    private(set) var totalRecordCount = 0
    private(set) var images: [UUID: Data] = [:]
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    private(set) var error: AppError?

    init(
        wishRepository: WishRepository,
        wishProgressService: WishProgressService,
        progressRepository: ProgressRepository,
        imageStorage: ImageStorageService
    ) {
        self.wishRepository = wishRepository
        self.wishProgressService = wishProgressService
        self.progressRepository = progressRepository
        self.imageStorage = imageStorage
    }

    func imageData(for wish: Wish) -> Data? {
        images[wish.id]
    }

    func load() {
        isLoading = true
        error = nil

        defer {
            isLoading = false
            hasLoaded = true
        }

        do {
            let wishes = try wishRepository.fetchAll()
            let unlocked = wishes.filter { $0.status == .unlocked }
            let completed = wishes.filter { $0.status == .completed }

            var completedConditions = 0
            var recordCount = 0

            for wish in wishes {
                let progress = try wishProgressService.progress(for: wish)
                completedConditions += progress.conditions.filter { $0.snapshot.isCompleted }.count

                for item in progress.conditions {
                    recordCount += try progressRepository.fetchRecords(
                        conditionID: item.condition.id
                    ).count
                }
            }

            var loadedImages: [UUID: Data] = [:]
            for wish in unlocked + completed {
                guard let imagePath = wish.imagePath else { continue }
                do {
                    loadedImages[wish.id] = try imageStorage.loadImageData(at: imagePath)
                } catch {
                    // 图片读取失败时显示占位图，不影响成就页。
                    loadedImages[wish.id] = nil
                }
            }

            unlockedWishes = unlocked
            completedWishes = completed
            completedConditionCount = completedConditions
            totalRecordCount = recordCount
            images = loadedImages
        } catch {
            self.error = AppError.wrap(error)
        }
    }
}
