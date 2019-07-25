//
//  NavigationController.swift
//  hermes
//
//  Created by Aidan Cline on 4/4/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController, UINavigationControllerDelegate {
    
    var root = UIViewController()
    var statusBarStyle = ApplicationInterface.UIStatusBarStyles.dark {
        didSet {
            if !view.isHidden {
                interface.setStatusBarAnimated(statusBarStyle)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        interactivePopGestureRecognizer?.isEnabled = true
        isNavigationBarHidden = true
        show(root, sender: nil)
        
        NotificationCenter.default.addObserver(forName: .tabChanged, object: nil, queue: .main) { (notification) in
            if !self.view.isHidden {
                interface.setStatusBar(self.statusBarStyle)
            }
        }
        
        NotificationCenter.default.addObserver(forName: .updateStatusBar, object: nil, queue: .main) { (notification) in
            if !self.view.isHidden {
                interface.setStatusBarAnimated(self.statusBarStyle)
            }
        }

        NotificationCenter.default.addObserver(forName: .openViewController, object: nil, queue: .main) { (notification) in
            if !self.view.isHidden {
                if let viewController = openingViewController {
                    self.pushViewController(viewController, animated: true)
                }
            }
        }
    }
    
}
