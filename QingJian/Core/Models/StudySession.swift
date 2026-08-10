import Foundation
import SwiftData

enum FocusMode: String, Codable, CaseIterable, Identifiable {
    case countdown
    case stopwatch

    var id: String { rawValue }

    var localizedName: String {
        switch self {
        case .countdown: "倒计时"
        case .stopwatch: "自由计时"
        }
    }
}

@Model
final class StudySession {
    @Attribute(.unique) var id: UUID
    var startAt: Date
    var endAt: Date
    var durationSeconds: Int
    var subjectID: UUID?
    var subjectNameSnapshot: String
    var modeRaw: String
    var plannedSeconds: Int?
    var completed: Bool

    var mode: FocusMode {
        get { FocusMode(rawValue: modeRaw) ?? .countdown }
        set { modeRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        startAt: Date,
        endAt: Date,
        durationSeconds: Int,
        subjectID: UUID?,
        subjectNameSnapshot: String,
        mode: FocusMode,
        plannedSeconds: Int?,
        completed: Bool
    ) {
        self.id = id
        self.startAt = startAt
        self.endAt = endAt
        self.durationSeconds = durationSeconds
        self.subjectID = subjectID
        self.subjectNameSnapshot = subjectNameSnapshot
        self.modeRaw = mode.rawValue
        self.plannedSeconds = plannedSeconds
        self.completed = completed
    }

    convenience init(draft: FocusSessionDraft) {
        self.init(
            startAt: draft.startAt,
            endAt: draft.endAt,
            durationSeconds: draft.durationSeconds,
            subjectID: draft.subjectID,
            subjectNameSnapshot: draft.subjectName,
            mode: draft.mode,
            plannedSeconds: draft.plannedSeconds,
            completed: draft.completed
        )
    }
}
