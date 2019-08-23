//
//  Account.swift
//  hermes
//
//  Created by Aidan Cline on 8/21/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit

class AccountViewController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        pushViewController(AccountRoot(), animated: false)
        isNavigationBarHidden = true
    }
}

class AccountRoot: TemplateViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Account"
    }
    
}
