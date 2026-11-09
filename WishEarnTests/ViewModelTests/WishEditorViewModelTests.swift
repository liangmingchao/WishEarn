import XCTest
@testable import WishEarn

@MainActor
final class WishEditorViewModelTests: XCTestCase {
    private let now = TestDates.make(year: 2026, month: 11, day: 8)

    private func makeSUT() -> (WishEditorViewModel, MockWishRepository, MockImageStorageService) {
        let repository = MockWishRepository()
        let imageStorage = MockImageStorageService()
        let clock = FixedClock(now: now, calendar: TestDates.calendar)
        let lifecycleService = WishLifecycleService(
            wishRepository: repository,
            pausePeriodRepository: MockWishPausePeriodRepository(),
            clock: clock
        )
        let viewModel = WishEditorViewModel(
            lifecycleService: lifecycleService,
            imageStorage: imageStorage,
            clock: clock
        )
        return (viewModel, repository, imageStorage)
    }

    private func makeEditingSUT(
        wish: Wish
    ) -> (WishEditorViewModel, MockWishRepository, MockImageStorageService) {
        let repository = MockWishRepository()
        repository.wishes = [wish]
        let imageStorage = MockImageStorageService()
        let clock = FixedClock(now: now, calendar: TestDates.calendar)
        let lifecycleService = WishLifecycleService(
            wishRepository: repository,
            pausePeriodRepository: MockWishPausePeriodRepository(),
            clock: clock
        )
        let viewModel = WishEditorViewModel(
            lifecycleService: lifecycleService,
            imageStorage: imageStorage,
            clock: clock,
            editingWish: wish
        )
        return (viewModel, repository, imageStorage)
    }

    func testSaveCreatesWish() throws {
        let (viewModel, repository, _) = makeSUT()
        viewModel.title = "  Kindle Paperwhite  "
        viewModel.descriptionText = "阅读目标"
        viewModel.priceText = "1,099.00"

        viewModel.save()

        XCTAssertTrue(viewModel.isSaved)
        XCTAssertNil(viewModel.error)
        XCTAssertEqual(repository.wishes.count, 1)

        let saved = try XCTUnwrap(repository.wishes.first)
        XCTAssertEqual(saved.title, "Kindle Paperwhite")
        XCTAssertEqual(saved.description, "阅读目标")
        XCTAssertEqual(saved.targetPrice, Decimal(string: "1099.00"))
        XCTAssertEqual(saved.currencyCode, "CNY")
        XCTAssertEqual(saved.status, .active)
        XCTAssertEqual(saved.createdAt, now)
        XCTAssertEqual(saved.updatedAt, now)
        XCTAssertNil(saved.imagePath)
    }

    func testSaveWithoutOptionalFields() throws {
        let (viewModel, repository, _) = makeSUT()
        viewModel.title = "Kindle"

        viewModel.save()

        let saved = try XCTUnwrap(repository.wishes.first)
        XCTAssertNil(saved.description)
        XCTAssertNil(saved.targetPrice)
        XCTAssertNil(saved.targetDate)
    }

    func testSavePersistsSelectedImage() throws {
        let (viewModel, repository, imageStorage) = makeSUT()
        let imageData = Data([1, 2, 3])
        viewModel.title = "Kindle"
        viewModel.selectedImageData = imageData

        viewModel.save()

        XCTAssertEqual(imageStorage.savedData, imageData)
        let saved = try XCTUnwrap(repository.wishes.first)
        XCTAssertEqual(saved.imagePath, imageStorage.savePath)
        XCTAssertEqual(imageStorage.savedWishID, saved.id)
    }

    func testSaveCleansUpImageWhenWishSaveFails() {
        let (viewModel, repository, imageStorage) = makeSUT()
        repository.error = PersistenceError.saveFailed("磁盘已满")
        viewModel.title = "Kindle"
        viewModel.selectedImageData = Data([1, 2, 3])

        viewModel.save()

        XCTAssertEqual(imageStorage.deletedPaths, [imageStorage.savePath])
        XCTAssertEqual(viewModel.error, .persistence(.saveFailed("磁盘已满")))
        XCTAssertFalse(viewModel.isSaved)
    }

    func testRemoveSelectedImage() {
        let (viewModel, _, _) = makeSUT()
        viewModel.selectedImageData = Data([1, 2, 3])

        viewModel.removeSelectedImage()

        XCTAssertNil(viewModel.selectedImageData)
        XCTAssertNil(viewModel.selectedPhotoItem)
    }

