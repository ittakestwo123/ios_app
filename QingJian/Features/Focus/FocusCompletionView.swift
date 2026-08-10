import SwiftUI

struct FocusCompletionView: View {
    let completion: FocusCompletion
    let quote: Quote?
    let onContinue: () -> Void
    let onDismiss: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    var body: some View {
        ZStack {
            PaperBackground()
            VStack(spacing: QingTheme.Spacing.regular) {
                ZStack {
                    BambooSprig()
                        .frame(width: 105, height: 114)
                        .opacity(0.55)
                        .offset(x: 17, y: 9)
                    PlumBlossom()
                        .frame(width: 86, height: 86)
                        .scaleEffect(appeared ? 1 : 0.74)
                    Image(systemName: "sparkle")
                        .foregroundStyle(QingTheme.morningGold)
                        .offset(x: 47, y: -40)
                        .opacity(appeared ? 1 : 0)
                }
                .frame(height: 118)
                .accessibilityLabel("一枝正在开放的梅花")

                Text("今天又向前了一点点")
                    .font(QingTheme.displayFont(size: 27, relativeTo: .title).weight(.semibold))
                    .foregroundStyle(QingTheme.pineInk)
                Text("本次 \(completion.sessionMinutes) 分钟 · 今日共 \(completion.todayMinutes) 分钟")
                    .font(.subheadline)
                    .foregroundStyle(QingTheme.secondaryInk)
                if completion.achievedGoal {
                    Label("今日目标已经完成", systemImage: "checkmark.seal.fill")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(QingTheme.sprout)
                }
                if let milestone = completion.milestone {
                    Label("连续点亮 \(milestone) 天", systemImage: "leaf.fill")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(QingTheme.sprout)
                }
                if let quote {
                    QingCard {
                        VStack(alignment: .leading, spacing: QingTheme.Spacing.small) {
                            Text("送给今天的你")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(QingTheme.mistGreen)
                            Text("“\(quote.text)”")
                                .font(QingTheme.displayFont(size: 17, relativeTo: .body))
                                .foregroundStyle(QingTheme.pineInk)
                            Text(quote.attribution)
                                .font(.caption)
                                .foregroundStyle(QingTheme.secondaryInk)
                        }
                    }
                }
                QingPrimaryButton("收下这句话", systemImage: "heart") { onDismiss() }
                Button("继续下一段", action: onContinue)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(QingTheme.pineInk)
                Button("完成", action: onDismiss)
                    .font(.caption)
                    .foregroundStyle(QingTheme.secondaryInk)
            }
            .padding(QingTheme.Spacing.large)
        }
        .onAppear {
            guard !reduceMotion else {
                appeared = true
                return
            }
            withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                appeared = true
            }
        }
    }
}
