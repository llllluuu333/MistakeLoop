import SwiftUI
import SwiftData

struct KnowledgeView: View {
    @Query(sort: \KnowledgeItem.updatedAt, order: .reverse) private var items: [KnowledgeItem]
    @State private var searchText = ""
    @State private var showNewKnowledge = false

    private var filteredItems: [KnowledgeItem] {
        items.filter {
            searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var recentItems: [KnowledgeItem] {
        Array(filteredItems.prefix(5))
    }

    private var modelCount: Int {
        items.filter { $0.subject == .or && $0.type == .modelCase }.count
    }

    private var masteredModels: Int {
        items.filter { item in
            guard item.subject == .or && item.type == .modelCase else { return false }
            return !item.mistakes.isEmpty && item.mistakes.allSatisfy(\.isResolved)
        }.count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                subjectGrid
                modelLibraryCard
                SectionTitle(title: "最近编辑")
                ForEach(recentItems) { item in
                    NavigationLink {
                        KnowledgeEntryView(item: item)
                    } label: {
                        recentRow(item)
                    }
                    .buttonStyle(.plain)
                }
                if recentItems.isEmpty {
                    EmptyState(
                        systemImage: "books.vertical",
                        title: "知识库还是空的",
                        subtitle: "点右上角 ＋ 新建一个知识条目"
                    )
                }
            }
            .padding()
        }
        .searchable(text: $searchText, prompt: "搜索知识条目")
        .navigationTitle("知识库")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showNewKnowledge = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showNewKnowledge) {
            NavigationStack {
                NewKnowledgeView()
            }
        }
    }

    private var subjectGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            ForEach(Subject.allCases) { subject in
                NavigationLink {
                    KnowledgeTreeView(subject: subject)
                } label: {
                    subjectCard(subject)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func subjectCard(_ subject: Subject) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(subject.rawValue)
                        .font(.headline)
                        .foregroundStyle(Theme.ink)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.grayText)
                }
                Text("\(items.filter { $0.subject == subject }.count) 个条目")
                    .font(.footnote)
                    .foregroundStyle(Theme.grayText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var modelLibraryCard: some View {
        NavigationLink {
            ModelLibraryView()
        } label: {
            GlassCard {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        SectionTitle(title: "运筹优化模型库")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Theme.grayText)
                    }
                    Text("\(modelCount) 个经典模型 · 已掌握 \(masteredModels) 个")
                        .font(.footnote)
                        .foregroundStyle(Theme.grayText)
                    ProgressBar(fraction: modelCount == 0 ? 0 : Double(masteredModels) / Double(modelCount))
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func recentRow(_ item: KnowledgeItem) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(item.title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(Theme.ink)
                HStack(spacing: 8) {
                    Chip(text: item.type.rawValue, foreground: Theme.subjectColor(item.subject), background: Theme.subjectBackground(item.subject))
                    SubjectChip(subject: item.subject)
                }
            }
            Spacer()
            Text(relativeDate(item.updatedAt))
                .font(.caption)
                .foregroundStyle(Theme.grayText)
        }
        .padding(16)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func relativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.localizedString(for: date, relativeTo: .now)
    }
}

#Preview {
    NavigationStack {
        KnowledgeView()
    }
    .modelContainer(for: [CardItem.self, MistakeItem.self, KnowledgeItem.self, ReviewLog.self], inMemory: true)
}
