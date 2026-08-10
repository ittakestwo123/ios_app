import XCTest

@testable import QingJian

@MainActor
final class AppSettingsTests: XCTestCase {
    func testDailyGoalClampsToFifteenMinutes() {
        let defaults = UserDefaults(suiteName: "QingJianTests-\(UUID().uuidString)")!
        let settings = AppSettings(defaults: defaults)

        settings.dailyGoalMinutes = 10

        XCTAssertEqual(settings.dailyGoalMinutes, 15)
        XCTAssertEqual(defaults.integer(forKey: "dailyGoalMinutes"), 15)
    }

    func testSoundIsOffByDefaultForQuietStudy() {
        let defaults = UserDefaults(suiteName: "QingJianTests-\(UUID().uuidString)")!

        XCTAssertFalse(AppSettings(defaults: defaults).soundEnabled)
    }

    func testDailyGoalAndTargetDatePersistAcrossSettingsInstances() {
        let defaults = UserDefaults(suiteName: "QingJianTests-\(UUID().uuidString)")!
        let targetDate = TestDates.date("2027-01-15 12:00")
        let first = AppSettings(defaults: defaults)

        first.dailyGoalMinutes = 300
        first.targetDate = targetDate

        let second = AppSettings(defaults: defaults)

        XCTAssertEqual(second.dailyGoalMinutes, 300)
        XCTAssertEqual(second.targetDate, targetDate)
    }

    func testStreakMilestoneIsClaimedOnlyOncePerDay() {
        let defaults = UserDefaults(suiteName: "QingJianTests-\(UUID().uuidString)")!
        let settings = AppSettings(defaults: defaults)
        let morning = TestDates.date("2026-08-10 09:00")
        let evening = TestDates.date("2026-08-10 20:00")

        XCTAssertEqual(settings.claimStreakMilestone(streak: 7, on: morning, calendar: TestDates.calendar), 7)
        XCTAssertNil(settings.claimStreakMilestone(streak: 7, on: evening, calendar: TestDates.calendar))
        XCTAssertEqual(settings.claimStreakMilestone(streak: 7, on: TestDates.date("2026-08-11 09:00"), calendar: TestDates.calendar), 7)
        XCTAssertEqual(settings.claimStreakMilestone(streak: 100, on: morning, calendar: TestDates.calendar), 100)
    }
}
