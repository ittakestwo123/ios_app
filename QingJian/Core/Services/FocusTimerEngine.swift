import Combine
import Foundation

@MainActor
protocol ActiveTimerStoring: AnyObject {
    func load() -> ActiveTimerState?
    func save(_ state: ActiveTimerState)
    func clear()
}

@MainActor
final class UserDefaultsActiveTimerStore: ActiveTimerStoring {
    private let key = "activeTimerState"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> ActiveTimerState? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(ActiveTimerState.self, from: data)
    }

    func save(_ state: ActiveTimerState) {
        defaults.set(try? JSONEncoder().encode(state), forKey: key)
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }
}

@MainActor
final class InMemoryActiveTimerStore: ActiveTimerStoring {
    private var state: ActiveTimerState?

    func load() -> ActiveTimerState? { state }
    func save(_ state: ActiveTimerState) { self.state = state }
    func clear() { state = nil }
}

@MainActor
final class FocusTimerEngine: ObservableObject {
    @Published private(set) var activeState: ActiveTimerState?
    @Published private(set) var snapshotValue: FocusTimerSnapshot = .idle

    private let store: ActiveTimerStoring
    private let now: () -> Date

    init(store: ActiveTimerStoring = UserDefaultsActiveTimerStore(), now: @escaping () -> Date = Date.init) {
        self.store = store
        self.now = now
    }

    func start(subjectID: UUID, subjectName: String, mode: FocusMode, plannedSeconds: Int?) {
        let safePlannedSeconds = mode == .countdown ? max(60, plannedSeconds ?? 1_500) : nil
        let state = ActiveTimerState(
            id: UUID(),
            startDate: now(),
            pauseStartedAt: nil,
            accumulatedPausedSeconds: 0,
            plannedSeconds: safePlannedSeconds,
            subjectID: subjectID,
            subjectName: subjectName,
            mode: mode
        )
        activeState = state
        store.save(state)
        refresh()
    }

    func pause() {
        guard var state = activeState, state.pauseStartedAt == nil else { return }
        state.pauseStartedAt = now()
        activeState = state
        store.save(state)
        refresh()
    }

    func resume() {
        guard var state = activeState, let pauseStartedAt = state.pauseStartedAt else { return }
        state.accumulatedPausedSeconds += Int(now().timeIntervalSince(pauseStartedAt).rounded(.down))
        state.pauseStartedAt = nil
        activeState = state
        store.save(state)
        refresh()
    }

    func refresh() {
        snapshotValue = snapshot()
    }

    func snapshot() -> FocusTimerSnapshot {
        guard let state = activeState else { return .idle }
        let elapsed = elapsedSeconds(for: state)
        let remaining = state.plannedSeconds.map { max(0, $0 - elapsed) }
        return FocusTimerSnapshot(
            elapsedSeconds: elapsed,
            remainingSeconds: remaining,
            isRunning: state.pauseStartedAt == nil,
            isPaused: state.pauseStartedAt != nil,
            isComplete: remaining == 0 && state.plannedSeconds != nil
        )
    }

    func restore() -> FocusTimerRestoreResult {
        guard let state = store.load() else { return .none }
        activeState = state
        let current = snapshot()
        if current.isComplete {
            guard let draft = makeDraft(from: state, duration: state.plannedSeconds ?? current.elapsedSeconds) else { return .none }
            discard()
            return .completed(draft)
        }
        snapshotValue = current
        return .active
    }

    func completeIfNeeded() -> FocusSessionDraft? {
        guard let state = activeState, snapshot().isComplete else { return nil }
        let draft = makeDraft(from: state, duration: state.plannedSeconds ?? elapsedSeconds(for: state))
        discard()
        return draft
    }

    func finish() -> FocusSessionDraft? {
        guard let state = activeState else { return nil }
        let duration = min(state.plannedSeconds ?? .max, elapsedSeconds(for: state))
        defer { discard() }
        guard duration >= 60 else { return nil }
        return makeDraft(from: state, duration: duration)
    }

    func discard() {
        activeState = nil
        snapshotValue = .idle
        store.clear()
    }

    private func elapsedSeconds(for state: ActiveTimerState) -> Int {
        let end = state.pauseStartedAt ?? now()
        let total = Int(end.timeIntervalSince(state.startDate).rounded(.down))
        return max(0, total - state.accumulatedPausedSeconds)
    }

    private func makeDraft(from state: ActiveTimerState, duration: Int) -> FocusSessionDraft? {
        guard duration >= 60 else { return nil }
        let endAt = state.startDate.addingTimeInterval(TimeInterval(duration + state.accumulatedPausedSeconds))
        return FocusSessionDraft(
            startAt: state.startDate,
            endAt: endAt,
            durationSeconds: duration,
            subjectID: state.subjectID,
            subjectName: state.subjectName,
            mode: state.mode,
            plannedSeconds: state.plannedSeconds,
            completed: true
        )
    }
}
