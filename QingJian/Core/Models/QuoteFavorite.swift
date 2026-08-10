import Foundation
import SwiftData

@Model
final class QuoteFavorite {
    @Attribute(.unique) var quoteID: String
    var favoritedAt: Date

    init(quoteID: String, favoritedAt: Date = .now) {
        self.quoteID = quoteID
        self.favoritedAt = favoritedAt
    }
}
