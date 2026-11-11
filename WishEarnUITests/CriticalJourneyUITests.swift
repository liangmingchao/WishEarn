import XCTest

final class CriticalJourneyUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCreateConditionRecordUnlockAndClaim() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()

        let createWish = app.buttons["创建第一个心愿"]
        XCTAssertTrue(createWish.waitForExistence(timeout: 10))
        createWish.tap()

        let wishTitle = app.textFields["wishTitleField"]
        XCTAssertTrue(wishTitle.waitForExistence(timeout: 5))
        wishTitle.tap()
        wishTitle.typeText("Kindle Paperwhite")
        app.buttons["保存"].firstMatch.tap()

        let wishCard = app.descendants(matching: .any)["wishCard-Kindle Paperwhite"]
        XCTAssertTrue(wishCard.waitForExistence(timeout: 10))
        wishCard.tap()

        let addCondition = app.buttons["添加第一个解锁条件"]
        XCTAssertTrue(addCondition.waitForExistence(timeout: 5))
        addCondition.tap()

        let conditionTitle = app.textFields["conditionTitleField"]
        XCTAssertTrue(conditionTitle.waitForExistence(timeout: 5))
        conditionTitle.tap()
        conditionTitle.typeText("完成第一版")

        let typeMenu = app.buttons["conditionTypeField"]
        XCTAssertTrue(typeMenu.waitForExistence(timeout: 5))
        typeMenu.tap()

        let checkpoint = app.buttons["目标完成"]
        XCTAssertTrue(checkpoint.waitForExistence(timeout: 5))
        checkpoint.tap()

        app.buttons["保存"].firstMatch.tap()

        let record = app.buttons["记录完成第一版"]
        XCTAssertTrue(record.waitForExistence(timeout: 10))
        record.tap()

        XCTAssertTrue(app.staticTexts["标记为已完成"].waitForExistence(timeout: 5))
        app.buttons["保存"].firstMatch.tap()

        let claim = app.buttons["unlockClaimButton"]
        XCTAssertTrue(claim.waitForExistence(timeout: 10))

        let celebration = XCTAttachment(screenshot: app.screenshot())
        celebration.name = "unlock-celebration"
        celebration.lifetime = .keepAlways
        add(celebration)

        claim.tap()

        let finish = app.buttons["unlockFinishButton"]
        XCTAssertTrue(finish.waitForExistence(timeout: 10))
        XCTAssertTrue(
            app.staticTexts["这份奖励，属于你了"].waitForExistence(timeout: 5)
        )

        let claimed = XCTAttachment(screenshot: app.screenshot())
        claimed.name = "unlock-claimed"
        claimed.lifetime = .keepAlways
        add(claimed)

        finish.tap()

        let completedStatus = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label == %@", "已兑现"))
            .firstMatch
        XCTAssertTrue(completedStatus.waitForExistence(timeout: 10))

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "critical-journey-completed"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
