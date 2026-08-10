import SwiftUI

struct QingCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(QingTheme.Spacing.regular)
            .background(QingTheme.card.opacity(0.94), in: RoundedRectangle(cornerRadius: QingTheme.Radius.card, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: QingTheme.Radius.card, style: .continuous)
                    .stroke(QingTheme.morningGold.opacity(0.20), lineWidth: 1)
            }
            .shadow(color: QingTheme.pineInk.opacity(0.06), radius: 10, y: 4)
    }
}

struct QingPrimaryButton: View {
    let title: String
    let systemImage: String?
    let action: () -> Void

    init(_ title: String, systemImage: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Label {
                Text(title)
            } icon: {
                if let systemImage {
                    Image(systemName: systemImage)
                }
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, QingTheme.Spacing.medium)
        }
        .buttonStyle(.plain)
        .foregroundStyle(QingTheme.paper)
        .background(QingTheme.pineInk, in: RoundedRectangle(cornerRadius: QingTheme.Radius.control, style: .continuous))
        .accessibilityLabel(title)
    }
}
