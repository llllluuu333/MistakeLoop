import SwiftUI
import SwiftData

struct NewCardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var subject: Subject = .math2
    @State private var type: CardType = .formula
    @State private var front = ""
    @State private var back = ""
    @State private var tag = ""

    var body: some View {
        Form {
            Section {
                Picker("科目", selection: $subject) {
                    ForEach(Subject.allCases) { subject in
                        Text(subject.rawValue).tag(subject)
                    }
                }
                Picker("类型", selection: $type) {
                    ForEach(CardType.allCases.filter { $0 != .mistake }) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
            }
            Section("正面 · 问题") {
                TextField("例如：拉格朗日中值定理的内容？", text: $front, axis: .vertical)
                    .lineLimit(2...4)
            }
            Section("背面 · 答案") {
                TextField("写下答案或要点", text: $back, axis: .vertical)
                    .lineLimit(3...8)
            }
            Section("标签（可选）") {
                TextField("例如：中值定理", text: $tag)
            }
        }
        .navigationTitle("新建卡片")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("取消") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("保存") { save() }
                    .disabled(front.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || back.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private func save() {
        let item = CardItem(
            subject: subject,
            type: type,
            front: front.trimmingCharacters(in: .whitespacesAndNewlines),
            back: back.trimmingCharacters(in: .whitespacesAndNewlines),
            tag: tag.trimmingCharacters(in: .whitespacesAndNewlines),
            nextReviewDate: .now
        )
        context.insert(item)
        dismiss()
    }
}
