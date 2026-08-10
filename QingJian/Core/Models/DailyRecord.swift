import Foundation
import SwiftData

@Model
final class DailyRecord {
    @Attribute(.unique) var dateKey: String
    var goalMinutesSnapshot: Int
    var note: String?

    init(dateKey: String, goalMinutesSnapshot: Int, note: String? = nil) {
        self.dateKey = dateKey
        self.goalMinutesSnapshot = goalMinutesSnapshot
        self.note = note
    }
}
