//
//  Template.swift
//  hermes
//
//  Created by Aidan Cline on 8/21/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit

class TemplateViewController: UIViewController, UIScrollViewDelegate {
    let header = UIVisualEffectView()
    let titleLabel = UILabel()
    var contentView = UIScrollView()
    override var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        view.tintColor = tint
        view.addSubview(contentView)
        view.addSubview(header)
        view.addSubview(titleLabel)
        contentView.delegate = self
        contentView.alwaysBounceVertical = true
        setTheme()
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        header.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.layoutMargins.top + 96)
        contentView.frame = view.bounds
        scrollViewDidScroll(contentView)
    }
    
    func setTheme() {
        view.backgroundColor = .systemGroupedBackground
        header.effect = UIBlurEffect(style: .systemMaterial)
        titleLabel.textColor = .label
        scrollViewDidScroll(contentView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentInset.top + scrollView.contentOffset.y + view.layoutMargins.top
        header.frame.size.height = limit((96 + view.layoutMargins.top) - offset, min: view.layoutMargins.top + 50)
        titleLabel.frame = CGRect(x: 16, y: view.layoutMargins.top, width: header.frame.width, height: 50)
        //header.contentView.backgroundColor = UITheme.current.blurEffectBackground.withAlphaComponent(limit((1 - (offset - view.layoutMargins.top - 50)/16)/2, min: 0.5))
        header.alpha = limit((offset/16)/2, min: 0, max: 1)
        contentView.verticalScrollIndicatorInsets.top = header.frame.height - view.layoutMargins.top
        contentView.verticalScrollIndicatorInsets.bottom = 50 + view.layoutMargins.bottom
        titleLabel.frame = CGRect(x: 16, y: header.frame.height - 8 - 31, width: header.frame.width - 32, height: 31)
        titleLabel.font = .systemFont(ofSize: limit(31 - (offset/46 * 10), min: 21, max: 41), weight: .bold)
    }
}
