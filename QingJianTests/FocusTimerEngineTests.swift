import XCTest

@testable import QingJian

@MainActor
final class FocusTimerEngineTests: XCTestCase {
    func testPauseExcludesTimeSpentPausedFromElapsedDuration() {
        let clock = TestClock(TestDates.date("2026-08-10 09:00"))
        let store = InMemoryActiveTimerStore()
        let engine = FocusTimerEngine(store: store, now: { clock.current })

        engine.start(subjectID: UUID(), subjectName: "数学", mode: .countdown, plannedSeconds: 1_500)
        clock.advance(300)
        engine.pause()
        clock.advance(600)
        engine.resume()
        clock.advance(120)

        XCTAssertEqual(engine.snapshot().elapsedSeconds, 420)
        XCTAssertEqual(engine.snapshot().remainingSeconds, 1_080)
    }

    func testRestoreCreatesCompletedDraftWhenCountdownExpiredWhileInactive() {
        let clock = TestClock(TestDates.date("2026-08-10 09:00"))
        let store = InMemoryActiveTimerStore()
        let subjectID = UUID()
        let running = FocusTimerEngine(store: store, now: { clock.current })
        running.start(subjectID: subjectID, subjectName: "英语", mode: .countdown, plannedSeconds: 1_500)
        clock.advance(1_800)

        let restored = FocusTimerEngine(store: store, now: { clock.current })
        let result = restored.restore()

        guard case let .completed(draft) = result else {
            return XCTFail("An elapsed countdown must create a completed draft")
        }
        XCTAssertEqual(draft.durationSeconds, 1_500)
        XCTAssertEqual(draft.subjectID, subjectID)
        XCTAssertNil(store.load())
    }

    func testDraftBelowOneMinuteIsRejected() {
        let clock = TestClock(TestDates.date("2026-08-10 09:00"))
        let engine = FocusTimerEngine(store: InMemoryActiveTimerStore(), now: { clock.current })
        engine.start(subjectID: UUID(), subjectName: "政治", mode: .stopwatch, plannedSeconds: nil)
        clock.advance(59)

        XCTAssertNil(engine.finish())
    }

    func testExactlyOneMinuteProducesAPersistableDraft() {
        let clock = TestClock(TestDates.date("2026-08-10 09:00"))
        let engine = FocusTimerEngine(store: InMemoryActiveTimerStore(), now: { clock.current })
        engine.start(subjectID: UUID(), subjectName: "专业课", mode: .stopwatch, plannedSeconds: nil)
        clock.advance(60)

        XCTAssertEqual(engine.finish()?.durationSeconds, 60)
    }

    func testRestoreKeepsPausedStateAndExcludesTimeWhileAppIsNotRunning() {
        let clock = TestClock(TestDates.date("2026-08-10 09:00"))
        let store = InMemoryActiveTimerStore()
        let running = FocusTimerEngine(store: store, now: { clock.current })
        running.start(subjectID: UUID(), subjectName: "数学", mode: .countdown, plannedSeconds: 1_500)
        clock.advance(300)
        running.pause()
        clock.advance(1_200)

        let restored = FocusTimerEngine(store: store, now: { clock.current })
        XCTAssertEqual(restored.restore(), .active)
        XCTAssertTrue(restored.snapshot().isPaused)
        XCTAssertEqual(restored.snapshot().elapsedSeconds, 300)

        restored.resume()
        clock.advance(60)
        XCTAssertEqual(restored.snapshot().elapsedSeconds, 360)
    }
}
