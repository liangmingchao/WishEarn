import SwiftUI

extension WishStatus {
    var displayName: String {
        switch self {
        case .active: return "进行中"
        case .unlocked: return "已解锁"
        case .completed: return "已兑现"
        case .paused: return "已暂停"
        case .archived: return "已归档"
        }
    }

    var badgeTone: StatusBadge.Tone {
        switch self {
        case .active: return .primary
        case .unlocked: return .success
        case .completed: return .neutral
        case .paused: return .warning
        case .archived: return .neutral
        }
    }

    /// Small semantic dot for themed cards where the label itself must use
    /// the theme's contrast-tested foreground.
    var indicatorColor: Color {
        switch self {
        case .active: return AppColors.primary
        case .unlocked: return AppColors.success
        case .completed: return AppColors.textTertiary
        case .paused: return AppColors.warning
        case .archived: return AppColors.textTertiary
        }
    }
}
