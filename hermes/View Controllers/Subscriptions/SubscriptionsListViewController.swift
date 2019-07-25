//
//  SubscriptionsListViewController.swift
//  hermes
//
//  Created by Aidan Cline on 5/24/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit

class SubscriptionsListViewController: BaseViewController {
    
    let loadingIndicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Subscriptions"
        largeTitle = false
        showBackButton = true

        loadingIndicator.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: 75)
        scrollView.addSubview(loadingIndicator)

        let subscriptionsHandler = YTSubscriptions()
        subscriptionsHandler.sort = .alphabetical
        subscriptionsHandler.maxResults = 50
        subscriptionsHandler.getUserSubscriptions {
            self.scrollView.removeSubview(self.loadingIndicator)
            //subscriptions = [String]()
            if subscriptionsHandler.list.count != 0 {
                self.scrollView.addGap(height: 8)
                for subscription in subscriptionsHandler.list.reversed() {
                    let view = ChannelView(frame: self.scrollView.bounds, channel: InvidiousChannel(identifier: subscription.identifier))
                    view.isIndividual = false
                    self.scrollView.addGap(height: 8)
                    self.scrollView.addSubview(view)
                }
                self.scrollView.addGap(height: 16)
            }
        }

        NotificationCenter.default.addObserver(forName: .signedOut, object: nil, queue: .main) { (notification) in
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    override func setThemes() {
        super.setThemes()
        loadingIndicator.style = interface.loadingIndicatorStyle
    }

}
