import Foundation
import Observation

@MainActor
@Observable
final class TodayViewModel {
    private let clock: ClockProviding

    init(clock: ClockProviding) {
        self.clock = clock
    }

    var todayText: String {
        clock.now.formatted(
            Date.FormatStyle(
                date: .long,
                time: .omitted,
                locale: Locale(identifier: "zh_CN"),
                calendar: clock.calendar,
                timeZone: clock.calendar.timeZone
            )
        )
    }
}
