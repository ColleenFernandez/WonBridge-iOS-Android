//
//  TSChatSystemCell.swift
//  TSWeChat
//
//  Created by Hilen on 1/11/16.
//  Copyright © 2016 Hilen. All rights reserved.
//

import UIKit

private let kChatInfoFont: UIFont = UIFont.systemFontOfSize(14)
private let kChatInfoLabelPaddingLeft: CGFloat = 12   //左右分别留出 8 像素的留白
private let kChatInfoLabelPaddingTop: CGFloat = 8   //上下分别留出 4 像素的留白
private let kChatInfoLabelMarginTop: CGFloat = 0  //距离顶部
private let kChatInfoLabelMarginBottom: CGFloat = 15 //距离底部
private let kChatInfoLabelMaxWdith : CGFloat = UIScreen.width - kChatInfoLabelPaddingLeft*2

final class EdgeLabel: UILabel {
    var labelEdge: UIEdgeInsets = UIEdgeInsets(top: 4, left: 7, bottom: 4, right: 7)
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    override func drawTextInRect(rect: CGRect) {
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, labelEdge))
    }
}

class ChatSystemCell: UITableViewCell {
    @IBOutlet weak var infomationLabel: EdgeLabel!{didSet {
        infomationLabel.font = kChatInfoFont
        infomationLabel.labelEdge = UIEdgeInsets(
            top: kChatInfoLabelPaddingTop,
            left: kChatInfoLabelPaddingLeft,
            bottom: kChatInfoLabelPaddingTop,
            right: kChatInfoLabelPaddingLeft
        )
        infomationLabel.font = kChatInfoFont
        infomationLabel.textColor = UIColor(colorNamed: WBColor.darkGray)
        infomationLabel.backgroundColor = UIColor(colorNamed: WBColor.lightGray)
        infomationLabel.textAlignment = .Center
        infomationLabel.numberOfLines = 0
        }}
    var model: ChatEntity?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
    }
    
    func getSystemMessage(model: ChatEntity) -> String {
       
        var systemMsg = ""
        if model._content.containsString(Constants.KEY_GROUPNOTI_MARKER) {
            systemMsg = model._content
        } else if model._content.containsString(Constants.KEY_LEAVEROOM_MARKER) {
            let name = model._content.substringToIndex(model._content.rangeOfString("$")!.startIndex)
            systemMsg = name + Constants.LEAVE_ROOM
        } else if model._content.containsString(Constants.KEY_BANISH_MARKER) {
            let names = model._content.substringToIndex(model._content.rangeOfString("$")!.startIndex)
            systemMsg = names + Constants.BANISH_ROOM
        } else if model._content.containsString(Constants.KEY_INVITE_MARKER) {
            let names = model._content.substringToIndex(model._content.rangeOfString("$")!.startIndex)
            systemMsg = names + Constants.INVITEED_ROOM
        } else if model._content.containsString(Constants.KEY_DELEGATE_MARKER) {
            let name = model._content.substringToIndex(model._content.rangeOfString("$")!.startIndex)
            systemMsg = name + Constants.BECOME_GROUPOWNER
        } else if model._content.containsString(Constants.KEY_ADD_MARKER) {
            let roomname_username = model._content.substringToIndex(model._content.rangeOfString("$", options: .BackwardsSearch)!.startIndex)
            let name = roomname_username.substringToIndex(model._content.rangeOfString("$")!.startIndex)
            systemMsg = name + Constants.ADDED_TO_ROOM
        }
        
        return systemMsg
    }
    
    func setCellContent(model: ChatEntity, user: UserEntity) {
        
        self.model = model
        
        if model._content.containsString(Constants.KEY_GROUPNOTI_MARKER) {
            infomationLabel.textColor = UIColor(colorNamed: WBColor.colorText2)
        } else {
            infomationLabel.textColor = UIColor(colorNamed: WBColor.darkGray)
        }
        
        self.infomationLabel.text = getSystemMessage(model)
        
//        if model._content.containsString(Constants.KEY_GROUPNOTI_MARKER) {
//            infomationLabel.textColor = UIColor(colorNamed: WBColor.colorText2)
////            systemMsg = model._content
//        } else if model._content.containsString(Constants.KEY_LEAVEROOM_MARKER) {
//            let name = model._content.substringToIndex(model._content.rangeOfString("$")!.startIndex)
//            systemMsg = name + Constants.LEAVE_ROOM
//        } else if model._content.containsString(Constants.KEY_BANISH_MARKER) {
//            let names = model._content.substringToIndex(model._content.rangeOfString("$")!.startIndex)
//            systemMsg = names + Constants.BANISH_ROOM
//        } else if model._content.containsString(Constants.KEY_INVITE_MARKER) {
//            let names = model._content.substringToIndex(model._content.rangeOfString("$")!.startIndex)
//            systemMsg = names + Constants.INVITEED_ROOM
//        } else if model._content.containsString(Constants.KEY_DELEGATE_MARKER) {
//            let name = model._content.substringToIndex(model._content.rangeOfString("$")!.startIndex)
//            systemMsg = name + Constants.BECOME_GROUPOWNER
//        } else if model._content.containsString(Constants.KEY_ADD_MARKER) {
//            let roomname_username = model._content.substringToIndex(model._content.rangeOfString("$", options: .BackwardsSearch)!.startIndex)
//            let name = roomname_username.substringToIndex(model._content.rangeOfString("$")!.startIndex)
//            systemMsg = name + Constants.ADDED_TO_ROOM
//        }
        
//        self.infomationLabel.text = systemMsg
    }
    
    override func layoutSubviews() {
        guard let model = self.model else {
            return
        }
        self.infomationLabel.setFrameWithString(getSystemMessage(model), width: kChatInfoLabelMaxWdith)
        self.infomationLabel.width = UIScreen.width  //左右的留白
        self.infomationLabel.height = self.infomationLabel.height + kChatInfoLabelPaddingTop*2   //上下的留白
        self.infomationLabel.left = 0
        self.infomationLabel.top = kChatInfoLabelMarginTop
    }
    
    class func layoutHeight(model: ChatEntity) -> CGFloat {
        
        if model.cellHeight != 0 {
            return model.cellHeight
        }
        
        var systemMsg = ""
        
        if model._content.containsString(Constants.KEY_GROUPNOTI_MARKER) {
            systemMsg = model._content
        } else if model._content.containsString(Constants.KEY_LEAVEROOM_MARKER) {
            let name = model._content.substringToIndex(model._content.rangeOfString("$")!.startIndex)
            systemMsg = name + Constants.LEAVE_ROOM
        } else if model._content.containsString(Constants.KEY_BANISH_MARKER) {
            let names = model._content.substringToIndex(model._content.rangeOfString("$")!.startIndex)
            systemMsg = names + Constants.BANISH_ROOM
        } else if model._content.containsString(Constants.KEY_INVITE_MARKER) {
            let names = model._content.substringToIndex(model._content.rangeOfString("$")!.startIndex)
            systemMsg = names + Constants.INVITEED_ROOM
        } else if model._content.containsString(Constants.KEY_DELEGATE_MARKER) {
            let name = model._content.substringToIndex(model._content.rangeOfString("$")!.startIndex)
            systemMsg = name + Constants.BECOME_GROUPOWNER
        } else if model._content.containsString(Constants.KEY_ADD_MARKER) {
            let roomname_username = model._content.substringToIndex(model._content.rangeOfString("$", options: .BackwardsSearch)!.startIndex)
            let name = roomname_username.substringToIndex(model._content.rangeOfString("$")!.startIndex)
            systemMsg = name + Constants.ADDED_TO_ROOM
        }
        
        var height: CGFloat = 0
        height += kChatInfoLabelMarginTop + kChatInfoLabelMarginTop
        let stringHeight: CGFloat = systemMsg.stringHeightWithMaxWidth(kChatInfoLabelMaxWdith, font: kChatInfoFont)
        height += stringHeight + kChatInfoLabelPaddingTop*2
        model.cellHeight = height + kChatInfoLabelMarginBottom
        return model.cellHeight
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}



