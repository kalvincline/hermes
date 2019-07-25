//
//  BaseViewController.swift
//  hermes
//
//  Created by Aidan Cline on 5/8/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, UIScrollViewDelegate {
    
    let titleLabel = UILabel()
    let header = UIVisualEffectView()
    let backButton = UIButton()
    
    let scrollView = GroupScrollView()
    let headerDivider = DividerLine()
    
    let refreshIndicator = UIActivityIndicatorView()

    private var completionBlocks = [(() -> Void)]()
    private var refreshHandlers = [(() -> Void)]()

    override var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var showBackButton = false {
        didSet {
            backButton.isHidden = !showBackButton
            if !largeTitle {
                titleLabel.frame.origin.x = 16 + backButton.frame.maxX
            } else {
                titleLabel.frame.origin.x = 16
            }
        }
    }

    var largeTitle = true {
        didSet {
            let height = (safeArea.top + ((largeTitle && scrollView.contentOffset.y <= 46) ? 96 : 50))
            header.frame.size.height = height
            scrollView.contentInset.top = height
            scrollView.scrollIndicatorInsets.top = height
        }
    }
    
    var showHeader = true {
        didSet {
            header.alpha = showHeader ? 1 : 0
        }
    }

    override func viewDidLoad() {
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        let height = (safeArea.top + ((largeTitle && scrollView.contentOffset.y <= 46) ? 96 : 50))
        let bottom = (drawerState != .closed) ? safeArea.top + 130 : safeArea.bottom + 50
        scrollView.frame = view.frame
        scrollView.delegate = self
        scrollView.keyboardDismissMode = .onDrag
        scrollView.alwaysBounceVertical = true
        scrollView.contentInset.top = height
        scrollView.scrollIndicatorInsets.top = height
        scrollView.contentInset.bottom = bottom
        scrollView.scrollIndicatorInsets.bottom = bottom
        view.addSubview(scrollView)

        header.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: 0)
        header.frame.size.height = safeArea.top + ((largeTitle && scrollView.contentOffset.y <= 46) ? 96 : 50)
        header.alpha = showHeader ? 1 : 0
        view.addSubview(header)
        
        backButton.setImage(UIImage(named: "arrow-left"), for: .normal)
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.tintColor = UIColor(named: "Light Tint")
        backButton.setTitleColor(UIColor(named: "Light Tint"), for: .normal)
        backButton.frame = CGRect(x: 16, y: 10 + safeArea.top, width: 25, height: 30)
        backButton.addTarget(self, action: #selector(self.backButtonTouchDown(_:)), for: .touchDown)
        backButton.addTarget(self, action: #selector(self.backButtonTouchUp(_:)), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(self.backButtonCancel(_:)), for: .touchUpOutside)
        backButton.addTarget(self, action: #selector(self.backButtonCancel(_:)), for: .touchDragOutside)
        view.addSubview(backButton)
        
        titleLabel.frame.origin.x = 16 + ((showBackButton && !largeTitle) ? backButton.frame.maxX : 0)
        titleLabel.frame.origin.y = header.frame.size.height - 16 - 28
        titleLabel.frame.size.width = header.frame.width - 16 - titleLabel.frame.origin.x
        titleLabel.frame.size.height = 35
        titleLabel.font = .systemFont(ofSize: (largeTitle ? 31 : 22), weight: .bold)
        header.contentView.addSubview(titleLabel)
        
        headerDivider.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: 1)
        scrollView.addSubview(headerDivider)
        
        setThemes()
        scrollViewDidScroll(scrollView)
        
        for block in completionBlocks {
            block()
            scrollView.setContentOffset(CGPoint(x: 0, y: -scrollView.contentInset.top), animated: false)
        }
        
        NotificationCenter.default.addObserver(forName: .themeChanged, object: nil, queue: .main) { (notification) in
            self.updateThemes(animated: true)
            self.setStatusBar((interface.style == .light) ? .dark : .light)
        }
        
        NotificationCenter.default.addObserver(forName: .changeDrawer, object: nil, queue: .main) { (notification) in
            if drawerState != .closed {
                self.scrollView.contentInset.bottom = 130 + safeArea.bottom
                self.scrollView.scrollIndicatorInsets.bottom = 130 + safeArea.bottom
            } else {
                self.scrollView.contentInset.bottom = 50 + safeArea.bottom
                self.scrollView.scrollIndicatorInsets.bottom = 50 + safeArea.bottom
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y + scrollView.contentInset.top
        
        if refreshHandlers.count > 0 {
            
        }
        
        if interface.style == .black {
            if largeTitle {
                header.contentView.backgroundColor = UIColor.black.withAlphaComponent((header.frame.height - safeArea.top - 50 - offset) / 46)
            } else {
                header.contentView.backgroundColor = UIColor.black.withAlphaComponent((header.frame.height - safeArea.top - 34 - offset) / 16)
            }
        }
        
        if largeTitle {
            header.frame.size.height = limit(safeArea.top + 96 - offset, min: safeArea.top + 50)
            titleLabel.font = titleLabel.font.withSize(limit(31 - offset * 0.25, min: 22, max: 36))
            titleLabel.frame.origin.y = header.frame.size.height - 16 - 28
            scrollView.scrollIndicatorInsets.top = limit(header.frame.height, min: safeArea.top + 96)
            if showBackButton {
                titleLabel.frame.origin.x = 16 + limit(offset/18.4 * backButton.frame.width, min: 0, max: backButton.frame.maxX)
            } else {
                titleLabel.frame.origin.x = 16
            }
        } else {
            header.frame.size.height = safeArea.top + 50 - limit(offset, max: 0)
            titleLabel.font = titleLabel.font.withSize(22)
            titleLabel.frame.origin.y = header.frame.size.height - 16 - 28
            scrollView.scrollIndicatorInsets.top = header.frame.height
            backButton.frame.origin.y = safeArea.top + 8 - limit(offset, max: 0)
            if showBackButton {
                titleLabel.frame.origin.x = 16 + backButton.frame.maxX
            } else {
                titleLabel.frame.origin.x = 16
            }
        }
    }

    func updateThemes(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.25 : 0) {
            self.setThemes()
        }
    }
    
    func setThemes() {
        header.effect = interface.blurEffect
        titleLabel.textColor = interface.textColor
        scrollView.indicatorStyle = interface.scrollIndicatorStyle
        view.backgroundColor = interface.backgroundColor
        if interface.style == .black {
            let offset = scrollView.contentInset.top + scrollView.contentOffset.y
            if largeTitle {
                header.contentView.backgroundColor = UIColor.black.withAlphaComponent((header.frame.height - safeArea.top - 50 - offset) / 46)
            } else {
                header.contentView.backgroundColor = UIColor.black.withAlphaComponent((header.frame.height - safeArea.top - 34 - offset) / 16)
            }
        } else {
            header.contentView.backgroundColor = interface.blurEffectBackground
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = !(self == navigationController?.viewControllers[0])
        switch interface.style {
        case .light:
            setStatusBar(.dark)
        default:
            setStatusBar(.light)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switch interface.style {
        case .light:
            setStatusBar(.dark)
        default:
            setStatusBar(.light)
        }
    }
    
    var backButtonTimer: Timer?
    
    @objc func backButtonTouchDown(_ button: UIButton) {
        backButtonTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (timer) in
            self.navigationController?.popToRootViewController(animated: true)
        })
    }
    
    @objc func backButtonTouchUp(_ button: UIButton) {
        navigationController?.popViewController(animated: true)
        backButton.cancelTracking(with: nil)
        backButtonTimer?.invalidate()
        backButtonTimer = nil
    }
    
    @objc func backButtonCancel(_ button: UIButton) {
        backButton.cancelTracking(with: nil)
        backButtonTimer?.invalidate()
        backButtonTimer = nil
    }

    func setStatusBar(_ style: ApplicationInterface.UIStatusBarStyles) {
        if let navigationController = navigationController as? NavigationController {
            navigationController.statusBarStyle = style
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate && largeTitle {
            let offset = scrollView.contentOffset.y + scrollView.contentInset.top
            let scroll = (scrollView.contentInset.top) * -1
            if offset / 46 <= 1.0 {
                scrollView.setContentOffset(CGPoint(x: 0, y: scroll), animated: true)
            }
        }
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return (drawerState != .fullscreen)
    }
    
    func addCompletionBlock(_ block: @escaping (() -> Void)) {
        completionBlocks.append(block)
    }
    
    func addRefreshHandler(_ block: @escaping (() -> Void)) {
        refreshHandlers.append(block)
    }

}
