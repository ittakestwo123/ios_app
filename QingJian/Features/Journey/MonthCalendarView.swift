import SwiftUI

struct MonthCalendarView: View {
    let sessions: [StudySession]
    let dailyRecords: [DailyRecord]
    let defaultGoalMinutes: Int
    @State private var displayedMonth = Date()
    @State private var selectedDay: CalendarSelection?
    private let calendar = Calendar.current
    private let stats = StudyStatsService()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: QingTheme.Spacing.regular) {
                QingCard {
                    VStack(spacing: QingTheme.Spacing.medium) {
                        monthHeader
                        weekdayHeader
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: QingTheme.Spacing.tiny), count: 7), spacing: QingTheme.Spacing.small) {
                            ForEach(calendarCells.indices, id: \.self) { index in
                                if let date = calendarCells[index] {
                                    CalendarDayCell(
                                        day: date,
                                        summary: stats.summary(on: date, sessions: sessions, goalMinutes: goalMinutes(for: date)),
                                        isToday: calendar.isDateInToday(date)
                                    ) {
                                        selectedDay = CalendarSelection(date: date)
                                    }
                                } else {
                                    Color.clear
                                        .frame(height: 38)
                                }
                            }
                        }
                    }
                }
                streakCard
                Text("有学习 ≥10 分钟的日子会点亮嫩叶；达成当天目标时，梅花与星点会出现。")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(QingTheme.secondaryInk)
                    .padding(.horizontal, QingTheme.Spacing.large)
            }
            .padding(.horizontal, QingTheme.Spacing.regular)
            .padding(.bottom, QingTheme.Spacing.extraLarge)
        }
        .sheet(item: $selectedDay) { selection in
            DayDetailView(date: selection.date, sessions: sessions, goalMinutes: goalMinutes(for: selection.date))
        }
    }

    private var monthHeader: some View {
        HStack {
            Button {
                moveMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
            }
            .accessibilityLabel("上个月")
            Spacer()
            Text(displayedMonth.formatted(.dateTime.year().month(.wide)))
                .font(QingTheme.displayFont(size: 22, relativeTo: .title3).weight(.semibold))
                .foregroundStyle(QingTheme.pineInk)
            Spacer()
            Button {
                moveMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
            }
            .accessibilityLabel("下个月")
        }
        .foregroundStyle(QingTheme.pineInk)
    }

    private var weekdayHeader: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(QingTheme.secondaryInk)
            }
        }
    }

    private var streakCard: some View {
        let current = stats.currentStreak(sessions: sessions, asOf: .now)
        let longest = stats.longestStreak(sessions: sessions)
        return QingCard {
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundStyle(QingTheme.sprout)
                    .font(.title2)
                VStack(alignment: .leading, spacing: QingTheme.Spacing.tiny) {
                    Text("连续点亮 \(current) 天")
                        .font(QingTheme.displayFont(size: 19, relativeTo: .title3).weight(.semibold))
                        .foregroundStyle(QingTheme.pineInk)
                    Text("最长连续 \(longest) 天。每一次回来，都算数。")
                        .font(.caption)
                        .foregroundStyle(QingTheme.secondaryInk)
                }
                Spacer()
            }
        }
    }

    private var calendarCells: [Date?] {
        guard let interval = calendar.dateInterval(of: .month, for: displayedMonth),
              let days = calendar.range(of: .day, in: .month, for: displayedMonth) else { return [] }
        let firstWeekday = calendar.component(.weekday, from: interval.start)
        let leading = (firstWeekday - calendar.firstWeekday + 7) % 7
        let dates: [Date?] = days.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: interval.start)
        }
        let raw = Array(repeating: nil as Date?, count: leading) + dates
        let trailing = (7 - raw.count % 7) % 7
        return raw + Array(repeating: nil, count: trailing)
    }

    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        let offset = calendar.firstWeekday - 1
        return Array(symbols[offset...]) + Array(symbols[..<offset])
    }

    private func moveMonth(by value: Int) {
        displayedMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) ?? displayedMonth
    }

    private func goalMinutes(for date: Date) -> Int {
        stats.goalMinutes(on: date, records: dailyRecords, defaultGoalMinutes: defaultGoalMinutes)
    }
}

private struct CalendarSelection: Identifiable {
    let date: Date
    var id: Date { date }
}

private struct CalendarDayCell: View {
    let day: Date
    let summary: DayStudySummary
    let isToday: Bool
    let action: () -> Void
    private let calendar = Calendar.current

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(summary.isLit ? QingTheme.quietFill : Color.clear)
                if isToday {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(QingTheme.morningGold, lineWidth: 1.5)
                }
                VStack(spacing: 1) {
                    Text("\(calendar.component(.day, from: day))")
                        .font(.caption2.weight(isToday ? .bold : .regular))
                        .foregroundStyle(QingTheme.ink)
                    if summary.goalReached {
                        ZStack {
                            PlumBlossom().frame(width: 18, height: 18)
                            Image(systemName: "sparkle")
                                .font(.system(size: 6))
                                .foregroundStyle(QingTheme.morningGold)
                                .offset(x: 9, y: -7)
                        }
                    } else if summary.isLit {
                        LeafMark().fill(QingTheme.sprout).frame(width: 14, height: 13)
                    }
                }
            }
            .frame(height: 42)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(day.qingMediumDate())
        .accessibilityValue(summary.goalReached ? "已达成目标" : summary.isLit ? "已学习 \(summary.minutes) 分钟" : "暂无学习记录")
    }
}
