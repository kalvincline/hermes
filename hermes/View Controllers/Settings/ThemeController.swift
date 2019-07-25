//
//  File.swift
//  hermes
//
//  Created by Aidan Cline on 2/25/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit

class ThemeController: BaseViewController {
    
    var lightView = ExampleView()
    var darkView = ExampleView()
    var blackView = ExampleView()
    
    let settingsGroup = CellGroup()
    let automaticCell = CellButton()
    let automaticSwitch = UISwitch()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showBackButton = true
        largeTitle = false
        title = "Theme"
        
        let height: CGFloat = 175
        let viewFrame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: height)
        
        lightView = ExampleView(frame: viewFrame, style: .light)
        darkView = ExampleView(frame: viewFrame, style: .dark)
        blackView = ExampleView(frame: viewFrame, style: .black)
        
        if #available(iOS 13, *) {
            automaticCell.isButtonActive = false
            automaticCell.title = "Use system theme"
            automaticCell.addSubview(automaticSwitch)
            
            automaticSwitch.frame = CGRect(x: scrollView.frame.width - 49 - 32 - 16, y: (automaticCell.frame.height - 31)/2, width: 49, height: 31)
            automaticSwitch.addTarget(self, action: #selector(self.switchToggled(_:)), for: .primaryActionTriggered)
            automaticSwitch.setOn(!settings.manualInterfaceStyle, animated: false)
            automaticSwitch.tintColor = interface.tintColor
            switchToggled(automaticSwitch)
            
            settingsGroup.frame.size.width = scrollView.frame.width
            settingsGroup.addCell(automaticCell)
            scrollView.addGap(height: 16)
            scrollView.addSubview(settingsGroup)
            scrollView.addGap(height: 8)
        }
        
        scrollView.addSubview(lightView)
        scrollView.addSubview(darkView)
        scrollView.addSubview(blackView)
    }
    
    @objc func switchToggled(_ toggle: UISwitch) {
        if toggle == automaticSwitch {
            if #available(iOS 13, *) {
                settings.manualInterfaceStyle = !toggle.isOn
                
                let userInterfaceStyle = traitCollection.userInterfaceStyle
                switch userInterfaceStyle {
                case .light, .unspecified:
                    settings.interfaceStyle = .light
                case .dark:
                    settings.interfaceStyle = .black
                @unknown default:
                    settings.interfaceStyle = .light
                }
                
                UIView.animate(withDuration: 0.25) {
                    for view in [self.lightView, self.darkView, self.blackView] {
                        print("did a thing")
                        view.alpha = !settings.manualInterfaceStyle ? 0.5 : 1
                        view.isUserInteractionEnabled = settings.manualInterfaceStyle
                    }
                }
            }
        }
    }
    
}

class ExampleView: UIView {
    
    let thumbnail = UIView()
    let main = UIView()
    let text = UIView()
    let button = UIButton()
    
    var isActive: Bool {
        return interface.style == style
    }
    
    typealias Style = ApplicationSettings.UIInterfaceStyles
    var style: Style = .light
    
    convenience init() {
        self.init(frame: .zero)
    }

    convenience init(frame: CGRect, style: Style) {
        self.init(frame: frame)
        self.style = style
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        button.addTarget(self, action: #selector(self.theme), for: .touchUpInside)
        
        main.layer.cornerRadius = 20
        main.clipsToBounds = true
        
        thumbnail.layer.cornerRadius = 12
        thumbnail.clipsToBounds = true
        
        text.layer.cornerRadius = 12
        text.clipsToBounds = true
        
        addSubview(main)
        main.addSubview(thumbnail)
        main.addSubview(text)
        main.addSubview(button)
        
        NotificationCenter.default.addObserver(forName: .themeChanged, object: nil, queue: .main) { (notification) in
            self.main.layer.borderColor = (self.isActive ? interface.tintColor : interface.textColor.withAlphaComponent(0/6)).cgColor
            self.main.layer.borderWidth = self.isActive ? 2 : 1
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let interface = ApplicationInterface(style: style)
        
        main.frame = CGRect(x: 16, y: 8, width: frame.width - 32, height: frame.height - 8)
        main.backgroundColor = interface.backgroundColor
        main.layer.borderColor = (isActive ? interface.tintColor : interface.textColor.withAlphaComponent(0/6)).cgColor
        main.layer.borderWidth = isActive ? 2 : 1
        
        button.frame = main.bounds
        
        thumbnail.frame = CGRect(x: 8, y: 8, width: main.frame.width - 16, height: main.frame.height - 16 -  8 - 24)
        thumbnail.backgroundColor = interface.textColor.withAlphaComponent(1/6)
        
        text.frame = CGRect(x: 8, y: main.frame.height - 8 - 24, width: main.frame.width - 16, height: 24)
        text.backgroundColor = interface.textColor.withAlphaComponent(1/6)
    }
    
    @objc func theme() {
        settings.interfaceStyle = style
    }
    
}
