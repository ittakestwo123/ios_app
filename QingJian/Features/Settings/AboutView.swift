import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QingTheme.Spacing.regular) {
                Text("晴笺")
                    .font(QingTheme.displayFont(size: 34, relativeTo: .largeTitle).weight(.semibold))
                    .foregroundStyle(QingTheme.pineInk)
                Text("专注、打卡与诗意陪伴")
                    .font(.subheadline)
                    .foregroundStyle(QingTheme.mistGreen)
                QingCard {
                    Text("把今天认真走过，明天会有光。晴笺希望把学习记录变成温柔而清晰的足迹，而不是压力。")
                        .foregroundStyle(QingTheme.ink)
                }
                QingCard {
                    VStack(alignment: .leading, spacing: QingTheme.Spacing.small) {
                        Text("素材致谢")
                            .font(.headline)
                            .foregroundStyle(QingTheme.pineInk)
                        Text("Today 背景使用陈继儒《梅竹图》（17 世纪，公共领域）图像的离线副本。详情见项目 ATTRIBUTIONS.md。")
                            .font(.subheadline)
                            .foregroundStyle(QingTheme.secondaryInk)
                    }
                }
                Text("版本 1.0")
                    .font(.caption)
                    .foregroundStyle(QingTheme.secondaryInk)
            }
            .padding(QingTheme.Spacing.large)
        }
        .background(PaperBackground())
        .navigationTitle("关于晴笺")
        .navigationBarTitleDisplayMode(.inline)
    }
}
