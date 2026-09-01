import Foundation
import SwiftData

@Model
final class KnowledgeItem {
    var subjectRaw: String
    var typeRaw: String
    var title: String
    var overview: String
    var formula: String
    var steps: String
    var code: String
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .nullify, inverse: \CardItem.knowledge)
    var cards: [CardItem] = []

    @Relationship(deleteRule: .nullify, inverse: \MistakeItem.knowledge)
    var mistakes: [MistakeItem] = []

    init(
        subject: Subject,
        type: EntryType,
        title: String,
        overview: String = "",
        formula: String = "",
        steps: String = "",
        code: String = ""
    ) {
        self.subjectRaw = subject.rawValue
        self.typeRaw = type.rawValue
        self.title = title
        self.overview = overview
        self.formula = formula
        self.steps = steps
        self.code = code
        self.createdAt = .now
        self.updatedAt = .now
    }

    var subject: Subject { Subject(rawValue: subjectRaw) ?? .math2 }
    var type: EntryType { EntryType(rawValue: typeRaw) ?? .concept }
}
