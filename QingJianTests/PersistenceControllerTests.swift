import SwiftData
import XCTest

@MainActor
final class PersistenceControllerTests: XCTestCase {
    func testSchemaContainsAllPhaseOneModels() throws {
        let names = Set(PersistenceController.schema.entities.map(\.name))

        XCTAssertEqual(
            names,
            Set(["StudySession", "Subject", "DailyRecord", "QuoteFavorite"])
        )
    }

    func testDefaultSubjectsSeedOnlyWhenStoreIsEmpty() throws {
        let container = try PersistenceController.makeContainer(inMemory: true)
        let context = ModelContext(container)

        try DefaultDataSeeder.seedSubjectsIfNeeded(in: context)
        try DefaultDataSeeder.seedSubjectsIfNeeded(in: context)

        let subjects = try context.fetch(FetchDescriptor<Subject>(sortBy: [SortDescriptor(\.sortOrder)]))

        XCTAssertEqual(subjects.map(\.name), SubjectCatalog.defaultNames)
        XCTAssertEqual(subjects.map(\.sortOrder), Array(0..<SubjectCatalog.defaultNames.count))
    }
}
