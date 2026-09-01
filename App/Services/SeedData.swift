import Foundation
import SwiftData

enum SeedData {
    @MainActor
    static func seedIfNeeded(context: ModelContext) {
        let count = (try? context.fetchCount(FetchDescriptor<KnowledgeItem>())) ?? 0
        guard count == 0 else { return }

        let simplex = KnowledgeItem(
            subject: .or, type: .method, title: "单纯形法",
            overview: "求解线性规划问题的经典迭代算法：从初始可行基出发，逐步改进目标值，直到检验数满足最优条件。",
            formula: "max z = c^T x\ns.t. Ax ≤ b, x ≥ 0",
            steps: "1 化为标准形\n2 确定初始可行基\n3 计算检验数，判断最优\n4 换基迭代，回到步骤 3",
            code: "from scipy.optimize import linprog\nres = linprog(c, A_ub=A, b_ub=b)\nprint(res.x)"
        )
        let transport = KnowledgeItem(
            subject: .or, type: .modelCase, title: "运输问题建模",
            overview: "把物资从多个产地运往多个销地，在满足供需约束的前提下使总运输成本最小。",
            formula: "min Σ c_ij · x_ij\ns.t. Σ_j x_ij = a_i,  Σ_i x_ij = b_j,  x_ij ≥ 0",
            steps: "1 列出产地供应量 a_i 与销地需求量 b_j\n2 建立运输表\n3 最小元素法求初始方案\n4 位势法检验与调整",
            code: "from scipy.optimize import linprog\n# x = [x11, x12, ..., xmn]\nres = linprog(c, A_eq=A, b_eq=b)\nprint(res.x.reshape(m, n))"
        )
        let assignment = KnowledgeItem(
            subject: .or, type: .modelCase, title: "指派问题",
            overview: "n 项任务指派给 n 个人，使总完成时间最少；可用匈牙利算法求解。",
            formula: "min Σ c_ij · x_ij\ns.t. Σ_j x_ij = 1,  Σ_i x_ij = 1,  x_ij ∈ {0, 1}",
            steps: "1 行归约：每行减最小元素\n2 列归约：每列减最小元素\n3 试指派并划线覆盖零元素\n4 调整矩阵直到得到 n 个独立零"
        )
        let lagrange = KnowledgeItem(
            subject: .math2, type: .formula, title: "拉格朗日中值定理",
            overview: "微分中值定理之一，把函数在区间上的增量与区间内某点的导数联系起来。",
            formula: "f(b) − f(a) = f′(ξ)(b − a),  ξ ∈ (a, b)",
            steps: "条件：f 在 [a,b] 连续，在 (a,b) 可导。\n几何意义：存在一点切线平行于割线。"
        )
        let meanValue = KnowledgeItem(
            subject: .math2, type: .method, title: "中值定理应用",
            overview: "证明含导数与函数值等式/不等式时，优先构造辅助函数并套用中值定理。",
            steps: "1 观察结论形式，反推辅助函数\n2 验证连续性与可导性\n3 应用中值定理得出结论\n4 注意 ξ 的存在区间"
        )
        let quickSort = KnowledgeItem(
            subject: .discrete, type: .concept, title: "快速排序复杂度",
            overview: "平均时间复杂度 O(n log n)，最坏 O(n²)，空间复杂度平均 O(log n)。",
            formula: "T(n) = 2T(n/2) + O(n)  →  O(n log n)",
            steps: "最坏情况：每次划分极不平衡（如已有序时选首元素）。\n优化：随机选基准或三数取中。"
        )
        let dp = KnowledgeItem(
            subject: .discrete, type: .method, title: "动态规划基本思想",
            overview: "把问题拆成重叠子问题，用状态转移方程递推，避免重复计算。",
            formula: "dp[i] = min(dp[j] + cost(j, i))",
            steps: "1 定义状态 dp[i]\n2 写状态转移方程\n3 确定边界条件\n4 按拓扑顺序递推"
        )
        let join = KnowledgeItem(
            subject: .sql, type: .code, title: "LEFT JOIN 与 INNER JOIN 区别",
            overview: "INNER JOIN 只保留匹配行；LEFT JOIN 保留左表全部行，未匹配的右表列记为 NULL。",
            code: "SELECT a.name, b.amount\nFROM users a\nLEFT JOIN orders b ON a.id = b.user_id\n-- 左表全部保留，无订单的用户 amount 为 NULL"
        )
        let groupBy = KnowledgeItem(
            subject: .sql, type: .code, title: "GROUP BY 常见误区",
            overview: "SELECT 中出现的非聚合列必须全部出现在 GROUP BY 中，否则语义错误。",
            code: "SELECT dept, COUNT(*), AVG(salary)\nFROM emp\nGROUP BY dept\n-- 只能按 dept 分组，再对每组的聚合函数取值"
        )

        [simplex, transport, assignment, lagrange, meanValue, quickSort, dp, join, groupBy].forEach {
            context.insert($0)
        }

        let card1 = CardItem(subject: .math2, type: .formula, front: "拉格朗日中值定理", back: "f(b) − f(a) = f′(ξ)(b − a)", knowledge: lagrange)
        let card2 = CardItem(subject: .or, type: .method, front: "单纯形法的第一步？", back: "把线性规划问题化为标准形", knowledge: simplex)
        let card3 = CardItem(subject: .sql, type: .code, front: "LEFT JOIN 保留哪一边的全部行？", back: "左表的全部行", knowledge: join)
        let card4 = CardItem(subject: .discrete, type: .concept, front: "快速排序的平均时间复杂度", back: "O(n log n)", knowledge: quickSort)
        [card1, card2, card3, card4].forEach { context.insert($0) }

        let mistake1 = MistakeItem(
            subject: .math2, problem: "证明题：用中值定理证明不等式", solution: "构造辅助函数，套用拉格朗日中值定理。",
            reason: .knowledge, knowledgePoint: "中值定理应用", knowledge: meanValue
        )
        mistake1.wrongCount = 4
        mistake1.correctStreak = 1
        let mistake2 = MistakeItem(
            subject: .or, problem: "单纯形法迭代计算失误", solution: "检查检验数与换基规则。",
            reason: .method, knowledgePoint: "单纯形法迭代", knowledge: simplex
        )
        mistake2.wrongCount = 3
        let mistake3 = MistakeItem(
            subject: .sql, problem: "GROUP BY 语句报错", solution: "SELECT 的非聚合列必须出现在 GROUP BY 中。",
            reason: .careless, knowledgePoint: "GROUP BY 使用", knowledge: groupBy
        )
        mistake3.wrongCount = 2
        mistake3.correctStreak = 2
        mistake3.statusRaw = "resolved"
        [mistake1, mistake2, mistake3].forEach { context.insert($0) }
    }
}
