import Foundation
import SwiftData

@Model
final class MistakeItem {
    var subjectRaw: String
    var problem: String
    var solution: String
    var reasonRaw: String
    var knowledgePoint: String
    var wrongCount: Int
    var correctStreak: Int
    var statusRaw: String
    var nextReviewDate: Date
    var createdAt: Date
    var knowledge: KnowledgeItem?

    init(
        subject: Subject,
        problem: String,
        solution: String = "",
        reason: MistakeReason = .knowledge,
        knowledgePoint: String,
        knowledge: KnowledgeItem? = nil,
        nextReviewDate: Date = .now
    ) {
        self.subjectRaw = subject.rawValue
        self.problem = problem
        self.solution = solution
        self.reasonRaw = reason.rawValue
        self.knowledgePoint = knowledgePoint
        self.knowledge = knowledge
        self.wrongCount = 1
        self.correctStreak = 0
        self.statusRaw = "active"
        self.nextReviewDate = nextReviewDate
        self.createdAt = .now
    }

    var subject: Subject { Subject(rawValue: subjectRaw) ?? .math2 }
    var reason: MistakeReason { MistakeReason(rawValue: reasonRaw) ?? .knowledge }
    var isResolved: Bool { statusRaw == "resolved" }
    var isDue: Bool { !isResolved && nextReviewDate <= .now }
}
