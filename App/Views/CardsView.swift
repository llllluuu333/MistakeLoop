import SwiftUI
import SwiftData

struct CardsView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \CardItem.createdAt, order: .reverse) private var cards: [CardItem]
    @Query(sort: \MistakeItem.createdAt, order: .reverse) private var mistakes: [MistakeItem]

    @State private var searchText = ""
    @State private var filter: Subject?
    @State private var showNewCard = false
    @State private var showNewMistake = false
    @State private var showCreateMenu = false

    private var filteredCards: [CardItem] {
        cards.filter { card in
            (filter == nil || card.subject == filter)
                && (searchText.isEmpty || card.front.localizedCaseInsensitiveContains(searchText) || card.tag.localizedCaseInsensitiveContains(searchText))
        }
    }

    private var filteredMistakes: [MistakeItem] {
        mistakes.filter { mistake in
            (filter == nil || mistake.subject == filter)
                && (searchText.isEmpty || mistake.problem.localizedCaseInsensitiveContains(searchText) || mistake.knowledgePoint.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            subjectFilter
            List {
                if !filteredCards.isEmpty {
                    Section("知识卡") {
                        ForEach(filteredCards) { card in
                            cardRow(card)
                                .swipeActions {
                                    Button(role: .destructive) {
                                        context.delete(card)
                                    } label: {
                                        Label("删除", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
                if !filteredMistakes.isEmpty {
                    Section("错题") {
                        ForEach(filteredMistakes) { mistake in
                            mistakeRow(mistake)
                                .swipeActions {
                                    Button(role: .destructive) {
                                        context.delete(mistake)
                                    } label: {
                                        Label("删除", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
                if filteredCards.isEmpty && filteredMistakes.isEmpty {
                    EmptyState(
                        systemImage: "square.stack",
                        title: "还没有内容",
                        subtitle: "点右上角 ＋ 新建卡片或记一道错题"
                    )
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.insetGrouped)
        }
        .searchable(text: $searchText, prompt: "搜索卡片或错题")
        .navigationTitle("卡片")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showCreateMenu = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .confirmationDialog("新建什么？", isPresented: $showCreateMenu, titleVisibility: .visible) {
            Button("新建卡片") { showNewCard = true }
            Button("记一道错题") { showNewMistake = true }
            Button("取消", role: .cancel) {}
        }
        .sheet(isPresented: $showNewCard) {
            NavigationStack {
                NewCardView()
            }
        }
        .sheet(isPresented: $showNewMistake) {
            NavigationStack {
                NewMistakeView()
            }
        }
    }

    private var subjectFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip("全部", subject: nil)
                ForEach(Subject.allCases) { subject in
                    filterChip(subject.rawValue, subject: subject)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Theme.background)
    }

    private func filterChip(_ title: String, subject: Subject?) -> some View {
        let isActive = filter == subject
        return Button {
            withAnimation(.snappy) {
                filter = subject
            }
        } label: {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(isActive ? Color.white : Theme.grayText)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    isActive ? Theme.primary : Color.white,
                    in: Capsule()
                )
                .overlay(
                    Capsule().stroke(isActive ? Color.clear : Color(hex: 0xD9DDE3), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func cardRow(_ card: CardItem) -> some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 8) {
                Text(card.front)
                    .font(.body.weight(.medium))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(2)
                HStack(spacing: 8) {
                    Chip(text: card.type.rawValue, foreground: Theme.subjectColor(card.subject), background: Theme.subjectBackground(card.subject))
                    SubjectChip(subject: card.subject)
                }
            }
            Spacer()
            Text(dueText(card.nextReviewDate))
                .font(.footnote.weight(.bold))
                .foregroundStyle(card.isDue ? Theme.primary : Theme.grayText)
        }
        .padding(.vertical, 4)
    }

    private func mistakeRow(_ mistake: MistakeItem) -> some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 8) {
                Text(mistake.problem)
                    .font(.body.weight(.medium))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(2)
                HStack(spacing: 8) {
                    Chip(text: "错题", foreground: Theme.red, background: Theme.redLight)
                    SubjectChip(subject: mistake.subject)
                    if !mistake.knowledgePoint.isEmpty {
                        Text(mistake.knowledgePoint)
                            .font(.caption)
                            .foregroundStyle(Theme.grayText)
                    }
                }
            }
            Spacer()
            Text(mistake.isResolved ? "已解决" : dueText(mistake.nextReviewDate))
                .font(.footnote.weight(.bold))
                .foregroundStyle(mistake.isResolved ? Theme.green : (mistake.isDue ? Theme.red : Theme.grayText))
        }
        .padding(.vertical, 4)
    }

    private func dueText(_ date: Date) -> String {
        if date <= .now { return "今天" }
        let calendar = Calendar.current
        if calendar.isDateInTomorrow(date) { return "明天" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        CardsView()
    }
    .modelContainer(for: [CardItem.self, MistakeItem.self, KnowledgeItem.self, ReviewLog.self], inMemory: true)
}
