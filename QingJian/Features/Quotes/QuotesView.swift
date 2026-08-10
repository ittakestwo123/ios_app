import SwiftData
import SwiftUI

struct QuotesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \QuoteFavorite.favoritedAt, order: .reverse) private var favorites: [QuoteFavorite]
    @State private var selectedCategory: QuoteCategory?
    @State private var randomQuote: Quote?
    @State private var recentRandomQuoteIDs: [String] = []
    private let service = QuoteService()

    private var visibleQuotes: [Quote] {
        service.filtered(category: selectedCategory)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PaperBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: QingTheme.Spacing.regular) {
                        todayCard
                        categoryPicker
                        Button {
                            randomQuote = service.randomQuote(
                                category: selectedCategory,
                                excludingIDs: Set(recentRandomQuoteIDs)
                            )
                            if let randomQuote {
                                recentRandomQuoteIDs = Array((recentRandomQuoteIDs + [randomQuote.id]).suffix(8))
                            }
                        } label: {
                            Label("随机抽一句", systemImage: "shuffle")
                                .font(.subheadline.weight(.medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, QingTheme.Spacing.medium)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(QingTheme.pineInk)
                        .background(QingTheme.quietFill, in: RoundedRectangle(cornerRadius: QingTheme.Radius.control, style: .continuous))

                        if let randomQuote {
                            QuoteRow(quote: randomQuote, isFavorite: isFavorite(randomQuote), onFavorite: { toggleFavorite(randomQuote) })
                        }

                        LazyVStack(spacing: QingTheme.Spacing.small) {
                            ForEach(visibleQuotes) { quote in
                                NavigationLink {
                                    QuoteDetailView(quote: quote)
                                } label: {
                                    QuoteRow(quote: quote, isFavorite: isFavorite(quote), onFavorite: { toggleFavorite(quote) })
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, QingTheme.Spacing.regular)
                    .padding(.bottom, QingTheme.Spacing.extraLarge)
                }
            }
            .navigationTitle("拾光")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var todayCard: some View {
        QingCard {
            let quote = service.dailyQuote(on: .now)
            VStack(alignment: .leading, spacing: QingTheme.Spacing.medium) {
                Text("今日一句")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(QingTheme.mistGreen)
                Text("“\(quote.text)”")
                    .font(QingTheme.displayFont(size: 22, relativeTo: .title3))
                    .foregroundStyle(QingTheme.pineInk)
                Text(quote.attribution)
                    .font(.caption)
                    .foregroundStyle(QingTheme.secondaryInk)
            }
        }
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: QingTheme.Spacing.small) {
                QuoteCategoryChip(title: "全部", selected: selectedCategory == nil) { selectedCategory = nil }
                ForEach(QuoteCategory.allCases) { category in
                    QuoteCategoryChip(title: category.title, selected: selectedCategory == category) {
                        selectedCategory = category
                    }
                }
            }
        }
    }

    private func isFavorite(_ quote: Quote) -> Bool {
        favorites.contains { $0.quoteID == quote.id }
    }

    private func toggleFavorite(_ quote: Quote) {
        if let favorite = favorites.first(where: { $0.quoteID == quote.id }) {
            modelContext.delete(favorite)
        } else {
            modelContext.insert(QuoteFavorite(quoteID: quote.id))
        }
        try? modelContext.save()
    }
}

private struct QuoteCategoryChip: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, QingTheme.Spacing.medium)
                .padding(.vertical, QingTheme.Spacing.small)
        }
        .buttonStyle(.plain)
        .foregroundStyle(selected ? QingTheme.paper : QingTheme.pineInk)
        .background(selected ? QingTheme.pineInk : QingTheme.quietFill, in: Capsule())
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

struct QuoteRow: View {
    let quote: Quote
    let isFavorite: Bool
    let onFavorite: () -> Void

    var body: some View {
        QingCard {
            HStack(alignment: .top, spacing: QingTheme.Spacing.medium) {
                VStack(alignment: .leading, spacing: QingTheme.Spacing.small) {
                    Text("“\(quote.text)”")
                        .font(QingTheme.displayFont(size: 18, relativeTo: .body))
                        .foregroundStyle(QingTheme.pineInk)
                        .multilineTextAlignment(.leading)
                    Text(quote.attribution)
                        .font(.caption)
                        .foregroundStyle(QingTheme.secondaryInk)
                }
                Spacer(minLength: 0)
                Button(action: onFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(isFavorite ? QingTheme.morningGold : QingTheme.secondaryInk)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isFavorite ? "取消收藏" : "收藏")
            }
        }
    }
}

#Preview {
    QuotesView()
        .modelContainer(for: [QuoteFavorite.self], inMemory: true)
}
