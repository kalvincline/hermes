//
//  UIHaptic.swift
//  CoverSheet
//
//  Created by The Potato on 11/2/18.
//  Copyright © 2018 Potatoco Technologies. All rights reserved.
//

import UIKit

class UIHapticFeedback {
    
    static func generate(style: UIHapticStyle) {
        if settings.useHapticFeedback {
            switch style {
            case .impact:
                UIImpactFeedbackGenerator().impactOccurred()
            case .impactLight:
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            case .impactMedium:
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            case .impactHeavy:
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            case .selection:
                UISelectionFeedbackGenerator().selectionChanged()
            case .errorNotification:
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            case .successNotification:
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            case .warningNotification:
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
            }
        }
    }
    
    enum UIHapticStyle {
        case impact
        case impactLight
        case impactMedium
        case impactHeavy
        case selection
        case errorNotification
        case successNotification
        case warningNotification
    }
}
