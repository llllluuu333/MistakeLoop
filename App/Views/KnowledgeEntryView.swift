import SwiftUI
import SwiftData

struct KnowledgeEntryView: View {
    let item: KnowledgeItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    Chip(text: item.type.rawValue, foreground: Theme.subjectColor(item.subject), background: Theme.subjectBackground(item.subject))
                    SubjectChip(subject: item.subject)
                    Spacer()
                    Text("更新于 \(shortDate(item.updatedAt))")
                        .font(.caption)
                        .foregroundStyle(Theme.grayText)
                }

                if !item.overview.isEmpty {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionTitle(title: "概述")
                            Text(item.overview)
                                .font(.body)
                                .foregroundStyle(Theme.ink)
                        }
                    }
                }

                if !item.formula.isEmpty {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionTitle(title: "核心公式")
                            Text(item.formula)
                                .font(.body.weight(.medium))
                                .foregroundStyle(Theme.ink)
                        }
                    }
                }

                if !item.steps.isEmpty {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionTitle(title: "要点 / 步骤")
                            Text(item.steps)
                                .font(.body)
                                .foregroundStyle(Theme.ink)
                        }
                    }
                }

                if !item.code.isEmpty {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionTitle(title: "代码示例")
                            ScrollView(.horizontal, showsIndicators: false) {
                                Text(item.code)
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundStyle(.white)
                                    .padding(14)
                                    .background(Color(hex: 0x2B2F36), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                        }
                    }
                }

                GlassCard {
                    HStack(spacing: 12) {
                        SectionTitle(title: "关联")
                        Spacer()
                        Chip(text: "卡片 \(item.cards.count) 张", foreground: Theme.purple, background: Theme.purpleLight)
                        Chip(text: "错题 \(item.mistakes.count) 道", foreground: Theme.red, background: Theme.redLight)
                    }
                }
            }
            .padding()
        }
        .background(Theme.background)
        .navigationTitle(item.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }
}
