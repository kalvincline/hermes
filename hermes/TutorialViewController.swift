//
//  TutorialViewController.swift
//  hermes
//
//  Created by Aidan Cline on 5/1/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController, UIScrollViewDelegate {
    
    let titleView = UILabel()
    let subtitleView = UILabel()
    let buttonView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    let imageView = UIImageView(image: UIImage(named: "gradient"))
    let logoView = UIImageView(image: UIImage(named: "logo"))
    let reminderLabel = UILabel()
    let arrow = UIImageView(image: UIImage(named: "arrow-down"))
    let scrollView = UIScrollView()
    let firstView = UIView()
    let secondView = UIView()

    var bumpTimer = Timer()
    var reminderTimer = Timer()
    var statusBar = ApplicationInterface.UIStatusBarStyles.light
    
    var showReminder = false {
        didSet {
            UIView.animate(withDuration: 0.25) {
                self.reminderLabel.alpha = (self.showReminder) ? 1 : 0
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .fullScreen
        
        view.layer.cornerRadius = 5
        
        imageView.frame = view.bounds
        imageView.contentMode = .scaleAspectFill
        logoView.frame = view.bounds
        logoView.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        
        scrollView.frame = view.bounds
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.delegate = self
        scrollView.contentSize.width = view.frame.width
        scrollView.contentInset.top = -safeArea.top
        
        buttonView.frame = CGRect(x: 32, y: view.frame.height - 50 - 16, width: view.frame.width - 64, height: 50)
        buttonView.layer.cornerRadius = 15
        buttonView.clipsToBounds = true
        buttonView.alpha = 0
        
        let button = UIButton(frame: buttonView.bounds)
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.titleLabel?.textColor = .white
        button.addTarget(self, action: #selector(self.buttonWasPressed), for: .touchDown)
        button.addTarget(self, action: #selector(self.buttonWasReleased), for: .touchUpOutside)
        button.addTarget(self, action: #selector(self.buttonWasPressed), for: .touchDragEnter)
        button.addTarget(self, action: #selector(self.buttonWasReleased), for: .touchDragExit)
        button.addTargetClosure { (button) in
            settings.userHasViewedTutorial = true
            UIView.animate(withDuration: 0.125) {
                self.buttonView.alpha = 1
            }
            interface.setStatusBarAnimated(self.statusBar)
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        
        buttonView.contentView.addSubview(button)
        
        bumpTimer = Timer.scheduledTimer(withTimeInterval: 7, repeats: true, block: { (timer) in
            if self.scrollView.contentOffset.y == 0 {
                UIView.animate(withDuration: 0.25, animations: {
                    self.arrow.frame.origin.y -= 15
                    self.reminderLabel.frame.origin.y -= 3
                }, completion: { (complete) in
                    UIView.animate(withDuration: 0.75, animations: {
                        self.arrow.frame.origin.y += 15
                        self.reminderLabel.frame.origin.y += 3
                    })
                })
            }
        })
        
        reminderTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: false, block: { (timer) in
            self.showReminder = true
        })
        
        titleView.text = "Welcome to Hermes"
        titleView.textColor = .white
        titleView.font = .systemFont(ofSize: 33, weight: .bold)
        titleView.frame = CGRect(x: 16, y: 35 + safeArea.top, width: view.frame.width - 32, height: 68)
        titleView.numberOfLines = 2
        titleView.sizeToFit()
        titleView.frame.size.width = view.frame.width - 32
        titleView.textAlignment = .center
        titleView.alpha = 0
        
        
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        subtitleView.text = "v\(appVersion ?? "")\((settings.beta) ? " beta" : "")"
        subtitleView.textColor = .white
        subtitleView.font = .italicSystemFont(ofSize: 13)
        subtitleView.frame = CGRect(x: 16, y: titleView.frame.maxY + 4, width: view.frame.width - 32, height: 20)
        subtitleView.textAlignment = .center
        subtitleView.alpha = 0
        
        arrow.contentMode = .scaleToFill
        arrow.tintColor = UIColor.white.withAlphaComponent(0.75)
        arrow.frame = CGRect(x: (scrollView.frame.width - 20)/2, y: scrollView.frame.height - 25 - 20 - safeArea.bottom, width: 20, height: 20)
        
        reminderLabel.frame = CGRect(x: 16, y: arrow.frame.minY - 24 - 15, width: view.frame.width - 32, height: 20)
        reminderLabel.font = .systemFont(ofSize: 16, weight: .medium)
        reminderLabel.text = "Scroll up to continue"
        reminderLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        reminderLabel.textAlignment = .center
        
        firstView.frame = scrollView.bounds
        firstView.frame.origin.y = 0
        secondView.frame = scrollView.bounds
        secondView.frame.origin.y = firstView.frame.maxY
        
        let label = UILabel(frame: CGRect(x: 16, y: safeArea.top + 64, width: view.frame.width - 32, height: 36))
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = "Keep scrolling! There will be a brief tutorial here later on."
        label.numberOfLines = 2
        label.sizeToFit()
        label.frame.size.width = view.frame.width - 32
        label.textColor = .white
        label.textAlignment = .center
        
        view.addSubview(imageView)
        view.addSubview(scrollView)
        
        scrollView.addSubview(firstView)
        scrollView.contentSize.height += firstView.frame.height
        scrollView.addSubview(secondView)
        scrollView.contentSize.height += secondView.frame.height
        
        firstView.addSubview(logoView)
        firstView.addSubview(titleView)
        firstView.addSubview(subtitleView)
        scrollView.addSubview(arrow)
        scrollView.addSubview(reminderLabel)
        
        secondView.addSubview(buttonView)
        secondView.addSubview(label)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func start() {
        statusBar = interface.statusBarStyle
        interface.setStatusBar(.light)
        titleView.frame.origin.y -= 32
        subtitleView.frame.origin.y -= 32
        UIView.animate(withDuration: 0.5, delay: 0.25, options: [], animations: {
            self.titleView.frame.origin.y += 32
            self.subtitleView.frame.origin.y += 32
            self.titleView.alpha = 1
            self.subtitleView.alpha = 1
            self.buttonView.alpha = 1
        }, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        firstView.alpha = 1 - offset / 100
        secondView.alpha = (offset - 100) / 100
        arrow.alpha = 1 - offset / 100
        arrow.frame.origin.y = scrollView.frame.height - 25 - 20 - safeArea.bottom + limit(offset/2, min: 0)
        reminderLabel.frame.origin.y = arrow.frame.minY - 24 - 15
        let transform = limit(1 - offset/750, max: 1)
        firstView.transform = CGAffineTransform(scaleX: transform, y: transform)
        showReminder = false
        reminderTimer.invalidate()
        if offset == 0 {
            reminderTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: false, block: { (timer) in
                self.showReminder = true
            })
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func buttonWasPressed() {
        UIView.animate(withDuration: 0.125) {
            self.buttonView.alpha = 0.5
        }
    }
    
    @objc func buttonWasReleased() {
        UIView.animate(withDuration: 0.125) {
            self.buttonView.alpha = 1
        }
    }

}
