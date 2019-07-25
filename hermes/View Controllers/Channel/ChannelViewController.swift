//
//  ChannelController.swift
//  hermes
//
//  Created by Aidan Cline on 6/20/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit

class ChannelViewController: UIViewController, UIScrollViewDelegate {
    
    var isUsingBanner = false {
        didSet {
            if isUsingBanner {
                header.alpha = (offset - 50) / 46
                roundBackButton.alpha = 1
                bannerView.frame.size.height = 96 + safeArea.top
                bannerView.alpha = 1
                scrollView.alignSubviews()
                bannerImageView.frame.size.height = limit(bannerView.frame.height - offset, min: 0)
                bannerImageView.frame.origin.y = offset
                scrollView.alignSubviews()
            } else {
                header.alpha = 1
                roundBackButton.alpha = 0
                bannerView.frame.size.height = 50 + safeArea.top
                bannerView.alpha = 0
                bannerImageView.frame.size.height = safeArea.top + 50
                bannerImageView.frame.origin.y = 0
                scrollView.alignSubviews()
            }
            
            if header.alpha >= 0.25 {
                setStatusBar(settings.interfaceStyle == .light ? .dark : .light)
            } else {
                setStatusBar(.light)
            }
            
            if header.alpha >= 0.125 && roundBackButton.frame.origin.x != -roundBackButton.frame.width {
                UIView.animate(withDuration: 0.125) {
                    self.roundBackButton.frame.origin.x = -self.roundBackButton.frame.width
                }
            } else if header.alpha <= 0.125 && roundBackButton.frame.origin.x != 16 {
                UIView.animate(withDuration: 0.125) {
                    self.roundBackButton.frame.origin.x = 16
                }
            }
        }
    }
    
    var featuredVideo: InvidiousVideo? {
        didSet {
            if featuredVideo != nil {
                titleView.backgroundColor = interface.contentColor
            } else {
                titleView.backgroundColor = interface.backgroundColor
            }
        }
    }
    
    var channel: InvidiousChannel? {
        didSet {
            update()
        }
    }
    
    let scrollView = GroupScrollView()
    
    let header = UIVisualEffectView()
    let backButton = UIButton()
    let roundBackButton = UIButton()
    
    let bannerView = UIView()
    let bannerImageView = UIImageView()
    let bannerGradient = UIGradientView()
    let titleView = UIView()
    let titleLabel = UILabel()
    let featuredVideoView = UIGradientView()
    
    let uploadsTitle = UILabel()
    
    let loadingIndicator = UIActivityIndicatorView()
    let videoLoadingIndicator = UIActivityIndicatorView()
    
    convenience init() {
        self.init(channel: nil)
    }
    
