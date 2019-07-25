//
//  SettingsController.swift
//  hermes
//
//  Created by Aidan Cline on 2/25/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit
import PopMenu

class SettingsController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showBackButton = true
        largeTitle = false
        title = "Settings"
        
        let aboutGroup = CellGroup(frame: CGRect(x: 0, y: 0, width: scrollView.frame.width, height: 66))
        let appearanceGroup = CellGroup(frame: CGRect(x: 0, y: 0, width: scrollView.frame.width, height: 66))
        let playbackGroup = CellGroup(frame: CGRect(x: 0, y: 0, width: scrollView.frame.width, height: 66))
        let payGroup = CellGroup(frame: CGRect(x: 0, y: 0, width: scrollView.frame.width, height: 66))
        
        let aboutCell = CellButton()
        
        let appIconCell = CellButton()
        let themeCell = CellButton()
        
        let backgroundPlayCell = CellButton()
        let autoplayCell = CellButton()
        
        let proCell = CellButton()
        let tipJarCell = CellButton()
        
        aboutCell.title = "About"
        aboutCell.isButtonActive = true
        aboutCell.showNavigationIndicator = true
        aboutCell.onTap = {
            self.navigationController?.pushViewController(AboutController(), animated: true)
        }
        
        appIconCell.title = "App icon"
        appIconCell.isButtonActive = true
        appIconCell.showNavigationIndicator = true
        appIconCell.onTap = {
            self.navigationController?.pushViewController(AppIconController(), animated: true)
        }
        
        themeCell.title = "Theme"
        themeCell.isButtonActive = true
        themeCell.showNavigationIndicator = true
        themeCell.onTap = {
            self.navigationController?.pushViewController(ThemeController(), animated: true)
        }
        
        aboutGroup.addCell(aboutCell)
        
        appearanceGroup.addCell(appIconCell)
        appearanceGroup.addCell(themeCell)
        
        playbackGroup.addCell(backgroundPlayCell)
        
        backgroundPlayCell.title = "Play in the background"
        backgroundPlayCell.isButtonActive = false
        
        backgroundSwitch.addTarget(self, action: #selector(self.toggle(_:)), for: .primaryActionTriggered)
        backgroundSwitch.setOn(settings.backgroundPlay, animated: false)
        backgroundSwitch.onTintColor = interface.tintColor
        backgroundPlayCell.addSubview(backgroundSwitch)
        
        playbackGroup.addCell(autoplayCell)
        
        autoplayCell.title = "Autoplay"
        autoplayCell.isButtonActive = false
        
        autoplaySwitch.addTarget(self, action: #selector(self.toggle(_:)), for: .primaryActionTriggered)
        autoplaySwitch.setOn(settings.autoplay, animated: false)
        autoplaySwitch.onTintColor = interface.tintColor
        autoplayCell.addSubview(autoplaySwitch)
        
        let experimentalCell = CellButton()
        experimentalCell.title = "Use experimental player"
        experimentalCell.isButtonActive = false
        
        experimentalSwitch.addTarget(self, action: #selector(self.toggle(_:)), for: .primaryActionTriggered)
        experimentalSwitch.onTintColor = interface.tintColor
        experimentalSwitch.setOn(settings.experimentalPlayer, animated: false)
        experimentalCell.addSubview(experimentalSwitch)
        
        let qualityCell = CellButton()
        qualityCell.title = "Preferred quality"
        qualityCell.subtitle = settings.preferredQuality.rawValue
        qualityCell.onTap = {
            UIHapticFeedback.generate(style: .impact)
            let menuController = PopMenuViewController(sourceView: qualityCell.arrow, actions: [
                PopMenuDefaultAction(title: "Auto", image: nil, color: nil, didSelect: { (action) in
                    settings.preferredQuality = .auto
                }),
                PopMenuDefaultAction(title: "Highest", image: nil, color: nil, didSelect: { (action) in
                    settings.preferredQuality = .highest
                }),
                PopMenuDefaultAction(title: "1080p60", image: nil, color: nil, didSelect: { (action) in
                    settings.preferredQuality = .q1080p60
                }),
                PopMenuDefaultAction(title: "1080p", image: nil, color: nil, didSelect: { (action) in
                    settings.preferredQuality = .q1080p
                }),
                PopMenuDefaultAction(title: "720p60", image: nil, color: nil, didSelect: { (action) in
                    settings.preferredQuality = .q720p60
                }),
                PopMenuDefaultAction(title: "720p", image: nil, color: nil, didSelect: { (action) in
                    settings.preferredQuality = .q720p
                }),
                PopMenuDefaultAction(title: "480p", image: nil, color: nil, didSelect: { (action) in
                    settings.preferredQuality = .q480p
                }),
                PopMenuDefaultAction(title: "360p", image: nil, color: nil, didSelect: { (action) in
                    settings.preferredQuality = .q360p
                }),
                PopMenuDefaultAction(title: "240p", image: nil, color: nil, didSelect: { (action) in
                    settings.preferredQuality = .q240p
                }),
                PopMenuDefaultAction(title: "144p", image: nil, color: nil, didSelect: { (action) in
                    settings.preferredQuality = .q144p
                })
                ], appearance: interface.popMenuAppearance)
            self.present(menuController, animated: true)
        }
        
        playbackGroup.addCell(qualityCell)
        playbackGroup.addCell(experimentalCell)
        
        NotificationCenter.default.addObserver(forName: .qualityChanged, object: nil, queue: .main) { (notification) in
            qualityCell.subtitle = settings.preferredQuality.rawValue
        }
        
        let tutorialButton = CellButton(frame: CGRect(x: 0, y: 0, width: scrollView.frame.width, height: 50))
        tutorialButton.title = "Reopen splash screen"
        tutorialButton.highlightColor = interface.tintColor
        tutorialButton.onTap = {
            settings.userHasViewedTutorial = false
            settings.userHasViewedTutorial = true
            let tutorial = TutorialViewController()
            self.present(tutorial, animated: true, completion: {
                tutorial.start()
            })
        }
        
        proCell.title = "Hermes Pro"
        proCell.showNavigationIndicator = true
        proCell.onTap = {
            openViewController(ProPurchasePage())
        }
        
        tipJarCell.title = "Tip jar"
        tipJarCell.showNavigationIndicator = true
        tipJarCell.onTap = {
            
        }
        
        payGroup.addCell(proCell)
        payGroup.addCell(tipJarCell)
        
        scrollView.addGap(height: 16)
        scrollView.addSubview(aboutGroup)
        scrollView.addGap(height: 16)
        scrollView.addSubview(appearanceGroup)
        scrollView.addGap(height: 16)
        scrollView.addSubview(playbackGroup)
        scrollView.addGap(height: 16)
        scrollView.addSubview(payGroup)
        scrollView.addGap(height: 16)
        scrollView.addSubview(tutorialButton)
        
        backgroundSwitch.frame = CGRect(x: scrollView.frame.width - 49 - 32 - 16, y: (backgroundPlayCell.frame.height - 31)/2, width: 49, height: 31)
        autoplaySwitch.frame = CGRect(x: scrollView.frame.width - 49 - 32 - 16, y: (autoplayCell.frame.height - 31)/2, width: 49, height: 31)
        experimentalSwitch.frame = CGRect(x: scrollView.frame.width - 49 - 32 - 16, y: (experimentalCell.frame.height - 31)/2, width: 49, height: 31)
    }
    
    let backgroundSwitch = UISwitch()
    let autoplaySwitch = UISwitch()
    let experimentalSwitch = UISwitch()
    
    @objc func toggle(_ toggleSwitch: UISwitch) {
        if toggleSwitch == backgroundSwitch {
            settings.backgroundPlay = backgroundSwitch.isOn
        } else if toggleSwitch == autoplaySwitch {
            settings.autoplay = autoplaySwitch.isOn
        } else if toggleSwitch == experimentalSwitch {
            settings.experimentalPlayer = experimentalSwitch.isOn
            if settings.experimentalPlayer {
                let alert = UIAlertController(title: "Are you sure you want to enable the experimental player?", message: "You'll get buttery smooth 1080p60 quality, but this player doesn't have proper implementation yet. Be prepared for bad audio sync and no controls.", preferredStyle: .alert)
                alert.addAction(.init(title: "I like living on the edge", style: .destructive, handler: nil))
                alert.addAction(.init(title: "Yeah, no thanks", style: .cancel, handler: { (_) in
                    self.experimentalSwitch.setOn(false, animated: true)
                    settings.experimentalPlayer = false
                }))
                
                alert.view.tintColor = interface.tintColor
                present(alert, animated: true)
            }
        }
    }
    
}
