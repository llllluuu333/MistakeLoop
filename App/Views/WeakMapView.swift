import SwiftUI
import SwiftData

struct WeakMapView: View {
    @Query(sort: \MistakeItem.createdAt, order: .reverse) private var mistakes: [MistakeItem]

    private var active: [MistakeItem] { mistakes.filter { !$0.isResolved } }
    private var resolved: [MistakeItem] { mistakes.filter { $0.isResolved } }

    private var weekWrongCount: Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now
        return mistakes
            .filter { $0.createdAt >= weekAgo }
            .reduce(0) { $0 + $1.wrongCount }
    }

    private var retriedCount: Int {
        active.filter { $0.correctStreak > 0 }.count
    }

    private var weakPoints: [(name: String, subject: Subject, count: Int)] {
        let grouped = Dictionary(grouping: active, by: \.knowledgePoint)
        return grouped
            .map { (name: $0.key, subject: $0.value.first?.subject ?? .math2, count: $0.value.reduce(0) { $0 + $1.wrongCount }) }
            .sorted { $0.count > $1.count }
            .prefix(5)
            .map { $0 }
    }

    private var maxWeakCount: Int {
        weakPoints.first?.count ?? 1
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    StatCard(label: "本周错题", value: "\(weekWrongCount)", unit: "道")
                    StatCard(label: "已重做", value: "\(retriedCount)", unit: "道")
                    StatCard(label: "已解决", value: "\(resolved.count)", unit: "个")
                }

                SectionTitle(title: "薄弱知识点")
                if weakPoints.isEmpty {
                    EmptyState(
                        systemImage: "scope",
                        title: "没有活跃薄弱点",
                        subtitle: "错题会在这里按知识点汇总"
                    )
                } else {
                    ForEach(weakPoints, id: \.name) { point in
                        weakPointRow(point)
                    }
                }

                if !resolved.isEmpty {
                    SectionTitle(title: "已解决")
                    ForEach(resolved) { mistake in
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Theme.green)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(mistake.knowledgePoint.isEmpty ? mistake.problem : mistake.knowledgePoint)
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(Theme.ink)
                                SubjectChip(subject: mistake.subject)
                            }
                            Spacer()
                        }
                        .padding(16)
                        .background(Theme.greenLight, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                }
            }
            .padding()
        }
        .background(Theme.background)
        .navigationTitle("薄弱点地图")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func weakPointRow(_ point: (name: String, subject: Subject, count: Int)) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Text(point.name)
                        .font(.body.weight(.medium))
                        .foregroundStyle(Theme.ink)
                    SubjectChip(subject: point.subject)
                    Spacer()
                    Text("错 \(point.count) 次")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Theme.red)
                }
                ProgressBar(fraction: Double(point.count) / Double(maxWeakCount), color: Theme.red)
            }
        }
    }
}

#Preview {
    NavigationStack {
        WeakMapView()
    }
    .modelContainer(for: [CardItem.self, MistakeItem.self, KnowledgeItem.self, ReviewLog.self], inMemory: true)
}
