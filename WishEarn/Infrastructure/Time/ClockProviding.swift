import Foundation

protocol ClockProviding: Sendable {
    var now: Date { get }
    var calendar: Calendar { get }
}

struct SystemClock: ClockProviding {
    var now: Date { Date() }
    var calendar: Calendar { Calendar.autoupdatingCurrent }
}

struct FixedClock: ClockProviding {
    let now: Date
    let calendar: Calendar

    init(now: Date, calendar: Calendar = .autoupdatingCurrent) {
        self.now = now
        self.calendar = calendar
    }
}
