import SwiftData
import SwiftUI

struct JourneyView: View {
    private enum Section: String, CaseIterable, Identifiable {
        case calendar
        case statistics

        var id: String { rawValue }
        var title: String { self == .calendar ? "日历" : "统计" }
    }

    @State private var section: Section = .calendar
    @EnvironmentObject private var settings: AppSettings
    @Query(sort: \StudySession.startAt, order: .reverse) private var sessions: [StudySession]
    @Query private var dailyRecords: [DailyRecord]

    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground()
                VStack(spacing: QingTheme.Spacing.medium) {
                    Picker("足迹内容", selection: $section) {
                        ForEach(Section.allCases) { value in
                            Text(value.title).tag(value)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, QingTheme.Spacing.regular)

                    switch section {
                    case .calendar:
                        MonthCalendarView(sessions: sessions, dailyRecords: dailyRecords, defaultGoalMinutes: settings.dailyGoalMinutes)
                    case .statistics:
                        StatisticsView(sessions: sessions, dailyRecords: dailyRecords, defaultGoalMinutes: settings.dailyGoalMinutes)
                    }
                }
                .padding(.top, QingTheme.Spacing.small)
            }
            .navigationTitle("足迹")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    JourneyView()
        .environmentObject(AppSettings())
        .modelContainer(for: [StudySession.self, DailyRecord.self], inMemory: true)
}
