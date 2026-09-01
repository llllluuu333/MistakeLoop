import SwiftUI
import SwiftData

struct KnowledgeTreeView: View {
    let subject: Subject
    @Query private var items: [KnowledgeItem]

    init(subject: Subject) {
        self.subject = subject
        let predicate = #Predicate<KnowledgeItem> { $0.subjectRaw == subject.rawValue }
        _items = Query(filter: predicate, sort: \KnowledgeItem.updatedAt, order: .reverse)
    }

    var body: some View {
        Group {
            if items.isEmpty {
                EmptyState(
                    systemImage: "doc.text",
                    title: "还没有知识条目",
                    subtitle: "以后学到的模型、公式、代码都可以沉淀到这里"
                )
            } else {
                List(items) { item in
                    NavigationLink {
                        KnowledgeEntryView(item: item)
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.title)
                                .font(.body.weight(.medium))
                                .foregroundStyle(Theme.ink)
                            HStack(spacing: 8) {
                                Chip(text: item.type.rawValue, foreground: Theme.subjectColor(subject), background: Theme.subjectBackground(subject))
                                if !item.cards.isEmpty {
                                    Chip(text: "卡片 \(item.cards.count)", foreground: Theme.purple, background: Theme.purpleLight)
                                }
                                if !item.mistakes.isEmpty {
                                    Chip(text: "错题 \(item.mistakes.count)", foreground: Theme.red, background: Theme.redLight)
                                }
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle(subject.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
}