    init(channel: InvidiousChannel?) {
        super.init(nibName: nil, bundle: nil)
        self.channel = channel
        update()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        navigationController?.interactivePopGestureRecognizer?.isEnabled = !(
            self == navigationController?.viewControllers[0])
        view.clipsToBounds = true
        view.addSubview(scrollView)
        view.addSubview(header)
        header.contentView.addSubview(backButton)
        view.addSubview(roundBackButton)
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true
        
        backButton.setImage(UIImage(named: "arrow-left"), for: .normal)
        backButton.tintColor = interface.tintColor
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.addTarget(self, action: #selector(self.backButtonTouchDown(_:)), for: .touchDown)
        backButton.addTarget(self, action: #selector(self.backButtonTouchUp(_:)), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(self.backButtonCancel(_:)), for: .touchUpOutside)
        backButton.addTarget(self, action: #selector(self.backButtonCancel(_:)), for: .touchDragOutside)
        
        roundBackButton.setImage(UIImage(named: "back arrow"), for: .normal)
        roundBackButton.tintColor = .white
        roundBackButton.imageView?.contentMode = .scaleAspectFit
        roundBackButton.addTarget(self, action: #selector(self.backButtonTouchDown(_:)), for: .touchDown)
        roundBackButton.addTarget(self, action: #selector(self.backButtonTouchUp(_:)), for: .touchUpInside)
        roundBackButton.addTarget(self, action: #selector(self.backButtonCancel(_:)), for: .touchUpOutside)
        roundBackButton.addTarget(self, action: #selector(self.backButtonCancel(_:)), for: .touchDragOutside)
        
        titleView.addSubview(titleLabel)
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        
        bannerView.addSubview(bannerImageView)
        bannerImageView.contentMode = .scaleAspectFill
        bannerImageView.clipsToBounds = true
        bannerGradient.colors = [UIColor.black.withAlphaComponent(0.25).cgColor, UIColor.clear.cgColor]
        bannerGradient.locations = [0, 0.5]
        bannerView.addSubview(bannerGradient)
        scrollView.addSubview(bannerView)
        scrollView.addSubview(titleView)
        updateThemes(animated: false)
        
        scrollViewDidScroll(scrollView)
        
        NotificationCenter.default.addObserver(forName: .themeChanged, object: nil, queue: .main) { (notification) in
            self.updateThemes(animated: true)
        }
        
        NotificationCenter.default.addObserver(forName: .changeDrawer, object: nil, queue: .main) { _ in
            self.scrollView.contentInset.bottom = safeArea.bottom + 50 + (drawerState != .closed ? 80 : 0)
            self.scrollView.scrollIndicatorInsets.bottom = self.scrollView.contentInset.bottom
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        scrollView.frame.size.width /= 2
        scrollView.frame.size.height /= 2
        scrollView.contentInset.bottom = safeArea.bottom + 50 + (drawerState != .closed ? 80 : 0)
        scrollView.scrollIndicatorInsets.top = isUsingBanner ? limit(bannerImageView.frame.height, min: safeArea.top + 50) : safeArea.top + 50
        scrollView.scrollIndicatorInsets.bottom = scrollView.contentInset.bottom
        
        header.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: 50 + safeArea.top)
        backButton.frame = CGRect(x: 16, y: 10 + safeArea.top, width: 25, height: 30)
        roundBackButton.frame = CGRect(x: 16, y: 10 + safeArea.top, width: 30, height: 30)
        
        titleView.frame.size.width = scrollView.frame.width
        titleView.frame.size.height = 50
        
        titleLabel.frame = CGRect(x: 16, y: 0, width: titleView.frame.width - 32, height: titleView.frame.height)
        
        bannerView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: (isUsingBanner) ? (96 + safeArea.top) : (50 + safeArea.top))
        bannerImageView.frame.size.width = bannerView.frame.width
        bannerGradient.frame = bannerView.bounds
        scrollView.alignSubviews()
    }
    
    func update() {
        if let channel = channel {
            
            if let title = channel.title {
                titleLabel.text = title
            } else {
                let channel = InvidiousChannel(identifier: channel.identifier)
                channel.getData(fields: [.title]) {
                    self.titleLabel.text = channel.title
                }
            }
            
            if let bannerURL = channel.banners?.medium {
                URLDataHandler.downloadImage(url: URL(string: bannerURL)!) { (image) in
                    self.setBanner(image)
                }
            } else {
                let channel = InvidiousChannel(identifier: channel.identifier)
                channel.getData(fields: [.banners]) {
                    if let bannerURL = channel.banners?.medium {
                        URLDataHandler.downloadImage(url: URL(string: bannerURL)!) { (image) in
                            self.setBanner(image)
                        }
                    }
                }
            }
        }
    }
    
    func setBanner(_ image: UIImage?) {
        if let image = image {
            let imageWidth = image.size.width
            let viewWidth = scrollView.frame.width
            bannerImageView.image = image.crop(rect: CGRect(x: limit(imageWidth - viewWidth * (image.size.height / (96 + safeArea.top)), min: 0)/2, y: 0, width: viewWidth * (image.size.height / (96 + safeArea.top)), height: image.size.height))
        }
        isUsingBanner = image != nil
    }
    
    var offset: CGFloat {
        return scrollView.contentOffset.y + scrollView.contentInset.top
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isUsingBanner {
            header.alpha = (offset - 50) / 46
            bannerImageView.frame.size.height = limit(bannerView.frame.height - offset, min: 0)
            bannerImageView.frame.origin.y = offset
        } else {
            header.alpha = 1
            bannerImageView.frame.size.height = safeArea.top + 50
            bannerImageView.frame.origin.y = 0
        }
        
        if settings.interfaceStyle == .black {
            header.contentView.backgroundColor = UIColor.black.withAlphaComponent(1 - offset / 16)
        } else {
            header.contentView.backgroundColor = interface.blurEffectBackground
        }
        
        bannerGradient.frame.origin.y = bannerImageView.frame.origin.y
        scrollView.scrollIndicatorInsets.top = limit(bannerImageView.frame.height, min: safeArea.top + 50)
        
        if header.alpha >= 0.125 && roundBackButton.frame.origin.x != -roundBackButton.frame.width {
            UIView.animate(withDuration: 0.125) {
                self.roundBackButton.frame.origin.x = -self.roundBackButton.frame.width
            }
        } else if header.alpha <= 0.125 && roundBackButton.frame.origin.x != 16 {
            UIView.animate(withDuration: 0.125) {
                self.roundBackButton.frame.origin.x = 16
            }
        }
        
        if header.alpha >= 0.25 {
            setStatusBar(settings.interfaceStyle == .light ? .dark : .light)
        } else {
            setStatusBar(.light)
        }
        
        let loadingDistance: CGFloat = 800
        if offset + scrollView.frame.height >= scrollView.contentSize.height - loadingDistance {
            loadVideos()
        }
    }
    
    var isLoading = false {
        didSet {
            if isLoading {
                videoLoadingIndicator.transform = CGAffineTransform(scaleX: 1, y: 1)
                videoLoadingIndicator.alpha = 1
                videoLoadingIndicator.frame = CGRect(x: 16, y: 0, width: scrollView.frame.width - 32, height: 50)
                videoLoadingIndicator.startAnimating()
                scrollView.addSubview(videoLoadingIndicator)
            } else {
                videoLoadingIndicator.stopAnimating()
                scrollView.removeSubview(videoLoadingIndicator)
            }
        }
    }
    
    var videosPage = 0
    var videos: [String] = []
    
    func loadVideos() {
        if !isLoading {
            isLoading = true
            videosPage += 1
            channel?.getVideos(page: videosPage, {
                var isFinished = false
                if let videos = self.channel?.videos {
                    for video in videos {
                        if self.videos.contains(video.identifier!) {
                            isFinished = true
                            break
                        } else {
                            self.videos.append(video.identifier!)
                            let view = SmallVideoView(frame: CGRect(x: 0, y: 0, width: self.scrollView.frame.width, height: 0))
                            view.video = video
                            view.isIndividual = false
                            view.showChannel = false
                            self.scrollView.addSubview(view)
                            self.scrollView.addGap(height: 8)
                        }
                    }
                }
                if !isFinished {
                    self.isLoading = false
                } else {
                    self.scrollView.removeSubview(self.videoLoadingIndicator)
                }
            })
        }
    }
    
    func updateThemes(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.25 : 0) {
            self.setThemes()
        }
    }
    
    func setThemes() {
        featuredVideoView.colors = [interface.contentColor.cgColor, interface.backgroundColor.cgColor]
        featuredVideoView.locations = [0, 1]
        header.effect = interface.blurEffect
        header.contentView.backgroundColor = interface.blurEffectBackground
        view.backgroundColor = interface.backgroundColor
        titleView.backgroundColor = featuredVideo != nil ? interface.contentColor : interface.backgroundColor
        titleLabel.textColor = interface.textColor
        if header.alpha >= 0.25 {
            setStatusBar(settings.interfaceStyle == .light ? .dark : .light)
        } else {
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
        button.cancelTracking(with: nil)
        backButtonTimer?.invalidate()
        backButtonTimer = nil
    }
    
    @objc func backButtonCancel(_ button: UIButton) {
        button.cancelTracking(with: nil)
        backButtonTimer?.invalidate()
        backButtonTimer = nil
    }
    
    func setStatusBar(_ style: ApplicationInterface.UIStatusBarStyles) {
        if let navigationController = navigationController as? NavigationController {
            navigationController.statusBarStyle = style
        }
    }

}

extension UIImage {
    func crop(rect: CGRect) -> UIImage {
        var rect = rect
        rect.origin.x *= self.scale
        rect.origin.y *= self.scale
        rect.size.width *= self.scale
        rect.size.height *= self.scale
        
        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
}

extension Array {
    
    func contains<T: Equatable>(_ element: T) -> Bool {
        var result = false
        if let array = self as? [T] {
            for e in array {
                if e == element {
                    result = true
                    break
                }
            }
        }
        return result
    }
    
}
