//
//  AppDelegate.swift
//  hermes
//
//  Created by Aidan Cline on 1/30/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit
import StoreKit
import GoogleSignIn
import FirebaseCore
import SwiftyStoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?
    let viewController = MainViewController()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        FIRConfiguration.sharedInstance()?.setLoggerLevel(.min)
        FIRApp.configure(with: .init(contentsOfFile: Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")))
        GIDSignIn.sharedInstance()?.clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self
        
        SwiftyStoreKit.completeTransactions { (purchases) in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    settings.pro = purchase.productId == "com.aidancline.hermes.proversion"
                case .failed, .purchasing, .deferred:
                    settings.pro = false
                @unknown default:
                    break
                }
            }
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: false)
        let items = (urlComponents?.queryItems)! as [NSURLQueryItem]
        if settings.userHasViewedTutorial {
            if url.scheme == "hermes" {
                if let _ = items.first, let propertyName = items.first?.name, let propertyValue = items.first?.value {
                    if propertyName == "video" || propertyName == "v" {
                        openVideo(identifier: propertyValue)
                    }
                    if propertyName == "channel" || propertyName == "c" {
                        let viewController = ChannelViewController()
                        viewController.channel = InvidiousChannel(identifier: propertyValue)
                        openViewController(viewController)
                    }
                    if propertyName == "url" {
                        _ = openInHermes(URL(string: propertyValue)!)
                    }
                }
            } else if url.scheme == "com.googleusercontent.apps.529525107786-mofk76gcfa96lheblu78angl8n5rc9u6" {
                return GIDSignIn.sharedInstance().handle(url as URL?, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
            }
        }
        return true
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("GIDSignIn error: \(error.localizedDescription)")
            settings.signedIn = false
        } else {
            settings.signedIn = true
            settings.userAccessToken = user.authentication.accessToken
            settings.userRefreshToken = user.authentication.refreshToken
            settings.tokenExpireDate = user.authentication.accessTokenExpirationDate.timeIntervalSince1970
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        NotificationCenter.default.post(name: .enteredBackground, object: nil)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        NotificationCenter.default.post(name: .enteredForeground, object: nil)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

func openInHermes(_ url: URL) -> Bool {
    let urlString = url.absoluteString
    if urlString.contains("youtube.com/watch") {
        if let index = urlString.firstIndex(of: "?") {
            let firstIndex = urlString.index(index, offsetBy: 3)
            let lastIndex = urlString.index(firstIndex, offsetBy: 10)
            let substring = urlString[firstIndex...lastIndex]
            openVideo(identifier: String(substring))
        }
        return true
    } else if urlString.contains("youtube.com/channel") {
        
    } else if urlString.contains("youtu.be") {
        let dataTask = URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: {
            _, response, _ in
            if let expandedURL = response?.url {
                _ = openInHermes(expandedURL)
            }
        })
        dataTask.resume()
        return true
    } else {
        return false
    }
    
    return true
}
