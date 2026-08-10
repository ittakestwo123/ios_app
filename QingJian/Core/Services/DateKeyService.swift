import Foundation

struct DateKeyService {
    let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func startOfDay(for date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    func dateKey(for date: Date) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }

    func secondsByDay(start: Date, end: Date) -> [Date: Int] {
        guard end > start else { return [:] }

        var seconds: [Date: Int] = [:]
        var cursor = calendar.startOfDay(for: start)

        while cursor < end {
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            let segmentStart = max(start, cursor)
            let segmentEnd = min(end, nextDay)
            let duration = Int(segmentEnd.timeIntervalSince(segmentStart).rounded(.down))
            if duration > 0 {
                seconds[cursor, default: 0] += duration
            }
            cursor = nextDay
        }

        return seconds
    }
}
