import Foundation
import SwiftData

@Model
final class CardItem {
    var subjectRaw: String
    var typeRaw: String
    var front: String
    var back: String
    var tag: String
    var nextReviewDate: Date
    var intervalDays: Int
    var createdAt: Date
    var knowledge: KnowledgeItem?

    init(
        subject: Subject,
        type: CardType,
        front: String,
        back: String,
        tag: String = "",
        knowledge: KnowledgeItem? = nil,
        nextReviewDate: Date = .now
    ) {
        self.subjectRaw = subject.rawValue
        self.typeRaw = type.rawValue
        self.front = front
        self.back = back
        self.tag = tag
        self.knowledge = knowledge
        self.nextReviewDate = nextReviewDate
        self.intervalDays = 0
        self.createdAt = .now
    }

    var subject: Subject { Subject(rawValue: subjectRaw) ?? .math2 }
    var type: CardType { CardType(rawValue: typeRaw) ?? .formula }
    var isDue: Bool { nextReviewDate <= .now }
}
