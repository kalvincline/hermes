//
//  ActionViewController.swift
//  openInHermes
//
//  Created by Aidan Cline on 5/10/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var body: UITextView!
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let headerString = header.text
        let bodyString = body.text
        
        header.text = "Loading..."
        body.text = ""
        button.alpha = 0
        
        view.backgroundColor = (traitCollection.userInterfaceStyle == .dark) ? UIColor(white: 0.1, alpha: 1) : .white
        scrollView.contentSize = scrollView.bounds.size
        mainView.frame.origin.y = (scrollView.frame.height - mainView.frame.height)/2
            
        let item = extensionContext!.inputItems[0] as! NSExtensionItem
        let provider = item.attachments![0]
        if provider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
            provider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { (result, error) in
                if let error = error {
                    print(error)
                } else {
                    let url = result as? URL
                    if let urlString = url?.absoluteString {
                        if urlString.contains("youtube.com") || urlString.contains("youtu.be") {
                            self.close(withURL: URL(string: "hermes://?url=\(urlString)"))
                        } else {
                            self.header.text = headerString
                            self.body.text = bodyString
                            self.button.alpha = 1
                        }
                    }
                }
            }
        } else if provider.hasItemConformingToTypeIdentifier(kUTTypeText as String) {
            provider.loadItem(forTypeIdentifier: kUTTypeText as String, options: nil) { (result, error) in
                if let error = error {
                    print(error)
                } else {
                    let string = result as? String
                    if let urlString = string {
                        if urlString.contains("youtube.com") || urlString.contains("youtu.be") {
                            self.close(withURL: URL(string: "hermes://?url=\(urlString)"))
                        } else {
                            self.header.text = headerString
                            self.body.text = bodyString
                            self.button.alpha = 1
                        }
                    }
                }
            }
        }
    }
    
    func close(withURL url: URL?) {
        if let url = url {
            self.openURL(url)
        }
        extensionContext?.cancelRequest(withError: NSError(domain: String(), code: Int(), userInfo: nil))
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        close(withURL: nil)
    }
    
    func openURL(_ url: URL) {
        let selectorOpenURL = sel_registerName("openURL:")
        let context = NSExtensionContext()
        context.open(url, completionHandler: nil)
        
        var responder = self as UIResponder?
        
        while (responder != nil){
            if responder?.responds(to: selectorOpenURL) == true {
                responder?.perform(selectorOpenURL, with: url)
            }
            responder = responder!.next
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        view.backgroundColor = (traitCollection.userInterfaceStyle == .dark) ? UIColor(white: 0.1, alpha: 1) : .white
    }
    
}
