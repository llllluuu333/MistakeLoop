import Foundation

enum Subject: String, CaseIterable, Codable, Identifiable {
    case math2 = "数学二"
    case or = "运筹学优化"
    case discrete = "离散算法"
    case python = "Python"
    case sql = "SQL"

    var id: String { rawValue }
}

enum CardType: String, CaseIterable, Codable, Identifiable {
    case formula = "公式"
    case method = "方法"
    case concept = "概念"
    case code = "代码"
    case mistake = "错题"

    var id: String { rawValue }
}

enum EntryType: String, CaseIterable, Codable, Identifiable {
    case concept = "概念"
    case formula = "公式"
    case method = "方法"
    case code = "代码"
    case modelCase = "案例"

    var id: String { rawValue }
}

enum MistakeReason: String, CaseIterable, Codable, Identifiable {
    case knowledge = "知识点没掌握"
    case method = "方法不对"
    case careless = "粗心"
    case calculation = "计算错误"

    var id: String { rawValue }
}
