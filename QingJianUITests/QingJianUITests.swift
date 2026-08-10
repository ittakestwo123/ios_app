import XCTest

final class QingJianUITests: XCTestCase {
    func testCompletingOnboardingRevealsFourTabs() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestingResetState"]
        app.launch()

        XCTAssertTrue(app.staticTexts["晴笺"].waitForExistence(timeout: 5))
        app.buttons["继续"].tap()
        XCTAssertTrue(app.buttons["完成"].waitForExistence(timeout: 5))
        app.buttons["完成"].tap()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        XCTAssertTrue(tabBar.buttons["今日"].exists)
        XCTAssertTrue(tabBar.buttons["专注"].exists)
        XCTAssertTrue(tabBar.buttons["足迹"].exists)
        XCTAssertTrue(tabBar.buttons["拾光"].exists)
    }
}
