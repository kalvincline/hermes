//
//  Search.swift
//  hermes
//
//  Created by Aidan Cline on 8/21/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit

class SearchViewController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        pushViewController(SearchRoot(), animated: false)
        isNavigationBarHidden = true
    }
}

class SearchRoot: TemplateViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"
    }
    
}
