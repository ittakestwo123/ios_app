import XCTest

@testable import QingJian

final class StudyGardenTests: XCTestCase {
    func testGardenStageUsesPlumGrowthThresholds() {
        XCTAssertEqual(StudyGardenStage(progress: 0), .seed)
        XCTAssertEqual(StudyGardenStage(progress: 0.25), .leaf)
        XCTAssertEqual(StudyGardenStage(progress: 0.5), .plumBud)
        XCTAssertEqual(StudyGardenStage(progress: 0.8), .plumBloom)
        XCTAssertEqual(StudyGardenStage(progress: 1), .brightPlum)
    }
}
