//
//  ChatViewController+Subviews.swift
//  WonBridge
//
//  Created by July on 2016-09-25.
//  Copyright © 2016 elitedev. All rights reserved.
//

import Foundation

private let kCustomKeyboardHeight: CGFloat = 216

extension ChatViewController {
    
    func setupSubviews(delegate: UITextViewDelegate) {
        
        self.setupActionBar(delegate)
        initMessageTableView()
        setupKeyboardInputView()
    }
    
    // setup actionbar
    func setupActionBar(delegate: UITextViewDelegate) {
        
        self.chatActionBarView = ChatActionBarView.fromNib()
        self.chatActionBarView.delegate = self
        self.chatActionBarView.inputTextView.delegate = delegate
        self.view.addSubview(self.chatActionBarView)
        
        self.chatActionBarView.snp_makeConstraints { [weak self] (make) in
            guard let strongSelf = self else { return }
            make.left.equalTo(strongSelf.view.snp_left)
            make.right.equalTo(strongSelf.view.snp_right)
            strongSelf.actionBarPaddingBottomConstranit = make.bottom.equalTo(strongSelf.view.snp_bottom).constraint
            make.height.equalTo(kChatActionBarOriginalHeight)
        }
    }
    
    // init message tableview
    func initMessageTableView() {
        
        let tap = UITapGestureRecognizer()
        tap.cancelsTouchesInView = false
        self.listTableView.addGestureRecognizer(tap)
        tap.rx_event.subscribeNext { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.hideAllKeyboard()
        }.addDisposableTo(self.disposeBag)
        
        self.view.addSubview(self.listTableView)
        
        self.listTableView.snp_makeConstraints { (make) in
            make.top.left.right.equalTo(self.view)
            make.bottom.equalTo(self.chatActionBarView.snp_top)
        }
    }
    
    // emoji inputview, share more inputview, media gallery view
    func setupKeyboardInputView() {

        // emotion input view
        self.emotionInputView = ChatEmotionInputView.fromNib()
        self.emotionInputView.delegate = self
        self.view.addSubview(self.emotionInputView)
        self.emotionInputView.snp_makeConstraints { [weak self] (make) in
            guard let strongSelf = self else { return }
            make.left.equalTo(strongSelf.view.snp_left)
            make.right.equalTo(strongSelf.view.snp_right)
            make.top.equalTo(strongSelf.chatActionBarView.snp_bottom).offset(0)
            make.height.equalTo(kCustomKeyboardHeight)
        }
        
        // shareMoreView 
        self.shareMoreView = ChatShareMoreView.fromNib()
        self.shareMoreView.delegate = self
        self.view.addSubview(self.shareMoreView)
        self.shareMoreView.snp_makeConstraints { [weak self] (make) in
            guard let strongSelf = self else { return }
            make.left.equalTo(strongSelf.view.snp_left)
            make.right.equalTo(strongSelf.view.snp_right)
            make.top.equalTo(strongSelf.chatActionBarView.snp_bottom).offset(0)
            make.height.equalTo(kCustomKeyboardHeight)
        }

        // media gallery view
        self.shareMediaView = ChatShareMediaView.fromNib()
        self.shareMediaView.videoCellTapDelegate = self
        self.view.addSubview(self.shareMediaView)
        self.shareMediaView.snp_makeConstraints { [weak self] (make) in
            guard let strongSelf = self else { return }
            make.left.equalTo(strongSelf.view.snp_left)
            make.right.equalTo(strongSelf.view.snp_right)
            make.top.equalTo(strongSelf.chatActionBarView.snp_bottom).offset(0)
            make.height.equalTo(kCustomKeyboardHeight)
        }
    }
    
    // set block status
    // actionbar will be set according to block status of friend
    func setBlockState(block: Bool) {        
        self.chatActionBarView.setActivate(block)
    }
}




