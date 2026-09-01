import Foundation

enum ReviewGrade: Int, CaseIterable, Identifiable {
    case remembered = 0
    case fuzzy = 1
    case forgot = 2

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .remembered: return "记得"
        case .fuzzy: return "模糊"
        case .forgot: return "忘了"
        }
    }
}

enum ReviewScheduler {
    static func nextDate(after grade: ReviewGrade) -> Date {
        let days: Int
        switch grade {
        case .remembered: days = 3
        case .fuzzy: days = 1
        case .forgot: days = 0
        }
        return Calendar.current.date(byAdding: .day, value: days, to: .now) ?? .now
    }

    static func nextDateAfterMistakeRetry(correct: Bool, currentStreak: Int) -> (date: Date, newStreak: Int) {
        if correct {
            let newStreak = currentStreak + 1
            let days = newStreak >= 2 ? 7 : 2
            return (Calendar.current.date(byAdding: .day, value: days, to: .now) ?? .now, newStreak)
        } else {
            return (Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now, 0)
        }
    }

    static func consecutiveDays(from dates: [Date]) -> Int {
        guard !dates.isEmpty else { return 0 }
        let calendar = Calendar.current
        let daySet = Set(dates.map { calendar.startOfDay(for: $0) })
        var cursor = calendar.startOfDay(for: .now)
        if !daySet.contains(cursor) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: cursor),
                  daySet.contains(yesterday) else { return 0 }
            cursor = yesterday
        }
        var count = 0
        while daySet.contains(cursor) {
            count += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }
        return count
    }
}
