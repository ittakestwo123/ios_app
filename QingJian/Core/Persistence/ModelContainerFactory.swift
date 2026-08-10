import SwiftData

enum PersistenceController {
    static var schema: Schema {
        Schema([
            StudySession.self,
            Subject.self,
            DailyRecord.self,
            QuoteFavorite.self
        ])
    }

    static func makeContainer(inMemory: Bool = false) throws -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
