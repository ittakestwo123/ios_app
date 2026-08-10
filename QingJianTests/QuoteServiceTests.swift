import XCTest

@testable import QingJian

final class QuoteServiceTests: XCTestCase {
    func testDailyQuoteIsStableForTheSameCalendarDay() {
        let quotes = [
            Quote(id: "a", text: "甲", attribution: "晴笺原创", category: .selfEncouragement, sourceType: .original),
            Quote(id: "b", text: "乙", attribution: "晴笺原创", category: .persistence, sourceType: .original)
        ]
        let service = QuoteService(quotes: quotes, calendar: TestDates.calendar)
        let day = TestDates.date("2026-08-10 08:00")

        XCTAssertEqual(service.dailyQuote(on: day), service.dailyQuote(on: day.addingTimeInterval(60 * 60 * 10)))
    }

    func testRandomQuoteReturnsAnItemFromTheRequestedCategory() {
        let quotes = [
            Quote(id: "a", text: "甲", attribution: "晴笺原创", category: .selfEncouragement, sourceType: .original),
            Quote(id: "b", text: "乙", attribution: "晴笺原创", category: .reading, sourceType: .original)
        ]
        let service = QuoteService(quotes: quotes, calendar: TestDates.calendar)

        XCTAssertEqual(service.randomQuote(category: .reading)?.id, "b")
    }

    func testRandomQuoteCanExcludeRecentlyShownIDs() {
        let quotes = [
            Quote(id: "a", text: "甲", attribution: "晴笺原创", category: .selfEncouragement, sourceType: .original),
            Quote(id: "b", text: "乙", attribution: "晴笺原创", category: .selfEncouragement, sourceType: .original)
        ]
        let service = QuoteService(quotes: quotes, calendar: TestDates.calendar)

        XCTAssertEqual(service.randomQuote(excludingIDs: ["a"])?.id, "b")
    }
}
