import Foundation

enum ProgressRecordMapper {
    static func toDomain(_ entity: ProgressRecordEntity) throws -> ProgressRecord {
        try ProgressRecord(
            id: entity.id,
            conditionID: entity.conditionID,
            value: entity.value,
            note: entity.note,
            recordedAt: entity.recordedAt,
            createdAt: entity.createdAt,
            updatedAt: entity.updatedAt
        )
    }

    static func makeEntity(from record: ProgressRecord) -> ProgressRecordEntity {
        ProgressRecordEntity(
            id: record.id,
            conditionID: record.conditionID,
            value: record.value,
            note: record.note,
            recordedAt: record.recordedAt,
            createdAt: record.createdAt,
            updatedAt: record.updatedAt
        )
    }

    static func update(_ entity: ProgressRecordEntity, from record: ProgressRecord) {
        entity.conditionID = record.conditionID
        entity.value = record.value
        entity.note = record.note
        entity.recordedAt = record.recordedAt
        entity.createdAt = record.createdAt
        entity.updatedAt = record.updatedAt
    }
}
