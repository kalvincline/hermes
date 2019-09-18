//
//  DrawerPresentationManager.swift
//  hermes
//
//  Created by Aidan Cline on 9/6/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit

class DrawerPresentationManager: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    var sourceView: UIView?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.375
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        let fromVC = transitionContext.viewController(forKey: .from) as! UITabBarController
        let fromView = fromVC.view!
        let toVC = transitionContext.viewController(forKey: .to)!
        let toView = toVC.view!
        
        toView.frame.origin.y = sourceView?.frame.origin.y ?? fromView.frame.height
        UIView.animate(withDuration: transitionDuration(using: transitionContext)) {
            toView.frame.origin.y = container.layoutMargins.top + 20
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
}

class DrawerDismissalManager: UIPercentDrivenInteractiveTransition, UIViewControllerTransitioningDelegate {
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self
    }

}
