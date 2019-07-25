//
//  AppIconController.swift
//  hermes
//
//  Created by Aidan Cline on 4/13/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit

class AppIconController: BaseViewController {
    
    let button = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showBackButton = true
        largeTitle = false
        title = "App icon"
        
        scrollView.addSubview(UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 16)))
        
        let icons = [nil, "inverted", "blackonwhite", "whiteonblack", "ares", "aphrodite", "poseidon", "coral", "forest", "happy", "iris", "outrun", "classic", "modernclassic"]
        let names = ["Default", "Inverted", "Black on White", "White on Black", "Ares", "Aphrodite", "Poseidon", "Coral", "Forest", "Happy", "Iris", "Outrun", "Classic", "Modern Classic"]
        for (i, icon) in icons.enumerated() {
            let view = IconView(frame: CGRect(x: 0, y: 0, width: scrollView.frame.width, height: 75))
            view.icon = icon
            view.title = names[i]
            scrollView.addSubview(view)
        }
    }
    
}

class IconView: UIView {
    
    var icon: String? {
        didSet {
            if let icon = icon {
                iconView.image = UIImage(named: "\(icon).png")
            } else {
                iconView.image = UIImage(named: "default")
            }
        }
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    let iconView = UIImageView()
    let titleLabel = UILabel()
    let button = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame.size.height = 75
        
        button.addTargetClosure { (button) in
            settings.appIcon = self.icon
        }
        
        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(button)
        updateTheme(animated: false)
        
        NotificationCenter.default.addObserver(forName: .themeChanged, object: nil, queue: .main) { (notification) in
            self.updateTheme(animated: true)
        }
        NotificationCenter.default.addObserver(forName: .appIconChanged, object: nil, queue: .main) { (notification) in
            UIView.animate(withDuration: 0.25) {
                self.button.layer.borderColor = interface.tintColor.withAlphaComponent((settings.appIcon == self.icon) ? 1 : 0).cgColor
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        iconView.frame = CGRect(x: 16, y: 4, width: frame.height - 8, height: frame.height - 8)
        iconView.layer.cornerRadius = iconView.frame.height / 4
        iconView.layer.borderWidth = 1
        iconView.layer.borderColor = UIColor(white: 0.5, alpha: 1/3).cgColor
        iconView.clipsToBounds = true
        
        button.frame = bounds
        button.frame.origin.x = 12
        button.frame.size.width = frame.width - 24
        button.layer.cornerRadius = iconView.layer.cornerRadius + 4
        button.layer.borderColor = interface.tintColor.withAlphaComponent((settings.appIcon == icon) ? 1 : 0).cgColor
        button.layer.borderWidth = 2
        
        titleLabel.frame = CGRect(x: iconView.frame.maxX + 8, y: (frame.height - 20)/2, width: frame.width - (iconView.frame.maxX + 8 + 16), height: 20)
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
    }
    
    func updateTheme(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.25 : 0) {
            self.titleLabel.textColor = interface.textColor
            self.backgroundColor = .clear
        }
    }
    
}
