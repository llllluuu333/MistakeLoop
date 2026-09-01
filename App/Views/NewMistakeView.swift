import SwiftUI
import SwiftData

struct NewMistakeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: \KnowledgeItem.title) private var knowledgeItems: [KnowledgeItem]

    @State private var subject: Subject
    @State private var reason: MistakeReason = .knowledge
    @State private var problem = ""
    @State private var solution = ""
    @State private var knowledgePoint: String
    @State private var knowledge: KnowledgeItem?

    init(
        initialSubject: Subject? = nil,
        initialKnowledgePoint: String? = nil,
        initialKnowledge: KnowledgeItem? = nil
    ) {
        _subject = State(initialValue: initialSubject ?? .math2)
        _knowledgePoint = State(initialValue: initialKnowledgePoint ?? "")
        _knowledge = State(initialValue: initialKnowledge)
    }

    private var suggestions: [KnowledgeItem] {
        let keyword = knowledgePoint.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else { return [] }
        return knowledgeItems
            .filter { $0.subject == subject && $0.title.localizedCaseInsensitiveContains(keyword) }
            .prefix(3)
            .map { $0 }
    }

    var body: some View {
        Form {
            Section {
                Picker("科目", selection: $subject) {
                    ForEach(Subject.allCases) { subject in
                        Text(subject.rawValue).tag(subject)
                    }
                }
                Picker("错误原因", selection: $reason) {
                    ForEach(MistakeReason.allCases) { reason in
                        Text(reason.rawValue).tag(reason)
                    }
                }
            }
            Section("题目") {
                TextEditor(text: $problem)
                    .frame(minHeight: 100)
            }
            Section("答案与思路（可选）") {
                TextEditor(text: $solution)
                    .frame(minHeight: 100)
            }
            Section("关联知识点") {
                TextField("例如：中值定理应用", text: $knowledgePoint)
            }
            if !suggestions.isEmpty {
                Section("智能关联知识库") {
                    ForEach(suggestions) { item in
                        Button {
                            knowledgePoint = item.title
                            knowledge = item
                        } label: {
                            HStack {
                                Text(item.title)
                                    .foregroundStyle(Theme.ink)
                                Spacer()
                                Image(systemName: "link")
                                    .foregroundStyle(Theme.primary)
                            }
                        }
                    }
                }
            }
            Section {
                Text("保存后自动加入复习队列")
                    .font(.footnote)
                    .foregroundStyle(Theme.grayText)
            }
        }
        .navigationTitle("记错题")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("取消") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("保存") { save() }
                    .disabled(problem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private func save() {
        let item = MistakeItem(
            subject: subject,
            problem: problem.trimmingCharacters(in: .whitespacesAndNewlines),
            solution: solution.trimmingCharacters(in: .whitespacesAndNewlines),
            reason: reason,
            knowledgePoint: knowledgePoint.trimmingCharacters(in: .whitespacesAndNewlines),
            knowledge: knowledge,
            nextReviewDate: .now
        )
        context.insert(item)
        dismiss()
    }
}
