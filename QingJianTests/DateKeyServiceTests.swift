import XCTest

@testable import QingJian

final class DateKeyServiceTests: XCTestCase {
    func testSplitSessionAcrossMidnightAllocatesSecondsToBothDays() {
        let service = DateKeyService(calendar: TestDates.calendar)
        let seconds = service.secondsByDay(
            start: TestDates.date("2026-12-31 23:50"),
            end: TestDates.date("2027-01-01 00:10")
        )

        XCTAssertEqual(seconds[TestDates.date("2026-12-31 00:00")], 600)
        XCTAssertEqual(seconds[TestDates.date("2027-01-01 00:00")], 600)
    }

    func testDateKeyUsesTheUsersLocalCalendarDay() {
        let service = DateKeyService(calendar: TestDates.calendar)

        XCTAssertEqual(service.dateKey(for: TestDates.date("2026-08-10 00:05")), "2026-08-10")
        XCTAssertEqual(service.dateKey(for: TestDates.date("2026-08-10 23:55")), "2026-08-10")
    }
}
