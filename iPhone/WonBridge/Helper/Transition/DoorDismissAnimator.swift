//
//  DoorDismissViewController.swift
//  WonBridge
//
//  Created by July on 2016-10-04.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class DoorDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 1.0;
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        
        let screenBounds = UIScreen.mainScreen().bounds
        let finalFrame = CGRectOffset(screenBounds, 0, screenBounds.size.height)
        fromViewController?.view.frame = finalFrame
        
        let upScreenShotView = fromViewController?.view.snapshotViewAfterScreenUpdates(true)
        upScreenShotView?.frame = screenBounds
        let bottomScreenShotView = fromViewController?.view.snapshotViewAfterScreenUpdates(true)
        bottomScreenShotView?.frame = screenBounds
        
        addTopMaskLayer(upScreenShotView!)
        addBottomMaskLayer(bottomScreenShotView!)
        
        let containerView = transitionContext.containerView()
        
        containerView!.addSubview((toViewController?.view)!)
        containerView!.sendSubviewToBack((toViewController?.view)!)
        containerView!.addSubview(bottomScreenShotView!)
        containerView!.addSubview(upScreenShotView!)
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext),
                                   delay: 0,
                                   options: UIViewAnimationOptions.CurveEaseInOut,
                                   animations: { () -> Void in
                                    upScreenShotView?.frame = CGRectOffset(screenBounds, 0, -screenBounds.size.height)
                                    bottomScreenShotView?.frame = CGRectOffset(screenBounds, 0, screenBounds.size.height)
            },
                                   completion: { (finished) -> Void in
                                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                                    if finished {
                                        upScreenShotView?.removeFromSuperview()
                                        bottomScreenShotView?.removeFromSuperview()
                                    }
                                    
                                    if transitionContext.transitionWasCancelled() {
                                        fromViewController?.view.frame = screenBounds
                                        toViewController?.view.removeFromSuperview()
                                    }
        })
    }
    
    func addTopMaskLayer(view:UIView) {
        let maskLayer = CALayer()
        maskLayer.frame = view.bounds
        let upLayer = CAShapeLayer()
        upLayer.frame = CGRectMake(0, 0, maskLayer.frame.size.width, maskLayer.frame.size.height/2.0)
        upLayer.path = UIBezierPath(rect: upLayer.bounds).CGPath
        upLayer.fillColor = UIColor.redColor().CGColor
        let bottomLayer = CAShapeLayer()
        bottomLayer.frame = CGRectMake(0, maskLayer.frame.size.height/2.0, maskLayer.frame.size.width, maskLayer.frame.size.height/2.0)
        maskLayer.addSublayer(upLayer)
        maskLayer.addSublayer(bottomLayer)
        view.layer.mask = maskLayer
    }
    
    func addBottomMaskLayer(view:UIView) {
        let maskLayer = CALayer()
        maskLayer.frame = view.bounds
        let upLayer = CAShapeLayer()
        upLayer.frame = CGRectMake(0, 0, maskLayer.frame.size.width, maskLayer.frame.size.height/2.0)
        let bottomLayer = CAShapeLayer()
        bottomLayer.frame = CGRectMake(0, maskLayer.frame.size.height/2.0, maskLayer.frame.size.width, maskLayer.frame.size.height/2.0)
        bottomLayer.path = UIBezierPath(rect: upLayer.bounds).CGPath
        bottomLayer.fillColor = UIColor.redColor().CGColor
        maskLayer.addSublayer(upLayer)
        maskLayer.addSublayer(bottomLayer)
        view.layer.mask = maskLayer
    }
}
