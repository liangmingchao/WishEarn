import XCTest

final class WishPhotoCropUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCropScreenShowsControlsAndReset() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing-crop"]
        app.launch()

        XCTAssertTrue(app.navigationBars["裁剪照片"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["cropCancelButton"].exists)
        XCTAssertTrue(app.buttons["cropConfirmButton"].exists)
        XCTAssertTrue(app.buttons["cropResetButton"].exists)
        XCTAssertTrue(app.staticTexts["自由裁剪"].exists)

        app.buttons["cropResetButton"].tap()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "wish-photo-crop"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
