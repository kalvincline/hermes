//
//  AppDelegate.swift
//  hermes
//
//  Created by Aidan Cline on 8/21/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseCore
import GoogleAPIClientForREST

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , GIDSignInDelegate {

    var window: UIWindow?
    let viewController = MainViewController()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        
        FIRConfiguration.sharedInstance()?.setLoggerLevel(.min)
        FIRApp.configure(with: FIROptions(contentsOfFile: Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")))
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        setupShortcuts(user: nil)
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.absoluteString == "com.googleusercontent.apps.60942394550-auudr87489l2052ktetai16lr99p0n33" {
            return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        } else {
            return true
        }
    }
    
    func setupShortcuts(user: GIDGoogleUser?) {
        let watchLater = UIApplicationShortcutItem(type: "com.aidancline.hermes.watchlater", localizedTitle: "Watch Later", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(systemImageName: "clock"), userInfo: nil)
        let subscriptions = UIApplicationShortcutItem(type: "com.aidancline.hermes.subscriptions", localizedTitle: "Subscriptions", localizedSubtitle: nil, icon: .init(systemImageName: "rectangle.stack"), userInfo: nil)
        var account = UIApplicationShortcutItem(type: "com.aidancline.hermes.account", localizedTitle: "Account", localizedSubtitle: nil, icon: .init(systemImageName: "person.crop.circle"), userInfo: nil)
        if let user = user {
            account = UIApplicationShortcutItem(type: "com.aidancline.hermes.account", localizedTitle: "Account", localizedSubtitle: user.profile.name, icon: .init(systemImageName: "person.crop.circle"), userInfo: nil)
        }
        let search = UIApplicationShortcutItem(type: "com.aidancline.hermes.search", localizedTitle: "Search", localizedSubtitle: nil, icon: .init(systemImageName: "magnifyingglass"), userInfo: nil)
        UIApplication.shared.shortcutItems = [watchLater, subscriptions, account, search]
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            isSignedIn = false
            setupShortcuts(user: nil)
        } else {
            isSignedIn = true
            print("Signed in with user \(user.profile.name!)")
            setupShortcuts(user: user)
        }
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if shortcutItem.type == "com.aidancline.hermes.watchlater" {
            shortcutHandler(.watchLater)
        } else if shortcutItem.type == "com.aidancline.hermes.subscriptions" {
            shortcutHandler(.subscriptions)
        } else if shortcutItem.type == "com.aidancline.hermes.account" {
            shortcutHandler(.account)
        } else if shortcutItem.type == "com.aidancline.hermes.search" {
            shortcutHandler(.search)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

