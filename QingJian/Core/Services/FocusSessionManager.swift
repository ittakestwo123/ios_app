import Foundation
import SwiftData

@MainActor
enum FocusSessionManager {
    @discardableResult
    static func persist(
        _ draft: FocusSessionDraft,
        goalMinutes: Int,
        modelContext: ModelContext,
        dateService: DateKeyService = DateKeyService()
    ) -> StudySession {
        let session = StudySession(draft: draft)
        modelContext.insert(session)

        let days = dateService.secondsByDay(start: draft.startAt, end: draft.endAt).keys
        for day in days {
            let key = dateService.dateKey(for: day)
            let descriptor = FetchDescriptor<DailyRecord>(predicate: #Predicate { $0.dateKey == key })
            let alreadyRecorded = (try? modelContext.fetch(descriptor).isEmpty == false) ?? false
            if !alreadyRecorded {
                modelContext.insert(DailyRecord(dateKey: key, goalMinutesSnapshot: goalMinutes))
            }
        }

        try? modelContext.save()
        return session
    }
}
