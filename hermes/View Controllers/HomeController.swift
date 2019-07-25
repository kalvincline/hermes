//
//  HomeViewController.swift
//  hermes
//
//  Created by Aidan Cline on 6/3/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit

class Home: NavigationController {
    
    override func viewDidLoad() {
        root = HomeViewController()
        super.viewDidLoad()
    }
    
}

class HomeViewController: BaseViewController {
    
    let loadingIndicator = UIActivityIndicatorView()
    let errorMessageView = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        showBackButton = false
        load()
    }
    
    func load() {
        scrollView.removeAllSubviews()
        scrollView.addSubview(headerDivider)
        
        loadingIndicator.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: 100)
        loadingIndicator.startAnimating()
        scrollView.addSubview(loadingIndicator)
        
        let request = InvidiousTrending()
        request.getData {
            self.loadingIndicator.frame.size.height = 0
            self.scrollView.alignSubviews()
            self.scrollView.removeSubview(self.loadingIndicator)
            if let videos = request.videos {
                if videos.count > 0 {
                    for video in videos {
                        let view = VideoView(frame: CGRect(x: 0, y: 0, width: self.scrollView.frame.width, height: 0))
                        self.scrollView.addGap(height: 16)
                        self.scrollView.addSubview(view)
                        view.isIndividual = true
                        view.video = video
                        view.onFrameChange = {
                            self.scrollView.alignSubviews()
                        }
                        if video.identifier == videos.last?.identifier {
                            self.scrollView.addGap(height: 16)
                        }
                        self.scrollView.alignSubviews()
                    }
                } else {
                    self.error()
                }
            } else {
                self.error()
            }
        }
    }
    
    func error() {
        errorMessageView.font = .systemFont(ofSize: 16, weight: .semibold)
        errorMessageView.textAlignment = .center
        errorMessageView.numberOfLines = 2
        errorMessageView.frame = CGRect(x: 16, y: 0, width: scrollView.frame.width, height: 40)
        errorMessageView.text = "Big oof, there was an error getting trending videos"
        scrollView.addSubview(errorMessageView)
    }
    
    override func setThemes() {
        super.setThemes()
        errorMessageView.textColor = interface.textColor.withAlphaComponent(0.5)
        guard #available(iOS 13, *) else {
            loadingIndicator.style = interface.loadingIndicatorStyle
            return
        }
    }
    
}
