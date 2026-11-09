import Foundation
import Observation

@MainActor
@Observable
final class WishListViewModel {
    private let wishRepository: WishRepository
    private let wishProgressService: WishProgressService
    private let imageStorage: ImageStorageService
    private let lifecycleService: WishLifecycleServicing

    private(set) var wishes: [Wish] = []
    private(set) var conditionCounts: [UUID: Int] = [:]
    private(set) var progressByWish: [UUID: WishProgress] = [:]
    private(set) var images: [UUID: Data] = [:]
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    private(set) var error: AppError?
    var actionError: AppError?

    var filter: WishFilter = .all

    var activeWishCount: Int {
        wishes.filter { $0.status == .active }.count
    }

    init(
        wishRepository: WishRepository,
        wishProgressService: WishProgressService,
        imageStorage: ImageStorageService,
        lifecycleService: WishLifecycleServicing
    ) {
        self.wishRepository = wishRepository
        self.wishProgressService = wishProgressService
        self.imageStorage = imageStorage
        self.lifecycleService = lifecycleService
    }

    var filteredWishes: [Wish] {
        wishes.filter { filter.matches($0) }
    }

    func conditionCount(for wish: Wish) -> Int {
        conditionCounts[wish.id] ?? 0
    }

    func imageData(for wish: Wish) -> Data? {
        images[wish.id]
    }

    func overallProgress(for wish: Wish) -> Double? {
        progressByWish[wish.id]?.overallRatio
    }

    func delete(_ wish: Wish) {
        performLifecycleAction {
            try lifecycleService.delete(wishID: wish.id)
        }
    }

    func pause(_ wish: Wish) {
        performLifecycleAction {
            try lifecycleService.pause(wishID: wish.id)
        }
    }

    func resume(_ wish: Wish) {
        performLifecycleAction {
            try lifecycleService.resume(wishID: wish.id)
        }
    }

    func archive(_ wish: Wish) {
        performLifecycleAction {
            try lifecycleService.archive(wishID: wish.id)
        }
    }

    func complete(_ wish: Wish) {
        performLifecycleAction {
            try lifecycleService.complete(wishID: wish.id)
        }
    }

    private func performLifecycleAction(_ action: () throws -> Void) {
        do {
            try action()
            load()
        } catch {
            actionError = AppError.wrap(error)
        }
    }

    func load() {
        isLoading = true
        error = nil

        defer {
            isLoading = false
            hasLoaded = true
        }

        do {
            let fetched = try wishRepository.fetchAll()
            wishes = fetched

            var counts: [UUID: Int] = [:]
            var loadedProgress: [UUID: WishProgress] = [:]
            for wish in fetched {
                let progress = try wishProgressService.progress(for: wish)
                loadedProgress[wish.id] = progress
                counts[wish.id] = progress.conditions.count
            }
            conditionCounts = counts
            progressByWish = loadedProgress

            var loadedImages: [UUID: Data] = [:]
            for wish in fetched {
                guard let imagePath = wish.imagePath else { continue }
                do {
                    loadedImages[wish.id] = try imageStorage.loadImageData(at: imagePath)
                } catch {
                    // 图片读取失败时保留占位图，不让整个列表加载失败。
                    loadedImages[wish.id] = nil
                }
            }
            images = loadedImages
        } catch {
            self.error = AppError.wrap(error)
        }
    }
}
