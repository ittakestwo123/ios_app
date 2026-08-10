import XCTest

@testable import QingJian

final class SubjectCatalogTests: XCTestCase {
    func testNormalizedNamesTrimWhitespaceDropsEmptyValuesAndRemovesDuplicates() {
        let names = SubjectCatalog.normalizedNames([" 数学 ", "", "英语", "数学", "  ", "英语"])

        XCTAssertEqual(names, ["数学", "英语"])
    }

    func testDefaultNamesAreStableAndReadyForOnboarding() {
        XCTAssertEqual(SubjectCatalog.normalizedNames(Subject.defaultNames), ["数学", "英语", "政治", "专业课", "其他"])
    }
}
