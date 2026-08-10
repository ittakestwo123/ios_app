# 首版质量与上架准备 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为 QingJian 首版补上真实 UI 烟测和 Apple 隐私清单，使 Onboarding 到四 Tab 的关键入口可在 CI 中回归，并完善 App Store 基础合规材料。

**Architecture:** UI 测试使用独立 `QingJianUITests` target，通过受控的 `-uiTestingResetState` 启动参数清理测试专用 UserDefaults，并切换到内存 SwiftData 容器，避免 UI 回归受模拟器磁盘状态影响；生产逻辑不改变正常启动路径。隐私清单作为 App target 的资源加入工程，声明仅使用本地 UserDefaults 和 SwiftData，不声明收集或跟踪数据。

**Tech Stack:** SwiftUI, XCTest/XCUITest, SwiftData, Xcode 26, iOS 17 deployment target。

---

### Task 1: Add onboarding-to-tabs UI regression test

**Files:**
- Create: `QingJianUITests/QingJianUITests.swift`
- Modify: `QingJian/App/QingJianApp.swift`
- Modify: `QingJian.xcodeproj/project.pbxproj`
- Modify: `QingJian.xcodeproj/xcshareddata/xcschemes/QingJian.xcscheme`

- [ ] **Step 1: Write the failing UI test**

The test launches with a test-only reset flag, completes the existing onboarding buttons, and asserts all four localized tab labels:

```swift
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
```

- [ ] **Step 2: Run the new target in cloud CI and confirm the missing-target failure**

Run the workflow after adding the test source and target wiring. Before the target wiring is present, Xcode must report the source is not part of a target; after wiring, any failure must be an actual UI assertion or compile error rather than a missing test file.

- [ ] **Step 3: Add a test-only state reset at app launch**

At the top of `QingJianApp.init`, before `AppSettings` is read, derive the test flag, clear UserDefaults, and pass the same flag to the container factory:

```swift
let isUITesting = ProcessInfo.processInfo.arguments.contains("-uiTestingResetState")
if isUITesting, let bundleIdentifier = Bundle.main.bundleIdentifier {
    UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
}

container = try PersistenceController.makeContainer(inMemory: isUITesting)
```

The condition is inert for App Store builds and ordinary launches; ordinary launches continue to use the on-disk SwiftData container.

- [ ] **Step 4: Wire the UI test target and scheme**

Add a `com.apple.product-type.bundle.ui-testing` target with bundle identifier `com.qingjian.uitests`, deployment target 17.0, `TEST_TARGET_NAME = QingJian`, a source phase containing `QingJianUITests.swift`, and a shared-scheme `TestableReference` for this target.

- [ ] **Step 5: Run the UI test and all existing XCTest tests**

Run in GitHub Actions on the configured iPhone 17 simulator. Expected result: build succeeds, the UI smoke test passes, and all existing unit tests remain green.

### Task 2: Add App Store privacy manifest

**Files:**
- Create: `QingJian/Resources/PrivacyInfo.xcprivacy`
- Modify: `QingJian.xcodeproj/project.pbxproj`
- Modify: `README.md`

- [ ] **Step 1: Add the privacy manifest resource**

Use Apple privacy manifest keys with no tracking and no collected data:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>NSPrivacyTracking</key>
	<false/>
	<key>NSPrivacyCollectedDataTypes</key>
	<array/>
	<key>NSPrivacyAccessedAPITypes</key>
	<array>
		<dict>
			<key>NSPrivacyAccessedAPIType</key>
			<string>NSPrivacyAccessedAPICategoryUserDefaults</string>
			<key>NSPrivacyAccessedAPITypeReasons</key>
			<array>
				<string>CA92.1</string>
			</array>
		</dict>
	</array>
</dict>
</plist>
```

- [ ] **Step 2: Add it to the app resources phase**

Add the `PrivacyInfo.xcprivacy` file reference and `PBXBuildFile` to the existing app resources phase; do not add it to the test bundle.

- [ ] **Step 3: Document the manifest and privacy policy**

Update the README release checklist to point to `PRIVACY.md`, `privacy-policy.html`, and the new privacy manifest, while keeping signing/team setup as a manual macOS step.

- [ ] **Step 4: Run cloud build and tests**

Expected result: Xcode 26 build succeeds, XCTest/UI test succeeds, and the privacy manifest is copied into the built app resources.

### Task 3: Final audit and delivery

**Files:**
- Modify: `docs/SPEC_AUDIT.md`

- [ ] **Step 1: Record the new completed verification items**

Add the UI smoke test, privacy manifest, and latest CI run link to the audit without marking real-device/manual App Store submission as automated.

- [ ] **Step 2: Verify repository state and remote result**

Run `git diff --check`, inspect the final diff, run the GitHub Actions build/test workflow, and confirm a clean committed state before reporting.
