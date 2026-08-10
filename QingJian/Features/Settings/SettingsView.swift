import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settings: AppSettings
    @Query(sort: \StudySession.startAt, order: .reverse) private var sessions: [StudySession]
    @State private var exportURL: URL?
    @State private var notificationDenied = false

    var body: some View {
        NavigationStack {
            Form {
                Section("学习") {
                    Stepper(value: $settings.dailyGoalMinutes, in: 15...720, step: 15) {
                        LabeledContent("每日学习目标", value: "\(settings.dailyGoalMinutes) 分钟")
                    }
                    targetDateControl
                    NavigationLink("科目管理") { SubjectEditorView() }
                }

                Section("提醒") {
                    Toggle("每日学习提醒", isOn: Binding(
                        get: { settings.reminderEnabled },
                        set: { setReminderEnabled($0) }
                    ))
                    if settings.reminderEnabled {
                        DatePicker("提醒时间", selection: reminderDateBinding, displayedComponents: .hourAndMinute)
                            .onChange(of: settings.reminderHour) { _, _ in scheduleReminder() }
                            .onChange(of: settings.reminderMinute) { _, _ in scheduleReminder() }
                    }
                    Toggle("声音", isOn: $settings.soundEnabled)
                        .onChange(of: settings.soundEnabled) { _, _ in scheduleReminder() }
                    Toggle("触感", isOn: $settings.hapticsEnabled)
                }

                Section("外观") {
                    Picker("外观", selection: $settings.appearance) {
                        ForEach(AppAppearance.allCases) { appearance in
                            Text(appearance.title).tag(appearance)
                        }
                    }
                }

                Section("数据") {
                    Button("生成学习记录 CSV") {
                        exportURL = try? CSVExporter.exportURL(for: sessions)
                    }
                    if let exportURL {
                        ShareLink(item: exportURL) {
                            Label("分享 CSV 文件", systemImage: "square.and.arrow.up")
                        }
                    }
                }

                Section("关于") {
                    NavigationLink("隐私说明") { PrivacyView() }
                    NavigationLink("关于晴笺") { AboutView() }
                }
            }
            .navigationTitle("设置")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
            .alert("需要通知权限", isPresented: $notificationDenied) {
                Button("好") { }
            } message: {
                Text("可在系统设置中允许通知后，再开启每日提醒。")
            }
        }
    }

    private var targetDateControl: some View {
        Group {
            if settings.targetDate != nil {
                DatePicker("目标日", selection: Binding(
                    get: { settings.targetDate ?? .now },
                    set: { settings.targetDate = $0 }
                ), displayedComponents: .date)
                Button("清除目标日", role: .destructive) {
                    settings.targetDate = nil
                }
            } else {
                Button("设置目标日") {
                    settings.targetDate = Calendar.current.date(byAdding: .month, value: 4, to: .now)
                }
            }
        }
    }

    private var reminderDateBinding: Binding<Date> {
        Binding(
            get: { settings.reminderDate },
            set: { value in
                settings.reminderHour = Calendar.current.component(.hour, from: value)
                settings.reminderMinute = Calendar.current.component(.minute, from: value)
            }
        )
    }

    private func setReminderEnabled(_ enabled: Bool) {
        guard enabled else {
            settings.reminderEnabled = false
            NotificationService.cancelDailyReminder()
            return
        }
        Task {
            let granted = await NotificationService.requestPermission()
            await MainActor.run {
                settings.reminderEnabled = granted
                notificationDenied = !granted
            }
            if granted { await NotificationService.scheduleDailyReminder(hour: settings.reminderHour, minute: settings.reminderMinute, soundEnabled: settings.soundEnabled) }
        }
    }

    private func scheduleReminder() {
        guard settings.reminderEnabled else { return }
        Task { await NotificationService.scheduleDailyReminder(hour: settings.reminderHour, minute: settings.reminderMinute, soundEnabled: settings.soundEnabled) }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppSettings())
        .modelContainer(for: [StudySession.self, Subject.self], inMemory: true)
}
