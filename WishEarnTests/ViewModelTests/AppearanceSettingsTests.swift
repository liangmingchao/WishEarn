import Observation
import SwiftUI
import XCTest
@testable import WishEarn

@MainActor
final class AppearanceSettingsTests: XCTestCase {
    private var suiteName = ""
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        suiteName = "AppearanceSettingsTests-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        super.tearDown()
    }

    func testDefaultsToSystemWhenNothingStored() {
        let settings = AppearanceSettings(defaults: defaults)

        XCTAssertEqual(settings.mode, .system)
        XCTAssertNil(settings.colorScheme)
    }

    func testSelectingLightForcesLightSchemeAndPersists() {
        let settings = AppearanceSettings(defaults: defaults)

        settings.mode = .light

        XCTAssertEqual(settings.colorScheme, .light)
        XCTAssertEqual(
            defaults.string(forKey: AppearanceSettings.storageKey),
            AppearanceMode.light.rawValue
        )
    }

    func testSelectingDarkForcesDarkSchemeAndPersists() {
        let settings = AppearanceSettings(defaults: defaults)

        settings.mode = .dark

        XCTAssertEqual(settings.colorScheme, .dark)
        XCTAssertEqual(
            defaults.string(forKey: AppearanceSettings.storageKey),
            AppearanceMode.dark.rawValue
        )
    }

    func testStoredOverrideIsRestoredOnNextLaunch() {
        defaults.set(AppearanceMode.dark.rawValue, forKey: AppearanceSettings.storageKey)

        let settings = AppearanceSettings(defaults: defaults)

        XCTAssertEqual(settings.mode, .dark)
        XCTAssertEqual(settings.colorScheme, .dark)
    }

    func testUnknownStoredValueFallsBackToSystem() {
        defaults.set("amoled", forKey: AppearanceSettings.storageKey)

        let settings = AppearanceSettings(defaults: defaults)

        XCTAssertEqual(settings.mode, .system)
        XCTAssertNil(settings.colorScheme)
    }

    func testReturningToSystemClearsTheForcedScheme() {
        defaults.set(AppearanceMode.light.rawValue, forKey: AppearanceSettings.storageKey)
        let settings = AppearanceSettings(defaults: defaults)

        settings.mode = .system

        XCTAssertNil(settings.colorScheme)
        XCTAssertEqual(
            defaults.string(forKey: AppearanceSettings.storageKey),
            AppearanceMode.system.rawValue
        )
    }

    func testAllCasesCoverExactlyThreeAppearances() {
        XCTAssertEqual(AppearanceMode.allCases, [.system, .light, .dark])
        XCTAssertEqual(
            AppearanceMode.allCases.map(\.title),
            ["跟随系统", "浅色", "深色"]
        )
    }

    /// The root view reads `colorScheme` in its body; SwiftUI only rebuilds it
    /// if that read is observable. Regression guard for "change only applies
    /// after relaunch".
    func testReadingColorSchemeNotifiesObservationTrackingWhenModeChanges() {
        let settings = AppearanceSettings(defaults: defaults)
        let observed = expectation(description: "colorScheme 的读取被重新通知")

        withObservationTracking {
            _ = settings.colorScheme
        } onChange: {
            observed.fulfill()
        }

        settings.mode = .dark

        wait(for: [observed], timeout: 1)
        XCTAssertEqual(settings.colorScheme, .dark)
    }
}
