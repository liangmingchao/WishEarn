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
            return "本次时长"
        case .amount:
            return "本次金额"
        case .custom:
            return "本次数值"
        case .streak, .checkpoint:
            return ""
        }
    }

    /// The unit is displayed next to the input, not buried in the field label.
    var valueUnit: String? {
        switch condition.type {
        case .count:
            return condition.unit ?? "次"
        case .duration:
            return condition.unit ?? "分钟"
        case .amount:
            return condition.unit ?? "元"
        case .custom:
            return condition.unit
        case .streak, .checkpoint:
            return nil
        }
    }

    var valueValidationMessage: String? {
        guard showsValueField else { return nil }

        let trimmed = normalizedValueText
        guard !trimmed.isEmpty else { return nil }

        guard let parsed = Decimal(
            string: trimmed,
            locale: Locale(identifier: "en_US_POSIX")
        ) else {
            return "请输入有效的记录值。"
        }

        if condition.type == .amount {
            return parsed >= 0 ? nil : "金额不能为负数。"
        }

        return parsed > 0 ? nil : "记录值必须大于 0。"
    }

    var canSave: Bool {
        guard !isSaving else { return false }
        guard showsValueField else { return true }
        guard !normalizedValueText.isEmpty else { return false }
        return valueValidationMessage == nil
    }

    var completionTitle: String {
        if isEditing {
            return "修改完成记录"
        }

        switch condition.type {
        case .streak:
            return "记录一次完成"
        case .checkpoint:
            return "标记为已完成"
        default:
            return ""
        }
    }

    var completionMessage: String {
        if isEditing {
            return "保存后更新这条记录，并重新计算进度。"
        }

        switch condition.type {
        case .streak:
            return "保存后按记录日期计入连续天数。"
        case .checkpoint:
            return "完成一次即可达成，保存后不可重复记录。"
        default:
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
        if condition.type == .checkpoint {
            return condition.type.displayName
        }
        return "\(condition.type.displayName) · \(condition.targetDescription)"
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
        } else {
            // COUNT / CUSTOM 的“1”是最常见的单次行动，预填后可以直接保存。
            // DURATION / AMOUNT 不预填：1 分钟或 1 元更可能是误存，保留显式输入。
            switch condition.type {
            case .streak, .checkpoint, .count, .custom:
                valueText = "1"
            case .duration, .amount:
                valueText = ""
            }
        }
    }

    func save() {
        guard !isSaving else { return }

        error = nil

        let value: Decimal
        if showsValueField {
            guard let parsed = Decimal(
                string: normalizedValueText,
                locale: Locale(identifier: "en_US_POSIX")
            ) else {
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

    private var normalizedValueText: String {
        valueText
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
