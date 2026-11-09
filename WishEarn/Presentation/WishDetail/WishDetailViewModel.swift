import Foundation
import Observation

struct WishRecentRecord: Identifiable, Equatable {
    let record: ProgressRecord
    let condition: Condition

    var id: UUID { record.id }

    var conditionTitle: String {
        condition.title
    }

    var valueText: String {
        switch condition.type {
        case .checkpoint:
            return "已完成"
        case .streak:
            return "打卡"
        default:
            let value = NSDecimalNumber(decimal: record.value).stringValue
            if let unit = condition.unit {
                return "\(value) \(unit)"
            }
            return value
        }
    }
}

@MainActor
@Observable
final class WishDetailViewModel {
    private let wishRepository: WishRepository
    private let conditionLifecycleService: ConditionLifecycleServicing
    private let wishProgressService: WishProgressService
    private let lifecycleService: WishLifecycleServicing
    private let imageStorage: ImageStorageService
    private let progressRepository: ProgressRepository
    private let clock: ClockProviding

    private(set) var wish: Wish
    private(set) var conditions: [Condition] = []
    private(set) var progress: WishProgress?
    private(set) var imageData: Data?
    private(set) var recentRecords: [WishRecentRecord] = []
    private(set) var isLoading = false
    private(set) var error: AppError?
    var actionError: AppError?

    private var recordsByCondition: [UUID: [ProgressRecord]] = [:]

    init(
        wish: Wish,
        wishRepository: WishRepository,
        conditionLifecycleService: ConditionLifecycleServicing,
        wishProgressService: WishProgressService,
        lifecycleService: WishLifecycleServicing,
        imageStorage: ImageStorageService,
        progressRepository: ProgressRepository,
        clock: ClockProviding
    ) {
        self.wish = wish
        self.wishRepository = wishRepository
        self.conditionLifecycleService = conditionLifecycleService
        self.wishProgressService = wishProgressService
        self.lifecycleService = lifecycleService
        self.imageStorage = imageStorage
        self.progressRepository = progressRepository
        self.clock = clock
    }

    var nextSortOrder: Int {
        (conditions.map(\.sortOrder).max() ?? -1) + 1
    }

    var progressSummary: WishProgressSummary? {
        guard let progress, progress.requiredTotal > 0 else { return nil }
        return WishProgressSummary(
            completedConditionCount: progress.requiredCompleted,
            totalConditionCount: progress.requiredTotal
        )
    }

    var hasOptionalConditionsOnly: Bool {
        !conditions.isEmpty && progress?.requiredTotal == 0
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

            var loadedRecords: [UUID: [ProgressRecord]] = [:]
            var recordsWithConditions: [WishRecentRecord] = []

            for condition in conditions {
                let records = try progressRepository.fetchRecords(
                    conditionID: condition.id
                )
                loadedRecords[condition.id] = records
                recordsWithConditions.append(
                    contentsOf: records.map {
                        WishRecentRecord(record: $0, condition: condition)
                    }
                )
            }

            recordsByCondition = loadedRecords
            recentRecords = Array(
                recordsWithConditions
                    .sorted { $0.record.recordedAt > $1.record.recordedAt }
                    .prefix(3)
            )

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

    func canRecord(for condition: Condition) -> Bool {
        guard wish.status == .active else { return false }
        let records = recordsByCondition[condition.id] ?? []

        switch condition.type {
        case .checkpoint:
            return records.isEmpty
        case .streak:
            return !records.contains {
                clock.calendar.isDate($0.recordedAt, inSameDayAs: clock.now)
            }
        case .count, .duration, .amount, .custom:
            return true
        }
    }

    func pauseWish() {
        performLifecycleAction {
            try lifecycleService.pause(wishID: wish.id)
        }
    }

    func resumeWish() {
        performLifecycleAction {
            try lifecycleService.resume(wishID: wish.id)
        }
    }

    func archiveWish() {
        performLifecycleAction {
            try lifecycleService.archive(wishID: wish.id)
        }
    }

    func completeWish() {
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
}