    func testSaveRejectsEmptyTitle() {
        let (viewModel, repository, _) = makeSUT()
        viewModel.title = "   "

        viewModel.save()

        XCTAssertEqual(viewModel.error, .domain(.invalidInput("请输入心愿名称。")))
        XCTAssertFalse(viewModel.isSaved)
        XCTAssertTrue(repository.wishes.isEmpty)
    }

    func testCanSaveRequiresValidFields() {
        let (viewModel, _, _) = makeSUT()

        XCTAssertFalse(viewModel.canSave)
        XCTAssertEqual(viewModel.titleHelperText, "必填")

        viewModel.title = "Kindle"
        XCTAssertTrue(viewModel.canSave)
        XCTAssertNil(viewModel.titleHelperText)

        viewModel.priceText = "abc"
        XCTAssertFalse(viewModel.canSave)
        XCTAssertEqual(viewModel.priceValidationMessage, "参考价格格式不正确。")

        viewModel.priceText = "1,099"
        XCTAssertTrue(viewModel.canSave)
        XCTAssertNil(viewModel.priceValidationMessage)

        viewModel.hasTargetDate = true
        viewModel.targetDate = now.addingTimeInterval(-86_400)
        XCTAssertFalse(viewModel.canSave)
        XCTAssertEqual(
            viewModel.targetDateValidationMessage,
            "目标日期不能早于今天。"
        )

        viewModel.targetDate = now
        XCTAssertTrue(viewModel.canSave)
    }

    func testCancelledPhotoSelectionPreservesExistingImage() async {
        let (viewModel, _, _) = makeSUT()
        viewModel.selectedImageData = Data([1, 2])

        await viewModel.loadSelectedImage(from: nil)

        XCTAssertEqual(viewModel.selectedImageData, Data([1, 2]))
    }

    func testCurrencyPresentationUsesPersistedCode() throws {
        let wish = try Wish(
            title: "Kindle",
            targetPrice: 10,
            currencyCode: "USD",
            createdAt: now,
            updatedAt: now
        )
        let (viewModel, _, _) = makeEditingSUT(wish: wish)

        XCTAssertEqual(viewModel.currencyCode, "USD")
        XCTAssertTrue(viewModel.currencySummary.contains("USD"))
        XCTAssertFalse(viewModel.currencySymbol.isEmpty)
    }

    func testSaveRejectsInvalidPrice() {
        let (viewModel, repository, _) = makeSUT()
        viewModel.title = "Kindle"
        viewModel.priceText = "abc"

        viewModel.save()

        XCTAssertEqual(viewModel.error, .domain(.invalidInput("参考价格格式不正确。")))
        XCTAssertFalse(viewModel.isSaved)
        XCTAssertTrue(repository.wishes.isEmpty)
    }

    func testSaveRejectsPastTargetDate() {
        let (viewModel, repository, _) = makeSUT()
        viewModel.title = "Kindle"
        viewModel.hasTargetDate = true
        viewModel.targetDate = now.addingTimeInterval(-86_400)

        viewModel.save()

        XCTAssertEqual(viewModel.error, .domain(.invalidInput("目标日期不能早于今天。")))
        XCTAssertFalse(viewModel.isSaved)
        XCTAssertTrue(repository.wishes.isEmpty)
    }

    func testSaveMapsRepositoryError() {
        let (viewModel, repository, _) = makeSUT()
        repository.error = PersistenceError.saveFailed("磁盘已满")
        viewModel.title = "Kindle"

        viewModel.save()

        XCTAssertEqual(viewModel.error, .persistence(.saveFailed("磁盘已满")))
        XCTAssertFalse(viewModel.isSaved)
    }

    func testEditPrefillsFields() throws {
        let targetDate = TestDates.make(year: 2026, month: 11, day: 15)
        let price = try XCTUnwrap(Decimal(string: "1099.50"))
        let wish = try Wish(
            title: "Kindle",
            description: "阅读目标",
            targetPrice: price,
            targetDate: targetDate,
            createdAt: now,
            updatedAt: now
        )

        let (viewModel, _, _) = makeEditingSUT(wish: wish)

        XCTAssertTrue(viewModel.isEditing)
        XCTAssertEqual(viewModel.title, "Kindle")
        XCTAssertEqual(viewModel.descriptionText, "阅读目标")
        XCTAssertEqual(try XCTUnwrap(Decimal(string: viewModel.priceText)), price)
        XCTAssertTrue(viewModel.hasTargetDate)
        XCTAssertEqual(viewModel.targetDate, targetDate)
    }

