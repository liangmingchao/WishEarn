import XCTest
@testable import WishEarn

@MainActor
final class ConditionLifecycleServiceTests: XCTestCase {
    private let now = TestDates.make(year: 2026, month: 11, day: 8)

    private struct SUT {
        let service: ConditionLifecycleService
        let wishRepository: MockWishRepository
        let conditionRepository: MockConditionRepository
    }

    private func makeSUT(
        unlockService: WishUnlockServicing? = nil
    ) -> SUT {
        let wishRepository = MockWishRepository()
        let conditionRepository = MockConditionRepository()
        let service = ConditionLifecycleService(
            wishRepository: wishRepository,
            conditionRepository: conditionRepository,
            clock: FixedClock(now: now, calendar: TestDates.calendar),
            unlockService: unlockService
        )
        return SUT(
            service: service,
            wishRepository: wishRepository,
            conditionRepository: conditionRepository
        )
    }

    private func makeWish() throws -> Wish {
        try Wish(title: "Kindle", createdAt: now, updatedAt: now)
    }

    private func makeDraft(
        wishID: UUID,
        type: ConditionType,
        title: String = "条件",
        targetValue: Decimal = 10,
        unit: String? = nil,
        amountDirection: AmountDirection? = nil,
        sortOrder: Int = 0
    ) -> ConditionDraft {
        ConditionDraft(
            wishID: wishID,
            title: title,
            description: nil,
            type: type,
            targetValue: targetValue,
            unit: unit,
            amountDirection: amountDirection,
            isRequired: true,
            sortOrder: sortOrder
        )
    }

