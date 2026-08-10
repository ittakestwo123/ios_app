import Foundation
import SwiftUI

enum AppAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: "跟随系统"
        case .light: "浅色"
        case .dark: "深色"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

@MainActor
final class AppSettings: ObservableObject {
    private enum Key {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let dailyGoalMinutes = "dailyGoalMinutes"
        static let targetDate = "targetDate"
        static let lastSubjectID = "lastSubjectID"
        static let reminderEnabled = "reminderEnabled"
        static let reminderHour = "reminderHour"
        static let reminderMinute = "reminderMinute"
        static let soundEnabled = "soundEnabled"
        static let hapticsEnabled = "hapticsEnabled"
        static let appearance = "appearance"
        static let celebratedStreakMilestones = "celebratedStreakMilestones"
    }

    private let defaults: UserDefaults

    @Published var hasCompletedOnboarding: Bool { didSet { defaults.set(hasCompletedOnboarding, forKey: Key.hasCompletedOnboarding) } }
    @Published var dailyGoalMinutes: Int {
        didSet {
            let clamped = max(15, dailyGoalMinutes)
            if clamped != dailyGoalMinutes {
                dailyGoalMinutes = clamped
                return
            }
            defaults.set(dailyGoalMinutes, forKey: Key.dailyGoalMinutes)
        }
    }
    @Published var targetDate: Date? { didSet { defaults.set(targetDate, forKey: Key.targetDate) } }
    @Published var lastSubjectID: UUID? { didSet { defaults.set(lastSubjectID?.uuidString, forKey: Key.lastSubjectID) } }
    @Published var reminderEnabled: Bool { didSet { defaults.set(reminderEnabled, forKey: Key.reminderEnabled) } }
    @Published var reminderHour: Int { didSet { defaults.set(reminderHour, forKey: Key.reminderHour) } }
    @Published var reminderMinute: Int { didSet { defaults.set(reminderMinute, forKey: Key.reminderMinute) } }
    @Published var soundEnabled: Bool { didSet { defaults.set(soundEnabled, forKey: Key.soundEnabled) } }
    @Published var hapticsEnabled: Bool { didSet { defaults.set(hapticsEnabled, forKey: Key.hapticsEnabled) } }
    @Published var appearance: AppAppearance { didSet { defaults.set(appearance.rawValue, forKey: Key.appearance) } }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hasCompletedOnboarding = defaults.bool(forKey: Key.hasCompletedOnboarding)
        dailyGoalMinutes = max(15, defaults.object(forKey: Key.dailyGoalMinutes) as? Int ?? 240)
        targetDate = defaults.object(forKey: Key.targetDate) as? Date
        lastSubjectID = defaults.string(forKey: Key.lastSubjectID).flatMap(UUID.init(uuidString:))
        reminderEnabled = defaults.bool(forKey: Key.reminderEnabled)
        reminderHour = defaults.object(forKey: Key.reminderHour) as? Int ?? 19
        reminderMinute = defaults.object(forKey: Key.reminderMinute) as? Int ?? 30
        soundEnabled = defaults.object(forKey: Key.soundEnabled) as? Bool ?? false
        hapticsEnabled = defaults.object(forKey: Key.hapticsEnabled) as? Bool ?? true
        appearance = AppAppearance(rawValue: defaults.string(forKey: Key.appearance) ?? "system") ?? .system
    }

    var reminderDate: Date {
        Calendar.current.date(from: DateComponents(hour: reminderHour, minute: reminderMinute)) ?? .now
    }

    func claimStreakMilestone(streak: Int, on date: Date = .now, calendar: Calendar = .current) -> Int? {
        let milestone: Int
        switch streak {
        case 7, 30, 100:
            milestone = streak
        default:
            return nil
        }

        let dateKey = DateKeyService(calendar: calendar).dateKey(for: date)
        let marker = "\(dateKey)-\(milestone)"
        var claimed = defaults.stringArray(forKey: Key.celebratedStreakMilestones) ?? []
        guard !claimed.contains(marker) else { return nil }
        claimed.append(marker)
        defaults.set(claimed, forKey: Key.celebratedStreakMilestones)
        return milestone
    }
}
