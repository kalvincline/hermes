//
//  Subscriptions.swift
//  hermes
//
//  Created by Aidan Cline on 8/21/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit

class SubscriptionsViewController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        pushViewController(SubscriptionsRoot(), animated: false)
        isNavigationBarHidden = true
    }
}

class SubscriptionsRoot: TemplateViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Subscriptions"
    }
    
}
