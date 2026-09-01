import SwiftUI
import SwiftData

struct NewKnowledgeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var subject: Subject = .or
    @State private var type: EntryType = .concept
    @State private var title = ""
    @State private var overview = ""
    @State private var formula = ""
    @State private var steps = ""
    @State private var code = ""

    var body: some View {
        Form {
            Section {
                Picker("科目", selection: $subject) {
                    ForEach(Subject.allCases) { subject in
                        Text(subject.rawValue).tag(subject)
                    }
                }
                Picker("类型", selection: $type) {
                    ForEach(EntryType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
            }
            Section("标题") {
                TextField("例如：单纯形法", text: $title)
            }
            Section("概述") {
                TextEditor(text: $overview)
                    .frame(minHeight: 80)
            }
            Section("核心公式") {
                TextEditor(text: $formula)
                    .frame(minHeight: 60)
            }
            Section("要点 / 步骤") {
                TextEditor(text: $steps)
                    .frame(minHeight: 80)
            }
            Section("代码示例") {
                TextEditor(text: $code)
                    .frame(minHeight: 80)
                    .font(.system(.body, design: .monospaced))
            }
        }
        .navigationTitle("新建知识条目")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("取消") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("保存") { save() }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private func save() {
        let item = KnowledgeItem(
            subject: subject,
            type: type,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            overview: overview.trimmingCharacters(in: .whitespacesAndNewlines),
            formula: formula.trimmingCharacters(in: .whitespacesAndNewlines),
            steps: steps.trimmingCharacters(in: .whitespacesAndNewlines),
            code: code.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        context.insert(item)
        dismiss()
    }
}
