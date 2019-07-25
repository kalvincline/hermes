//
//  GlobalVars.swift
//  hermes
//
//  Created by Aidan Cline on 1/30/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit
import PopMenu

extension UIView {
    func setAnchorPoint(_ point: CGPoint) {
        var newPoint = CGPoint(x: bounds.size.width * point.x, y: bounds.size.height * point.y)
        var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y);
        
        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)
        
        var position = layer.position
        
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        layer.position = position
        layer.anchorPoint = point
    }
}

extension Notification.Name {
    static let themeChanged = Notification.Name(Bundle.main.bundleIdentifier! + ".themeChanged")
    static let videoOpened = Notification.Name(Bundle.main.bundleIdentifier! + ".videoOpened")
    static let statusBarChanged = Notification.Name(Bundle.main.bundleIdentifier! + ".statusBarChanged")
    static let statusBarChangedAnimated = Notification.Name(Bundle.main.bundleIdentifier! + ".statusBarChangedAnimated")
    static let changeDrawer = Notification.Name(Bundle.main.bundleIdentifier! + ".changeDrawer")
    static let updateStatusBar = Notification.Name(Bundle.main.bundleIdentifier! + ".updateStatusBar")
    static let openViewController = Notification.Name(Bundle.main.bundleIdentifier! + ".openViewController")
    static let enteredBackground = Notification.Name(Bundle.main.bundleIdentifier! + ".enteredBackground")
    static let enteredForeground = Notification.Name(Bundle.main.bundleIdentifier! + ".enteredForeground")
    static let appIconChanged = Notification.Name(Bundle.main.bundleIdentifier! + ".appIconChanged")
    static let tabChanged = Notification.Name(Bundle.main.bundleIdentifier! + ".tabChanged")
    static let signedIn = Notification.Name(Bundle.main.bundleIdentifier! + ".signedIn")
    static let signedOut = Notification.Name(Bundle.main.bundleIdentifier! + ".signedOut")
    static let subscriptionsChanged = Notification.Name(Bundle.main.bundleIdentifier! + ".subscriptionsChanged")
    static let qualityChanged = Notification.Name(Bundle.main.bundleIdentifier! + ".qualityChanged")
    static let proVersionChanged = Notification.Name(Bundle.main.bundleIdentifier! + "proVersionChanged")
}

enum States {
    case closed
    case small
    case fullscreen
}

enum Tabs {
    case home
    case subscriptions
    case account
    case search
}

var safeArea: UIEdgeInsets {
    return UIApplication.shared.windows[0].safeAreaInsets
}

var currentTab: Tabs = .home

enum DrawerStates {
    case closed
    case small
    case fullscreen
}

var drawerState = DrawerStates.closed {
    didSet {
        NotificationCenter.default.post(name: .changeDrawer, object: nil)
    }
}

func limit<T>(_ value: T, min small: T, max large: T) -> T where T: Comparable {
    return min(max(value, small), large)
}

func limit<T>(_ value: T, min small: T) -> T where T: Comparable {
    return max(value, small)
}

func limit<T>(_ value: T, max large: T) -> T where T: Comparable {
    return min(value, large)
}

let defaults = UserDefaults.standard
let π = CGFloat.pi

import GoogleAPIClientForREST
class ApplicationSettings {
    
    init() {
        if !defaults.bool(forKey: "backgroundPlay_isSet") {
            backgroundPlay = true
        }
        
        if !defaults.bool(forKey: "useHapticFeedback_isSet") {
            useHapticFeedback = true
        }
        
        if !defaults.bool(forKey: "autoplay_isSet") {
            autoplay = true
        }
    }
    
    var beta: Bool {
        return true
    }
    
    var developer: Bool {
        return false
    }
    
    var backgroundPlay: Bool {
        get {
            return defaults.bool(forKey: "backgroundPlay")
        }
        set {
            defaults.set(newValue, forKey: "backgroundPlay")
            defaults.set(true, forKey: "backgroundPlay_isSet")
        }
    }
    
    enum UIInterfaceStyles: Int {
        case light = 0
        case dark = 1
        case black = 2
    }
    
