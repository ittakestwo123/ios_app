import SwiftUI

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QingTheme.Spacing.regular) {
                Text("隐私说明")
                    .font(QingTheme.displayFont(size: 30, relativeTo: .title).weight(.semibold))
                    .foregroundStyle(QingTheme.pineInk)
                privacyBlock("晴笺不需要注册账号，也不会收集邮箱、手机号、定位、联系人、照片、健康数据或广告标识符。")
                privacyBlock("学习记录、科目、目标日、收藏与设置仅保存在这台设备的本地数据库中。应用没有服务器，也不会将这些内容上传到网络。")
                privacyBlock("当你主动开启学习提醒时，晴笺会向系统请求本地通知权限；通知只在你的设备上由系统调度。")
                privacyBlock("导出 CSV 时，文件由你主动选择分享方式。晴笺不会自动发送或备份你的记录。")
            }
            .padding(QingTheme.Spacing.large)
        }
        .background(PaperBackground(showsArtwork: false))
        .navigationTitle("隐私说明")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func privacyBlock(_ text: String) -> some View {
        QingCard {
            Text(text)
                .font(.body)
                .foregroundStyle(QingTheme.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
