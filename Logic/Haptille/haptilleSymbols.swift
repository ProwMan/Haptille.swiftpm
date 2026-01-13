import Foundation

enum HaptilleSymbol: String, CaseIterable, Codable {
    case strong
    case weak
    case shortPause
    case mediumPause
    case longPause
}

extension HaptilleSymbol {
    var displayName: String {
        switch self {
        case .strong:
            return "Strong"
        case .weak:
            return "Weak"
        case .shortPause:
            return "Short pause"
        case .mediumPause:
            return "Medium pause"
        case .longPause:
            return "Long pause"
        }
    }

    var shortLabel: String {
        switch self {
        case .strong:
            return "Strong"
        case .weak:
            return "Weak"
        case .shortPause:
            return "Short"
        case .mediumPause:
            return "Medium"
        case .longPause:
            return "Long"
        }
    }
}
