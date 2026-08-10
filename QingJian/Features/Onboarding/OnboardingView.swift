import SwiftData
import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.modelContext) private var modelContext
    @State private var page = 0
    @State private var wantsTargetDate = false
    @State private var selectedTargetDate = Calendar.current.date(byAdding: .month, value: 4, to: .now) ?? .now
    @State private var goalMinutes = 240
    @State private var subjectNames = Subject.defaultNames

    var body: some View {
        ZStack {
            PaperBackground()
            VStack(spacing: QingTheme.Spacing.large) {
                Spacer()
                pageContent
                    .frame(maxWidth: 520)
                Spacer()
                PageDots(current: page)
                navigationControls
            }
            .padding(QingTheme.Spacing.large)
        }
    }

    @ViewBuilder
    private var pageContent: some View {
        switch page {
        case 0:
            VStack(spacing: QingTheme.Spacing.regular) {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 46, weight: .light))
                    .foregroundStyle(QingTheme.morningGold)
                    .accessibilityHidden(true)
                Text("晴笺")
                    .font(QingTheme.displayFont(size: 42, relativeTo: .largeTitle).weight(.semibold))
                    .foregroundStyle(QingTheme.pineInk)
                Text("专注、打卡与诗意陪伴")
                    .font(.subheadline)
                    .foregroundStyle(QingTheme.mistGreen)
                Text("把今天认真走过，明天会有光。")
                    .font(QingTheme.displayFont(size: 22, relativeTo: .title2))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(QingTheme.ink)
                    .padding(.top, QingTheme.Spacing.small)
            }
        case 1:
            QingCard {
                VStack(alignment: .leading, spacing: QingTheme.Spacing.regular) {
                    Text("给今天一个方向")
                        .font(QingTheme.displayFont(size: 25, relativeTo: .title2).weight(.semibold))
                        .foregroundStyle(QingTheme.pineInk)
                    Toggle("设置一个目标日", isOn: $wantsTargetDate.animation())
                        .tint(QingTheme.mistGreen)
                    if wantsTargetDate {
                        DatePicker("目标日期", selection: $selectedTargetDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .tint(QingTheme.pineInk)
                    }
                    Divider()
                    Stepper(value: $goalMinutes, in: 15...720, step: 15) {
                        VStack(alignment: .leading) {
                            Text("每日学习目标")
                            Text("\(goalMinutes) 分钟")
                                .font(QingTheme.displayFont(size: 21, relativeTo: .title3))
                                .foregroundStyle(QingTheme.pineInk)
                        }
                    }
                }
            }
        default:
            QingCard {
                VStack(alignment: .leading, spacing: QingTheme.Spacing.medium) {
                    Text("先写下要学习的科目")
                        .font(QingTheme.displayFont(size: 25, relativeTo: .title2).weight(.semibold))
                        .foregroundStyle(QingTheme.pineInk)
                    Text("以后可随时在设置中调整。")
                        .font(.subheadline)
                        .foregroundStyle(QingTheme.secondaryInk)
                    ForEach(subjectNames.indices, id: \.self) { index in
                        HStack {
                            TextField("科目名称", text: $subjectNames[index])
                                .textFieldStyle(.roundedBorder)
                            Button(role: .destructive) {
                                guard subjectNames.count > 1 else { return }
                                subjectNames.remove(at: index)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                            }
                            .accessibilityLabel("删除\(subjectNames[index])")
                        }
                    }
                    Button {
                        subjectNames.append("")
                    } label: {
                        Label("新增科目", systemImage: "plus")
                    }
                    .tint(QingTheme.pineInk)
                }
            }
        }
    }

    private var navigationControls: some View {
        HStack(spacing: QingTheme.Spacing.medium) {
            if page > 0 {
                Button("上一步") { page -= 1 }
                    .buttonStyle(.bordered)
                    .tint(QingTheme.pineInk)
            }
            Button(page == 2 ? "完成" : "继续") {
                if page == 2 {
                    completeOnboarding()
                } else {
                    page += 1
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(QingTheme.pineInk)
        }
    }

    private func completeOnboarding() {
        settings.dailyGoalMinutes = goalMinutes
        settings.targetDate = wantsTargetDate ? selectedTargetDate : nil
        for (index, name) in SubjectCatalog.namesForOnboarding(subjectNames).enumerated() {
            modelContext.insert(Subject(name: name, sortOrder: index))
        }
        try? modelContext.save()
        settings.hasCompletedOnboarding = true
    }
}

private struct PageDots: View {
    var current: Int

    var body: some View {
        HStack(spacing: QingTheme.Spacing.small) {
            ForEach(0..<3, id: \.self) { index in
                Capsule()
                    .fill(index == current ? QingTheme.pineInk : QingTheme.mistGreen.opacity(0.24))
                    .frame(width: index == current ? 22 : 8, height: 8)
            }
        }
        .accessibilityLabel("引导第\(current + 1)页，共3页")
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppSettings())
        .modelContainer(for: [Subject.self], inMemory: true)
}
