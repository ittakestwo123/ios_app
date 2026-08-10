# 首版质量与上架准备 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为 QingJian 首版补上真实 UI 烟测和 Apple 隐私清单，使 Onboarding 到四 Tab 的关键入口可在 CI 中回归，并完善 App Store 基础合规材料。

**Architecture:** 首版质量验证沿用稳定的 XCTest target，并使用 CI 的 Onboarding/Today 模拟器截图作为视觉 smoke；由于 Xcode 26 无 Team 的云端 UI-test 注入需要签名配置，首版不加入独立 XCUITest target，避免测试工程反而阻塞核心 build/test。隐私清单作为 App target 的资源加入工程，声明仅使用本地 UserDefaults 和 SwiftData，不声明收集或跟踪数据。

**Tech Stack:** SwiftUI, XCTest/XCUITest, SwiftData, Xcode 26, iOS 17 deployment target。

---

### Task 1: Add onboarding-to-tabs UI regression test (deferred)

**Decision:** Deferred for a future signed CI configuration. The current workflow still captures onboarding and Today screenshots after the app build, while the stable unit XCTest target remains the required gate.

- [x] **Decision: defer the independent XCUITest target**

The target was prototyped and tested in GitHub Actions. Xcode 26 attempted to inject signed XCTest/Testing frameworks into the unsigned simulator app and exited 65 without an available Apple Team. The target was removed to keep the required build/test gate stable. The existing XCTest suite and post-build onboarding/Today screenshots remain active; a signed macOS CI setup can add this test later without changing product code.

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
