import SwiftUI
import SwiftData

@main
struct MistakeLoopApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(for: [
            CardItem.self,
            MistakeItem.self,
            KnowledgeItem.self,
            ReviewLog.self,
        ])
    }
}
