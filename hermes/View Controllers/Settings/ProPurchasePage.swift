//
//  ProPurchasePage.swift
//  Hermes for YouTube
//
//  Created by Aidan Cline on 6/26/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit
import SwiftyStoreKit

class ProPurchasePage: BaseViewController {
    
    let descriptionView = UITextView()
    let purchaseButton = UIButton(type: .roundedRect)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Hermes Pro"
        largeTitle = false
        showBackButton = true
        
        descriptionView.frame = CGRect(x: 16, y: 0, width: scrollView.frame.width - 32, height: 100)
        descriptionView.sizeToFit()
        descriptionView.frame.size.width = scrollView.frame.width - 32
        
        updateButton()
        
        purchaseButton.addTargetClosure { (button) in
            SwiftyStoreKit.purchaseProduct("proversion") { (result) in
                switch result {
                case .success(purchase: let purchase):
                    if purchase.productId == "com.aidancline.hermesforyoutube.proversion" {
                        let alert = UIAlertController(title: "You got Hermes Pro!", message: "Thanks so much for your support. Enjoy the app!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                        alert.view.tintColor = interface.tintColor
                        self.present(alert, animated: true)
                        UIHapticFeedback.generate(style: .successNotification)
                    }
                case .error(error: let error):
                    var message = "The App Store didn't return an error message."
                    switch error.code {
                    case .unknown: break
                    case .clientInvalid: message = "The client is invalid."
                    case .paymentCancelled: break
                    case .paymentInvalid: message = "The purchase identifier was invalid."
                    case .paymentNotAllowed: message = "You can't make payments on this device."
                    case .storeProductNotAvailable: message = "The purchase isn't available."
                    case .cloudServicePermissionDenied: message = "Permission to access the cloud service was denied."
                    case .cloudServiceNetworkConnectionFailed: message = "Couldn't connect to the network."
                    case .cloudServiceRevoked: message = "Permission to use this cloud service was revoked."
                    default: break
                    }
                    let alert = UIAlertController(title: "Couldn't make the purchase", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
                    alert.view.tintColor = interface.tintColor
                    self.present(alert, animated: true)
                    UIHapticFeedback.generate(style: .errorNotification)
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: .proVersionChanged, object: nil, queue: .main) { (notification) in
            self.updateButton()
        }
    }
    
    func updateButton() {
        if settings.pro {
            self.scrollView.removeSubview(self.purchaseButton)
        } else {
            self.purchaseButton.setTitle("Get Hermes Pro", for: .normal)
            self.purchaseButton.setTitleColor(.white, for: .normal)
            self.purchaseButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
            self.purchaseButton.frame = CGRect(x: 16, y: 0, width: self.scrollView.frame.width - 32, height: 50)
            self.purchaseButton.layer.cornerRadius = 20
            self.purchaseButton.backgroundColor = UIColor(red: 1, green: 2/3, blue: 0, alpha: 1)
            if self.purchaseButton.superview != self.scrollView {
                self.scrollView.addSubview(self.purchaseButton)
            }
        }
    }
    
}
