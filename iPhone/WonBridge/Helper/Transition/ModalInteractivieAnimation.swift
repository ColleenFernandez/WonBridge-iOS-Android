//
//  ModalInteractivieAnimation.swift
//  WonBridge
//
//  Created by July on 2016-10-04.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

enum InteractiveDirection: Int {
    case horizental
    case vertical
}

class ModalInteractiveAnimation: UIPercentDrivenInteractiveTransition {
    
    var direction:InteractiveDirection
    var interacting:Bool = false
    private var shouldComplete:Bool = false
    private var presentingViewController:UIViewController? = nil
    override var percentComplete: CGFloat {
        get {
            return 1 - self.percentComplete
        }
    }
    
    init(direction: InteractiveDirection) {
        self.direction = direction
    }
    
    func wireToViewController(viewController:UIViewController) {
        presentingViewController = viewController
        prepareGestureRecognizeInView(viewController.view)
    }
    
    func prepareGestureRecognizeInView(view:UIView) {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        view.addGestureRecognizer(gesture)
    }
    
    func handleGesture(gestureRecoginizer:UIPanGestureRecognizer) {
        let trainsiton = gestureRecoginizer.translationInView(gestureRecoginizer.view!.superview!)
        switch gestureRecoginizer.state {
        case UIGestureRecognizerState.Began:
            interacting = true
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        case UIGestureRecognizerState.Changed:
            var fraction = direction == InteractiveDirection.horizental ? trainsiton.x/320 : trainsiton.y/400
            fraction = fmax(fraction, 0.0)
            fraction = fmin(fraction, 1)
            shouldComplete = fraction > 0.5
            updateInteractiveTransition(fraction)
        case UIGestureRecognizerState.Ended:
            fallthrough
        case UIGestureRecognizerState.Cancelled:
            interacting = false
            if !shouldComplete || gestureRecoginizer.state == UIGestureRecognizerState.Cancelled {
                cancelInteractiveTransition()
            }
            else {
                finishInteractiveTransition()
            }
        default:
            break
        }
    }
}