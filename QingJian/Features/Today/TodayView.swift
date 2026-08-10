import SwiftData
import SwiftUI

struct TodayView: View {
    @Binding var selectedTab: Int
    let openFreeTimer: () -> Void
    @EnvironmentObject private var settings: AppSettings
    @Query(sort: \StudySession.startAt, order: .reverse) private var sessions: [StudySession]
    @Query(sort: \Subject.sortOrder) private var subjects: [Subject]
    @Query(sort: \QuoteFavorite.favoritedAt, order: .reverse) private var favorites: [QuoteFavorite]
    @Environment(\.modelContext) private var modelContext
    @State private var showsSettings = false

    private let stats = StudyStatsService()
    private let quoteService = QuoteService()

    private var today: DayStudySummary {
        stats.summary(on: .now, sessions: sessions, goalMinutes: settings.dailyGoalMinutes)
    }

    private var quote: Quote {
        quoteService.dailyQuote(on: .now)
    }

    private var progress: Double {
        guard settings.dailyGoalMinutes > 0 else { return 0 }
        return Double(today.minutes) / Double(settings.dailyGoalMinutes)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return "早上好"
        case 12..<18: return "下午好"
        default: return "晚上好"
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: QingTheme.Spacing.regular) {
                        header
                        targetDayCard
                        quoteCard
                        progressCard
                        actionButtons
                        StudyGardenView(progress: progress)
                        subjectSummary
                    }
                    .padding(.horizontal, QingTheme.Spacing.regular)
                    .padding(.bottom, QingTheme.Spacing.extraLarge)
                }
            }
            .navigationTitle("今日")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showsSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("打开设置")
                }
            }
            .sheet(isPresented: $showsSettings) {
                SettingsView()
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: QingTheme.Spacing.tiny) {
                Text(greeting)
                    .font(QingTheme.displayFont(size: 29, relativeTo: .largeTitle).weight(.semibold))
                    .foregroundStyle(QingTheme.pineInk)
                Text("把这一小段时间，留给眼前的事。")
                    .font(.subheadline)
                    .foregroundStyle(QingTheme.secondaryInk)
            }
            Spacer(minLength: 0)
            Image(systemName: "sun.max.fill")
                .foregroundStyle(QingTheme.morningGold)
                .font(.title2)
                .accessibilityHidden(true)
        }
        .padding(.top, QingTheme.Spacing.small)
    }

    @ViewBuilder
    private var targetDayCard: some View {
        QingCard {
            if let targetDate = settings.targetDate {
                let days = Calendar.current.dateComponents(
                    [.day],
                    from: Calendar.current.startOfDay(for: .now),
                    to: Calendar.current.startOfDay(for: targetDate)
                ).day ?? 0
                HStack {
                    VStack(alignment: .leading, spacing: QingTheme.Spacing.small) {
                        Text("目标日")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(QingTheme.mistGreen)
                        Text(days >= 0 ? "距离目标日还有 \(days) 天" : "目标日已经抵达")
                            .font(QingTheme.displayFont(size: 20, relativeTo: .title3).weight(.semibold))
                            .foregroundStyle(QingTheme.pineInk)
                        Text(targetDate.qingMediumDate())
                            .font(.caption)
                            .foregroundStyle(QingTheme.secondaryInk)
                    }
                    Spacer()
                    Image(systemName: days >= 0 ? "flag.checkered" : "checkmark.seal.fill")
                        .font(.title2)
                        .foregroundStyle(days >= 0 ? QingTheme.morningGold : QingTheme.sprout)
                        .accessibilityHidden(true)
                }
            } else {
                Button {
                    showsSettings = true
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: QingTheme.Spacing.small) {
                            Text("写下一个想抵达的日子")
                                .font(QingTheme.displayFont(size: 19, relativeTo: .title3).weight(.semibold))
                            Text("不急，等你准备好再把它写下来。")
                                .font(.caption)
                                .foregroundStyle(QingTheme.secondaryInk)
                        }
                        Spacer()
                        Image(systemName: "pencil.line")
                    }
                }
                .buttonStyle(.plain)
                .foregroundStyle(QingTheme.pineInk)
            }
        }
    }

    private var quoteCard: some View {
        NavigationLink {
            QuoteDetailView(quote: quote)
        } label: {
            QingCard {
                VStack(alignment: .leading, spacing: QingTheme.Spacing.medium) {
                    HStack {
                        Text("今日一句 · 拾光")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(QingTheme.mistGreen)
                        Spacer()
                        Button {
                            toggleFavorite(quote)
                        } label: {
                            Image(systemName: isFavorite(quote) ? "heart.fill" : "heart")
                                .foregroundStyle(isFavorite(quote) ? QingTheme.morningGold : QingTheme.secondaryInk)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(isFavorite(quote) ? "取消收藏今日一句" : "收藏今日一句")
                    }
                    Text("“\(quote.text)”")
                        .font(QingTheme.displayFont(size: 20, relativeTo: .title3))
                        .foregroundStyle(QingTheme.pineInk)
                        .multilineTextAlignment(.leading)
                    Text(quote.attribution)
                        .font(.caption)
                        .foregroundStyle(QingTheme.secondaryInk)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityHint("打开拾光详情")
    }

    private var progressCard: some View {
        QingCard {
            HStack(spacing: QingTheme.Spacing.large) {
                ProgressRing(progress: progress, label: "\(Int(min(progress, 1) * 100))%")
                    .frame(width: 112, height: 112)
                VStack(alignment: .leading, spacing: QingTheme.Spacing.small) {
                    Text("今日学习进度")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(QingTheme.mistGreen)
                    Text("已学习 \(today.minutes) / \(settings.dailyGoalMinutes) 分钟")
                        .font(QingTheme.displayFont(size: 20, relativeTo: .title3).weight(.semibold))
                        .foregroundStyle(QingTheme.pineInk)
                        .fixedSize(horizontal: false, vertical: true)
                    Label("当前连续点亮 \(stats.currentStreak(sessions: sessions, asOf: .now)) 天", systemImage: "leaf.fill")
                        .font(.caption)
                        .foregroundStyle(QingTheme.secondaryInk)
                        .accessibilityLabel("当前连续点亮 \(stats.currentStreak(sessions: sessions, asOf: .now)) 天")
                }
                Spacer(minLength: 0)
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: QingTheme.Spacing.small) {
            QingPrimaryButton("开始专注", systemImage: "play.fill") {
                selectedTab = 1
            }
            Button {
                openFreeTimer()
            } label: {
                Label("自由计时", systemImage: "stopwatch")
                    .font(.subheadline.weight(.medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, QingTheme.Spacing.medium)
            }
            .buttonStyle(.plain)
            .foregroundStyle(QingTheme.pineInk)
            .background(QingTheme.quietFill, in: RoundedRectangle(cornerRadius: QingTheme.Radius.control, style: .continuous))
            .accessibilityHint("打开专注页后选择自由计时")
        }
    }

    private var subjectSummary: some View {
        QingCard {
            VStack(alignment: .leading, spacing: QingTheme.Spacing.medium) {
                Text("今日科目")
                    .font(QingTheme.displayFont(size: 20, relativeTo: .title3).weight(.semibold))
                    .foregroundStyle(QingTheme.pineInk)
                let totals = stats.subjectTotals(sessions: sessions, on: .now)
                if totals.isEmpty {
                    Text("还没有记录。开始一段专注，让今天留下一点痕迹。")
                        .font(.caption)
                        .foregroundStyle(QingTheme.secondaryInk)
                } else {
                    ForEach(totals.prefix(5)) { total in
                        HStack {
                            Text(total.name)
                            Spacer()
                            Text(total.minutes.qingMinuteText)
                                .foregroundStyle(QingTheme.pineInk)
                        }
                        .font(.subheadline)
                        .padding(.vertical, QingTheme.Spacing.tiny)
                    }
                }
                if subjects.isEmpty {
                    Text("可在设置中添加科目。")
                        .font(.caption2)
                        .foregroundStyle(QingTheme.secondaryInk)
                }
            }
        }
    }

    private func isFavorite(_ quote: Quote) -> Bool {
        favorites.contains { $0.quoteID == quote.id }
    }

    private func toggleFavorite(_ quote: Quote) {
        if let favorite = favorites.first(where: { $0.quoteID == quote.id }) {
            modelContext.delete(favorite)
        } else {
            modelContext.insert(QuoteFavorite(quoteID: quote.id))
        }
        try? modelContext.save()
    }
}

#Preview {
    TodayView(selectedTab: .constant(0), openFreeTimer: {})
        .environmentObject(AppSettings())
        .environmentObject(FocusTimerEngine(store: InMemoryActiveTimerStore()))
        .modelContainer(for: [StudySession.self, Subject.self, QuoteFavorite.self], inMemory: true)
}
