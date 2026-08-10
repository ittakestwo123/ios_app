import SwiftUI

struct ProgressRing: View {
    var progress: Double
    var lineWidth: CGFloat = 12
    var label: String

    private var clampedProgress: Double { min(max(progress, 0), 1) }

    var body: some View {
        ZStack {
            Circle()
                .stroke(QingTheme.quietFill, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: clampedProgress)
                .stroke(
                    AngularGradient(colors: [QingTheme.mistGreen, QingTheme.sprout, QingTheme.morningGold], center: .center),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            Text(label)
                .font(QingTheme.displayFont(size: 19, relativeTo: .title3).weight(.semibold))
                .foregroundStyle(QingTheme.pineInk)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("今日学习进度")
        .accessibilityValue("\(Int(clampedProgress * 100))%")
    }
}
