import Foundation

enum QuoteCategory: String, Codable, CaseIterable, Identifiable {
    case persistence
    case reading
    case composure
    case morning
    case landscape
    case selfEncouragement

    var id: String { rawValue }

    var title: String {
        switch self {
        case .persistence: "坚持"
        case .reading: "读书"
        case .composure: "从容"
        case .morning: "清晨"
        case .landscape: "山水"
        case .selfEncouragement: "自我鼓励"
        }
    }
}

enum QuoteSourceType: String, Codable {
    case classical
    case original
}

struct Quote: Codable, Identifiable, Equatable {
    var id: String
    var text: String
    var attribution: String
    var category: QuoteCategory
    var sourceType: QuoteSourceType
}

struct QuoteService {
    let quotes: [Quote]
    let calendar: Calendar

    init(quotes: [Quote] = QuoteService.loadBundledQuotes(), calendar: Calendar = .current) {
        self.quotes = quotes
        self.calendar = calendar
    }

    func dailyQuote(on date: Date) -> Quote {
        guard !quotes.isEmpty else {
            return Quote(id: "fallback", text: "把今天认真走过，明天会有光。", attribution: "晴笺原创", category: .selfEncouragement, sourceType: .original)
        }
        let ordinal = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        return quotes[(ordinal - 1) % quotes.count]
    }

    func randomQuote(category: QuoteCategory? = nil, excludingIDs: Set<String> = []) -> Quote? {
        let candidates = category.map { requested in quotes.filter { $0.category == requested } } ?? quotes
        let fresh = candidates.filter { !excludingIDs.contains($0.id) }
        return (fresh.isEmpty ? candidates : fresh).randomElement()
    }

    func filtered(category: QuoteCategory?) -> [Quote] {
        guard let category else { return quotes }
        return quotes.filter { $0.category == category }
    }

    static func loadBundledQuotes() -> [Quote] {
        guard let url = Bundle.main.url(forResource: "quotes", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let quotes = try? JSONDecoder().decode([Quote].self, from: data) else {
            return []
        }
        return quotes
    }
}
