//
//  UILabel+Extension.swift
//  WonBridge
//
//  Created by July on 2016-09-24.
//  Copyright © 2016 elitedev. All rights reserved.
//

import Foundation

extension UILabel {
    func contentSize() -> CGSize {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = self.lineBreakMode
        paragraphStyle.alignment = self.textAlignment
        let attributes: [String : AnyObject] = [NSFontAttributeName: self.font, NSParagraphStyleAttributeName: paragraphStyle]
        let contentSize: CGSize = self.text!.boundingRectWithSize(
            self.frame.size,
            options: ([.UsesLineFragmentOrigin, .UsesFontLeading]),
            attributes: attributes,
            context: nil
            ).size
        return contentSize
    }
    
    func linesHeight(string: String, lines: Int, width: CGFloat) -> CGFloat {
        self.numberOfLines = lines        
        let attributes: [String : AnyObject] = [
            NSFontAttributeName: self.font,
            ]
        let resultSize: CGSize = string.boundingRectWithSize(
            CGSize(width: width, height: CGFloat.max),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: attributes,
            context: nil
            ).size
        let resultHeight: CGFloat = resultSize.height
        return resultHeight
    }
    
    func setFrameWithString(string: String, width: CGFloat, lines: Int) {
        self.numberOfLines = lines
        let attributes: [String : AnyObject] = [
            NSFontAttributeName: self.font,
            ]
        let resultSize: CGSize = string.boundingRectWithSize(
            CGSize(width: width, height: CGFloat.max),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: attributes,
            context: nil
            ).size
        let resultHeight: CGFloat = resultSize.height
        let resultWidth: CGFloat = resultSize.width
        var frame: CGRect = self.frame
        frame.size.height = resultHeight
        frame.size.width = resultWidth
        self.frame = frame
    }
    
    func setFrameWithString(string: String, width: CGFloat) {
        self.numberOfLines = 0
        let attributes: [String : AnyObject] = [
            NSFontAttributeName: self.font,
            ]
        let resultSize: CGSize = string.boundingRectWithSize(
            CGSize(width: width, height: CGFloat.max),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: attributes,
            context: nil
            ).size
        let resultHeight: CGFloat = resultSize.height
        let resultWidth: CGFloat = resultSize.width
        var frame: CGRect = self.frame
        frame.size.height = resultHeight
        frame.size.width = resultWidth
        self.frame = frame
    }
    
    func lineCounts() -> Int {
        
        var lineCounts = 1
        let labelSize = CGSizeMake(self.bounds.size.width, CGFloat(MAXFLOAT))
        let blockHeight = self.text?.stringHeightWithMaxWidth(labelSize.width, font: self.font)
        let unitHeight = "A".stringHeightWithMaxWidth(labelSize.width, font: self.font)
        lineCounts = Int(blockHeight! / unitHeight)
        return lineCounts
    }
    
//    func lineCounts() -> Int {
//        
//        let constrain = CGSizeMake(self.bounds.size.width, FLT_MAX)
//        let content = self.text
//        
//        
//        return 0
//    }
}

