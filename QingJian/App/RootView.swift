import SwiftData
import SwiftUI

struct RootView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var timerEngine: FocusTimerEngine
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if settings.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .task {
            seedInitialDataIfNeeded()
            handleRestore()
        }
        .onChange(of: scenePhase) { _, newValue in
            guard newValue == .active else { return }
            timerEngine.refresh()
            saveAutoCompletedTimerIfNeeded()
        }
    }

    private func seedInitialDataIfNeeded() {
        guard settings.hasCompletedOnboarding else { return }
        do {
            try DefaultDataSeeder.seedSubjectsIfNeeded(in: modelContext)
        } catch {
            assertionFailure("无法初始化默认科目：\(error.localizedDescription)")
        }
    }

    private func handleRestore() {
        if case let .completed(draft) = timerEngine.restore() {
            _ = FocusSessionManager.persist(draft, goalMinutes: settings.dailyGoalMinutes, modelContext: modelContext)
        }
    }

    private func saveAutoCompletedTimerIfNeeded() {
        guard let draft = timerEngine.completeIfNeeded() else { return }
        _ = FocusSessionManager.persist(draft, goalMinutes: settings.dailyGoalMinutes, modelContext: modelContext)
        NotificationService.cancelFocusEnd()
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var requestedFreeTimer = false

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView(selectedTab: $selectedTab) {
                requestedFreeTimer = true
                selectedTab = 1
            }
                .tabItem { Label("今日", systemImage: "sun.max") }
                .tag(0)
            FocusView(requestedFreeTimer: $requestedFreeTimer)
                .tabItem { Label("专注", systemImage: "timer") }
                .tag(1)
            JourneyView()
                .tabItem { Label("足迹", systemImage: "calendar") }
                .tag(2)
            QuotesView()
                .tabItem { Label("拾光", systemImage: "quote.opening") }
                .tag(3)
        }
        .tint(QingTheme.pineInk)
    }
}
