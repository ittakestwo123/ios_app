import SwiftData
import SwiftUI
import UIKit

private enum FocusPreset: String, CaseIterable, Identifiable {
    case minutes25
    case minutes50
    case minutes90
    case custom
    case free

    var id: String { rawValue }

    var title: String {
        switch self {
        case .minutes25: "25 分钟"
        case .minutes50: "50 分钟"
        case .minutes90: "90 分钟"
        case .custom: "自定义"
        case .free: "自由计时"
        }
    }

    var seconds: Int? {
        switch self {
        case .minutes25: 25 * 60
        case .minutes50: 50 * 60
        case .minutes90: 90 * 60
        case .custom, .free: nil
        }
    }
}

struct FocusCompletion: Identifiable {
    let id = UUID()
    let sessionMinutes: Int
    let todayMinutes: Int
    let achievedGoal: Bool
    let streak: Int
    let milestone: Int?
}

struct FocusView: View {
    @Binding var requestedFreeTimer: Bool
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var timerEngine: FocusTimerEngine
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Subject.sortOrder) private var subjects: [Subject]
    @Query(sort: \StudySession.startAt, order: .reverse) private var sessions: [StudySession]
    @State private var selectedSubjectID: UUID?
    @State private var preset: FocusPreset = .minutes25
    @State private var customMinutes = 40
    @State private var completion: FocusCompletion?
    @State private var showEarlyFinishDialog = false
    @State private var showShortSessionAlert = false
    @State private var now = Date()

    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let stats = StudyStatsService()
    private let quoteService = QuoteService()

    private var activeSubject: Subject? {
        if let state = timerEngine.activeState,
           let matching = subjects.first(where: { $0.id == state.subjectID }) {
            return matching
        }
        if let selectedSubjectID, let selected = subjects.first(where: { $0.id == selectedSubjectID }) {
            return selected
        }
        if let lastID = settings.lastSubjectID, let last = subjects.first(where: { $0.id == lastID }) {
            return last
        }
        return subjects.first(where: { !$0.isArchived })
    }

    private var snapshot: FocusTimerSnapshot {
        _ = now
        return timerEngine.snapshot()
    }

    private var isActive: Bool { timerEngine.activeState != nil }

    private var effectiveMode: FocusMode {
        preset == .free ? .stopwatch : .countdown
    }

    private var plannedSeconds: Int? {
        if let seconds = preset.seconds { return seconds }
        if preset == .custom { return customMinutes * 60 }
        return nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: QingTheme.Spacing.large) {
                        subjectSection
                        if !isActive { presetSection }
                        timerSection
                        controls
                        gentleNote
                    }
                    .padding(QingTheme.Spacing.regular)
                    .padding(.bottom, QingTheme.Spacing.extraLarge)
                }
            }
            .navigationTitle("专注")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if selectedSubjectID == nil {
                    selectedSubjectID = settings.lastSubjectID ?? subjects.first?.id
                }
                applyRequestedFreeTimer()
            }
            .onChange(of: requestedFreeTimer) { _, _ in applyRequestedFreeTimer() }
            .onReceive(ticker) { value in
                now = value
                timerEngine.refresh()
                completeIfNeeded()
            }
            .confirmationDialog("保存这段专注吗？", isPresented: $showEarlyFinishDialog, titleVisibility: .visible) {
                Button("保存这段专注") {
                    finishAndPersist()
                }
                Button("放弃", role: .destructive) {
                    timerEngine.discard()
                    NotificationService.cancelFocusEnd()
                }
            } message: {
                Text("这段专注已经超过一分钟，会被记入今天的足迹。")
            }
            .alert("这一段还不到一分钟", isPresented: $showShortSessionAlert) {
                Button("好") {
                    timerEngine.discard()
                    NotificationService.cancelFocusEnd()
                }
            } message: {
                Text("先不记入足迹，准备好后再开始也没关系。")
            }
            .sheet(item: $completion) { completion in
                FocusCompletionView(
                    completion: completion,
                    quote: quoteService.randomQuote(),
                    onContinue: { startNextSegment() },
                    onDismiss: { self.completion = nil }
                )
                .presentationDetents([.medium])
            }
        }
    }

    private var subjectSection: some View {
        QingCard {
            VStack(alignment: .leading, spacing: QingTheme.Spacing.medium) {
                Text("正在学习什么？")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(QingTheme.mistGreen)
                if isActive, let state = timerEngine.activeState {
                    Label(state.subjectName, systemImage: "bookmark.fill")
                        .font(QingTheme.displayFont(size: 21, relativeTo: .title3).weight(.semibold))
                        .foregroundStyle(QingTheme.pineInk)
                } else if subjects.isEmpty {
                    Text("先在设置中添加一个科目。")
                        .foregroundStyle(QingTheme.secondaryInk)
                } else {
                    Picker("选择科目", selection: Binding(
                        get: { selectedSubjectID ?? activeSubject?.id ?? subjects.first?.id ?? UUID() },
                        set: { selectedSubjectID = $0 }
                    )) {
                        ForEach(subjects.filter { !$0.isArchived }) { subject in
                            Text(subject.name).tag(subject.id)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(QingTheme.pineInk)
                    .accessibilityLabel("选择专注科目")
                }
            }
        }
    }

    private var presetSection: some View {
        QingCard {
            VStack(alignment: .leading, spacing: QingTheme.Spacing.medium) {
                Text("这一段想专注多久？")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(QingTheme.mistGreen)
                Picker("时长", selection: $preset) {
                    ForEach(FocusPreset.allCases) { value in
                        Text(value.title).tag(value)
                    }
                }
                .pickerStyle(.segmented)
                if preset == .custom {
                    Stepper("\(customMinutes) 分钟", value: $customMinutes, in: 5...180, step: 5)
                        .font(.subheadline)
                }
            }
        }
    }

    private var timerSection: some View {
        VStack(spacing: QingTheme.Spacing.medium) {
            ZStack {
                Circle()
                    .stroke(QingTheme.quietFill, lineWidth: 16)
                Circle()
                    .trim(from: 0, to: timerProgress)
                    .stroke(QingTheme.mistGreen, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: QingTheme.Spacing.small) {
                    Text(displaySeconds.qingClockText)
                        .font(.system(size: 48, weight: .medium, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(QingTheme.pineInk)
                        .accessibilityLabel(isCountdown ? "剩余时间" : "累计时间")
                        .accessibilityValue(displaySeconds.qingClockText)
                    Text(isCountdown ? "剩余时间" : "累计时间")
                        .font(.caption)
                        .foregroundStyle(QingTheme.secondaryInk)
                }
            }
            .frame(width: 230, height: 230)
            .padding(.vertical, QingTheme.Spacing.small)

            if isActive {
                Text(snapshot.isPaused ? "这一段先停在这里。" : "专注进行中，慢一点也没有关系。")
                    .font(QingTheme.displayFont(size: 17, relativeTo: .subheadline))
                    .foregroundStyle(QingTheme.secondaryInk)
            } else {
                Text(preset == .free ? "不设终点，按自己的节奏来。" : "从这一小段开始就好。")
                    .font(QingTheme.displayFont(size: 17, relativeTo: .subheadline))
                    .foregroundStyle(QingTheme.secondaryInk)
            }
        }
        .accessibilityElement(children: .contain)
    }

    private var controls: some View {
        Group {
            if !isActive {
                QingPrimaryButton("开始专注", systemImage: "play.fill") {
                    startTimer()
                }
                .disabled(activeSubject == nil)
                .opacity(activeSubject == nil ? 0.5 : 1)
            } else {
                HStack(spacing: QingTheme.Spacing.small) {
                    Button {
                        if snapshot.isPaused {
                            timerEngine.resume()
                            scheduleFocusNotificationIfNeeded()
                        } else {
                            timerEngine.pause()
                            NotificationService.cancelFocusEnd()
                        }
                    } label: {
                        Label(snapshot.isPaused ? "继续" : "暂停", systemImage: snapshot.isPaused ? "play.fill" : "pause.fill")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, QingTheme.Spacing.medium)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(QingTheme.paper)
                    .background(QingTheme.pineInk, in: RoundedRectangle(cornerRadius: QingTheme.Radius.control, style: .continuous))
                    .accessibilityLabel(snapshot.isPaused ? "继续专注" : "暂停专注")

                    Button {
                        requestFinish()
                    } label: {
                        Label("结束", systemImage: "stop.fill")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, QingTheme.Spacing.medium)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(QingTheme.pineInk)
                    .background(QingTheme.quietFill, in: RoundedRectangle(cornerRadius: QingTheme.Radius.control, style: .continuous))
                    .accessibilityLabel("结束这一段专注")
                }
            }
        }
    }

    private var gentleNote: some View {
        Text("计时会以真实经过时间计算；切到后台或重新打开后，仍会回到正确的进度。")
            .font(.caption)
            .multilineTextAlignment(.center)
            .foregroundStyle(QingTheme.secondaryInk)
            .padding(.horizontal, QingTheme.Spacing.large)
    }

    private var isCountdown: Bool {
        timerEngine.activeState?.mode == .countdown || (!isActive && effectiveMode == .countdown)
    }

    private var displaySeconds: Int {
        if isActive {
            return isCountdown ? snapshot.remainingSeconds ?? 0 : snapshot.elapsedSeconds
        }
        return isCountdown ? (plannedSeconds ?? 0) : 0
    }

    private var timerProgress: Double {
        if isCountdown, let planned = timerEngine.activeState?.plannedSeconds ?? plannedSeconds, planned > 0 {
            return isActive ? min(Double(snapshot.elapsedSeconds) / Double(planned), 1) : 0
        }
        return isActive ? min(Double(snapshot.elapsedSeconds) / 3_600, 1) : 0
    }

    private func startTimer() {
        guard let subject = activeSubject else { return }
        timerEngine.start(subjectID: subject.id, subjectName: subject.name, mode: effectiveMode, plannedSeconds: plannedSeconds)
        settings.lastSubjectID = subject.id
        scheduleFocusNotificationIfNeeded()
        performHaptic()
    }

    private func requestFinish() {
        if snapshot.elapsedSeconds < 60 {
            showShortSessionAlert = true
        } else {
            showEarlyFinishDialog = true
        }
    }

    private func finishAndPersist() {
        guard let draft = timerEngine.finish() else { return }
        persist(draft)
    }

    private func completeIfNeeded() {
        guard let draft = timerEngine.completeIfNeeded() else { return }
        persist(draft)
    }

    private func persist(_ draft: FocusSessionDraft) {
        let oldMinutes = stats.summary(on: .now, sessions: sessions, goalMinutes: settings.dailyGoalMinutes).minutes
        _ = FocusSessionManager.persist(draft, goalMinutes: settings.dailyGoalMinutes, modelContext: modelContext)
        NotificationService.cancelFocusEnd()
        let updatedSessions = sessions + [StudySession(draft: draft)]
        let newMinutes = stats.summary(on: .now, sessions: updatedSessions, goalMinutes: settings.dailyGoalMinutes).minutes
        let streak = stats.currentStreak(sessions: updatedSessions, asOf: .now)
        let milestone = settings.claimStreakMilestone(streak: streak)
        completion = FocusCompletion(
            sessionMinutes: draft.durationSeconds / 60,
            todayMinutes: newMinutes,
            achievedGoal: oldMinutes < settings.dailyGoalMinutes && newMinutes >= settings.dailyGoalMinutes,
            streak: streak,
            milestone: milestone
        )
        performHaptic()
    }

    private func startNextSegment() {
        completion = nil
        startTimer()
    }

    private func scheduleFocusNotificationIfNeeded() {
        guard let planned = timerEngine.activeState?.plannedSeconds,
              timerEngine.activeState?.pauseStartedAt == nil else { return }
        let fireDate = Date().addingTimeInterval(TimeInterval(max(1, timerEngine.snapshot().remainingSeconds ?? planned)))
        Task { await NotificationService.scheduleFocusEnd(at: fireDate, soundEnabled: settings.soundEnabled) }
    }

    private func applyRequestedFreeTimer() {
        guard requestedFreeTimer, !isActive else { return }
        preset = .free
        requestedFreeTimer = false
    }

    private func performHaptic() {
        guard settings.hapticsEnabled else { return }
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
}

#Preview {
    FocusView(requestedFreeTimer: .constant(false))
        .environmentObject(AppSettings())
        .environmentObject(FocusTimerEngine(store: InMemoryActiveTimerStore()))
        .modelContainer(for: [Subject.self, StudySession.self], inMemory: true)
}
