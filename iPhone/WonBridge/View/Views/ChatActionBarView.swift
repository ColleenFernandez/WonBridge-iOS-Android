
//
//  TSChatActionBarView.swift
//  TSWeChat
//
//  Created by Hilen on 12/16/15.
//  Copyright © 2015 Hilen. All rights reserved.
//

import UIKit

let kChatActionBarOriginalHeight: CGFloat = 50      //ActionBar orginal height
let kChatActionBarTextViewMaxHeight: CGFloat = 90   //Expandable textview max height

/**
 *  表情按钮和分享按钮来控制键盘位置
 */
protocol ChatActionBarViewDelegate: class {
    
    /**
     显示表情键盘，并且处理键盘高度
     */
    func chatActionBarShowEmotionKeyboard()
    
    /**
     显示分享键盘，并且处理键盘高度
     */
    func chatActionBarShowShareKeyboard()
    
    func chatActionBarHideMediaKeyboard()
}

class ChatActionBarView: UIView {
    enum ChatKeyboardType: Int {
        case Default, Text, Emotion, Share, Media
    }
    
    var keyboardType: ChatKeyboardType? = .Default
    weak var delegate: ChatActionBarViewDelegate?
    var inputTextViewCurrentHeight: CGFloat = kChatActionBarOriginalHeight
    
    @IBOutlet weak var textChatBackView: UIView! { didSet {
        textChatBackView.hidden = false
        textChatBackView.backgroundColor = UIColor.whiteColor()
        textChatBackView.layer.cornerRadius = 5.0
        textChatBackView.layer.masksToBounds = true
        }}
    
    @IBOutlet weak var inputTextView: HPTextViewInternal! { didSet{
        inputTextView.font = UIFont.systemFontOfSize(17)        
        inputTextView.textContainerInset = UIEdgeInsetsMake(6, 5, 6, 5)
        inputTextView.backgroundColor = UIColor.clearColor()
        inputTextView.hidden = false
        inputTextView.enablesReturnKeyAutomatically = true
        inputTextView.layoutManager.allowsNonContiguousLayout = false
        inputTextView.textContainer.lineBreakMode = .ByWordWrapping
        inputTextView.scrollsToTop = false
        }}
    
    @IBOutlet weak var shareButton: ChatButton! { didSet {
        shareButton.showTypingKeyboard = false
        }}
    @IBOutlet weak var emotionButton: ChatButton! { didSet{
        emotionButton.showTypingKeyboard = false
        }}
    
    @IBOutlet weak var textSendButton: ChatButton!
    
    @IBOutlet weak var imageSendButton: UIButton! { didSet{
        imageSendButton.setBackgroundImage(UIImage.imageWithColor(UIColor.clearColor()), forState: .Normal)
        imageSendButton.setBackgroundImage(UIImage.imageWithColor(UIColor(netHex: 0xC6C7CB)), forState: .Highlighted)
        imageSendButton.layer.cornerRadius = 5.0
        imageSendButton.layer.masksToBounds = true
        imageSendButton.hidden = true
        }}

    override init (frame: CGRect) {
        super.init(frame : frame)
        self.initContent()
    }
    
    convenience init () {
        self.init(frame:CGRect.zero)
        self.initContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initContent() {
        let topBorder = UIView()
        let bottomBorder = UIView()
        topBorder.backgroundColor = UIColor.whiteColor()
        bottomBorder.backgroundColor = UIColor.whiteColor()
        self.addSubview(topBorder)
        self.addSubview(bottomBorder)
        
        topBorder.snp_makeConstraints { (make) -> Void in
            make.top.left.right.equalTo(self)
            make.height.equalTo(0.5)
        }
        bottomBorder.snp_makeConstraints { (make) -> Void in
            make.bottom.left.right.equalTo(self)
            make.height.equalTo(0.5)
        }
    }
    
    override func awakeFromNib() {
        initContent()
    }
}

// MARK: - @extension TSChatActionBarView
//控制键盘的各种互斥事件
extension ChatActionBarView {
    //重置所有 Button 的图片
    func resetButtonUI() {
        self.shareButton.setImage(WBAsset.Tool_chat_selection_1.image, forState: .Normal)
        self.shareButton.setImage(WBAsset.Tool_chat_selection_1.image, forState: .Highlighted)
        
        self.emotionButton.setImage(WBAsset.Tool_emotion_1.image, forState: .Normal)
        self.emotionButton.setImage(WBAsset.Tool_emotion_1.image, forState: .Highlighted)
        
        self.textSendButton.setImage(WBAsset.Tool_chat_send_1.image, forState: .Normal)
        self.textSendButton.setImage(WBAsset.Tool_chat_send_1.image, forState: .Highlighted)
    }
    
