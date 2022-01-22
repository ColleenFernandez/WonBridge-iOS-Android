//
//  ChatTimeCell.swift
//  WonBridge
//
//  Created by July on 2016-09-25.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit

private let kChatTimeLabelMaxWdith : CGFloat = UIScreen.width - 30*2
private let kChatTimeLabelPaddingLeft: CGFloat = 6   //左右分别留出 6 像素的留白
private let kChatTimeLabelPaddingTop: CGFloat = 3   //上下分别留出 3 像素的留白
private let kChatTimeLabelMarginTop: CGFloat = 10   //顶部 10 px, left, right
private let kChatTimeGeneralMargin: CGFloat = 10


class ChatTimeCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel! {didSet {
        timeLabel.textColor = UIColor(netHex: 0x7F7F7F)
        }}
    
    @IBOutlet weak var leftDivView: UIView! { didSet {
        leftDivView.backgroundColor = UIColor(netHex: 0xAAAAAA)
        }}
    
    @IBOutlet weak var rightDivView: UIView! { didSet {
        rightDivView.backgroundColor = UIColor(netHex: 0xAAAAAA)
        }}
    
    var model: ChatEntity?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.backgroundColor = UIColor.clearColor()
        self.contentView.backgroundColor = UIColor.clearColor()
    }
    
    func setCellContent(model: ChatEntity) {
        self.model = model
        self.timeLabel.text = String(format: "%@", model._content!)
    }
    
    override func layoutSubviews() {
        guard let message = self.model?._content else {
            return
        }
        self.timeLabel.setFrameWithString(message, width: kChatTimeLabelMaxWdith)
        self.timeLabel.width = self.timeLabel.width + kChatTimeLabelPaddingLeft*2  //左右的留白
        self.timeLabel.left =  (UIScreen.width - self.timeLabel.width) / 2
        self.timeLabel.height = self.timeLabel.height + kChatTimeLabelPaddingTop*2
        self.timeLabel.top = kChatTimeLabelMarginTop

        self.leftDivView.height = 1
        self.leftDivView.centerY = self.timeLabel.centerY
        self.leftDivView.left = kChatTimeGeneralMargin
        self.leftDivView.width = (UIScreen.width - timeLabel.width)/2 - 2*kChatTimeGeneralMargin

        self.rightDivView.height = 1
        self.rightDivView.centerY = self.timeLabel.centerY
        self.rightDivView.left = self.timeLabel.right + kChatTimeGeneralMargin
        self.rightDivView.width = (UIScreen.width - timeLabel.width)/2 - 2*kChatTimeGeneralMargin
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    class func heightForCell() -> CGFloat {
        return 40
    }
}
