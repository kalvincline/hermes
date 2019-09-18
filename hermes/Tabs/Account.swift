//
//  Account.swift
//  hermes
//
//  Created by Aidan Cline on 8/21/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit
import GoogleSignIn

class AccountViewController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        pushViewController(AccountRoot(), animated: false)
        isNavigationBarHidden = true
    }
}

class AccountRoot: TemplateViewController, UITableViewDelegate, UITableViewDataSource, GIDSignInUIDelegate {
    
    var mainView: UITableView {
        return contentView as! UITableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.uiDelegate = self
        if isSignedIn {
            GIDSignIn.sharedInstance()?.signInSilently()
        }
        
        contentView = UITableView(frame: contentView.frame, style: .insetGrouped)
        mainView.backgroundColor = .clear
        mainView.delegate = self
        mainView.dataSource = self
        mainView.contentInset.top = 66
        mainView.contentInset.bottom = 50
        mainView.separatorInset.left = 32
        mainView.separatorInset.right = 32
        mainView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        title = "Account"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                
            }
        } else if indexPath.section == 1 {
            tableView.deselectRow(at: indexPath, animated: true)
            if isSignedIn {
                signOut()
            } else {
                GIDSignIn.sharedInstance().signIn()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "Settings"
            }
            
            cell.accessoryType = .disclosureIndicator
        } else if indexPath.section == 1 {
            cell.textLabel?.text = isSignedIn ? "Sign out" : "Sign in"
            cell.textLabel?.font = .systemFont(ofSize: cell.textLabel?.font.pointSize ?? 0, weight: .bold)
            cell.backgroundColor = isSignedIn ? .red : .secondarySystemGroupedBackground
            cell.textLabel?.textColor = .white
            signInHandlers.append {
                cell.backgroundColor = isSignedIn ? .red : tint
                cell.textLabel?.text = isSignedIn ? "Sign out" : "Sign in"
            }
            
            signOutHandlers.append {
                cell.backgroundColor = isSignedIn ? .red : tint
                cell.textLabel?.text = isSignedIn ? "Sign out" : "Sign in"
            }
        }
        
        return cell
    }
    
}