    var interfaceStyle: UIInterfaceStyles {
        get {
            return UIInterfaceStyles(rawValue: defaults.integer(forKey: "interfaceStyle")) ?? .light
        }
        set {
            defaults.set(newValue.rawValue, forKey: "interfaceStyle")
            NotificationCenter.default.post(name: .themeChanged, object: nil)
        }
    }
    
    var manualInterfaceStyle: Bool {
        get {
            return defaults.bool(forKey: "manualInterfaceStyle")
        }
        set {
            defaults.set(newValue, forKey: "manualInterfaceStyle")
        }
    }
    
    var watchHistory: [String] {
        get {
            return defaults.array(forKey: "watchHistory") as? [String] ?? []
        }
        set {
            defaults.set(newValue, forKey: "watchHistory")
        }
    }
    
    var searchHistory: [String] {
        get {
            return defaults.array(forKey: "searchHistory") as? [String] ?? []
        }
        set {
            defaults.set(newValue, forKey: "searchHistory")
        }
    }
    
    var appIcon: String? {
        get {
            return defaults.string(forKey: "appIcon")
        }
        set {
            UIApplication.shared.setAlternateIconName(newValue) { (error) in
                if let error = error {
                    print(error)
                }
            }
            defaults.set(newValue, forKey: "appIcon")
            NotificationCenter.default.post(name: .appIconChanged, object: nil)
        }
    }
    
    var userHasViewedTutorial: Bool {
        get {
            return defaults.bool(forKey: "userHasViewedTutorial")
        }
        set {
            defaults.set(newValue, forKey: "userHasViewedTutorial")
        }
    }
    
    var useHapticFeedback: Bool {
        get {
            return defaults.bool(forKey: "useHapticFeedback")
        }
        set {
            defaults.set(newValue, forKey: "useHapticFeedback")
            defaults.set(true, forKey: "useHapticFeedback_isSet")
        }
    }
    
    var autoplay: Bool {
        get {
            return defaults.bool(forKey: "autoplay")
        }
        set {
            defaults.set(newValue, forKey: "autoplay")
            defaults.set(true, forKey: "autoplay_isSet")
        }
    }
    
    var experimentalPlayer: Bool {
        get {
            return defaults.bool(forKey: "experimentalPlayer")
        }
        set {
            defaults.set(newValue, forKey: "experimentalPlayer")
        }
    }
    
    enum VideoQuality: String {
        case highest = "Highest"
        case auto = "Auto"
        case q1080p60 = "1080p60"
        case q1080p = "1080p"
        case q720p60 = "720p60"
        case q720p = "720p"
        case q480p = "480p"
        case q360p = "360p"
        case q240p = "240p"
        case q144p = "144p"
    }
    
    var preferredQuality: VideoQuality {
        get {
            return VideoQuality(rawValue: defaults.string(forKey: "preferredQuality") ?? "auto") ?? .auto
        }
        set {
            defaults.set(newValue.rawValue, forKey: "preferredQuality")
            NotificationCenter.default.post(name: .qualityChanged, object: nil)
        }
    }

    var signedIn = false {
        didSet {
            NotificationCenter.default.post(name: .signedIn, object: nil)
        }
    }
    
    var userAccessToken: String? {
        get {
            return defaults.string(forKey: "accessToken")
        }
        set {
            defaults.set(newValue, forKey: "accessToken")
        }
    }
    
    var userRefreshToken: String? {
        get {
            return defaults.string(forKey: "refreshToken")
        }
        set {
            defaults.set(newValue, forKey: "refreshToken")
        }
    }
    
    var tokenExpireDate: Double? {
        get {
            return defaults.double(forKey: "tokenExpireDate")
        }
        set {
            defaults.set(newValue, forKey: "tokenExpireDate")
        }
    }

    func reset() {
        backgroundPlay = true
        interfaceStyle = .light
        watchHistory = []
        searchHistory = []
        appIcon = nil
        userHasViewedTutorial = false
        useHapticFeedback = true
        autoplay = true
        experimentalPlayer = false
    }
    
    var pro = false {
        didSet {
            NotificationCenter.default.post(name: .proVersionChanged, object: nil)
        }
    }

}

