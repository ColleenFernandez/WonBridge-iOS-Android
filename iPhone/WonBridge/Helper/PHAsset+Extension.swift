//
//  PHAsset+Extension.swift
//  WonBridge
//
//  Created by July on 2016-09-24.
//  Copyright © 2016 elitedev. All rights reserved.
//

import Foundation
import Photos

extension PHAsset {
    func getUIImage() -> UIImage? {
        let manager = PHImageManager.defaultManager()
        let options = PHImageRequestOptions()
        options.synchronous = true
        options.networkAccessAllowed = true
        options.version = .Current
        options.deliveryMode = .HighQualityFormat
        options.resizeMode = .Exact
        
        var image: UIImage?
        manager.requestImageForAsset(
            self,
            targetSize: CGSize(width: CGFloat(self.pixelWidth), height: CGFloat(self.pixelHeight)),
            contentMode: .AspectFill,
            options: options,
            resultHandler: {(result, info)->Void in
                if let theResult = result {
                    image = theResult
                } else {
                    image = nil
                }
        })
                
        return image
    }
    
    
}