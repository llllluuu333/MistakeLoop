import SwiftUI
import SwiftData

struct ModelLibraryView: View {
    @Query private var items: [KnowledgeItem]

    init() {
        let modelCaseRaw = EntryType.modelCase.rawValue
        let predicate = #Predicate<KnowledgeItem> { $0.typeRaw == modelCaseRaw }
        _items = Query(filter: predicate, sort: \KnowledgeItem.updatedAt, order: .reverse)
    }

    private var masteredCount: Int {
        items.filter { !$0.mistakes.isEmpty && $0.mistakes.allSatisfy(\.isResolved) }.count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("\(items.count) 个模型")
                                .font(.title2.weight(.bold))
                                .foregroundStyle(Theme.ink)
                            Spacer()
                        }
                        Text("已掌握 \(masteredCount) · 学习中 \(items.count - masteredCount)")
                            .font(.footnote)
                            .foregroundStyle(Theme.grayText)
                        ProgressBar(fraction: items.isEmpty ? 0 : Double(masteredCount) / Double(items.count), color: Theme.green)
                    }
                }

                ForEach(items) { item in
                    NavigationLink {
                        KnowledgeEntryView(item: item)
                    } label: {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(item.title)
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(Theme.ink)
                                HStack(spacing: 8) {
                                    SubjectChip(subject: item.subject)
                                    Chip(text: "案例", foreground: Theme.subjectColor(item.subject), background: Theme.subjectBackground(item.subject))
                                }
                            }
                            Spacer()
                            Text(masteredStatus(item))
                                .font(.footnote.weight(.bold))
                                .foregroundStyle(masteredColor(item))
                        }
                        .padding(16)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .background(Theme.background)
        .navigationTitle("建模案例库")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func masteredStatus(_ item: KnowledgeItem) -> String {
        if item.mistakes.isEmpty { return "待练习" }
        return item.mistakes.allSatisfy(\.isResolved) ? "已掌握" : "学习中"
    }

    private func masteredColor(_ item: KnowledgeItem) -> Color {
        if item.mistakes.isEmpty { return Theme.grayText }
        return item.mistakes.allSatisfy(\.isResolved) ? Theme.green : Theme.primary
    }
}
