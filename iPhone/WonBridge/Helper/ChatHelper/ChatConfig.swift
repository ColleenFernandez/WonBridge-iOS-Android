//
//  ChatConfig.swift
//  WonBridge
//
//  Created by July on 2016-09-24.
//  Copyright © 2016 elitedev. All rights reserved.
//

import Foundation

let kSendImageMaxHW: CGFloat = 512

public class ChatConfig {
    /**
     获取缩略图的尺寸
     
     - parameter originalSize: 原始图的尺寸 size
     
     - returns: 返回的缩略图尺寸
     */
    class func getThumbImageSize(originalSize: CGSize) -> CGSize {
        
        let imageRealHeight = originalSize.height
        let imageRealWidth = originalSize.width
        
        var resizeThumbWidth: CGFloat
        var resizeThumbHeight: CGFloat
        /**
         *  1）如果图片的高度 >= 图片的宽度 , 高度就是最大的高度，宽度等比
         *  2）如果图片的高度 < 图片的宽度 , 以宽度来做等比，算出高度
         */
        if imageRealHeight >= imageRealWidth {
            let scaleWidth = imageRealWidth * kChatImageMaxHeight / imageRealHeight
            resizeThumbWidth = (scaleWidth > kChatImageMinWidth) ? scaleWidth : kChatImageMinWidth
            resizeThumbHeight = kChatImageMaxHeight
        } else {
            let scaleHeight = imageRealHeight * kChatImageMaxWidth / imageRealWidth
            resizeThumbHeight = (scaleHeight > kChatImageMinHeight) ? scaleHeight : kChatImageMinHeight
            resizeThumbWidth = kChatImageMaxWidth
        }
        
        return CGSizeMake(resizeThumbWidth, resizeThumbHeight)
    }
    
    class func getChatImageSize(originalSize: CGSize) -> CGSize {
        
        let imageRealHeight = originalSize.height
        let imageRealWidth = originalSize.width
        
        var resizeThumbWidth: CGFloat
        var resizeThumbHeight: CGFloat
        /**
         *  1）如果图片的高度 >= 图片的宽度 , 高度就是最大的高度，宽度等比
         *  2）如果图片的高度 < 图片的宽度 , 以宽度来做等比，算出高度
         */
        if imageRealHeight >= imageRealWidth {
            let scaleWidth = imageRealWidth * kSendImageMaxHW / imageRealHeight
            resizeThumbWidth = (scaleWidth > kChatImageMinWidth) ? scaleWidth : kChatImageMinWidth
            resizeThumbHeight = kSendImageMaxHW
        } else {
            let scaleHeight = imageRealHeight * kSendImageMaxHW / imageRealWidth
            resizeThumbHeight = (scaleHeight > kChatImageMinHeight) ? scaleHeight : kChatImageMinHeight
            resizeThumbWidth = kSendImageMaxHW
        }
        
        return CGSizeMake(resizeThumbWidth, resizeThumbHeight)
    }
}