import Foundation

struct StreakResult: Equatable, Sendable {
    let currentStreak: Int
    let longestStreak: Int
    let lastRecordedAt: Date?
    let isCompleted: Bool
}