    func testCreateCountConditionUsesCanonicalUnit() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)

        let condition = try sut.service.createCondition(
            makeDraft(wishID: wish.id, type: .count, targetValue: 20, unit: "  ")
        )

        XCTAssertEqual(condition.unit, "次")
        XCTAssertEqual(condition.createdAt, now)
        XCTAssertEqual(
            try sut.conditionRepository.fetchConditions(wishID: wish.id),
            [condition]
        )
    }

    func testDurationUnitHonorsRequestedUnit() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)

        let condition = try sut.service.createCondition(
            makeDraft(wishID: wish.id, type: .duration, targetValue: 90, unit: "分钟")
        )

        XCTAssertEqual(condition.unit, "分钟")
    }

    func testDurationDefaultsToHours() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)

        let condition = try sut.service.createCondition(
            makeDraft(wishID: wish.id, type: .duration, targetValue: 10)
        )

        XCTAssertEqual(condition.unit, "小时")
    }

    func testAmountRequiresDirection() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)

        XCTAssertThrowsError(
            try sut.service.createCondition(
                makeDraft(wishID: wish.id, type: .amount, targetValue: 1000)
            )
        ) { error in
            XCTAssertEqual(error as? DomainError, .invalidInput("金额条件必须指定金额方向。"))
        }
    }

    func testAmountUsesYuanUnit() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)

        let condition = try sut.service.createCondition(
            makeDraft(
                wishID: wish.id,
                type: .amount,
                targetValue: 5000,
                amountDirection: .income
            )
        )

        XCTAssertEqual(condition.unit, "元")
        XCTAssertEqual(condition.amountDirection, .income)
    }

    func testCheckpointNormalizesTargetAndUnit() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)

        let condition = try sut.service.createCondition(
            makeDraft(wishID: wish.id, type: .checkpoint, targetValue: 1, unit: "次")
        )

        XCTAssertEqual(condition.targetValue, 1)
        XCTAssertNil(condition.unit)
    }

    func testCheckpointRejectsNonOneTarget() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)

        XCTAssertThrowsError(
            try sut.service.createCondition(
                makeDraft(wishID: wish.id, type: .checkpoint, targetValue: 2)
            )
        ) { error in
            XCTAssertEqual(error as? DomainError, .invalidInput("完成型条件的目标值必须为 1。"))
        }
    }

    func testCustomUsesRequestedUnit() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)

        let condition = try sut.service.createCondition(
            makeDraft(wishID: wish.id, type: .custom, targetValue: 300, unit: "页")
        )

        XCTAssertEqual(condition.unit, "页")
    }

    func testCreateRequiresExistingWish() {
        let sut = makeSUT()

        XCTAssertThrowsError(
            try sut.service.createCondition(
                makeDraft(wishID: UUID(), type: .count)
            )
        ) { error in
            XCTAssertEqual(error as? DomainError, .notFound)
        }
    }

    func testUpdateRequiresExistingCondition() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)

        let condition = try Condition(
            wishID: wish.id,
            title: "健身",
            type: .count,
            targetValue: 20,
            createdAt: now
        )

        XCTAssertThrowsError(try sut.service.updateCondition(condition)) { error in
            XCTAssertEqual(error as? DomainError, .notFound)
        }
    }

    func testUpdateSavesCondition() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)

        let condition = try sut.service.createCondition(
            makeDraft(wishID: wish.id, type: .count, title: "健身", targetValue: 20)
        )
        let updated = try Condition(
            id: condition.id,
            wishID: condition.wishID,
            title: "力量训练",
            type: condition.type,
            targetValue: 30,
            unit: condition.unit,
            isRequired: condition.isRequired,
            sortOrder: condition.sortOrder,
            createdAt: condition.createdAt
        )

        try sut.service.updateCondition(updated)

        XCTAssertEqual(sut.conditionRepository.conditionsByWish[wish.id]?.first?.title, "力量训练")
    }

    func testUpdateRejectsWishChange() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        let otherWish = try Wish(title: "跑鞋", createdAt: now, updatedAt: now)
        try sut.wishRepository.save(wish)
        try sut.wishRepository.save(otherWish)

        let condition = try sut.service.createCondition(
            makeDraft(wishID: wish.id, type: .count)
        )
        let moved = try Condition(
            id: condition.id,
            wishID: otherWish.id,
            title: condition.title,
            type: condition.type,
            targetValue: condition.targetValue,
            unit: condition.unit,
            isRequired: condition.isRequired,
            sortOrder: condition.sortOrder,
            createdAt: condition.createdAt
        )

        XCTAssertThrowsError(try sut.service.updateCondition(moved)) { error in
            XCTAssertEqual(error as? DomainError, .invalidInput("不能修改条件所属的心愿。"))
        }
    }

    func testDeleteDelegatesToRepository() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)
        let condition = try sut.service.createCondition(
            makeDraft(wishID: wish.id, type: .count)
        )

        try sut.service.delete(conditionID: condition.id)

        XCTAssertTrue(try sut.conditionRepository.fetchConditions(wishID: wish.id).isEmpty)
    }

    func testReorderPersistsSortOrder() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)

        let first = try sut.service.createCondition(
            makeDraft(wishID: wish.id, type: .count, title: "第一", sortOrder: 0)
        )
        let second = try sut.service.createCondition(
            makeDraft(wishID: wish.id, type: .count, title: "第二", sortOrder: 1)
        )
        let third = try sut.service.createCondition(
            makeDraft(wishID: wish.id, type: .count, title: "第三", sortOrder: 2)
        )

        try sut.service.reorder([third, first, second])

        let reordered = try sut.conditionRepository.fetchConditions(wishID: wish.id)
        XCTAssertEqual(reordered.map(\.title), ["第三", "第一", "第二"])
        XCTAssertEqual(reordered.map(\.sortOrder), [0, 1, 2])
    }

    func testCreateConditionTriggersUnlockEvaluation() throws {
        let unlockService = MockWishUnlockService()
        let sut = makeSUT(unlockService: unlockService)
        let wish = try makeWish()
        try sut.wishRepository.save(wish)

        _ = try sut.service.createCondition(
            makeDraft(wishID: wish.id, type: .count)
        )

        XCTAssertEqual(unlockService.evaluatedWishIDs, [wish.id])
    }

    func testUpdateConditionTriggersUnlockEvaluation() throws {
        let unlockService = MockWishUnlockService()
        let sut = makeSUT(unlockService: unlockService)
        let wish = try makeWish()
        try sut.wishRepository.save(wish)
        let condition = try sut.service.createCondition(
            makeDraft(wishID: wish.id, type: .count, targetValue: 10)
        )
        unlockService.evaluatedWishIDs.removeAll()

        let updated = try Condition(
            id: condition.id,
            wishID: condition.wishID,
            title: condition.title,
            type: condition.type,
            targetValue: 5,
            unit: condition.unit,
            isRequired: condition.isRequired,
            sortOrder: condition.sortOrder,
            createdAt: condition.createdAt
        )
        try sut.service.updateCondition(updated)

        XCTAssertEqual(unlockService.evaluatedWishIDs, [wish.id])
    }

    func testDeleteConditionTriggersUnlockEvaluation() throws {
        let unlockService = MockWishUnlockService()
        let sut = makeSUT(unlockService: unlockService)
        let wish = try makeWish()
        try sut.wishRepository.save(wish)
        let condition = try sut.service.createCondition(
            makeDraft(wishID: wish.id, type: .count)
        )
        unlockService.evaluatedWishIDs.removeAll()

        try sut.service.delete(conditionID: condition.id)

        XCTAssertEqual(unlockService.evaluatedWishIDs, [wish.id])
    }

    func testUnlockEvaluationFailureDoesNotBlockConditionCreation() throws {
        let unlockService = MockWishUnlockService()
        unlockService.error = PersistenceError.saveFailed("解锁失败")
        let sut = makeSUT(unlockService: unlockService)
        let wish = try makeWish()
        try sut.wishRepository.save(wish)

        let condition = try sut.service.createCondition(
            makeDraft(wishID: wish.id, type: .count)
        )

        XCTAssertEqual(
            try sut.conditionRepository.fetchConditions(wishID: wish.id),
            [condition]
        )
    }
}
