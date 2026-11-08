import Foundation

struct AppDependencies {
    var clock: ClockProviding

    static var live: AppDependencies {
        AppDependencies(clock: SystemClock())
    }

    static var preview: AppDependencies {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai") ?? .current

        var components = DateComponents()
        components.year = 2026
        components.month = 11
        components.day = 8
        components.hour = 9

        let date = calendar.date(from: components) ?? Date()
        return AppDependencies(clock: FixedClock(now: date, calendar: calendar))
    }
}
