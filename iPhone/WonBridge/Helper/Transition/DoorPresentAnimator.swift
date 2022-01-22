//
//  DoorPresentAnimator.swift
//  WonBridge
//
//  Created by July on 2016-10-04.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

class DoorPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 1.0;
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        
        let screenBounds = UIScreen.mainScreen().bounds
        let finalFrame = transitionContext.finalFrameForViewController(toViewController!)
        
        let upScreenShotView = toViewController?.view.snapshotViewAfterScreenUpdates(true)
        upScreenShotView?.frame = CGRectOffset(finalFrame, 0, -screenBounds.size.height)
        let bottomScreenShotView = toViewController?.view.snapshotViewAfterScreenUpdates(true)
        bottomScreenShotView?.frame = CGRectOffset(finalFrame, 0, screenBounds.size.height)
        
        addTopMaskLayer(upScreenShotView!)
        addBottomMaskLayer(bottomScreenShotView!)
        
        let containerView = transitionContext.containerView()
        containerView!.addSubview(upScreenShotView!)
        containerView!.addSubview(bottomScreenShotView!)
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext),
                                   delay: 0,
                                   options: UIViewAnimationOptions.CurveEaseInOut,
                                   animations: { () -> Void in
                                    upScreenShotView?.frame = finalFrame
                                    bottomScreenShotView?.frame = finalFrame
            },
                                   completion: { (finished) -> Void in
                                    transitionContext.completeTransition(true)
                                    if finished {
                                        let toView = toViewController?.view
                                        containerView!.addSubview(toView!)
                                        upScreenShotView?.removeFromSuperview()
                                        bottomScreenShotView?.removeFromSuperview()
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
