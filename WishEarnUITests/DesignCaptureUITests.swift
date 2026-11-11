import XCTest

/// Produces the Issue #30 Light/Dark evidence from a real simulator run.
///
/// The tests are skipped during the normal CI suite. The evidence workflow is
/// split into three short runs because one long UI-test session is fragile on
/// the Xcode 27 simulator:
///
///     xcrun simctl uninstall booted com.wishearn.app
///     TEST_RUNNER_WISH_SEED=1 xcodebuild test ... -only-testing:WishEarnUITests/DesignCaptureUITests/testSeedFeaturedWish
///     TEST_RUNNER_WISH_SEED=1 xcodebuild test ... -only-testing:WishEarnUITests/DesignCaptureUITests/testSeedOtherWishes
///     TEST_RUNNER_WISH_SCREENSHOTS=1 xcodebuild test ... -only-testing:WishEarnUITests/DesignCaptureUITests/testCaptureIssue30Screenshots
///
/// Data is created through the shipping UI and persisted in the simulator's
/// real local store; no seeding hook ships in the app.
final class DesignCaptureUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        let environment = ProcessInfo.processInfo.environment
        try XCTSkipUnless(
            environment["WISH_SEED"] == "1"
                || environment["WISH_SCREENSHOTS"] == "1"
                || environment["WISH_PHOTO"] == "1",
            "Design evidence tests are opt-in via TEST_RUNNER_WISH_SEED, TEST_RUNNER_WISH_PHOTO or TEST_RUNNER_WISH_SCREENSHOTS."
        )

        app = XCUIApplication()
        app.launch()
        XCTAssertTrue(
            app.staticTexts["我的心愿"].waitForExistence(timeout: 15)
        )
    }

    func testSeedCameraWish() throws {
        try skipUnless("WISH_SEED")
        createWish(title: "一台新的相机")
        addCheckpointCondition(wish: "一台新的相机", title: "选好相机型号")
    }

    func testSeedReadingCornerWish() throws {
        try skipUnless("WISH_SEED")
        createWish(title: "一个可以让周末慢下来的阅读角")
        addCheckpointCondition(
            wish: "一个可以让周末慢下来的阅读角",
            title: "挑一盏温暖又不刺眼的落地灯"
        )
    }

    func testSeedTiramisuWish() throws {
        try skipUnless("WISH_SEED")
        createWish(title: "学会做提拉米苏")
        addCheckpointCondition(wish: "学会做提拉米苏", title: "买齐食材")
        addCheckpointCondition(wish: "学会做提拉米苏", title: "练习做一次")
        recordCondition(wish: "学会做提拉米苏", title: "买齐食材")
    }

    /// Must run last: the repository lists newest first, so this wish becomes
    /// the featured cover on Home.
    func testSeedPhotoForFeaturedWish() throws {
        try skipUnless("WISH_PHOTO")

        openWish("京都的秋天")
        app.buttons["更多操作"].tap()
        let edit = app.buttons["编辑心愿"]
        XCTAssertTrue(edit.waitForExistence(timeout: 5))
        edit.tap()

        let addPhoto = app.buttons["添加心愿照片"]
        let changePhoto = app.buttons["更换照片"]
        if addPhoto.waitForExistence(timeout: 3) {
            addPhoto.tap()
        } else {
            XCTAssertTrue(changePhoto.waitForExistence(timeout: 5))
            changePhoto.tap()
        }

        sleep(3)

        let cell = app.collectionViews.cells.firstMatch
        let image = app.images.firstMatch
        if cell.waitForExistence(timeout: 5) {
            cell.tap()
        } else if image.waitForExistence(timeout: 5) {
            image.tap()
        }

        if app.buttons["添加"].waitForExistence(timeout: 3) {
            app.buttons["添加"].tap()
        } else if app.buttons["完成"].waitForExistence(timeout: 3) {
            app.buttons["完成"].tap()
        }

        let save = app.buttons["保存"].firstMatch
        XCTAssertTrue(save.waitForExistence(timeout: 8))
        save.tap()
        XCTAssertTrue(app.buttons["更多操作"].waitForExistence(timeout: 10))
    }

    /// Must run last: the repository lists newest first, so this wish becomes
    /// the featured cover on Home.
    func testSeedFeaturedWish() throws {
        try skipUnless("WISH_SEED")
        createWish(title: "京都的秋天", price: "6000")
        addCheckpointCondition(wish: "京都的秋天", title: "订好机票")
        addCheckpointCondition(wish: "京都的秋天", title: "存下旅行基金")
        addCheckpointCondition(wish: "京都的秋天", title: "整理旅行清单")
        recordCondition(wish: "京都的秋天", title: "订好机票")
        recordCondition(wish: "京都的秋天", title: "存下旅行基金")
    }

    func testCaptureLightScreenshots() throws {
        try skipUnless("WISH_SCREENSHOTS")
        XCTAssertTrue(
            app.descendants(matching: .any)["wishCard-京都的秋天"]
                .waitForExistence(timeout: 10)
        )

        capture("home-light")
        app.swipeUp()
        capture("home-scrolled-light")
        scrollToTop()

        openWish("京都的秋天")
        capture("detail-light")
        app.navigationBars.buttons.firstMatch.tap()

        app.tabBars.buttons["行动"].tap()
        XCTAssertTrue(
            app.staticTexts["今天，慢慢来"].waitForExistence(timeout: 5)
        )
        capture("today-light")

        app.tabBars.buttons["心愿"].tap()
        openWish("一个可以让周末慢下来的阅读角")
        capture("detail-long-title-light")
        app.navigationBars.buttons.firstMatch.tap()

        app.tabBars.buttons["行动"].tap()
        capture("today-long-condition-light")
    }

    func testCaptureDarkScreenshots() throws {
        try skipUnless("WISH_SCREENSHOTS")
        XCTAssertTrue(
            app.descendants(matching: .any)["wishCard-京都的秋天"]
                .waitForExistence(timeout: 10)
        )

        capture("home-dark")

        openWish("京都的秋天")
        capture("detail-dark")
        app.navigationBars.buttons.firstMatch.tap()

        app.tabBars.buttons["行动"].tap()
        XCTAssertTrue(
            app.staticTexts["今天，慢慢来"].waitForExistence(timeout: 5)
        )
        capture("today-dark")
    }

    // MARK: - Environment gates

    private func skipUnless(_ key: String) throws {
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment[key] == "1",
            "Set TEST_RUNNER_\(key)=1 to run the design evidence workflow."
        )
    }

    // MARK: - Data creation

    private func createWish(title: String, price: String? = nil) {
        scrollToTop()
        let existing = app.descendants(matching: .any)["wishCard-\(title)"]
        if existing.waitForExistence(timeout: 2) {
            return
        }

        let emptyButton = app.buttons["创建第一个心愿"]
        let toolbarButton = app.buttons["创建心愿"]
        if emptyButton.waitForExistence(timeout: 2) {
            emptyButton.tap()
        } else {
            XCTAssertTrue(toolbarButton.waitForExistence(timeout: 5))
            toolbarButton.tap()
        }

        typeInto(app.textFields["wishTitleField"], title)

        if let price {
            let priceField = app.textFields["0.00"]
            if priceField.waitForExistence(timeout: 2) {
                typeInto(priceField, price)
            }
        }

        app.buttons["保存"].firstMatch.tap()

        let card = app.descendants(matching: .any)["wishCard-\(title)"]
        var found = card.waitForExistence(timeout: 5)
        var swipes = 0
        while !found && swipes < 8 {
            app.swipeUp()
            found = card.waitForExistence(timeout: 2)
            swipes += 1
        }
        XCTAssertTrue(found)
        scrollToTop()
    }

    private func addCheckpointCondition(wish: String, title: String) {
        openWish(wish)
        if app.staticTexts[title].firstMatch.waitForExistence(timeout: 1) {
            app.navigationBars.buttons.firstMatch.tap()
            return
        }

        let first = app.buttons["添加第一个解锁条件"]
        if first.waitForExistence(timeout: 2) {
            scrollToHittable(first)
            first.tap()
        } else {
            let add = app.buttons["添加条件"]
            XCTAssertTrue(add.waitForExistence(timeout: 5))
            scrollToHittable(add)
            add.tap()
        }

        typeInto(app.textFields["conditionTitleField"], title)

        let typeButton = app.buttons["conditionTypeField"]
        XCTAssertTrue(typeButton.waitForExistence(timeout: 5))
        scrollToHittable(typeButton)
        typeButton.tap()

        let checkpoint = app.buttons["目标完成"]
        XCTAssertTrue(checkpoint.waitForExistence(timeout: 5))
        checkpoint.tap()

        app.buttons["保存"].firstMatch.tap()
        XCTAssertTrue(
            app.buttons["更多操作"].waitForExistence(timeout: 10)
        )
        app.navigationBars.buttons.firstMatch.tap()
    }

    private func recordCondition(wish: String, title: String) {
        openWish(wish)
        let record = app.buttons["记录\(title)"]
        if !record.waitForExistence(timeout: 2) {
            // Already completed on a previous attempt.
            app.navigationBars.buttons.firstMatch.tap()
            return
        }
        scrollToHittable(record)
        record.tap()

        XCTAssertTrue(
            app.staticTexts["标记为已完成"].waitForExistence(timeout: 5)
        )

        app.buttons["保存"].firstMatch.tap()
        XCTAssertTrue(
            app.buttons["更多操作"].waitForExistence(timeout: 10)
        )
        app.navigationBars.buttons.firstMatch.tap()
    }

    // MARK: - Navigation and capture

    private func openWish(_ title: String) {
        scrollToTop()
        let card = app.descendants(matching: .any)["wishCard-\(title)"]
        var found = card.waitForExistence(timeout: 5)
        var swipes = 0
        while !found && swipes < 8 {
            app.swipeUp()
            found = card.waitForExistence(timeout: 2)
            swipes += 1
        }
        XCTAssertTrue(found)

        scrollToHittable(card)
        card.tap()
        XCTAssertTrue(
            app.buttons["更多操作"].waitForExistence(timeout: 10)
        )
    }

    private func typeInto(_ field: XCUIElement, _ text: String) {
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        scrollToHittable(field)
        sleep(1)
        field.tap()
        sleep(1)
        field.typeText(text)
    }

    private func scrollToTop() {
        for _ in 0..<4 {
            app.swipeDown()
        }
    }

    private func scrollToHittable(_ element: XCUIElement, attempts: Int = 8) {
        var remaining = attempts
        while !element.isHittable && remaining > 0 {
            app.swipeUp()
            remaining -= 1
        }
    }

    private func capture(_ name: String) {
        sleep(1)
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
