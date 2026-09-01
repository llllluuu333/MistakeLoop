import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \CardItem.createdAt) private var cards: [CardItem]
    @Query(sort: \MistakeItem.createdAt) private var mistakes: [MistakeItem]
    @Query(sort: \ReviewLog.date) private var logs: [ReviewLog]

    @State private var showNewMistake = false
    @State private var showReview = false
    @State private var showSettings = false

    private var dueCards: [CardItem] { cards.filter { $0.isDue } }
    private var dueMistakes: [MistakeItem] { mistakes.filter { $0.isDue } }
    private var streak: Int {
        ReviewScheduler.consecutiveDays(from: logs.map(\.date))
    }

    private var weakPoints: [(name: String, subject: Subject, count: Int)] {
        let active = mistakes.filter { !$0.isResolved }
        let grouped = Dictionary(grouping: active, by: \.knowledgePoint)
        return grouped
            .map { (name: $0.key, subject: $0.value.first?.subject ?? .math2, count: $0.value.reduce(0) { $0 + $1.wrongCount }) }
            .sorted { $0.count > $1.count }
            .prefix(2)
            .map { $0 }
    }

    private var reviewQueue: [ReviewItem] {
        let cards = dueCards.map { ReviewItem.card($0) }
        let mistakes = dueMistakes.map { ReviewItem.mistake($0) }
        return (cards + mistakes).sorted { $0.dueDate < $1.dueDate }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                taskCard
                weakPointsCard
                actionButtons
            }
            .padding()
        }
        .background(Theme.background)
        .navigationTitle("今天")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
        .sheet(isPresented: $showNewMistake) {
            NavigationStack {
                NewMistakeView()
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsView()
            }
        }
        .navigationDestination(isPresented: $showReview) {
            ReviewView(items: reviewQueue)
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(Theme.ink)
                Text(dateText)
                    .font(.subheadline)
                    .foregroundStyle(Theme.grayText)
            }
            Spacer()
            Text("🔥 \(streak) 天")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Theme.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Theme.primaryLight, in: Capsule())
        }
    }

    private var taskCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(title: "今日任务")
                HStack {
                    Text("待复习卡片")
                        .font(.body)
                        .foregroundStyle(Theme.ink)
                    Spacer()
                    Text("\(dueCards.count) / \(cards.count)")
                        .font(.body.weight(.bold))
                        .foregroundStyle(Theme.primary)
                }
                ProgressBar(fraction: cards.isEmpty ? 0 : Double(dueCards.count) / Double(cards.count))
                HStack {
                    Text("重做错题")
                        .font(.body)
                        .foregroundStyle(Theme.ink)
                    Spacer()
                    Text("\(dueMistakes.count) 道")
                        .font(.body.weight(.bold))
                        .foregroundStyle(Theme.primary)
                }
                Divider()
                HStack {
                    Text("今日学习目标")
                        .font(.body)
                        .foregroundStyle(Theme.ink)
                    Spacer()
                    Text("90 分钟")
                        .font(.body)
                        .foregroundStyle(Theme.grayText)
                }
            }
        }
    }

    private var weakPointsCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionTitle(title: "本周薄弱点")
                ForEach(weakPoints, id: \.name) { point in
                    HStack(spacing: 10) {
                        Text(point.name)
                            .font(.body)
                            .foregroundStyle(Theme.ink)
                        SubjectChip(subject: point.subject)
                        Spacer()
                        Text("错 \(point.count) 次")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Theme.red)
                    }
                }
                if weakPoints.isEmpty {
                    Text("暂无薄弱点，继续保持！")
                        .font(.subheadline)
                        .foregroundStyle(Theme.grayText)
                }
                NavigationLink {
                    WeakMapView()
                } label: {
                    Text("查看薄弱点地图 〉")
                        .font(.subheadline)
                        .foregroundStyle(Theme.grayText)
                }
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                showReview = true
            } label: {
                Label("开始今日复习", systemImage: "play.fill")
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(reviewQueue.isEmpty)
            .opacity(reviewQueue.isEmpty ? 0.5 : 1)

            Button {
                showNewMistake = true
            } label: {
                Text("记一道错题")
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        if hour < 12 { return "早上好" }
        if hour < 18 { return "下午好" }
        return "晚上好"
    }

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 EEEE"
        return formatter.string(from: .now)
    }
}

#Preview {
    NavigationStack {
        TodayView()
    }
    .modelContainer(for: [CardItem.self, MistakeItem.self, KnowledgeItem.self, ReviewLog.self], inMemory: true)
}
