import SwiftData

enum DefaultDataSeeder {
    @MainActor
    static func seedSubjectsIfNeeded(in modelContext: ModelContext) throws {
        let existingSubjects = try modelContext.fetch(FetchDescriptor<Subject>())
        guard existingSubjects.isEmpty else { return }

        for (index, name) in SubjectCatalog.defaultNames.enumerated() {
            modelContext.insert(Subject(name: name, sortOrder: index))
        }
        try modelContext.save()
    }
}