    func testEditUpdatesWishAndPreservesIdentity() throws {
        let originalCreatedAt = TestDates.make(year: 2026, month: 11, day: 1)
        let wish = try Wish(
            title: "Kindle",
            targetPrice: 1099,
            status: .paused,
            createdAt: originalCreatedAt,
            updatedAt: originalCreatedAt
        )
        let (viewModel, repository, imageStorage) = makeEditingSUT(wish: wish)
        viewModel.title = "Kindle Paperwhite"
        viewModel.priceText = "1299"

        viewModel.save()

        XCTAssertTrue(viewModel.isSaved)
        let updated = try XCTUnwrap(repository.wishes.first)
        XCTAssertEqual(updated.id, wish.id)
        XCTAssertEqual(updated.title, "Kindle Paperwhite")
        XCTAssertEqual(updated.targetPrice, Decimal(1299))
        XCTAssertEqual(updated.status, .paused)
        XCTAssertEqual(updated.createdAt, originalCreatedAt)
        XCTAssertEqual(updated.updatedAt, now)
        XCTAssertNil(imageStorage.savedData)
        XCTAssertTrue(imageStorage.deletedPaths.isEmpty)
    }

    func testEditPreservesImageWhenUntouched() throws {
        let wish = try Wish(
            title: "Kindle",
            imagePath: "WishImages/old.jpg",
            createdAt: now,
            updatedAt: now
        )
        let (viewModel, repository, imageStorage) = makeEditingSUT(wish: wish)
        imageStorage.storedImages["WishImages/old.jpg"] = Data([1, 2])

        viewModel.loadExistingImageIfNeeded()
        XCTAssertEqual(viewModel.selectedImageData, Data([1, 2]))

        viewModel.title = "Kindle 2"
        viewModel.save()

        let updated = try XCTUnwrap(repository.wishes.first)
        XCTAssertEqual(updated.imagePath, "WishImages/old.jpg")
        XCTAssertNil(imageStorage.savedData)
        XCTAssertTrue(imageStorage.deletedPaths.isEmpty)
    }

    func testEditRemovesImage() throws {
        let wish = try Wish(
            title: "Kindle",
            imagePath: "WishImages/old.jpg",
            createdAt: now,
            updatedAt: now
        )
        let (viewModel, repository, imageStorage) = makeEditingSUT(wish: wish)
        viewModel.title = "Kindle 2"

        viewModel.removeSelectedImage()
        viewModel.save()

        XCTAssertNil(repository.wishes.first?.imagePath)
        XCTAssertEqual(imageStorage.deletedPaths, ["WishImages/old.jpg"])
    }

    func testEditReplacesImage() throws {
        let wish = try Wish(
            title: "Kindle",
            imagePath: "WishImages/old.jpg",
            createdAt: now,
            updatedAt: now
        )
        let (viewModel, repository, imageStorage) = makeEditingSUT(wish: wish)
        viewModel.title = "Kindle 2"
        viewModel.selectedImageData = Data([9, 9])

        viewModel.save()

        XCTAssertEqual(imageStorage.savedData, Data([9, 9]))
        XCTAssertEqual(repository.wishes.first?.imagePath, imageStorage.savePath)
        XCTAssertEqual(imageStorage.deletedPaths, ["WishImages/old.jpg"])
    }

    func testEditCleansUpNewImageWhenWishSaveFails() throws {
        let wish = try Wish(
            title: "Kindle",
            imagePath: "WishImages/old.jpg",
            createdAt: now,
            updatedAt: now
        )
        let (viewModel, repository, imageStorage) = makeEditingSUT(wish: wish)
        repository.error = PersistenceError.saveFailed("磁盘已满")
        viewModel.title = "Kindle 2"
        viewModel.selectedImageData = Data([9, 9])

        viewModel.save()

        XCTAssertEqual(imageStorage.deletedPaths, [imageStorage.savePath])
        XCTAssertEqual(viewModel.error, .persistence(.saveFailed("磁盘已满")))
        XCTAssertFalse(viewModel.isSaved)
    }
}
