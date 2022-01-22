//
//  GroupNotiViewController.swift
//  WonBridge
//
//  Created by July on 2016-10-01.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

private let kMaxNotiTextLength = 1000

class GroupNotiViewController: BaseViewController {
    
    @IBOutlet weak var lblNotiTextCount: UILabel!
    @IBOutlet weak var txvContent: PlaceholderTextView!
    
    var sendAction: ((notification: String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initView() {
        
        lblNotiTextCount.text = "\(kMaxNotiTextLength)"
        txvContent.text = ""
        
        txvContent.becomeFirstResponder()
        txvContent.tintColor = UIColor(colorNamed: WBColor.colorAccent)
    }
    
    func showNotiEditView(sender: UIViewController, sendAction: ((notification: String) -> Void)?) {
        
        sender.presentViewController(self, animated: true, completion: nil)
        
        self.sendAction = sendAction
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func sendButtonTapped(sender: AnyObject) {
        
        guard !txvContent.text!.isEmpty else { return }
        
        txvContent.resignFirstResponder()
        
        let notification = txvContent.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        sendAction!(notification: notification)
    }
}

// MARK: - @protocol UITextViewDelegate
extension GroupNotiViewController: UITextViewDelegate {
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        guard let _text = textView.text else { return true }
        
        let newLength = _text.characters.count + text.characters.count - range.length
        
        return newLength <= kMaxNotiTextLength
    }
    
    func textViewDidChange(textView: UITextView) {
        
        lblNotiTextCount.text = "\(kMaxNotiTextLength - textView.text.characters.count)"
    }
}


