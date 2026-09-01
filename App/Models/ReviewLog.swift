import Foundation
import SwiftData

@Model
final class ReviewLog {
    var date: Date
    var count: Int

    init(date: Date = .now, count: Int = 1) {
        self.date = date
        self.count = count
    }
}
