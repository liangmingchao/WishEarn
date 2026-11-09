import Foundation

struct ProgressRecordDraft: Equatable {
    var conditionID: UUID
    var value: Decimal
    var note: String?
    var recordedAt: Date
}
