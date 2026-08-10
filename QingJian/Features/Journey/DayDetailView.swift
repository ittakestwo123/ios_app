import SwiftData
import SwiftUI

struct DayDetailView: View {
    let date: Date
    let sessions: [StudySession]
    let goalMinutes: Int
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var note = ""
    @State private var record: DailyRecord?
    private let calendar = Calendar.current
    private let dateService = DateKeyService()
    private let stats = StudyStatsService()
    private let quoteService = QuoteService()

    private var summary: DayStudySummary {
        stats.summary(on: date, sessions: sessions, goalMinutes: goalMinutes)
    }

    private var daySessions: [StudySession] {
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: date)) else { return [] }
        return sessions.filter { $0.endAt > calendar.startOfDay(for: date) && $0.startAt < nextDay }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("这一天") {
                    LabeledContent("总学习时长", value: summary.minutes.qingMinuteText)
                    LabeledContent("每日目标", value: "\(goalMinutes) 分钟")
                    Label(summary.goalReached ? "当天目标已完成" : "留下的每一分钟都会被记住", systemImage: summary.goalReached ? "checkmark.seal.fill" : "leaf.fill")
                        .foregroundStyle(summary.goalReached ? QingTheme.sprout : QingTheme.mistGreen)
                }

                Section("科目") {
                    let totals = stats.subjectTotals(sessions: sessions, on: date)
                    if totals.isEmpty {
                        Text("这一天还没有专注记录。")
                            .foregroundStyle(QingTheme.secondaryInk)
                    } else {
                        ForEach(totals) { total in
                            LabeledContent(total.name, value: total.minutes.qingMinuteText)
                        }
                    }
                }

                Section("专注记录") {
                    if daySessions.isEmpty {
                        Text("暂无记录")
                            .foregroundStyle(QingTheme.secondaryInk)
                    } else {
                        ForEach(daySessions) { session in
                            VStack(alignment: .leading, spacing: QingTheme.Spacing.tiny) {
                                Text(session.subjectNameSnapshot)
                                    .font(.headline)
                                Text("\(session.startAt.formatted(.dateTime.hour().minute())) · \(stats.seconds(of: session, on: date) / 60) 分钟")
                                    .font(.caption)
                                    .foregroundStyle(QingTheme.secondaryInk)
                            }
                        }
                    }
                }

                Section("当天拾光") {
                    let quote = quoteService.dailyQuote(on: date)
                    Text("“\(quote.text)”")
                        .font(QingTheme.displayFont(size: 18, relativeTo: .body))
                    Text(quote.attribution)
                        .font(.caption)
                        .foregroundStyle(QingTheme.secondaryInk)
                }

                Section("给这一天留一句话") {
                    TextEditor(text: $note)
                        .frame(minHeight: 88)
                    Button("保存备注") { saveNote() }
                        .tint(QingTheme.pineInk)
                }
            }
            .navigationTitle(date.qingMediumDate())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
            .task { loadNote() }
        }
    }

    private func loadNote() {
        let key = dateService.dateKey(for: date)
        let descriptor = FetchDescriptor<DailyRecord>(predicate: #Predicate { $0.dateKey == key })
        record = try? modelContext.fetch(descriptor).first
        note = record?.note ?? ""
    }

    private func saveNote() {
        if let record {
            record.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            let newRecord = DailyRecord(dateKey: dateService.dateKey(for: date), goalMinutesSnapshot: goalMinutes, note: note.trimmingCharacters(in: .whitespacesAndNewlines))
            modelContext.insert(newRecord)
            record = newRecord
        }
        try? modelContext.save()
    }
}
