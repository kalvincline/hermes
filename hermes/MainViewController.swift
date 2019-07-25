//
//  ViewController.swift
//  hermes
//
//  Created by Aidan Cline on 1/30/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit
import AVKit
import StoreKit

class MainViewController: UIViewController {
    
    let volumeView = VolumeView()
    
    let homeVC = Home()
    let subscriptionsVC = Subscriptions()
    let accountVC = Account()
    let searchVC = Search()
    let mainView = UIView()
    let mainViewSheet = UIView()
    
    let drawerView = Drawer()
    let tabBar = TabBarView()
    
    let tutorial = TutorialViewController()
    
    var videoFrame = CGRect()
    var smallVideoFrame = CGRect()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        settings.searchHistory = []
        for VC in [homeVC, subscriptionsVC, accountVC, searchVC] {
            VC.view.frame.size = CGSize(width: view.frame.width, height: view.frame.height)
            addChild(VC)
            mainView.addSubview(VC.view)
            VC.didMove(toParent: self)
            VC.view.isHidden = true
        }
        
        mainViewSheet.layer.cornerRadius = 10
        mainViewSheet.clipsToBounds = true
        mainViewSheet.alpha = 0
        mainView.addSubview(mainViewSheet)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch {
            print("can't set audio category")
        }

        homeVC.view.isHidden = false
        
        self.view.tintColor = interface.tintColor
        view.addSubview(mainView)
        drawerView.frame = view.bounds
        view.addSubview(drawerView)
        drawerState = .closed
        view.addSubview(tabBar)
        layoutViews()
        setThemes(animated: false)
        
