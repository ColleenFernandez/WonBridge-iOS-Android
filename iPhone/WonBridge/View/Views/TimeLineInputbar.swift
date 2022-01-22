//
//  TimeLineInputbar.swift
//  WonBridge
//
//  Created by July on 2016-09-20.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

@objc protocol TimeLineInputbarDelegate: class {
    
    func didPressSendButton(inputbar: TimeLineInputbar)
    
    optional func didChangeHeight(height: CGFloat)
    optional func didBecomeFirstResponder(inputbar: TimeLineInputbar)
}

class TimeLineInputbar: UIToolbar, HPGrowingTextViewDelegate {
    
    let RIGHT_BUTTON_SIZE = 30
    
    var tDelegate: TimeLineInputbarDelegate?
    
    var placeholder: String = "" { didSet {
        
        textView.placeholder = placeholder
        
        }
    }
    var sendButtonImage: UIImage = UIImage() { didSet {
        
        sendButton.setImage(sendButtonImage, forState: .Normal)
        
        }
    }
    
    var normalImage: String!
    var selectedImage: String!
    
    var text: String {
        
        return textView.text
    }
    
    var sendButton: UIButton!
    var backgroundView: UIView!
    var textView: HPGrowingTextView!
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        addContent()
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        addContent()
    }
    
    func addContent() {
        
        addBackgroundView()
        addRightButton()
        addTextView()
    }
    
    func addBackgroundView() {
        
        let size = self.frame.size
        
        backgroundView = UIView(frame: CGRectMake(5, 5, size.width - 10, size.height - 10))
        backgroundView.backgroundColor = UIColor.whiteColor()
        backgroundView.layer.cornerRadius = 5
        backgroundView.layer.masksToBounds = true
        
        backgroundView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.addSubview(backgroundView)
    }
    
    func addRightButton() {
        
        let size  = self.frame.size
        
        sendButton = UIButton(type: .Custom)
        sendButton.frame = CGRectMake(size.width - CGFloat(RIGHT_BUTTON_SIZE) - 10, 0, CGFloat(RIGHT_BUTTON_SIZE), size.height)
        sendButton.autoresizingMask = [.FlexibleTopMargin, .FlexibleLeftMargin]
        
        sendButton.setImage(sendButtonImage, forState: .Normal)
        
        sendButton.addTarget(self, action: #selector(didPressSendButton(_:)), forControlEvents: .TouchUpInside)
        
        self.addSubview(sendButton)
    }
    
    func addTextView() {
        
        let size = backgroundView.frame.size
        
        textView = HPGrowingTextView(frame: CGRectMake(0, 4, size.width - (CGFloat(RIGHT_BUTTON_SIZE) + 12), size.height - 8))
        textView.isScrollable = false
        textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5)
        
        textView.minNumberOfLines = 1
        textView.maxNumberOfLines = 3
        textView.font = UIFont.systemFontOfSize(15)
        
        textView.delegate = self
        textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0)
        textView.placeholder = placeholder
        
        textView.keyboardType = .Default
        textView.returnKeyType = .Default
        textView.enablesReturnKeyAutomatically = true
        
        textView.autoresizingMask = .FlexibleWidth
        
        self.backgroundView.addSubview(textView)
    }
    
    func beginEditing() {
        
        textView.becomeFirstResponder()
    }
    
    func endEditing() {
        
        textView.resignFirstResponder()
    }
    
    // MARK: - delegate
    func didPressSendButton(sender: UIButton) {
        
        tDelegate?.didPressSendButton(self)
        
        self.textView.text = ""
    }
    
    // MARK: - TextView delegate
    func growingTextView(growingTextView: HPGrowingTextView!, willChangeHeight height: Float) {
        
        let diff = growingTextView.frame.size.height - CGFloat(height)
        
        var rect = self.frame
        rect.size.height -= diff
        rect.origin.y += diff
        self.frame = rect
        
        if tDelegate != nil && tDelegate?.didChangeHeight != nil {
        
            tDelegate!.didChangeHeight!(self.frame.size.height)
        }
    }
    
    func growingTextViewDidBeginEditing(growingTextView: HPGrowingTextView!) { }
    
    func growingTextViewDidChange(growingTextView: HPGrowingTextView!) {
        
        let text = growingTextView.text.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        if text == "" {
            
            sendButton.setImage(UIImage(named: normalImage), forState: .Normal)
            
        } else {
            
            sendButton.setImage(UIImage(named: selectedImage), forState: .Normal)
        }
    }
}
