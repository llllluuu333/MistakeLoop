import SwiftUI
import SwiftData

enum AppTab: String, CaseIterable, Identifiable {
    case today
    case knowledge
    case cards
    case weakMap

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today: return "今天"
        case .knowledge: return "知识库"
        case .cards: return "卡片"
        case .weakMap: return "薄弱点"
        }
    }

    var systemImage: String {
        switch self {
        case .today: return "calendar"
        case .knowledge: return "books.vertical"
        case .cards: return "square.stack"
        case .weakMap: return "scope"
        }
    }

    @ViewBuilder
    var destination: some View {
        switch self {
        case .today: TodayView()
        case .knowledge: KnowledgeView()
        case .cards: CardsView()
        case .weakMap: WeakMapView()
        }
    }
}

struct RootTabView: View {
    @State private var selection: AppTab = .today
    @Environment(\.modelContext) private var context

    var body: some View {
        TabView(selection: $selection) {
            ForEach(AppTab.allCases) { tab in
                NavigationStack {
                    tab.destination
                }
                .tabItem { Label(tab.title, systemImage: tab.systemImage) }
                .tag(tab)
            }
        }
        .tint(Theme.primary)
        .task {
            SeedData.seedIfNeeded(context: context)
        }
    }
}
