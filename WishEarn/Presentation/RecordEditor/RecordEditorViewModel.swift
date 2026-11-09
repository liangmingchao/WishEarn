import Foundation
import Observation

@MainActor
@Observable
final class RecordEditorViewModel {
    private let condition: Condition
    private let existingRecord: ProgressRecord?
    private let service: ProgressRecordServicing
    private let clock: ClockProviding

    var valueText = ""
    var noteText = ""
    var recordedAt: Date

    private(set) var isSaving = false
    private(set) var isSaved = false
    var error: AppError?

    var isEditing: Bool {
        existingRecord != nil
    }

    var showsValueField: Bool {
        condition.type != .streak && condition.type != .checkpoint
    }

    var valueLabel: String {
        switch condition.type {
        case .count:
            return "本次次数"
        case .duration:
            return "本次时长（\(condition.unit ?? "分钟")）"
        case .amount:
            return "本次金额（\(condition.unit ?? "元")）"
        case .custom:
            let unit = condition.unit.map { "（\($0)）" } ?? ""
            return "本次数值\(unit)"
        case .streak, .checkpoint:
            return ""
        }
    }

    var amountDirectionText: String? {
        condition.amountDirection?.displayName
    }

    var conditionTitle: String {
        condition.title
    }

    var conditionSummary: String {
        "\(condition.type.displayName) · \(condition.targetDescription)"
    }

    init(
        condition: Condition,
        record: ProgressRecord? = nil,
        service: ProgressRecordServicing,
        clock: ClockProviding
    ) {
        self.condition = condition
        self.existingRecord = record
        self.service = service
        self.clock = clock
        self.recordedAt = record?.recordedAt ?? clock.now

        if let record {
            valueText = NSDecimalNumber(decimal: record.value).stringValue
            noteText = record.note ?? ""
        } else if condition.type == .streak || condition.type == .checkpoint {
            valueText = "1"
        }
    }

    func save() {
        guard !isSaving else { return }

        error = nil

        let value: Decimal
        if showsValueField {
            let trimmedValue = valueText
                .replacingOccurrences(of: ",", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            guard let parsed = Decimal(string: trimmedValue, locale: Locale(identifier: "en_US_POSIX")) else {
                error = .domain(.invalidInput("请输入有效的记录值。"))
                return
            }

            if condition.type == .amount {
                guard parsed >= 0 else {
                    error = .domain(.invalidInput("金额不能为负数。"))
                    return
                }
            } else {
                guard parsed > 0 else {
                    error = .domain(.invalidInput("记录值必须大于 0。"))
                    return
                }
            }
            value = parsed
        } else {
            value = 1
        }

        let trimmedNote = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        let note = trimmedNote.isEmpty ? nil : trimmedNote

        isSaving = true
        defer { isSaving = false }

        do {
            if let existingRecord {
                var updated = existingRecord
                try updated.update(
                    value: value,
                    note: note,
                    recordedAt: recordedAt,
                    now: clock.now
                )
                try service.updateRecord(updated)
            } else {
                let draft = ProgressRecordDraft(
                    conditionID: condition.id,
                    value: value,
                    note: note,
                    recordedAt: recordedAt
                )
                _ = try service.createRecord(draft)
            }
            isSaved = true
        } catch {
            self.error = AppError.wrap(error)
        }
    }
}
