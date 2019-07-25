//
//  TemplateViewController.swift
//  hermesforyoutube
//
//  Created by Aidan Cline on 7/24/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit

class TemplateViewController: UIViewController, UIScrollViewDelegate {
    
    override var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    let header = UIVisualEffectView()
    let titleLabel = UILabel()
    let scrollView = UITableView()
    
}
