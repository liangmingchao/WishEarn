import XCTest
@testable import WishEarn

@MainActor
final class WishLifecycleServiceTests: XCTestCase {
    private let now = TestDates.make(year: 2026, month: 11, day: 8)

    private struct SUT {
        let service: WishLifecycleService
        let wishRepository: MockWishRepository
        let pauseRepository: MockWishPausePeriodRepository
    }

    private func makeSUT() -> SUT {
        let wishRepository = MockWishRepository()
        let pauseRepository = MockWishPausePeriodRepository()
        let service = WishLifecycleService(
            wishRepository: wishRepository,
            pausePeriodRepository: pauseRepository,
            clock: FixedClock(now: now, calendar: TestDates.calendar)
        )
        return SUT(
            service: service,
            wishRepository: wishRepository,
            pauseRepository: pauseRepository
        )
    }

    private func makeWish(status: WishStatus = .active) throws -> Wish {
        try Wish(
            title: "Kindle",
            status: status,
            createdAt: now,
            updatedAt: now
        )
    }

    func testCreateWishSavesActiveWish() throws {
        let sut = makeSUT()
        let wish = try makeWish()

        try sut.service.createWish(wish)

        XCTAssertEqual(sut.wishRepository.wishes, [wish])
    }

    func testCreateWishRejectsNonActiveStatus() throws {
        let sut = makeSUT()
        let wish = try makeWish(status: .paused)

        XCTAssertThrowsError(try sut.service.createWish(wish)) { error in
            XCTAssertEqual(error as? DomainError, .invalidInput("新心愿必须处于进行中状态。"))
        }
    }

    func testUpdateWishRequiresExistingWish() throws {
        let sut = makeSUT()
        let wish = try makeWish()

        XCTAssertThrowsError(try sut.service.updateWish(wish)) { error in
            XCTAssertEqual(error as? DomainError, .notFound)
        }
    }

    func testUpdateWishSavesExistingWish() throws {
        let sut = makeSUT()
        var wish = try makeWish()
        try sut.wishRepository.save(wish)

        let later = TestDates.make(year: 2026, month: 11, day: 9)
        try wish.updateDetails(
            title: "Kindle 2",
            description: nil,
            imagePath: nil,
            targetPrice: nil,
            currencyCode: "CNY",
            targetDate: nil,
            now: later
        )
        try sut.service.updateWish(wish)

        XCTAssertEqual(sut.wishRepository.wishes.first?.title, "Kindle 2")
    }

    func testPauseActiveWishCreatesOpenPeriod() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)

        try sut.service.pause(wishID: wish.id)

        XCTAssertEqual(sut.wishRepository.wishes.first?.status, .paused)
        XCTAssertEqual(sut.pauseRepository.periods.count, 1)
        XCTAssertEqual(sut.pauseRepository.periods.first?.startedAt, now)
        XCTAssertTrue(sut.pauseRepository.periods.first?.isOpen == true)
    }

    func testPauseRejectsNonActiveWish() throws {
        let sut = makeSUT()
        let wish = try makeWish(status: .paused)
        try sut.wishRepository.save(wish)

        XCTAssertThrowsError(try sut.service.pause(wishID: wish.id)) { error in
            XCTAssertEqual(
                error as? DomainError,
                .invalidStateTransition(from: "paused", to: "paused")
            )
        }
        XCTAssertTrue(sut.pauseRepository.periods.isEmpty)
    }

    func testResumePausedWishClosesPeriod() throws {
        let sut = makeSUT()
        let wish = try makeWish(status: .paused)
        try sut.wishRepository.save(wish)

        let period = try WishPausePeriod(
            wishID: wish.id,
            startedAt: TestDates.make(year: 2026, month: 11, day: 7)
        )
        try sut.pauseRepository.save(period)

        try sut.service.resume(wishID: wish.id)

        XCTAssertEqual(sut.wishRepository.wishes.first?.status, .active)
        XCTAssertEqual(sut.pauseRepository.periods.first?.endedAt, now)
    }

    func testResumeRejectsActiveWish() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)

        XCTAssertThrowsError(try sut.service.resume(wishID: wish.id)) { error in
            XCTAssertEqual(
                error as? DomainError,
                .invalidStateTransition(from: "active", to: "active")
            )
        }
    }

    func testResumeWithoutOpenPeriodThrows() throws {
        let sut = makeSUT()
        let wish = try makeWish(status: .paused)
        try sut.wishRepository.save(wish)

        XCTAssertThrowsError(try sut.service.resume(wishID: wish.id)) { error in
            XCTAssertEqual(error as? DomainError, .invalidInput("暂停记录缺失，无法恢复心愿。"))
        }
    }

    func testArchiveActiveWish() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)

        try sut.service.archive(wishID: wish.id)

        XCTAssertEqual(sut.wishRepository.wishes.first?.status, .archived)
    }

    func testArchivePausedWishClosesOpenPeriod() throws {
        let sut = makeSUT()
        let wish = try makeWish(status: .paused)
        try sut.wishRepository.save(wish)

        let period = try WishPausePeriod(wishID: wish.id, startedAt: now)
        try sut.pauseRepository.save(period)

        try sut.service.archive(wishID: wish.id)

        XCTAssertEqual(sut.wishRepository.wishes.first?.status, .archived)
        XCTAssertEqual(sut.pauseRepository.periods.first?.endedAt, now)
    }

    func testArchiveRejectsCompletedWish() throws {
        let sut = makeSUT()
        let wish = try makeWish(status: .completed)
        try sut.wishRepository.save(wish)

        XCTAssertThrowsError(try sut.service.archive(wishID: wish.id)) { error in
            XCTAssertEqual(
                error as? DomainError,
                .invalidStateTransition(from: "completed", to: "archived")
            )
        }
    }

    func testCompleteUnlockedWishSetsCompletedAt() throws {
        let sut = makeSUT()
        let wish = try makeWish(status: .unlocked)
        try sut.wishRepository.save(wish)

        try sut.service.complete(wishID: wish.id)

        XCTAssertEqual(sut.wishRepository.wishes.first?.status, .completed)
        XCTAssertEqual(sut.wishRepository.wishes.first?.completedAt, now)
    }

    func testCompleteRejectsActiveWish() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)

        XCTAssertThrowsError(try sut.service.complete(wishID: wish.id)) { error in
            XCTAssertEqual(
                error as? DomainError,
                .invalidStateTransition(from: "active", to: "completed")
            )
        }
    }

    func testDeleteWishDelegatesToRepository() throws {
        let sut = makeSUT()
        let wish = try makeWish()
        try sut.wishRepository.save(wish)

        try sut.service.delete(wishID: wish.id)

        XCTAssertTrue(sut.wishRepository.wishes.isEmpty)
    }
}
