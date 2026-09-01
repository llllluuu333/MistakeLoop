import SwiftUI
import SwiftData

@main
struct MistakeLoopApp: App {
    private let container: ModelContainer

    init() {
        let schema = Schema([CardItem.self, MistakeItem.self, KnowledgeItem.self, ReviewLog.self])
        if let cloudContainer = try? ModelContainer(
            for: schema,
            configurations: ModelConfiguration(cloudKitDatabase: .automatic)
        ) {
            container = cloudContainer
        } else {
            container = try! ModelContainer(for: schema)
        }
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(container)
    }
}
