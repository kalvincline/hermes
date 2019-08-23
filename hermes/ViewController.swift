//
//  ViewController.swift
//  hermes
//
//  Created by Aidan Cline on 8/21/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let tabBar = TabBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.frame = view.bounds
        tabBar.tabs = [
            TabBar.Tab(icon: UIImage(named: "home")!, viewController: HomeViewController()),
            TabBar.Tab(icon: UIImage(named: "subscriptions")!, viewController: SubscriptionsViewController()),
            TabBar.Tab(icon: UIImage(named: "account")!, viewController: AccountViewController()),
            TabBar.Tab(icon: UIImage(named: "search")!, viewController: SearchViewController())
        ]
        
        view.addSubview(tabBar)
        
        UITheme.current = traitCollection.userInterfaceStyle == .dark ? UITheme.darkTheme : UITheme.lightTheme
        UITheme.addStatusBarHandler { (style) in
            switch style {
            case .hidden:
                self.statusBarHidden = true
            case .darkContent:
                self.statusBarStyle = .default
                self.statusBarHidden = false
            case .lightContent:
                self.statusBarStyle = .lightContent
                self.statusBarHidden = false
            }
            
            self.setNeedsStatusBarAppearanceUpdate()
        }
        
        UITheme.addStatusBarAnimatedHandler { (style) in
            switch style {
            case .hidden:
                self.statusBarHidden = true
            case .darkContent:
                self.statusBarStyle = .default
                self.statusBarHidden = false
            case .lightContent:
                self.statusBarStyle = .lightContent
                self.statusBarHidden = false
            }
            
            UIView.animate(withDuration: 0.5) {
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    var statusBarHidden = false
    override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }
    
    var statusBarStyle: UIStatusBarStyle = .default
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UITheme.setStatusBarAnimated(UITheme.current.statusBarStyle)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        UITheme.current = traitCollection.userInterfaceStyle == .dark ? UITheme.darkTheme : UITheme.lightTheme
    }
}

class TabBar: UIView {
    var iconViews: [UIButton] = []
    var contentViews: [UIView] = []
    var tabs: [Tab] = [] {
        didSet {
            contentView.subviews.forEach { (subview) in
                subview.removeFromSuperview()
            }
            
            barView.contentView.subviews.forEach { (subview) in
                subview.removeFromSuperview()
            }
            
            iconViews = []
            contentViews = []
            for (i, tab) in tabs.enumerated() {
                let view = tab.viewController.view!
                view.alpha = i == currentTab ? 1 : 0
                contentView.addSubview(view)
                contentViews.append(view)
                
                let iconView = UIButton(type: .custom)
                iconView.setImage(tab.icon, for: .normal)
                iconView.frame = CGRect(x: CGFloat(i) * (frame.width / CGFloat(tabs.count)), y: 0, width: frame.width / CGFloat(tabs.count), height: 50)
                iconView.tintColor = (i == currentTab) ? UITheme.current.tint : UIColor(white: 0.5, alpha: 0.75)
                iconView.addTargetClosure { (button) in
                    self.currentTab = i
                }
                
                barView.contentView.addSubview(iconView)
                iconViews.append(iconView)
            }
        }
    }
    
    var currentTab = 0 {
        didSet {
            for (i, view) in contentViews.enumerated() {
                view.alpha = (i == currentTab) ? 1 : 0
            }
            
            for (i, iconView) in iconViews.enumerated() {
                iconView.tintColor = (i == currentTab) ? UITheme.current.tint : UIColor(white: 0.5, alpha: 0.75)
            }
        }
    }
    
    struct Tab {
        var icon: UIImage
        var viewController: UIViewController
    }
    
    let contentView = UIView()
    let contentViewTint = UIView()
    let barView = UIVisualEffectView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(contentView)
        addSubview(barView)
        contentView.addSubview(contentViewTint)
        UITheme.addHandler { (theme) in
            self.setTheme(theme)
        }
    }
    
    convenience init(frame: CGRect, tabs: [Tab]) {
        self.init(frame: frame)
        self.tabs = tabs
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        barView.frame = CGRect(x: 0, y: frame.height - (50 + safeArea.bottom), width: frame.width, height: 50 + safeArea.bottom)
        contentView.frame = bounds
        tabs.forEach { (tab) in
            tab.viewController.view.frame = bounds
        }
        
        for (i, iconView) in iconViews.enumerated() {
            iconView.frame = CGRect(x: CGFloat(i) * (frame.width / CGFloat(tabs.count)), y: 0, width: frame.width / CGFloat(tabs.count), height: 50)
            iconView.contentMode = .center
        }
        
        minimize(factor: minimizationFactor)
    }
    
    var minimizationFactor: CGFloat = 0
    func minimize() {
        minimize(factor: 1)
    }
    
    func minimize(factor: CGFloat) {
        minimizationFactor = factor
        var scaleFactor = (contentView.frame.height - (safeArea.top + 10)) / (contentView.frame.height)
        scaleFactor = 1 - factor * (1 - scaleFactor)
        contentView.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        contentViewTint.alpha = factor
        barView.frame.origin.y = frame.height - barView.frame.height * (1 - factor)
    }
    
    func setTheme(_ theme: UITheme.Theme) {
        barView.effect = theme.blurEffect
        barView.contentView.backgroundColor = theme.blurEffectBackground
        contentViewTint.backgroundColor = .init(white: 0.5, alpha: 0.25)
        for (i, iconView) in iconViews.enumerated() {
            iconView.tintColor = (i == currentTab) ? theme.tint : UIColor(white: 0.5, alpha: 0.75)
        }
    }
}

func openVideo(_ video: InvidiousVideo?) {
    
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
