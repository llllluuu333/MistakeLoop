import SwiftUI

extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

enum Theme {
    static let primary = Color(hex: 0xFF7A2F)
    static let primaryLight = Color(hex: 0xFFE9DA)
    static let purple = Color(hex: 0x8B7CFF)
    static let purpleLight = Color(hex: 0xF2F0FF)
    static let green = Color(hex: 0x2FA96B)
    static let greenLight = Color(hex: 0xE4F6EC)
    static let red = Color(hex: 0xE5484D)
    static let redLight = Color(hex: 0xFDE8E8)
    static let ink = Color(hex: 0x23262B)
    static let grayText = Color(hex: 0x8A9099)
    static let surface = Color.white
    static let background = Color(hex: 0xF5F6F9)

    static func subjectColor(_ subject: Subject) -> Color {
        switch subject {
        case .math2: return Theme.primary
        case .or: return Theme.purple
        case .discrete: return Theme.green
        case .python: return Color(hex: 0x3B82F6)
        case .sql: return Theme.red
        }
    }

    static func subjectBackground(_ subject: Subject) -> Color {
        switch subject {
        case .math2: return Theme.primaryLight
        case .or: return Theme.purpleLight
        case .discrete: return Theme.greenLight
        case .python: return Color(hex: 0xE8F0FE)
        case .sql: return Theme.redLight
        }
    }
}
