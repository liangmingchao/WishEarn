import Foundation

extension ConditionType {
    var displayName: String {
        switch self {
        case .count: return "累计次数"
        case .streak: return "连续坚持"
        case .duration: return "累计时长"
        case .amount: return "累计金额"
        case .checkpoint: return "目标完成"
        case .custom: return "自定义"
        }
    }

    var symbolName: String {
        switch self {
        case .count: return "repeat"
        case .streak: return "flame"
        case .duration: return "clock"
        case .amount: return "yensign.circle"
        case .checkpoint: return "flag.checkered"
        case .custom: return "slider.horizontal.3"
        }
    }
}

extension AmountDirection {
    var displayName: String {
        switch self {
        case .income: return "收入"
        case .saving: return "节省"
        case .other: return "其他"
        }
    }
}

extension Condition {
    var targetDescription: String {
        switch type {
        case .checkpoint:
            return "完成"
        default:
            let value = NSDecimalNumber(decimal: targetValue).stringValue
            if let unit {
                return "\(value) \(unit)"
            }
            return value
        }
    }
}