        if #available(iOS 13, *), !settings.manualInterfaceStyle { // fancy ios 13 features, don't enable this until it comes out
            let interfaceStyle = UITraitCollection.current.userInterfaceStyle
            switch interfaceStyle {
            case .light, .unspecified:
                settings.interfaceStyle = .light
            case .dark:
                settings.interfaceStyle = .black
            @unknown default:
                settings.interfaceStyle = .light
            }
        }
        
        guard #available(iOS 13, *) else {
            view.addSubview(volumeView)
            return
        }
        
        drawerView.didPan = { translation in
            let translation = -translation
            UIView.animate(withDuration: 0.25) {
                let scale = (self.mainView.frame.height - safeArea.top - 10) / self.mainView.frame.height
                if drawerState == .fullscreen {
                    let transition = translation / 100
                    let scaleAmount = limit(scale - transition/100, min: scale, max: 1)
                    self.mainView.transform = CGAffineTransform(scaleX: scaleAmount, y: scaleAmount)
                    self.mainView.layer.cornerRadius = limit(10 + transition * 5, min: 5, max: 10)
                    self.mainView.alpha = limit(2/3 - transition/10, min: 2/3, max: 1)
                    self.mainViewSheet.alpha = 1 + transition/2
                    let newTabBarY = self.view.frame.height + translation * 0.3
                    self.tabBar.frame.origin.y = limit(newTabBarY, min: self.view.frame.height - safeArea.bottom - 50)
                } else if drawerState == .small {
                    let transition = translation / 30
                    let scaleAmount = limit(1 + scale * (1-transition)/200, min: scale, max: 1)
                    self.mainView.transform = CGAffineTransform(scaleX: scaleAmount, y: scaleAmount)
                    self.mainView.layer.cornerRadius = limit(2.5 * transition, min: 5, max: 10)
                    self.mainView.alpha = limit(1 - transition/25, min: 2/3, max: 1)
                    self.mainViewSheet.alpha = transition/8
                    let newTabBarY = self.view.frame.height - safeArea.bottom - 50 + translation * 0.3
                    self.tabBar.frame.origin.y = limit(newTabBarY, min: self.view.frame.height - safeArea.bottom - 50)
                }
            }
        }
        
        drawerView.didEndPanning = {
            UIView.animate(withDuration: 0.25, delay: 0, options: .beginFromCurrentState, animations: {
                if drawerState == .fullscreen {
                    let scale = (self.mainView.frame.height - safeArea.top - 10) / self.mainView.frame.height
                    self.mainView.transform = CGAffineTransform(scaleX: scale, y: scale)
                    self.mainView.layer.cornerRadius = 10
                    self.mainView.alpha = 2/3
                    self.mainViewSheet.alpha = 1
                    self.tabBar.frame.origin.y = self.view.frame.height
                } else {
                    self.mainView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.mainView.layer.cornerRadius = 5
                    self.mainView.alpha = 1
                    self.mainViewSheet.alpha = 0
                    self.tabBar.frame.origin.y = self.view.frame.height - safeArea.bottom - 50
                }
            }, completion: nil)
        }
        
        NotificationCenter.default.addObserver(forName: .themeChanged, object: nil, queue: .main) { (notification) in
            self.setThemes(animated: true)
        }
        NotificationCenter.default.addObserver(forName: .statusBarChanged, object: nil, queue: .main) { (notification) in
            self.setNeedsStatusBarAppearanceUpdate()
        }
        NotificationCenter.default.addObserver(forName: .statusBarChangedAnimated, object: nil, queue: .main) { (notification) in
            UIView.animate(withDuration: 0.25, animations: {
                self.setNeedsStatusBarAppearanceUpdate()
            })
        }
        NotificationCenter.default.post(name: .themeChanged, object: nil)
        view.addSubview(tutorial.view)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if settings.developer {
            settings.userHasViewedTutorial = false
        }
        if !settings.userHasViewedTutorial {
            self.tutorial.view.removeFromSuperview()
            present(tutorial, animated: false, completion: {
                self.tutorial.start()
            })
        } else {
            tutorial.view.removeFromSuperview()
        }
    }
    
    func layoutViews() {
        tabBar.frame = CGRect(x: 0, y: view.frame.height - 50 - safeArea.bottom, width: view.frame.width, height: 50 + safeArea.bottom)
        for button in [tabBar.home, tabBar.subscriptions, tabBar.account, tabBar.downloads, tabBar.search] {
            button.addTarget(self, action: #selector(tabButtonPressed(_:)), for: .touchUpInside)
            button.addTarget(self, action: #selector(tabButtonDragged(_:)), for: .touchDragExit)
        }
        tabButtonPressed(tabBar.home)
        mainView.frame = self.view.frame
        mainViewSheet.frame = mainView.bounds
        mainView.setAnchorPoint(CGPoint(x: 0.5, y: 1.0))
        mainView.clipsToBounds = true
    }
    
    @objc func tabButtonDragged(_ button: UIButton) {
        button.cancelTracking(with: nil)
    }
    
    @objc func tabButtonPressed(_ button: UIButton) {
        if button == tabBar.home && currentTab == .home {
            if homeVC.viewControllers.count == 1 {
                (homeVC.root as! HomeViewController).scrollView.setContentOffset(CGPoint(x: 0, y: -96 - safeArea.top), animated: true)
            } else {
                homeVC.popToRootViewController(animated: true)
            }
        }
        if button == tabBar.subscriptions && currentTab == .subscriptions {
            if subscriptionsVC.viewControllers.count == 1 {
                (subscriptionsVC.root as! SubscriptionsViewController).scrollView.setContentOffset(CGPoint(x: 0, y: -96 - safeArea.top), animated: true)
            } else {
                subscriptionsVC.popToRootViewController(animated: true)
            }
        }
        if button == tabBar.account && currentTab == .account {
            if accountVC.viewControllers.count == 1 {
                (accountVC.root as! AccountViewController).scrollView.setContentOffset(CGPoint(x: 0, y: -96 - safeArea.top), animated: true)
            } else {
                accountVC.popToRootViewController(animated: true)
            }
        }
        if button == tabBar.search && currentTab == .search {
            if searchVC.viewControllers.count == 1 {
                let scrollView = (searchVC.root as! SearchViewController).scrollView
                scrollView.setContentOffset(CGPoint(x: 0, y: -scrollView.contentInset.top), animated: true)
            } else {
                searchVC.popToRootViewController(animated: true)
            }
        }
        for button in [tabBar.home, tabBar.subscriptions, tabBar.account, tabBar.downloads, tabBar.search] {
            button.tintColor = UIColor(white: 0.5, alpha: 1.0)
        }
        button.tintColor = interface.tintColor
        for view in [homeVC.view, subscriptionsVC.view, accountVC.view, searchVC.view] {
            view!.isHidden = true
        }
        switch button {
        case tabBar.home:
            homeVC.view.isHidden = false
            currentTab = .home
        case tabBar.subscriptions:
            subscriptionsVC.view.isHidden = false
            currentTab = .subscriptions
        case tabBar.account:
            accountVC.view.isHidden = false
            currentTab = .account
        case tabBar.search:
            searchVC.view.isHidden = false
            currentTab = .search
        default: ()
        }
        
        NotificationCenter.default.post(name: .tabChanged, object: nil)
        NotificationCenter.default.post(name: .updateStatusBar, object: nil)
    }
    
    func setThemes(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.25 : 0) {
            self.tabBar.effect = interface.blurEffect
            self.mainViewSheet.backgroundColor = UIColor(red: 0.9, green: 0.95, blue: 1, alpha: (interface.style == .black) ? 0.125 : 0)
            if interface.style == .black {
                self.tabBar.contentView.backgroundColor = .clear
            } else {
                self.tabBar.contentView.backgroundColor = interface.blurEffectBackground
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        switch interface.statusBarStyle {
        case .dark:
            if #available(iOS 13, *) {
                return .darkContent
            } else {
                return .default
            }
            //return .default // fancy ios 13 features, don't use them until it comes out
        case .light:
            return .lightContent
        case .hidden:
            return .default
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return interface.statusBarStyle == .hidden
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13, *), !settings.manualInterfaceStyle {
            let userInterfaceStyle = traitCollection.userInterfaceStyle
            switch userInterfaceStyle {
            case .light, .unspecified:
                settings.interfaceStyle = .light
            case .dark:
                settings.interfaceStyle = .black
            @unknown default:
                settings.interfaceStyle = .light
            }
        }
    }

}

class TabBarView: UIVisualEffectView {
    
    let home = UIButton()
    let subscriptions = UIButton()
    let account = UIButton()
    let downloads = UIButton()
    let search = UIButton()
    
    let color = UIColor(white: 0.5, alpha: 1.0)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let height: CGFloat = 50
        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: height + safeArea.bottom)
        home.setImage(UIImage(named: "home"), for: .normal)
        subscriptions.setImage(UIImage(named: "subscriptions"), for: .normal)
        account.setImage(UIImage(named: "account"), for: .normal)
        downloads.setImage(UIImage(named: "downloads"), for: .normal)
        search.setImage(UIImage(named: "search"), for: .normal)
        let buttons = [home, subscriptions, account, search]
        for (i, button) in buttons.enumerated() {
            let width = frame.width / CGFloat(buttons.count)
            button.frame = CGRect(x: CGFloat(i) * width, y: 0.0, width: width, height: height)
            button.imageView?.frame = button.bounds
            button.imageView?.contentMode = .scaleToFill
            contentView.addSubview(button)
        }
    }
    
}
