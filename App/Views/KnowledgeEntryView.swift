import SwiftUI
import SwiftData
import UIKit

struct KnowledgeEntryView: View {
    let item: KnowledgeItem
    @Environment(\.modelContext) private var context
    @State private var showNewMistake = false

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
                            HStack {
                                SectionTitle(title: "代码示例")
                                Spacer()
                                Button("复制") {
                                    UIPasteboard.general.string = item.code
                                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                                }
                                .font(.footnote.weight(.semibold))
                                .buttonStyle(.bordered)
                                .tint(Theme.primary)
                            }
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

                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionTitle(title: "沉淀")
                        HStack(spacing: 12) {
                            Button {
                                createCard()
                            } label: {
                                Label("生成复习卡", systemImage: "rectangle.stack.badge.plus")
                            }
                            .buttonStyle(.bordered)
                            .tint(Theme.primary)

                            Button {
                                showNewMistake = true
                            } label: {
                                Label("记一道错题", systemImage: "exclamationmark.bubble")
                            }
                            .buttonStyle(.bordered)
                            .tint(Theme.red)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Theme.background)
        .navigationTitle(item.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showNewMistake) {
            NavigationStack {
                NewMistakeView(
                    initialSubject: item.subject,
                    initialKnowledgePoint: item.title,
                    initialKnowledge: item
                )
            }
        }
    }

    private func createCard() {
        let card = CardItem(
            subject: item.subject,
            type: item.cardType,
            front: item.title,
            back: item.overview.isEmpty ? (item.formula.isEmpty ? item.steps : item.formula) : item.overview,
            knowledge: item,
            nextReviewDate: .now
        )
        context.insert(card)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    private func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }
}
