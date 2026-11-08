import XCTest
@testable import WishEarn

@MainActor
final class TodayViewModelTests: XCTestCase {
    private func makeClock() -> FixedClock {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai")!

        var components = DateComponents()
        components.year = 2026
        components.month = 11
        components.day = 8
        components.hour = 9

        return FixedClock(now: calendar.date(from: components)!, calendar: calendar)
    }

    func testTodayTextUsesInjectedClock() {
        let viewModel = TodayViewModel(clock: makeClock())

        XCTAssertEqual(viewModel.todayText, "2026年11月8日")
    }

    func testContainerBuildsTodayViewModelWithInjectedClock() {
        let container = AppContainer.preview()

        XCTAssertEqual(container.makeTodayViewModel().todayText, "2026年11月8日")
    }

    func testRouterDefaultsToWishTab() {
        XCTAssertEqual(AppRouter().selectedTab, .wishes)
    }
}
