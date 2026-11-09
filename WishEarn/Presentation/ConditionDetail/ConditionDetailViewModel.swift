import Foundation
import Observation

@MainActor
@Observable
final class ConditionDetailViewModel {
    let condition: Condition

    private let service: ProgressRecordServicing

    private(set) var records: [ProgressRecord] = []
    private(set) var isLoading = false
    private(set) var error: AppError?
    var actionError: AppError?

    init(condition: Condition, service: ProgressRecordServicing) {
        self.condition = condition
        self.service = service
    }

    var totalValue: Decimal {
        records.reduce(Decimal(0)) { $0 + $1.value }
    }

    var summaryText: String {
        switch condition.type {
        case .count, .duration, .amount, .custom:
            let total = NSDecimalNumber(decimal: totalValue).stringValue
            let target = NSDecimalNumber(decimal: condition.targetValue).stringValue
            let unit = condition.unit.map { " \($0)" } ?? ""
            return "累计 \(total) / \(target)\(unit)"
        case .streak:
            return "已记录 \(records.count) 天"
        case .checkpoint:
            return records.isEmpty ? "未完成" : "已完成"
        }
    }

    var conditionSummary: String {
        "\(condition.type.displayName) · \(condition.targetDescription)"
    }

    func load() {
        isLoading = true
        error = nil

        defer { isLoading = false }

        do {
            records = try service.records(conditionID: condition.id)
        } catch {
            self.error = AppError.wrap(error)
        }
    }

    func deleteRecord(_ record: ProgressRecord) {
        do {
            try service.delete(recordID: record.id)
            load()
        } catch {
            actionError = AppError.wrap(error)
        }
    }
}
