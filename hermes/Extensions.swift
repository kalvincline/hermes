//
//  Extensions.swift
//  hermes
//
//  Created by Aidan Cline on 8/24/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit
import GoogleSignIn

extension NSNumber {
    
    func formatUsingAbbrevation () -> String {
        let num = Int(truncating: self)
        let numFormatter = NumberFormatter()
        
        typealias Abbrevation = (threshold:Double, divisor:Double, suffix:String)
        let abbreviations:[Abbrevation] = [(0, 1, ""),
                                           (1_000.0, 1_000.0, "K"),
                                           (1_000_000.0, 1_000_000.0, "M"),
                                           (1_000_000_000.0, 1_000_000_000.0, "B")]
        
        let startValue = Double (abs(num))
        let abbreviation:Abbrevation = {
            var prevAbbreviation = abbreviations[0]
            for tmpAbbreviation in abbreviations {
                if (startValue < tmpAbbreviation.threshold) {
                    break
                }
                prevAbbreviation = tmpAbbreviation
            }
            return prevAbbreviation
        } ()
        
        let value = Double(num) / abbreviation.divisor
        numFormatter.positiveSuffix = abbreviation.suffix
        numFormatter.negativeSuffix = abbreviation.suffix
        numFormatter.allowsFloats = true
        numFormatter.minimumIntegerDigits = 1
        numFormatter.minimumFractionDigits = 0
        numFormatter.maximumFractionDigits = 1
        
        return numFormatter.string(from: NSNumber (value:value))!
    }
    
}

class ClosureWrapper: NSObject {
    let closure: UIButtonTargetClosure
    init(_ closure: @escaping UIButtonTargetClosure) {
        self.closure = closure
    }
}

class GestureClosureWrapper: NSObject {
    let closure: UIGestureClosure
    init(_ closure: @escaping UIGestureClosure) {
        self.closure = closure
    }
}

typealias UIGestureClosure = (UIGestureRecognizer) -> ()

extension UIGestureRecognizer {
    
    private struct AssociatedKeys {
        static var targetClosure = "targetClosure"
    }
    
    private var targetClosure: UIGestureClosure? {
        get {
            guard let closureWrapper = objc_getAssociatedObject(self, &AssociatedKeys.targetClosure) as? GestureClosureWrapper else { return nil }
            return closureWrapper.closure
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.targetClosure, GestureClosureWrapper(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func addTargetClosure(closure: @escaping UIGestureClosure) {
        targetClosure = closure
        addTarget(self, action: #selector(UIGestureRecognizer.closureAction))
    }
    
    @objc func closureAction() {
        guard let targetClosure = targetClosure else { return }
        targetClosure(self)
    }
    
}

typealias UIButtonTargetClosure = (UIButton) -> ()

extension UIButton {
    
    private struct AssociatedKeys {
        static var targetClosure = "targetClosure"
    }
    
    private var targetClosure: UIButtonTargetClosure? {
        get {
            guard let closureWrapper = objc_getAssociatedObject(self, &AssociatedKeys.targetClosure) as? ClosureWrapper else { return nil }
            return closureWrapper.closure
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.targetClosure, ClosureWrapper(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func addTargetClosure(closure: @escaping UIButtonTargetClosure) {
        targetClosure = closure
        addTarget(self, action: #selector(UIButton.closureAction), for: .touchUpInside)
    }
    
    @objc func closureAction() {
        guard let targetClosure = targetClosure else { return }
        targetClosure(self)
    }
}

extension UIView {
    var viewController: UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.viewController
        } else {
            return nil
        }
    }
}

func limit<T>(_ value: T, min small: T, max large: T) -> T where T: Comparable {
    return min(max(value, small), large)
}

func limit<T>(_ value: T, min small: T) -> T where T: Comparable {
    return max(value, small)
}

func limit<T>(_ value: T, max large: T) -> T where T: Comparable {
    return min(value, large)
}

/*var safeArea: UIEdgeInsets {
    return UIApplication.shared.windows[0].safeAreaInsets
}*/

var signInHandlers: [() -> Void] = []
var signOutHandlers: [() -> Void] = []
var isSignedIn: Bool {
    get {
        return UserDefaults.standard.bool(forKey: "isSignedIn")
    }
    set {
        UserDefaults.standard.set(newValue, forKey: "isSignedIn")
        for handler in (newValue ? signInHandlers : signOutHandlers) {
            handler()
        }
    }
}

func signOut() {
    GIDSignIn.sharedInstance().signOut()
    isSignedIn = false
    print("Signed out user")
    AppDelegate().setupShortcuts(user: nil)
}
