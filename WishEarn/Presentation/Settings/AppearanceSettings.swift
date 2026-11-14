import SwiftUI

/// The appearance the app renders in.
///
/// `system` is the default so a user who never touches the setting keeps
/// following iOS. `light` and `dark` are explicit overrides that must survive
/// relaunch, so the choice is persisted rather than kept in memory.
enum AppearanceMode: String, CaseIterable, Identifiable, Sendable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system:
            return "跟随系统"
        case .light:
            return "浅色"
        case .dark:
            return "深色"
        }
    }

    /// `nil` means “do not force a scheme”: SwiftUI then follows the device.
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

@MainActor
@Observable
final class AppearanceSettings {
    static let storageKey = "appearanceMode"

    private let defaults: UserDefaults

    var mode: AppearanceMode {
        didSet {
            guard mode != oldValue else { return }
            defaults.set(mode.rawValue, forKey: Self.storageKey)
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if let stored = defaults.string(forKey: Self.storageKey),
           let mode = AppearanceMode(rawValue: stored) {
            self.mode = mode
        } else {
            self.mode = .system
        }
    }

    var colorScheme: ColorScheme? {
        mode.colorScheme
    }
}
