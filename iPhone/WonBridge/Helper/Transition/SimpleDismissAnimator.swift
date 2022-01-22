//
//  SimpleDismissAnimator.swift
//  WonBridge
//
//  Created by July on 2016-10-04.
//  Copyright © 2016 elitedev. All rights reserved.
//

class SimpleDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.25
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        
        let screenBounds = UIScreen.mainScreen().bounds
        
        let containerView = transitionContext.containerView()
        toViewController?.view.frame = screenBounds
        containerView!.addSubview((toViewController?.view)!)
        containerView!.sendSubviewToBack((toViewController?.view)!)
        
        UIView.animateWithDuration(transitionDuration(transitionContext),
                                   delay: 0.0,
                                   options: UIViewAnimationOptions.CurveEaseIn,
                                   animations: { () -> Void in
                                    fromViewController?.view.frame = CGRectOffset(screenBounds, screenBounds.size.width, 0)
            },
                                   completion: { (finished) -> Void in
                                    let cancelled = transitionContext.transitionWasCancelled()
                                    transitionContext.completeTransition(!cancelled)
                                    if cancelled {
                                        toViewController?.view.removeFromSuperview()
                                    }
        })
    }
}
