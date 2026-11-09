import Foundation

@MainActor
final class WishProgressService {
    private let conditionRepository: ConditionRepository
    private let progressRepository: ProgressRepository
    private let pausePeriodRepository: WishPausePeriodRepository
    private let progressCalculator: ProgressCalculator

    init(
        conditionRepository: ConditionRepository,
        progressRepository: ProgressRepository,
        pausePeriodRepository: WishPausePeriodRepository,
        progressCalculator: ProgressCalculator
    ) {
        self.conditionRepository = conditionRepository
        self.progressRepository = progressRepository
        self.pausePeriodRepository = pausePeriodRepository
        self.progressCalculator = progressCalculator
    }

    func progress(for wish: Wish) throws -> WishProgress {
        let conditions = try conditionRepository.fetchConditions(wishID: wish.id)
        let pausePeriods = try pausePeriodRepository.fetchPeriods(wishID: wish.id)

        var items: [ConditionProgress] = []
        for condition in conditions {
            let records = try progressRepository.fetchRecords(conditionID: condition.id)
            let snapshot = progressCalculator.calculate(
                condition: condition,
                records: records,
                pausePeriods: pausePeriods
            )
            items.append(ConditionProgress(condition: condition, snapshot: snapshot))
        }

        let required = items.filter { $0.condition.isRequired }
        let completed = required.filter { $0.snapshot.isCompleted }.count

        return WishProgress(
            wish: wish,
            conditions: items,
            requiredTotal: required.count,
            requiredCompleted: completed
        )
    }
}