class ApplicationInterface {
    
    init() {}
    
    init(style: ApplicationSettings.UIInterfaceStyles) {
        customStyle = style
    }
    
    private var customStyle: ApplicationSettings.UIInterfaceStyles?
    var style: ApplicationSettings.UIInterfaceStyles {
        return customStyle ?? settings.interfaceStyle
    }
    
    var textColor: UIColor {
        switch style {
        case .light:
            return .black
        case .dark:
            return .white
        case .black:
            return .white
        }
    }
    
    var backgroundColor: UIColor {
        switch style {
        case .light:
            return UIColor(white: 0.95, alpha: 1)
        case .dark:
            return UIColor(white: 0.114, alpha: 1)
        case .black:
            return .black
        }
    }
    
    var accentColor: UIColor {
        switch style {
        case .light:
            return UIColor(white: 0.95, alpha: 1)
        case .dark:
            return UIColor(white: 0.075, alpha: 1)
        case .black:
            return UIColor(white: 0.1, alpha: 1)
        }
    }
    
    var contentColor: UIColor {
        switch style {
        case .light:
            return UIColor(white: 1.0, alpha: 1)
        case .dark:
            return UIColor(white: 0.15, alpha: 1)
        case .black:
            return UIColor(white: 0.1, alpha: 1)
        }
    }
    
    var tintColor: UIColor {
        return UIColor(red: 0.375, green: 0.354, blue: 1, alpha: 1)
    }
    
    var placeholderColor: UIColor {
        return UIColor(white: 0.5, alpha: 1/3)
    }
    
    var blurEffect: UIBlurEffect {
        switch style {
        case .light:
            return UIBlurEffect(style: .light)
        case .dark, .black:
            return UIBlurEffect(style: .dark)
        }
    }
    
    var blurEffectBackground: UIColor {
        switch style {
        case .light:
            return UIColor(white: 0.95, alpha: 0.75)
        case .dark:
            return UIColor(white: 0.125, alpha: 0.5)
        case .black:
            return UIColor(white: 0, alpha: 0)
        }
    }
    
    var scrollIndicatorStyle: UIScrollView.IndicatorStyle {
        switch style {
        case .light:
            return .black
        default:
            return .white
        }
    }
    
    var loadingIndicatorStyle: UIActivityIndicatorView.Style {
        switch style {
        case .light:
            return .gray
        default:
            return .white
        }
    }
    
    enum UIStatusBarStyles {
        case dark
        case light
        case hidden
    }
    
    private(set) var statusBarStyle = UIStatusBarStyles.dark
    
    func setStatusBar(_ style: UIStatusBarStyles) {
        statusBarStyle = style
        NotificationCenter.default.post(name: .statusBarChanged, object: nil)
    }
    
    func setStatusBarAnimated(_ style: UIStatusBarStyles) {
        statusBarStyle = style
        NotificationCenter.default.post(name: .statusBarChangedAnimated, object: nil)
    }
    
    var popMenuAppearance: PopMenuAppearance {
        let appearance = PopMenuAppearance()
        appearance.popMenuColor.backgroundColor = .solid(fill: contentColor)
        appearance.popMenuColor.actionColor = .tint(textColor)
        appearance.popMenuStatusBarStyle = nil
        return appearance
    }
    
}

let settings = ApplicationSettings()
let interface = ApplicationInterface()

extension NSNumber {
    
    func formatUsingAbbrevation () -> String {
        let num = Int(truncating: self)
        let numFormatter = NumberFormatter()
        
        typealias Abbrevation = (threshold:Double, divisor:Double, suffix:String)
        let abbreviations:[Abbrevation] = [(0, 1, ""),
                                           (1_000.0, 1_000.0, "K"),
                                           (1_000_000.0, 1_000_000.0, "M"),
                                           (1_000_000_000.0, 1_000_000_000.0, "B")]
        
        let startValue = Double (abs(num))
        let abbreviation:Abbrevation = {
            var prevAbbreviation = abbreviations[0]
            for tmpAbbreviation in abbreviations {
                if (startValue < tmpAbbreviation.threshold) {
                    break
                }
                prevAbbreviation = tmpAbbreviation
            }
            return prevAbbreviation
        } ()
        
        let value = Double(num) / abbreviation.divisor
        numFormatter.positiveSuffix = abbreviation.suffix
        numFormatter.negativeSuffix = abbreviation.suffix
        numFormatter.allowsFloats = true
        numFormatter.minimumIntegerDigits = 1
        numFormatter.minimumFractionDigits = 0
        numFormatter.maximumFractionDigits = 1
        
        return numFormatter.string(from: NSNumber (value:value))!
    }
    
}

