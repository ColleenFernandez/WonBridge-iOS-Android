//
//  WBMediaModel.swift
//  WonBridge
//
//  Created by Elite on 10/16/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import Photos

let PHOTO_LOADING_DID_END_NOTIFICATION      =   "PHOTO_LOADING_DID_END_NOTIFICATION"
let PHOTO_PROGRESS_NOTIFICATION             =   "PHOTO_PROGRESS_NOTIFICATION"

class WBMediaModel: NSObject {
    
    var image: UIImage?
    
    var loadingInProgress: Bool = false
    
    var asset: PHAsset?
    var assetImageRequestID: PHImageRequestID = PHInvalidImageRequestID
    var assetVideoRequestID: PHImageRequestID = PHInvalidImageRequestID
    var assetTargetSize: CGSize = CGSizeZero
    var isVideo: Bool = false
    var isSelected: Bool = false
    
    var _underlyingImage: UIImage?
    
    var underlyingImage: UIImage? {
        get {
            return _underlyingImage
        }
        set {
            self._underlyingImage = newValue
        }
    }
    
    override init() {
        super.init()
    }
    
    convenience init(asset: PHAsset, targetSize: CGSize) {
        
        self.init()
        self.asset = asset
        self.assetTargetSize = targetSize
        self.isVideo = asset.mediaType == PHAssetMediaType.Video
    }
    
    // cancel request
    func cancelAnyRequest() {
        
        cancelImageRequest()
        cancelVideoRequest()
    }
    
    func cancelImageRequest() {
        
        guard assetImageRequestID != PHInvalidImageRequestID else { return }
        
        PHImageManager.defaultManager().cancelImageRequest(assetImageRequestID)
        assetImageRequestID = PHInvalidImageRequestID
    }
    
    func cancelVideoRequest() {
        
        guard assetVideoRequestID != PHInvalidImageRequestID else { return }
        
        PHImageManager.defaultManager().cancelImageRequest(assetVideoRequestID)
        assetVideoRequestID = PHInvalidImageRequestID
    }
    
    func loadUnderlyingImageAndNotify() {
        
        guard !loadingInProgress else { return }
        loadingInProgress = true
        
        do {
            if self.underlyingImage != nil {
                self.imageLoadingComplete()
            } else {
                self.performLoadUnderlyingImageAndNotify()
            }
        }
    }
    
    func imageLoadingComplete() {
        // complete so notify
        loadingInProgress = false
        
        NSNotificationCenter.defaultCenter().postNotificationName(PHOTO_LOADING_DID_END_NOTIFICATION, object: self)
    }
    
    func performLoadUnderlyingImageAndNotify() {
        
        guard asset != nil else { return }
        
        performLoadingUnderlyingImageAndNotify(asset!, targetSize: assetTargetSize)
    }
    
    func performLoadingUnderlyingImageAndNotify(asset: PHAsset, targetSize: CGSize) {
        
        // get underlying image
        let options = PHImageRequestOptions()
        options.resizeMode = PHImageRequestOptionsResizeMode.Fast
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.HighQualityFormat
        options.synchronous = false
        options.progressHandler = { (progress, error, stop, info) in
            // do something with the returned parameters
            let dict: NSDictionary = ["progress": NSNumber(double: progress), "photo": self]
            NSNotificationCenter.defaultCenter().postNotificationName(PHOTO_PROGRESS_NOTIFICATION, object: dict)
        }
        
        assetImageRequestID = PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: assetTargetSize, contentMode: PHImageContentMode.AspectFit, options: options, resultHandler: { (result, info) in
            self.underlyingImage = result
            self.imageLoadingComplete()
        })
    }
}




