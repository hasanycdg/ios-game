import SwiftUI
#if os(iOS)
import UIKit
#endif

/// Dünne, plattformsichere Haptik-Fassade.
enum Haptics {
    enum ImpactStyle {
        case light, medium, rigid
        #if os(iOS)
        var uiStyle: UIImpactFeedbackGenerator.FeedbackStyle {
            switch self {
            case .light: .light
            case .medium: .medium
            case .rigid: .rigid
            }
        }
        #endif
    }

    static func impact(_ style: ImpactStyle = .light) {
        #if os(iOS)
        UIImpactFeedbackGenerator(style: style.uiStyle).impactOccurred()
        #endif
    }

    static func success() {
        #if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }

    static func warning() {
        #if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        #endif
    }
}
