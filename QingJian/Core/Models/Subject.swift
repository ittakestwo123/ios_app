import Foundation
import SwiftData

@Model
final class Subject {
    @Attribute(.unique) var id: UUID
    var name: String
    var colorToken: String
    var sortOrder: Int
    var isArchived: Bool

    init(
        id: UUID = UUID(),
        name: String,
        colorToken: String = "mistGreen",
        sortOrder: Int,
        isArchived: Bool = false
    ) {
        self.id = id
        self.name = name
        self.colorToken = colorToken
        self.sortOrder = sortOrder
        self.isArchived = isArchived
    }
}

extension Subject {
    static let defaultNames = SubjectCatalog.defaultNames
}
