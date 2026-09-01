import SwiftUI
import SwiftData

enum ReviewItem: Identifiable {
    case card(CardItem)
    case mistake(MistakeItem)

    var id: String {
        switch self {
        case .card(let card): return "card-\(card.createdAt.timeIntervalSince1970)"
        case .mistake(let mistake): return "mistake-\(mistake.createdAt.timeIntervalSince1970)"
        }
    }

    var dueDate: Date {
        switch self {
        case .card(let card): return card.nextReviewDate
        case .mistake(let mistake): return mistake.nextReviewDate
        }
    }

    var subject: Subject {
        switch self {
        case .card(let card): return card.subject
        case .mistake(let mistake): return mistake.subject
        }
    }

    var typeLabel: String {
        switch self {
        case .card(let card): return card.type.rawValue
        case .mistake: return "错题"
        }
    }

    var frontText: String {
        switch self {
        case .card(let card): return card.front
        case .mistake(let mistake): return mistake.problem
        }
    }

    var backText: String {
        switch self {
        case .card(let card): return card.back
        case .mistake(let mistake):
            return mistake.solution.isEmpty ? "暂无解答，请自行对照资料" : mistake.solution
        }
    }
}

struct ReviewView: View {
    let items: [ReviewItem]

    @State private var index = 0
    @State private var showAnswer = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    private var current: ReviewItem? {
        items.indices.contains(index) ? items[index] : nil
    }

    var body: some View {
        Group {
            if let current {
                VStack(spacing: 18) {
                    progressHeader
                    Spacer()
                    cardContent(current)
                    Spacer()
                    if showAnswer {
                        gradeButtons(current)
                    } else {
                        revealButton
                    }
                }
                .padding()
            } else {
                completionView
            }
        }
        .navigationTitle("今日复习")
        .navigationBarTitleDisplayMode(.inline)
        .background(Theme.background)
        .toolbar {
            if !items.isEmpty && index < items.count {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("\(index + 1) / \(items.count)")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Theme.grayText)
                }
            }
        }
    }

    private var progressHeader: some View {
        ProgressView(value: Double(index), total: Double(max(items.count, 1)))
            .tint(Theme.primary)
    }

    private func cardContent(_ item: ReviewItem) -> some View {
        GlassCard(cornerRadius: 32) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    Chip(
                        text: item.typeLabel,
                        foreground: Theme.subjectColor(item.subject),
                        background: Theme.subjectBackground(item.subject)
                    )
                    SubjectChip(subject: item.subject)
                }
                Text(item.frontText)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Theme.ink)
                if showAnswer {
                    Divider()
                    Text(item.backText)
                        .font(.body)
                        .foregroundStyle(Theme.ink)
                        .transition(.opacity)
                } else {
                    Text("先在脑中回忆，再翻面")
                        .font(.footnote)
                        .foregroundStyle(Theme.grayText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
        }
    }

    private var revealButton: some View {
        Button {
            withAnimation(.snappy) {
                showAnswer = true
            }
        } label: {
            Text("显示答案")
        }
        .buttonStyle(PrimaryButtonStyle())
    }

    private func gradeButtons(_ item: ReviewItem) -> some View {
        Group {
            switch item {
            case .card:
                HStack(spacing: 12) {
                    gradeButton("记得", color: Theme.green, background: Theme.greenLight) {
                        grade(item, .remembered)
                    }
                    gradeButton("模糊", color: Theme.primary, background: Theme.primaryLight) {
                        grade(item, .fuzzy)
                    }
                    gradeButton("忘了", color: Theme.grayText, background: Color(hex: 0xF0F2F5)) {
                        grade(item, .forgot)
                    }
                }
            case .mistake:
                HStack(spacing: 12) {
                    gradeButton("做对了", color: Theme.green, background: Theme.greenLight) {
                        grade(item, .remembered)
                    }
                    gradeButton("还不会", color: Theme.red, background: Theme.redLight) {
                        grade(item, .forgot)
                    }
                }
            }
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    private func gradeButton(
        _ title: String,
        color: Color,
        background: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    private func grade(_ item: ReviewItem, _ grade: ReviewGrade) {
        switch item {
        case .card(let card):
            card.nextReviewDate = ReviewScheduler.nextDate(after: grade)
        case .mistake(let mistake):
            let correct = grade == .remembered
            let result = ReviewScheduler.nextDateAfterMistakeRetry(
                correct: correct,
                currentStreak: mistake.correctStreak
            )
            mistake.correctStreak = result.newStreak
            mistake.nextReviewDate = result.date
            if correct && result.newStreak >= 2 {
                mistake.statusRaw = "resolved"
            }
            if !correct {
                mistake.wrongCount += 1
            }
        }
        context.insert(ReviewLog())
        withAnimation(.snappy) {
            showAnswer = false
            index += 1
        }
    }

    private var completionView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(Theme.green)
            Text("今日复习完成")
                .font(.title2.weight(.bold))
                .foregroundStyle(Theme.ink)
            Text("共复习 \(items.count) 项")
                .font(.subheadline)
                .foregroundStyle(Theme.grayText)
            Spacer()
            Button {
                dismiss()
            } label: {
                Text("完成")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
    }
}
