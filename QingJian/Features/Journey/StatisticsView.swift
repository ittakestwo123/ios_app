import Charts
import SwiftUI

struct StatisticsView: View {
    let sessions: [StudySession]
    let dailyRecords: [DailyRecord]
    let defaultGoalMinutes: Int
    private let stats = StudyStatsService()
    private let calendar = Calendar.current

    private var recentDays: [DayStudySummary] {
        stats.summaries(endingOn: .now, dayCount: 7, sessions: sessions) { day in
            stats.goalMinutes(on: day, records: dailyRecords, defaultGoalMinutes: defaultGoalMinutes)
        }
    }

    private var recentWeeks: [WeekTotal] {
        let days = stats.summaries(endingOn: .now, dayCount: 28, sessions: sessions) { day in
            stats.goalMinutes(on: day, records: dailyRecords, defaultGoalMinutes: defaultGoalMinutes)
        }
        return stride(from: 0, to: days.count, by: 7).enumerated().map { index, offset in
            WeekTotal(week: "第\(index + 1)周", minutes: days[offset..<min(offset + 7, days.count)].reduce(0) { $0 + $1.minutes })
        }
    }

    private var monthMinutes: Int {
        let monthStart = calendar.dateInterval(of: .month, for: .now)?.start ?? calendar.startOfDay(for: .now)
        let dayCount = (calendar.dateComponents([.day], from: monthStart, to: calendar.startOfDay(for: .now)).day ?? 0) + 1
        return stats.summaries(endingOn: .now, dayCount: dayCount, sessions: sessions) { day in
            stats.goalMinutes(on: day, records: dailyRecords, defaultGoalMinutes: defaultGoalMinutes)
        }.reduce(0) { $0 + $1.minutes }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: QingTheme.Spacing.regular) {
                metricGrid
                chartCard(title: "最近 7 天") {
                    Chart(recentDays) { day in
                        BarMark(
                            x: .value("日期", day.date, unit: .day),
                            y: .value("分钟", day.minutes)
                        )
                        .foregroundStyle(day.goalReached ? QingTheme.morningGold : QingTheme.mistGreen)
                        .cornerRadius(5)
                    }
                    .chartYAxis { AxisMarks(position: .leading) }
                    .frame(height: 180)
                }
                chartCard(title: "近 4 周趋势") {
                    Chart(recentWeeks) { week in
                        LineMark(x: .value("周", week.week), y: .value("分钟", week.minutes))
                            .foregroundStyle(QingTheme.pineInk)
                            .interpolationMethod(.catmullRom)
                        PointMark(x: .value("周", week.week), y: .value("分钟", week.minutes))
                            .foregroundStyle(QingTheme.morningGold)
                    }
                    .frame(height: 160)
                }
                chartCard(title: "科目分布") {
                    let totals = stats.subjectTotals(sessions: sessions)
                    if totals.isEmpty {
                        Text("完成第一段专注后，这里会留下科目分布。")
                            .font(.caption)
                            .foregroundStyle(QingTheme.secondaryInk)
                    } else {
                        Chart(totals.prefix(6)) { total in
                            BarMark(x: .value("分钟", total.minutes), y: .value("科目", total.name))
                                .foregroundStyle(QingTheme.sprout)
                                .cornerRadius(5)
                        }
                        .frame(height: max(130, CGFloat(totals.prefix(6).count) * 36))
                    }
                }
            }
            .padding(.horizontal, QingTheme.Spacing.regular)
            .padding(.bottom, QingTheme.Spacing.extraLarge)
        }
    }

    private var metricGrid: some View {
        let currentStreak = stats.currentStreak(sessions: sessions, asOf: .now)
        let longestStreak = stats.longestStreak(sessions: sessions)
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: QingTheme.Spacing.small) {
            MetricTile(title: "本周总时长", value: recentDays.reduce(0) { $0 + $1.minutes }.qingMinuteText, icon: "clock")
            MetricTile(title: "本月总时长", value: monthMinutes.qingMinuteText, icon: "calendar")
            MetricTile(title: "日均时长", value: (recentDays.reduce(0) { $0 + $1.minutes } / 7).qingMinuteText, icon: "chart.bar")
            MetricTile(title: "最长单次", value: (stats.longestSession(sessions: sessions) / 60).qingMinuteText, icon: "timer")
            MetricTile(title: "连续点亮", value: "\(currentStreak) 天 · 最长 \(longestStreak) 天", icon: "leaf")
        }
    }

    private func chartCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        QingCard {
            VStack(alignment: .leading, spacing: QingTheme.Spacing.medium) {
                Text(title)
                    .font(QingTheme.displayFont(size: 20, relativeTo: .title3).weight(.semibold))
                    .foregroundStyle(QingTheme.pineInk)
                content()
            }
        }
    }
}

private struct WeekTotal: Identifiable {
    let week: String
    let minutes: Int
    var id: String { week }
}

private struct MetricTile: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        QingCard {
            VStack(alignment: .leading, spacing: QingTheme.Spacing.small) {
                Image(systemName: icon)
                    .foregroundStyle(QingTheme.mistGreen)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(QingTheme.secondaryInk)
                Text(value)
                    .font(QingTheme.displayFont(size: 17, relativeTo: .headline).weight(.semibold))
                    .foregroundStyle(QingTheme.pineInk)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
