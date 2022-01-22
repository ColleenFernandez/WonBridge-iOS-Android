//
//  FullTextViewController.swift
//  WonBridge
//
//  Created by Elite on 10/10/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import YYText

class FullTextViewController: BaseViewController {
    
    var timeline: TimeLineEntity?
    
    @IBOutlet weak var fullTextView: YYTextView! { didSet {
        fullTextView.editable = false
        }}

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initView()
    }
    
    func initView() {
        
        self.title = "全文"
        
        guard timeline != nil else { return }
        
//        fullTextView.text = timeline!.content
        fullTextView.attributedText = WBTimeLineTextParser.parseText(timeline!.content, font: UIFont.systemFontOfSize(18), color: UIColor(netHex: 0x5B5B5B))
        
        fullTextView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        self.fullTextView.contentOffset = CGPointZero
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backbuttonTapped(sender: AnyObject?) {
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    private func didTapRichText(textView: YYTextView, textRange: NSRange) {
        //解析 userinfo 的文字
        let attributedString = textView.textLayout!.text
        if textRange.location >= attributedString.length {
            return
        }
        
        guard let hightlight: YYTextHighlight = attributedString.yy_attribute(YYTextHighlightAttributeName, atIndex: UInt(textRange.location)) as? YYTextHighlight else {
            return
        }
        
        guard let info = hightlight.userInfo where info.count > 0 else {
            return
        }
        
        if let URL: String = info[kChatTextKeyURL] as? String {
            openURL(URL)
        }
    }
    
    func openURL(link: String) {
        UIApplication.sharedApplication().openURL(NSURL(string: link)!)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension FullTextViewController: YYTextViewDelegate {
    
    func textView(textView: YYTextView, didTapHighlight highlight: YYTextHighlight, inRange characterRange: NSRange, rect: CGRect) {
        self.didTapRichText(textView, textRange: characterRange)
    }
}
