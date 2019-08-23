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
        view.addSubview(contentView)
        view.addSubview(header)
        header.contentView.addSubview(titleLabel)
        contentView.delegate = self
        contentView.alwaysBounceVertical = true
        UITheme.addHandler { (theme) in
            self.setTheme(theme)
        }
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        header.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: safeArea.top + 96)
        contentView.frame = view.bounds
        scrollViewDidScroll(contentView)
    }
    
    func setTheme(_ theme: UITheme.Theme) {
        view.backgroundColor = theme.background
        header.effect = theme.blurEffect
        titleLabel.textColor = theme.text
        scrollViewDidScroll(contentView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentInset.top + scrollView.contentOffset.y + safeArea.top
        header.frame.size.height = limit((96 + safeArea.top) - offset, min: safeArea.top + 50)
        titleLabel.frame = CGRect(x: 16, y: safeArea.top, width: header.frame.width, height: 50)
        header.contentView.backgroundColor = UITheme.current.blurEffectBackground.withAlphaComponent(limit((1 - (offset - safeArea.top - 50)/16)/2, min: 0.5))
        contentView.verticalScrollIndicatorInsets.top = header.frame.height - safeArea.top
        contentView.verticalScrollIndicatorInsets.bottom = 50 + safeArea.bottom
        titleLabel.frame = CGRect(x: 16, y: header.frame.height - 8 - 31, width: header.frame.width - 32, height: 31)
        titleLabel.font = .systemFont(ofSize: limit(31 - (offset/46 * 10), min: 21, max: 41), weight: .bold)
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
