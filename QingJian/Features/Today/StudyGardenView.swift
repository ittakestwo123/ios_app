import SwiftUI

enum StudyGardenStage: Equatable {
    case seed
    case leaf
    case plumBud
    case plumBloom
    case brightPlum

    init(progress: Double) {
        switch progress {
        case ..<0.25: self = .seed
        case ..<0.5: self = .leaf
        case ..<0.8: self = .plumBud
        case ..<1: self = .plumBloom
        default: self = .brightPlum
        }
    }

    var title: String {
        switch self {
        case .seed: "种下一点安静"
        case .leaf: "梅枝生出新叶"
        case .plumBud: "梅枝正在含苞"
        case .plumBloom: "梅花初绽"
        case .brightPlum: "今日梅枝盛放"
        }
    }
}

struct StudyGardenView: View {
    var progress: Double
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    private var stage: StudyGardenStage { StudyGardenStage(progress: progress) }

    var body: some View {
        QingCard {
            HStack(spacing: QingTheme.Spacing.regular) {
                ZStack(alignment: .bottom) {
                    BambooSprig()
                        .frame(width: 76, height: 86)
                        .opacity(0.68)

                    plumState
                        .scaleEffect(appeared ? 1 : 0.82)
                        .offset(x: -8, y: -6)
                }
                .frame(width: 90, height: 94)

                VStack(alignment: .leading, spacing: QingTheme.Spacing.small) {
                    Text("今日梅枝")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(QingTheme.mistGreen)
                    Text(stage.title)
                        .font(QingTheme.displayFont(size: 18, relativeTo: .headline).weight(.semibold))
                        .foregroundStyle(QingTheme.pineInk)
                    Text("学习进度会让这枝梅慢慢有了形状。")
                        .font(.caption)
                        .foregroundStyle(QingTheme.secondaryInk)
                }
                Spacer(minLength: 0)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("今日梅枝，\(stage.title)")
        .onAppear {
            guard !reduceMotion else {
                appeared = true
                return
            }
            withAnimation(.spring(response: 0.42, dampingFraction: 0.72)) {
                appeared = true
            }
        }
        .onChange(of: stage) { _, _ in
            guard !reduceMotion else { return }
            appeared = false
            withAnimation(.easeInOut(duration: 0.28)) {
                appeared = true
            }
        }
    }

    @ViewBuilder
    private var plumState: some View {
        switch stage {
        case .seed:
            Circle().fill(QingTheme.morningGold).frame(width: 16, height: 16)
        case .leaf:
            LeafMark().fill(QingTheme.sprout).frame(width: 33, height: 38)
        case .plumBud:
            VStack(spacing: -3) {
                Circle().fill(QingTheme.apricot).frame(width: 22, height: 22)
                Circle().fill(QingTheme.morningGold).frame(width: 7, height: 7)
            }
        case .plumBloom:
            PlumBlossom().frame(width: 50, height: 50)
        case .brightPlum:
            ZStack {
                PlumBlossom().frame(width: 53, height: 53).offset(x: -11, y: 6)
                PlumBlossom().frame(width: 39, height: 39).offset(x: 16, y: -12)
                Image(systemName: "sparkle")
                    .font(.caption)
                    .foregroundStyle(QingTheme.morningGold)
                    .offset(x: 28, y: -27)
            }
        }
    }
}

struct PlumBlossom: View {
    var body: some View {
        GeometryReader { proxy in
            let petalSize = min(proxy.size.width, proxy.size.height) * 0.46
            ZStack {
                ForEach(0..<5, id: \.self) { index in
                    Capsule(style: .continuous)
                        .fill(QingTheme.apricot)
                        .frame(width: petalSize * 0.72, height: petalSize)
                        .offset(y: -petalSize * 0.36)
                        .rotationEffect(.degrees(Double(index) * 72))
                }
                Circle()
                    .fill(QingTheme.morningGold)
                    .frame(width: petalSize * 0.42, height: petalSize * 0.42)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}

struct BambooSprig: View {
    var body: some View {
        GeometryReader { proxy in
            Path { path in
                path.move(to: CGPoint(x: proxy.size.width * 0.48, y: proxy.size.height))
                path.addQuadCurve(
                    to: CGPoint(x: proxy.size.width * 0.58, y: 0),
                    control: CGPoint(x: proxy.size.width * 0.40, y: proxy.size.height * 0.42)
                )
            }
            .stroke(QingTheme.pineInk, style: StrokeStyle(lineWidth: 3, lineCap: .round))

            ForEach(0..<5, id: \.self) { index in
                LeafMark()
                    .fill(QingTheme.mistGreen)
                    .frame(width: 29, height: 14)
                    .rotationEffect(.degrees(index.isMultiple(of: 2) ? -25 : 35))
                    .position(
                        x: proxy.size.width * (index.isMultiple(of: 2) ? 0.34 : 0.72),
                        y: proxy.size.height * (0.2 + Double(index) * 0.15)
                    )
            }
        }
    }
}

struct LeafMark: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY),
            control: CGPoint(x: rect.maxX * 0.75, y: rect.maxY)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY),
            control: CGPoint(x: rect.minX, y: rect.minY * 1.35)
        )
        return path
    }
}

#Preview {
    ZStack {
        PaperBackground()
        StudyGardenView(progress: 0.82)
            .padding()
    }
}
