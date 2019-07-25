//
//  AboutController.swift
//  hermes
//
//  Created by Aidan Cline on 4/13/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit

class AboutController: BaseViewController {
    
    let icon = UIImageView()
    let iconView = UIView()
    let nameLabel = UILabel()
    let versionLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showBackButton = true
        largeTitle = false
        title = "About"
        
        iconView.frame = CGRect(x: 16, y: 16, width: scrollView.frame.width - 32, height: 150)
        iconView.layer.shadowPath = UIBezierPath(roundedRect: CGRect(origin: .zero, size: CGSize(width: iconView.frame.height, height: iconView.frame.height)), cornerRadius: 50).cgPath
        iconView.layer.shadowColor = UIColor.black.cgColor
        iconView.layer.shadowOffset = CGSize(width: 0, height: 20)
        iconView.layer.shadowRadius = 20
        iconView.layer.shadowOpacity = 0.25
        
        icon.frame = iconView.bounds
        icon.frame.size.width = iconView.frame.height
        icon.image = UIImage(named: "hd icon")
        icon.layer.cornerRadius = icon.frame.height / 4
        icon.clipsToBounds = true
        iconView.addSubview(icon)
        
        nameLabel.frame = CGRect(x: icon.frame.maxX + 16, y: icon.frame.maxY - (icon.frame.height + 34 + 16)/2, width: view.frame.width - icon.frame.maxX - 64, height: 34)
        nameLabel.font = .systemFont(ofSize: 31, weight: .black)
        nameLabel.text = "Hermes"
        nameLabel.textAlignment = .center
        iconView.addSubview(nameLabel)
        
        versionLabel.frame = CGRect(x: icon.frame.maxX + 16, y: nameLabel.frame.maxY, width: view.frame.width - icon.frame.maxX - 64, height: 16)
        versionLabel.font = .systemFont(ofSize: 14, weight: .light)
        versionLabel.textAlignment = .center
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        versionLabel.text = "v\(appVersion ?? "")\((settings.beta) ? " beta" : "")"
        iconView.addSubview(versionLabel)
        
        let channel = ChannelView(frame: CGRect(x: 0, y: 0, width: scrollView.frame.width, height: 0), channel: InvidiousChannel(identifier: "UCsxA22wQujlEBO2Ngo1H9tw"))
        
        scrollView.addSubview(iconView)
        scrollView.addGap(height: 32)
        scrollView.addSubview(channel)
    }
    
    override func setThemes() {
        super.setThemes()
        nameLabel.textColor = interface.textColor
        versionLabel.textColor = interface.textColor.withAlphaComponent(0.75)
    }
    
}
