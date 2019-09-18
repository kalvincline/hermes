//
//  ViewController.swift
//  hermes
//
//  Created by Aidan Cline on 8/21/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit
import Google
import GoogleSignIn

class MainViewController: UITabBarController {
    
    let home = HomeViewController()
    let subscriptions = SubscriptionsViewController()
    let account = AccountViewController()
    let search = SearchViewController()
    
    let tabBarBackgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
    let transitionManager = DrawerPresentationManager()
    
    let drawer = DrawerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = tint
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
        tabBar.insertSubview(tabBarBackgroundView, at: 0)
        viewControllers = [
            home,
            subscriptions,
            account,
            search
        ]
        
        videoHandler = { video in
            self.drawer.video = video
            self.present(self.drawer, animated: true)
        }
        
        shortcutHandler = { shortcut in
            switch shortcut {
            case .watchLater:
                ()
            case .subscriptions:
                self.selectedIndex = 1
            case .account:
                self.selectedIndex = 2
            case .search:
                self.selectedIndex = 3
            }
        }
        
        let homeItem = (self.tabBar.items?[0])! as UITabBarItem
        homeItem.image = UIImage(systemName: "house.fill")
        homeItem.title = "Home"
        let subscriptionsItem = (self.tabBar.items?[1])! as UITabBarItem
        subscriptionsItem.image = UIImage(systemName: "rectangle.stack.fill")
        subscriptionsItem.title = "Subscriptions"
        let accountItem = (self.tabBar.items?[2])! as UITabBarItem
        accountItem.image = UIImage(systemName: "person.crop.circle.fill")
        accountItem.title = "Account"
        let searchItem = (self.tabBar.items?[3])! as UITabBarItem
        searchItem.image = UIImage(systemName: "magnifyingglass")
        searchItem.title = "Search"
        
        _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (timer) in
            openVideo(nil)
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tabBarBackgroundView.frame = tabBar.bounds
    }
    
}

func openVideo(_ video: InvidiousVideo?) {
    videoHandler(video)
}

var videoHandler: ((InvidiousVideo?) -> Void) = { _ in }

let tint = UIColor(red: 0.375, green: 0.354, blue: 1, alpha: 1)

enum Shortcut {
    case watchLater
    case subscriptions
    case account
    case search
}

var shortcutHandler: ((Shortcut) -> Void) = { _ in }
