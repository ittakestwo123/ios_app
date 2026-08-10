import Foundation

extension Int {
    var qingMinuteText: String {
        let hours = self / 60
        let minutes = self % 60
        if hours > 0 && minutes > 0 { return "\(hours) 小时 \(minutes) 分钟" }
        if hours > 0 { return "\(hours) 小时" }
        return "\(minutes) 分钟"
    }

    var qingClockText: String {
        String(format: "%02d:%02d", self / 60, self % 60)
    }
}

extension Date {
    func qingMediumDate(calendar: Calendar = .current) -> String {
        formatted(.dateTime.year().month(.wide).day().locale(Locale(identifier: "zh_CN")))
    }
}
