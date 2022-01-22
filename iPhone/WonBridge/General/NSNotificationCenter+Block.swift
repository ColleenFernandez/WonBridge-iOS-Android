//
//  NSNotificationCenter+Block.swift
//  WonBridge
//
//  Created by July on 2016-09-20.
//  Copyright © 2016 elitedev. All rights reserved.
//

import Foundation

public extension NSNotificationCenter {
    
    func addObserver<T: AnyObject>(observer: T, name aName: String?, object anObject: AnyObject?, queue: NSOperationQueue? = NSOperationQueue.mainQueue(), handler: (observer: T, notification: NSNotification) -> Void) -> AnyObject {
        let observation = addObserverForName(aName, object: anObject, queue: queue) { [unowned observer] note in
            handler(observer: observer, notification: note)
        }
        
        ObservationRemover(observation).makeRetainedBy(observer)
        
        return observation
    }
}

private class ObservationRemover: NSObject {
    let observation: NSObjectProtocol
    
    init(_ obs: NSObjectProtocol) {
        observation = obs
        super.init()
    }
    
    func makeRetainedBy(owner: AnyObject) {
        observationRemoversForObject(owner).addObject(self)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(observation)
    }
}

private var ObservationRemoverKey: UnsafePointer<Void> = nil

private func observationRemoversForObject(object: AnyObject) -> NSMutableArray {
    if ObservationRemoverKey == nil {
        withUnsafePointer(&ObservationRemoverKey) { pointer in
            ObservationRemoverKey = UnsafePointer<Void>(pointer)
        }
    }
    
    var retainedRemovers = objc_getAssociatedObject(object, ObservationRemoverKey) as! NSMutableArray?
    if retainedRemovers == nil {
        retainedRemovers = NSMutableArray()
        objc_setAssociatedObject(object, ObservationRemoverKey, retainedRemovers, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
    return retainedRemovers!
}
