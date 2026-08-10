import Foundation

enum SubjectCatalog {
    static let defaultNames = ["数学", "英语", "政治", "专业课", "其他"]

    static func normalizedNames(_ names: [String]) -> [String] {
        var seen = Set<String>()

        return names.compactMap { rawName in
            let name = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty, seen.insert(name).inserted else { return nil }
            return name
        }
    }

    static func namesForOnboarding(_ names: [String]) -> [String] {
        let normalized = normalizedNames(names)
        return normalized.isEmpty ? defaultNames : normalized
    }
}
