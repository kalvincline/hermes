//
//  ThemeController.swift
//  hermes
//
//  Created by Aidan Cline on 8/21/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit

class UITheme {
    enum Styles: Int {
        case light = 0
        case dark = 1
        case custom = 2
    }
    
    struct Theme {
        let style: Styles
        let background: UIColor
        let content: UIColor
        let text: UIColor
        let blurEffect: UIBlurEffect
        var blurEffectBackground: UIColor {
            return background.withAlphaComponent(0.5)
        }
        let tint: UIColor
        let statusBarStyle: StatusBarStyle
    }
    
    static let lightTheme: Theme = .init(
        style: .light,
        background: .init(white: 0.95, alpha: 1),
        content: .white,
        text: .black,
        blurEffect: .init(style: .light),
        tint: .init(red: 0.375, green: 0.354, blue: 1, alpha: 1),
        statusBarStyle: .darkContent
    )
    
    static let darkTheme: Theme = .init(
        style: .dark,
        background: .black,
        content: .init(white: 0.1, alpha: 1),
        text: .white,
        blurEffect: .init(style: .dark),
        tint: .init(red: 0.375, green: 0.354, blue: 1, alpha: 1),
        statusBarStyle: .lightContent
    )
    
    typealias ThemeHandler = (Theme) -> Void
    static var handlers: [ThemeHandler] = []
    static func addHandler(_ handler: @escaping ThemeHandler) {
        handlers.append(handler)
    }
    
    static var current: Theme = lightTheme {
        didSet {
            let theme = current
            setStatusBarAnimated(theme.statusBarStyle)
            handlers.forEach { (handler) in
                UIView.animate(withDuration: 0.5, animations: {
                    handler(theme)
                })
            }
        }
    }
    
    enum StatusBarStyle {
        case lightContent
        case darkContent
        case hidden
    }
    
    static var statusBarAnimatedHandlers: [(StatusBarStyle) -> Void] = []
    static func addStatusBarAnimatedHandler(_ handler: @escaping (StatusBarStyle) -> Void) {
        statusBarAnimatedHandlers.append(handler)
    }
    
    static var statusBarHandlers: [(StatusBarStyle) -> Void] = []
    static func addStatusBarHandler(_ handler: @escaping (StatusBarStyle) -> Void) {
        statusBarHandlers.append(handler)
    }
    
    static func setStatusBar(_ style: StatusBarStyle) {
        statusBarHandlers.forEach { (handler) in
            handler(style)
        }
    }
    
    static func setStatusBarAnimated(_ style: StatusBarStyle) {
        statusBarAnimatedHandlers.forEach { (handler) in
            handler(style)
        }
    }
}
