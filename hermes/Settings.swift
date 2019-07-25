//
//  Settings.swift
//  hermesforyoutube
//
//  Created by Aidan Cline on 7/24/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit

class Settings {
    
    private static let defaults = UserDefaults()
    
    static var appIcon: String? {
        get {
            return defaults.string(forKey: "appIcon")
        }
        set {
            defaults.setValue(newValue, forKey: "appIcon")
        }
    }
    
    fileprivate(set) static var theme: ThemeStyles {
        get {
            return ThemeStyles(rawValue: defaults.integer(forKey: "theme")) ?? .light
        }
        set {
            defaults.setValue(newValue.rawValue, forKey: "theme")
        }
    }
    
    static var backgroundPlay: Bool {
        get {
            return !defaults.bool(forKey: "disableBackgroundPlay")
        }
        set {
            defaults.setValue(!newValue, forKey: "disableBackgroundPlay")
        }
    }
    
    static var autoplay: Bool {
        get {
            return !defaults.bool(forKey: "disableAutoplay")
        }
        set {
            defaults.setValue(!newValue, forKey: "disableAutoplay")
        }
    }
    
    static var preferredQuality: Quality {
        get {
            return Quality(rawValue: defaults.string(forKey: "preferredQuality") ?? "auto") ?? .auto
        }
        set {
            defaults.setValue(newValue.rawValue, forKey: "preferredQuality")
        }
    }
    
    static var experimentalPlayer: Bool {
        get {
            return defaults.bool(forKey: "experimentalPlayer")
        }
        set {
            defaults.setValue(newValue, forKey: "experimentalPlayer")
        }
    }
    
    static var pro = false {
        didSet {
            proPurchaseHandlers.forEach { (handler) in
                handler(pro)
            }
        }
    }
    typealias PurchaseHandler = (Bool) -> Void
    static var proPurchaseHandlers: [PurchaseHandler] = []
    static func addProPurchaseHandler(_ handler: @escaping PurchaseHandler) {
        proPurchaseHandlers.append(handler)
    }
    
}

class UIInterface {
    
    typealias ThemeHandler = (Theme) -> Void
    static var themeHandlers: [ThemeHandler] = []
    static func addThemeHandler(_ handler: @escaping ThemeHandler) {
        themeHandlers.append(handler)
    }
    
    class Theme {
        var style: ThemeStyles
        init(style: ThemeStyles) {
            self.style = style
        }
        
        var backgroundColor: UIColor {
            switch style {
            case .light:
                return UIColor(white: 0.95, alpha: 1)
            case .dark:
                return UIColor(white: 0.114, alpha: 1)
            case .extraDark:
                return .black
            }
        }
        
        var contentColor: UIColor {
            switch style {
            case .light:
                return .white
            case .dark:
                return UIColor(white: 0.15, alpha: 1)
            case .extraDark:
                return UIColor(white: 0.1, alpha: 1)
            }
        }
        
        var vibrancyEffect: UIBlurEffect {
            switch style {
            case .light:
                return .init(style: .light)
            case .dark, .extraDark:
                return .init(style: .dark)
            }
        }
        
        var vibrancyEffectBackground: UIColor {
            switch style {
            case .light:
                return UIColor(white: 0.95, alpha: 0.75)
            case .dark, .extraDark:
                return UIColor(white: 0.114, alpha: 0.5)
            }
        }
        
        var scrollIndicatorStyle: UIScrollView.IndicatorStyle {
            switch style {
            case .light:
                return .black
            case .dark, .extraDark:
                return .white
            }
        }
        
        var statusBarStyle: StatusBarStyle {
            switch style {
            case .light:
                return .dark
            case .dark, .extraDark:
                return .light
            }
        }
    }
    
    static var currentTheme: ThemeStyles {
        get {
            return Settings.theme
        }
        set {
            Settings.theme = newValue
            UIView.animate(withDuration: 0.25) {
                self.themeHandlers.forEach({ (handler) in
                    handler(Theme(style: newValue))
                })
            }
        }
    }
    
    enum StatusBarStyle {
        case dark
        case light
        case hidden
    }
    
    static var statusBarDidUpdate: () -> Void = {}
    static private(set) var statusBarStyle: StatusBarStyle = .dark
    static func setStatusBarStyle(_ style: StatusBarStyle) {
        statusBarStyle = style
        statusBarDidUpdate()
    }
    
}

var safeArea: UIEdgeInsets {
    return UIApplication.shared.windows[0].safeAreaInsets
}

enum ThemeStyles: Int {
    case light = 0
    case dark = 1
    case extraDark = 2
}

enum Quality: String {
    case auto = "auto"
    case highest = "highest"
    case q1080p60 = "1080p60"
    case q1080p = "1080p"
    case q720p60 = "720p60"
    case q720p = "720p"
    case q480p = "480p"
    case q360p = "360p"
    case q240p = "240p"
    case q144p = "144p"
}
