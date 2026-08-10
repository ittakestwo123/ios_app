# QingJian Phase 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 完善 QingJian 的首版工程骨架，让首次启动、设置持久化、默认科目与四 Tab 根导航具备稳定的可运行基础。

**Architecture:** 保留现有 feature-first SwiftUI 结构。将 SwiftData schema/container 与默认数据初始化集中到 `Core/Persistence`，将科目名称清理保持为无副作用的纯逻辑；`AppSettings` 继续使用注入的 `UserDefaults` 保存用户偏好。页面通过环境对象和 SwiftData 查询消费这些基础能力。

**Tech Stack:** SwiftUI, SwiftData, Foundation, XCTest, iOS 17.0 deployment target; no third-party dependencies.

---

### Task 1: Define Phase 1 behavior tests first

**Files:**
- Create: `QingJianTests/PersistenceControllerTests.swift`
- Create: `QingJianTests/SubjectCatalogTests.swift`
- Modify: `QingJianTests/AppSettingsTests.swift`

- [x] Test that the in-memory SwiftData container exposes all four persisted models.
- [x] Test that default subjects are seeded once and a second seed does not duplicate them.
- [x] Test that onboarding subject input trims whitespace, drops empty names, and keeps the first occurrence of duplicates.
- [x] Test that daily goal and target date survive a new `AppSettings` instance backed by the same `UserDefaults` suite.
- [x] Attempt the focused XCTest command; the Windows environment stopped before compilation because `xcodebuild` is unavailable.

### Task 2: Implement persistence and onboarding data boundaries

**Files:**
- Create: `QingJian/Core/Persistence/ModelContainerFactory.swift`
- Create: `QingJian/Core/Persistence/DefaultDataSeeder.swift`
- Create: `QingJian/Core/Models/SubjectCatalog.swift`
- Modify: `QingJian/App/QingJianApp.swift`
- Modify: `QingJian/App/RootView.swift`
- Modify: `QingJian/Features/Onboarding/OnboardingView.swift`
- Modify: `QingJian.xcodeproj/project.pbxproj`

- [x] Centralize the SwiftData schema and production/in-memory container creation.
- [x] Seed the five default subjects only when the store has no subjects, then save once.
- [x] Route onboarding subject names through the tested normalizer before inserting SwiftData models.
- [x] Run initial seeding from the root task so a recovered or existing install remains idempotent.

### Task 3: Verify project wiring and documentation

**Files:**
- Modify: `README.md`
- Modify: `docs/SPEC_AUDIT.md`

- [x] Verify every Swift source and test is referenced by the Xcode project file and the deployment target remains `17.0`.
- [x] Verify only Apple SDK imports are used and the model schema includes `StudySession`, `Subject`, `DailyRecord`, and `QuoteFavorite`.
- [x] Attempt the required `xcrun`/`xcodebuild` commands; report the exact unavailable-toolchain result instead of claiming a build passed.
- [x] Update README with the Phase 1 behavior and macOS/Xcode run instructions.
