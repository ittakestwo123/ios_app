import Foundation
import UserNotifications

enum NotificationService {
    static let focusEndIdentifier = "qingjian.focus-end"
    static let dailyReminderIdentifier = "qingjian.daily-reminder"

    static func requestPermission() async -> Bool {
        (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    static func scheduleFocusEnd(at date: Date, soundEnabled: Bool = true) async {
        let content = UNMutableNotificationContent()
        content.title = "这一段专注完成啦"
        content.body = "回来收下一点晴光。"
        content.sound = soundEnabled ? .default : nil
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, date.timeIntervalSinceNow), repeats: false)
        let request = UNNotificationRequest(identifier: focusEndIdentifier, content: content, trigger: trigger)
        try? await UNUserNotificationCenter.current().add(request)
    }

    static func cancelFocusEnd() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [focusEndIdentifier])
    }

    static func scheduleDailyReminder(hour: Int, minute: Int, soundEnabled: Bool = true) async {
        let content = UNMutableNotificationContent()
        content.title = "留一点时间给自己"
        content.body = "哪怕只是安静读完一页，也很好。"
        content.sound = soundEnabled ? .default : nil
        let trigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: hour, minute: minute), repeats: true)
        let request = UNNotificationRequest(identifier: dailyReminderIdentifier, content: content, trigger: trigger)
        try? await UNUserNotificationCenter.current().add(request)
    }

    static func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [dailyReminderIdentifier])
    }
}
