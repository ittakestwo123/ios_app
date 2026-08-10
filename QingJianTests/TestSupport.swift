import Foundation

@testable import QingJian

enum TestDates {
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai")!
        calendar.locale = Locale(identifier: "zh_CN")
        return calendar
    }()

    static func date(_ value: String) -> Date {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        guard let date = formatter.date(from: value) else {
            fatalError("Invalid test date: \(value)")
        }
        return date
    }
}

final class TestClock {
    var current: Date

    init(_ current: Date) {
        self.current = current
    }

    func advance(_ seconds: TimeInterval) {
        current = current.addingTimeInterval(seconds)
    }
}
