import Foundation

struct ActiveTimerState: Codable, Equatable {
    var id: UUID
    var startDate: Date
    var pauseStartedAt: Date?
    var accumulatedPausedSeconds: Int
    var plannedSeconds: Int?
    var subjectID: UUID
    var subjectName: String
    var mode: FocusMode
}

struct FocusSessionDraft: Equatable {
    var startAt: Date
    var endAt: Date
    var durationSeconds: Int
    var subjectID: UUID
    var subjectName: String
    var mode: FocusMode
    var plannedSeconds: Int?
    var completed: Bool
}

struct FocusTimerSnapshot: Equatable {
    var elapsedSeconds: Int
    var remainingSeconds: Int?
    var isRunning: Bool
    var isPaused: Bool
    var isComplete: Bool

    static let idle = FocusTimerSnapshot(
        elapsedSeconds: 0,
        remainingSeconds: nil,
        isRunning: false,
        isPaused: false,
        isComplete: false
    )
}

enum FocusTimerRestoreResult: Equatable {
    case none
    case active
    case completed(FocusSessionDraft)
}
