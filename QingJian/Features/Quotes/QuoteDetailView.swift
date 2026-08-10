import SwiftData
import SwiftUI

struct QuoteDetailView: View {
    let quote: Quote
    @Environment(\.modelContext) private var modelContext
    @Query private var favorites: [QuoteFavorite]

    private var isFavorite: Bool {
        favorites.contains { $0.quoteID == quote.id }
    }

    var body: some View {
        ZStack {
            PaperBackground()
            VStack(spacing: QingTheme.Spacing.large) {
                Spacer()
                Text("“\(quote.text)”")
                    .font(QingTheme.displayFont(size: 30, relativeTo: .title))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(QingTheme.pineInk)
                    .padding(.horizontal, QingTheme.Spacing.large)
                Text(quote.attribution)
                    .font(.subheadline)
                    .foregroundStyle(QingTheme.secondaryInk)
                Text(quote.sourceType == .classical ? "古典作品 · 公共领域" : "晴笺原创")
                    .font(.caption)
                    .foregroundStyle(QingTheme.mistGreen)
                HStack(spacing: QingTheme.Spacing.medium) {
                    Button {
                        toggleFavorite()
                    } label: {
                        Label(isFavorite ? "已收藏" : "收藏", systemImage: isFavorite ? "heart.fill" : "heart")
                    }
                    .buttonStyle(.bordered)
                    .tint(QingTheme.pineInk)
                    ShareLink(item: "\(quote.text)——\(quote.attribution)") {
                        Label("分享文字", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.bordered)
                    .tint(QingTheme.pineInk)
                }
                Spacer()
            }
        }
        .navigationTitle("拾光")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func toggleFavorite() {
        if let favorite = favorites.first(where: { $0.quoteID == quote.id }) {
            modelContext.delete(favorite)
        } else {
            modelContext.insert(QuoteFavorite(quoteID: quote.id))
        }
        try? modelContext.save()
    }
}