func formatTimeInterval(_ difference: TimeInterval) -> String {
    var result = ""
    var printed = Double()
    
    if difference < 60 {
        printed = Double(Int(difference))
        result = "\(String(format: "%g", printed)) SECOND"
    } else if difference < 60 * 60 {
        printed = Double(Int(difference) / 60)
        result = "\(String(format: "%g", printed)) MINUTE"
    } else if difference < 60 * 60 * 24 {
        printed = Double(Int(difference) / 60 / 60)
        result = "\(String(format: "%g", printed)) HOUR"
    } else if difference < 60 * 60 * 24 * 7 {
        printed = Double(Int(difference) / 60 / 60 / 24)
        result = "\(String(format: "%g", printed)) DAY"
    } else if difference < 60 * 60 * 24 * 7 * 4 {
        printed = Double(Int(difference) / 60 / 60 / 24 / 7)
        result = "\(String(format: "%g", printed)) WEEK"
    } else if difference < 60 * 60 * 24 * 365 {
        printed = Double(Int(difference) / 60 / 60 / 24 / 7 / 4)
        result = "\(String(format: "%g", printed)) MONTH"
    } else {
        printed = Double(floor(difference / 60 / 60 / 24 / 365 * 10)) / 10
        result = "\(String(format: "%g", printed)) YEAR"
    }
    
    if printed != 1 {
        result.append("S")
    }
    
    return result
}

func openVideo(identifier: String?) {
    openVideo(nil)
    if let id = identifier {
        let video = InvidiousVideo(identifier: id)
        drawerState = .fullscreen
        video.getData(fields: [.all]) {
            openVideo(video)
            NotificationCenter.default.post(name: .videoOpened, object: nil)
        }
    }
}

var currentVideo: InvidiousVideo?

func openVideo(_ video: InvidiousVideo?) {
    if video != nil {
        drawerState = .fullscreen
    }
    currentVideo = video
    UIHapticFeedback.generate(style: .selection)
    NotificationCenter.default.post(name: .videoOpened, object: nil)
}

var openingViewController: UIViewController?

func openViewController(_ viewController: UIViewController) {
    
    openingViewController = viewController
    if drawerState == .fullscreen {
        drawerState = .small
    }
    NotificationCenter.default.post(name: .openViewController, object: nil)
    openingViewController = nil
    
}

typealias UIButtonTargetClosure = (UIButton) -> ()

class ClosureWrapper: NSObject {
    let closure: UIButtonTargetClosure
    init(_ closure: @escaping UIButtonTargetClosure) {
        self.closure = closure
    }
}

extension UIButton {
    
    private struct AssociatedKeys {
        static var targetClosure = "targetClosure"
    }
    
    private var targetClosure: UIButtonTargetClosure? {
        get {
            guard let closureWrapper = objc_getAssociatedObject(self, &AssociatedKeys.targetClosure) as? ClosureWrapper else { return nil }
            return closureWrapper.closure
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.targetClosure, ClosureWrapper(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func addTargetClosure(closure: @escaping UIButtonTargetClosure) {
        targetClosure = closure
        addTarget(self, action: #selector(UIButton.closureAction), for: .touchUpInside)
    }
    
    @objc func closureAction() {
        guard let targetClosure = targetClosure else { return }
        targetClosure(self)
    }
}

func inBackground(_ block: @escaping () -> Void) {
    DispatchQueue.global(qos: .default).async(execute: block)
}

func inForeground(_ block: @escaping () -> Void) {
    DispatchQueue.main.async(execute: block)
}
