import XCTest

@testable import QingJian

final class StudyStatsServiceTests: XCTestCase {
    private let service = StudyStatsService(calendar: TestDates.calendar)

    func testCurrentStreakCountsSevenConsecutiveDaysWithAtLeastTenMinutes() {
        let end = TestDates.date("2027-01-03 20:00")
        let sessions = (0..<7).map { offset in
            let date = TestDates.calendar.date(byAdding: .day, value: -offset, to: end)!
            return session(start: date, duration: 600)
        }

        XCTAssertEqual(service.currentStreak(sessions: sessions, asOf: end), 7)
        XCTAssertEqual(service.longestStreak(sessions: sessions), 7)
    }

    func testBrokenStreakDoesNotCountAStudyDayBelowTenMinutes() {
        let end = TestDates.date("2026-09-03 20:00")
        let today = session(start: end, duration: 600)
        let yesterday = session(start: TestDates.calendar.date(byAdding: .day, value: -1, to: end)!, duration: 599)
        let beforeYesterday = session(start: TestDates.calendar.date(byAdding: .day, value: -2, to: end)!, duration: 600)

        XCTAssertEqual(service.currentStreak(sessions: [today, yesterday, beforeYesterday], asOf: end), 1)
    }

    func testEmptyDataProducesZeroedStatistics() {
        XCTAssertEqual(service.currentStreak(sessions: [], asOf: TestDates.date("2026-08-10 12:00")), 0)
        XCTAssertEqual(service.longestStreak(sessions: []), 0)
        XCTAssertEqual(service.totalSeconds(sessions: []), 0)
    }

    func testSameStudyTimeRespectsAChangedDailyGoal() {
        let session = session(start: TestDates.date("2026-08-10 09:00"), duration: 3_600)
        let day = TestDates.date("2026-08-10 12:00")

        XCTAssertTrue(service.summary(on: day, sessions: [session], goalMinutes: 60).goalReached)
        XCTAssertFalse(service.summary(on: day, sessions: [session], goalMinutes: 90).goalReached)
    }

    func testDaySpecificGoalSnapshotKeepsHistoricalCompletionStable() {
        let firstDay = TestDates.date("2026-08-09 12:00")
        let secondDay = TestDates.date("2026-08-10 12:00")
        let sessions = [session(start: firstDay, duration: 3_600), session(start: secondDay, duration: 3_600)]
        let summaries = service.summaries(endingOn: secondDay, dayCount: 2, sessions: sessions) { day in
            TestDates.calendar.isDate(day, inSameDayAs: firstDay) ? 60 : 90
        }

        XCTAssertTrue(summaries[0].goalReached)
        XCTAssertFalse(summaries[1].goalReached)
    }

    func testSubjectTotalsSplitOneCrossMidnightSessionBetweenDays() {
        let session = StudySession(
            startAt: TestDates.date("2026-12-31 23:50"),
            endAt: TestDates.date("2027-01-01 00:10"),
            durationSeconds: 1_200,
            subjectID: UUID(),
            subjectNameSnapshot: "英语",
            mode: .countdown,
            plannedSeconds: 1_200,
            completed: true
        )

        XCTAssertEqual(service.subjectTotals(sessions: [session], on: TestDates.date("2026-12-31 12:00")).first?.seconds, 600)
        XCTAssertEqual(service.subjectTotals(sessions: [session], on: TestDates.date("2027-01-01 12:00")).first?.seconds, 600)
    }

    private func session(start: Date, duration: Int) -> StudySession {
        StudySession(
            startAt: start,
            endAt: start.addingTimeInterval(TimeInterval(duration)),
            durationSeconds: duration,
            subjectID: UUID(),
            subjectNameSnapshot: "数学",
            mode: .countdown,
            plannedSeconds: duration,
            completed: true
        )
    }
}
