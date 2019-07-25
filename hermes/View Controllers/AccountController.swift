//
//  AccountController.swift
//  hermes
//
//  Created by Aidan Cline on 2/1/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit
import GoogleSignIn

class Account: NavigationController {
    
    override func viewDidLoad() {
        root = AccountViewController()
        super.viewDidLoad()
        view.frame.size = CGSize(width: view.frame.width / 2, height: view.frame.height / 2)
    }
    
}

class AccountViewController: BaseViewController, GIDSignInUIDelegate {
    
    let signInButton = UIButton(type: .roundedRect)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Account"
        showBackButton = false
        let settingsCell = CellButton(frame: CGRect(x: 0, y: 0, width: scrollView.frame.width - 32, height: 50))
        settingsCell.title = "Settings"
        settingsCell.showNavigationIndicator = true
        settingsCell.isButtonActive = true
        settingsCell.onTap = {
            openViewController(SettingsController())
        }
        
        let settingsGroup = CellGroup(frame: CGRect(x: 0, y: 0, width: scrollView.frame.width, height: 50))
        settingsGroup.addCell(settingsCell)
        
        scrollView.addGap(height: 16)
        scrollView.addSubview(settingsGroup)
        
        GIDSignIn.sharedInstance()?.uiDelegate = self
        if settings.userAccessToken != nil {
            if GIDSignIn.sharedInstance().hasAuthInKeychain() {
                signInSilently()
            } else {
                signIn()
            }
        }
        
        signInButton.frame = CGRect(x: 16, y: 0, width: scrollView.frame.width - 32, height: 50)
        signInButton.layer.cornerRadius = 20
        signInButton.clipsToBounds = true
        signInButton.backgroundColor = settings.signedIn ? .red : interface.tintColor
        signInButton.setTitleColor(.white, for: .normal)
        signInButton.setTitle(settings.signedIn ? "Sign out" : "Sign in", for: .normal)
        signInButton.contentHorizontalAlignment = .center
        signInButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        
        signInButton.addTargetClosure { (button) in
            if settings.signedIn {
                self.updateButton()
                let alert = UIAlertController(title: "Are you sure you want to sign out?", message: "You won't be able to do things like vote on videos or subscribe to channels.", preferredStyle: .alert)
                let signInAction = UIAlertAction(title: "Yeah, sign me out", style: .destructive, handler: { (action) in
                    signOut()
                })
                let closeAction = UIAlertAction(title: "Nope, keep me signed in", style: .cancel, handler: nil)
                alert.addAction(signInAction)
                alert.addAction(closeAction)
                alert.view.tintColor = interface.tintColor
                self.present(alert, animated: true)
            } else {
                signIn()
            }
        }
        
        updateButton()
        
        scrollView.addGap(height: 16)
        scrollView.addSubview(signInButton)
        
        NotificationCenter.default.addObserver(forName: .signedIn, object: nil, queue: .main) { (notification) in
            self.updateButton()
        }
    }
    
    func updateButton() {
        UIView.animate(withDuration: 0.25, animations: {
            if !(settings.signedIn && self.signInButton.title(for: .normal) == "Sign out") {
                self.signInButton.alpha = 0
            }
        }, completion: { complete in
            UIView.animate(withDuration: 0.25) {
                self.signInButton.alpha = 1
                self.signInButton.backgroundColor = settings.signedIn ? .red : interface.tintColor
                self.signInButton.setTitle(settings.signedIn ? "Sign out" : "Sign in", for: .normal)
            }
        })
    }
    
    override func setThemes() {
        super.setThemes()
        signInButton.backgroundColor = interface.contentColor
    }
    
    struct HTTPField {
        var value: String
        var header: String
    }

    func performPostRequest(targetURL: URL!, body: [HTTPField]?, completion: @escaping (_ data: Data, _ HTTPStatusCode: Int, _ error: Error?) -> Void) {
        let session = URLSession(configuration: .default)
        var request = URLRequest(url: targetURL)
        request.httpMethod = "POST"
        if let body = body {
            for field in body {
                request.addValue(field.value, forHTTPHeaderField: field.header)
            }
        }
        let task = session.dataTask(with: request) { (data: Data!, response: URLResponse!, error: Error!) in
            DispatchQueue.global(qos: .default).async {
                completion(data, (response as! HTTPURLResponse?)?.statusCode ?? -1, error)
            }
        }
        task.resume()
    }

}

func signInSilently() {
    let ytScopes = [
        "https://www.googleapis.com/auth/youtube",
        "https://www.googleapis.com/auth/youtube.force-ssl",
        "https://www.googleapis.com/auth/youtube.readonly"
    ]
    
    let scopes = GIDSignIn.sharedInstance().scopes
    GIDSignIn.sharedInstance().scopes = scopes! + ytScopes
    GIDSignIn.sharedInstance().signInSilently()
}

func signIn() {
    let ytScopes = [
        "https://www.googleapis.com/auth/youtube",
        "https://www.googleapis.com/auth/youtube.force-ssl",
        "https://www.googleapis.com/auth/youtube.readonly"
    ]
    
    let scopes = GIDSignIn.sharedInstance().scopes
    GIDSignIn.sharedInstance().scopes = scopes! + ytScopes
    GIDSignIn.sharedInstance().signIn()
}

func signOut() {
    GIDSignIn.sharedInstance().signOut()
    settings.signedIn = false
    settings.userAccessToken = nil
    settings.userRefreshToken = nil
    NotificationCenter.default.post(name: .signedOut, object: nil)
}