    //当是表情键盘 或者 分享键盘的时候，此时点击文本输入框，唤醒键盘事件。
    func inputTextViewCallKeyboard() {
        self.keyboardType = .Text
        self.textChatBackView.hidden = false
        
        //设置接下来按钮的动作
        self.imageSendButton.hidden = true
        self.emotionButton.showTypingKeyboard = false
        self.shareButton.showTypingKeyboard = false
    }

    //显示文字输入的键盘
    func showTyingKeyboard() {
        self.keyboardType = .Text
        self.inputTextView.becomeFirstResponder()
        self.textChatBackView.hidden = false
        
        //设置接下来按钮的动作
        self.imageSendButton.hidden = true
        self.emotionButton.showTypingKeyboard = false
        self.shareButton.showTypingKeyboard = false
    }
    
    /*
    显示表情键盘
    当点击唤起自定义键盘时，操作栏的输入框需要 resignFirstResponder，这时候会给键盘发送通知。
    通知在  TSChatViewController+Keyboard.swift 中需要对 actionbar 进行重置位置计算
    */
    func showEmotionKeyboard() {
        self.keyboardType = .Emotion
        self.inputTextView.resignFirstResponder()
        self.inputTextView.hidden = false
        if let delegate = self.delegate {
            delegate.chatActionBarShowEmotionKeyboard()
        }
        
        //设置接下来按钮的动作        
        self.emotionButton.showTypingKeyboard = true
        self.shareButton.showTypingKeyboard = false
    }
    
    //显示分享键盘
    func showShareKeyboard() {
        self.keyboardType = .Share
        self.inputTextView.resignFirstResponder()
        if let delegate = self.delegate {
            delegate.chatActionBarShowShareKeyboard()
        }

        //设置接下来按钮的动作
        self.imageSendButton.hidden = true
        self.emotionButton.showTypingKeyboard = false
        self.shareButton.showTypingKeyboard = true
    }
    
    func hideMediaKeyboard() {
        self.keyboardType = .Share
        replaceActionBarUI(imageChat: false, isPhotoView: false)
        if let delegate = self.delegate {
            delegate.chatActionBarHideMediaKeyboard()
        }
    }
    
    //取消输入
    func resignKeyboard() {
        self.keyboardType = .Default
        self.inputTextView.resignFirstResponder()
        
        //设置接下来按钮的动作
        self.emotionButton.showTypingKeyboard = false
        self.shareButton.showTypingKeyboard = false
        
        resetButtonUI()
        replaceActionBarUI(imageChat: false, isPhotoView: false)
    }
    
    /**
     <暂无用到>
     控制切换键盘的时候光标的颜色
     如果是切到 表情或分享 ，就是透明
     如果是输入文字，就是蓝色
     
     - parameter color: 目标颜色
     */
    private func changeTextViewCursorColor(color: UIColor) {
        self.inputTextView.tintColor = color
        UIView.setAnimationsEnabled(false)
        self.inputTextView.resignFirstResponder()
        self.inputTextView.becomeFirstResponder()
        UIView.setAnimationsEnabled(true)
    }
    
    func replaceActionBarUI(imageChat imageChat: Bool, isPhotoView: Bool) {
        
        if imageChat {
            self.keyboardType = .Media
            self.textChatBackView.hidden = true
            if isPhotoView {
                 self.imageSendButton.hidden = false
            }
            self.shareButton.setImage(UIImage(named: "button_cancle_contants-box_chat"), forState: .Normal)
        } else {
            self.keyboardType = .Share
            self.textChatBackView.hidden = false
            self.imageSendButton.hidden = true
            self.shareButton.setImage(UIImage(named: "button_method_chat"), forState: .Normal)
        }
    }
    
    func resetTextSendButtonUI() {
        
        let text = self.inputTextView.text.stringByReplacingOccurrencesOfString(" ", withString: "")
        if text == "" {
            self.textSendButton.replaceSendButtonUI(canSend: false)
        } else {
            self.textSendButton.replaceSendButtonUI(canSend: true)
        }
    }
    
    // set user interaction of action bar 
    // active status = user interaction enable state
    func setActivate(active: Bool) {
        
        self.shareButton.userInteractionEnabled = active
        self.textSendButton.userInteractionEnabled = active
        self.emotionButton.userInteractionEnabled = active
        self.inputTextView.userInteractionEnabled = active
        
        if active {
            self.inputTextView.text = ""
            self.inputTextView.textColor = UIColor.darkTextColor()
        } else {
            self.inputTextView.text = Constants.HOLDER_BLOCKING
            self.inputTextView.textColor = UIColor.lightGrayColor()
        }
    }
}








