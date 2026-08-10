import Foundation

struct DayStudySummary: Identifiable, Equatable {
    var date: Date
    var seconds: Int
    var goalMinutes: Int

    var id: Date { date }
    var minutes: Int { seconds / 60 }
    var goalReached: Bool { seconds >= goalMinutes * 60 }
    var isLit: Bool { seconds >= 600 }
}

struct SubjectStudyTotal: Identifiable, Equatable {
    var name: String
    var seconds: Int

    var id: String { name }
    var minutes: Int { seconds / 60 }
}

struct StudyStatsService {
    let calendar: Calendar
    private let dateService: DateKeyService

    init(calendar: Calendar = .current) {
        self.calendar = calendar
        dateService = DateKeyService(calendar: calendar)
    }

    func totalSeconds(sessions: [StudySession]) -> Int {
        sessions.reduce(0) { $0 + max(0, $1.durationSeconds) }
    }

    func dailyTotals(sessions: [StudySession]) -> [Date: Int] {
        sessions.reduce(into: [:]) { partial, session in
            let split = dateService.secondsByDay(start: session.startAt, end: session.endAt)
            for (day, seconds) in split {
                partial[day, default: 0] += seconds
            }
        }
    }

    func summary(on date: Date, sessions: [StudySession], goalMinutes: Int) -> DayStudySummary {
        let day = calendar.startOfDay(for: date)
        return DayStudySummary(date: day, seconds: dailyTotals(sessions: sessions)[day, default: 0], goalMinutes: goalMinutes)
    }

    func summaries(endingOn endDate: Date, dayCount: Int, sessions: [StudySession], goalMinutes: Int) -> [DayStudySummary] {
        summaries(endingOn: endDate, dayCount: dayCount, sessions: sessions) { _ in goalMinutes }
    }

    func summaries(
        endingOn endDate: Date,
        dayCount: Int,
        sessions: [StudySession],
        goalMinutesForDate: (Date) -> Int
    ) -> [DayStudySummary] {
        let totals = dailyTotals(sessions: sessions)
        return (0..<dayCount).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: offset - dayCount + 1, to: calendar.startOfDay(for: endDate)) else { return nil }
            return DayStudySummary(date: day, seconds: totals[day, default: 0], goalMinutes: goalMinutesForDate(day))
        }
    }

    func goalMinutes(on date: Date, records: [DailyRecord], defaultGoalMinutes: Int) -> Int {
        let key = dateService.dateKey(for: date)
        return records.first(where: { $0.dateKey == key })?.goalMinutesSnapshot ?? defaultGoalMinutes
    }

    func currentStreak(sessions: [StudySession], asOf date: Date) -> Int {
        let totals = dailyTotals(sessions: sessions)
        var day = calendar.startOfDay(for: date)
        var streak = 0
        while totals[day, default: 0] >= 600 {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return streak
    }

    func longestStreak(sessions: [StudySession]) -> Int {
        let litDays = dailyTotals(sessions: sessions)
            .filter { $0.value >= 600 }
            .map(\.key)
            .sorted()
        guard !litDays.isEmpty else { return 0 }

        var longest = 1
        var current = 1
        for pair in zip(litDays, litDays.dropFirst()) {
            let expected = calendar.date(byAdding: .day, value: 1, to: pair.0)
            if expected == pair.1 {
                current += 1
            } else {
                current = 1
            }
            longest = max(longest, current)
        }
        return longest
    }

    func longestSession(sessions: [StudySession]) -> Int {
        sessions.map(\.durationSeconds).max() ?? 0
    }

    func subjectTotals(sessions: [StudySession]) -> [SubjectStudyTotal] {
        let totals = sessions.reduce(into: [String: Int]()) { partial, session in
            partial[session.subjectNameSnapshot, default: 0] += session.durationSeconds
        }
        return totals.map { SubjectStudyTotal(name: $0.key, seconds: $0.value) }.sorted { $0.seconds > $1.seconds }
    }

    func subjectTotals(sessions: [StudySession], on date: Date) -> [SubjectStudyTotal] {
        let day = calendar.startOfDay(for: date)
        let totals = sessions.reduce(into: [String: Int]()) { partial, session in
            let seconds = dateService.secondsByDay(start: session.startAt, end: session.endAt)[day, default: 0]
            guard seconds > 0 else { return }
            partial[session.subjectNameSnapshot, default: 0] += seconds
        }
        return totals.map { SubjectStudyTotal(name: $0.key, seconds: $0.value) }.sorted { $0.seconds > $1.seconds }
    }

    func seconds(of session: StudySession, on date: Date) -> Int {
        dateService.secondsByDay(start: session.startAt, end: session.endAt)[calendar.startOfDay(for: date), default: 0]
    }
}
