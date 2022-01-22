//
//  ChatTextCell.swift
//  WonBridge
//
//  Created by July on 2016-09-25.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import YYText

let kChatTextLeft: CGFloat = 72
let kChatTextMaxWidth: CGFloat = UIScreen.width - kChatTextLeft - 92
let kChatTextMarginTop: CGFloat = 12
let kChatTextMarginBottom: CGFloat = 11
let kChatTextMarginLeft: CGFloat = 17
let kChatBubbleWidthBuffer: CGFloat = kChatTextMarginLeft * 2
let kChatBubbleBottomTransparentHeight: CGFloat = 11
let kChatBubbleHeightBuffer: CGFloat = kChatTextMarginTop + kChatTextMarginBottom
let kChatBubbleImageViewHeight: CGFloat = 54
let kChatBubbleImageViewWidth: CGFloat = 50
let kChatBubblePaddingTop: CGFloat = 0
let kChatBubbleMaginLeft: CGFloat = 5
let kChatBubblePaddingBottom: CGFloat = 8
let kChatBubbleLeft: CGFloat = kChatAvatarMarginLeft + kChatAvatarWidth + kChatBubbleMaginLeft
let kChatTextFont: UIFont = UIFont.systemFontOfSize(16)
let kTimeIconDimension: CGFloat = 13
let kChatTimeLabelMaxWidth: CGFloat = 82
let kChatemojiMarginLeft: CGFloat = 8
let kChatEmojiWidth: CGFloat = kChatBubbleWidthBuffer

private let colorFromMe = UIColor.whiteColor()
private let colorFromOther = UIColor(netHex: 0x0d282f)

class ChatTextCell: ChatBaseCell {
   
    @IBOutlet weak var contentLabel: YYLabel! { didSet {
        contentLabel.font = kChatTextFont
        contentLabel.numberOfLines = 0
        contentLabel.backgroundColor = UIColor.clearColor()
        contentLabel.textVerticalAlignment = YYTextVerticalAlignment.Top
        contentLabel.displaysAsynchronously = false
        contentLabel.ignoreCommonProperties = true
        contentLabel.highlightTapAction = ({ [weak self] containerView, text, range, rect in
            self!.didTapRichLabelText(self!.contentLabel, textRange: range)
        })
        }
    }
    
    @IBOutlet weak var bubbleImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //Initialization code
    }
    
    override func setCellContent(model: ChatEntity, room: RoomEntity?, user: UserEntity) {
        
        super.setCellContent(model, room: room, user: user)
        
        if  model.isEmoji {
            
            let msg = model._content
            let emojiName = model._content.substringWithRange(msg.startIndex.advancedBy(1) ..< msg.endIndex.advancedBy(-1))

            self.contentLabel.text = ""
            self.contentLabel.hidden = true
            
            if let path = WBConfig.ExpressionBundle!.pathForResource("\(emojiName)@3x", ofType:"png") {
                self.bubbleImageView.image = UIImage(contentsOfFile: path)
            }
            
            self.bubbleImageView.contentMode = .ScaleAspectFit
            
        } else {
            
            self.contentLabel.hidden = false
            
            if let richTextLinePositionModifier = model.richTextLinePositionModifier {
                self.contentLabel.linePositionModifier = richTextLinePositionModifier
            }
            
            if let richTextLayout = model.richTextLayout {
                self.contentLabel.textLayout = richTextLayout
            }
            
            if let richTextAttributedString = model.richTextAttributedString {
                self.contentLabel.attributedText = richTextAttributedString
            }
            
            self.bubbleImageView.contentMode = .ScaleToFill
            
            //拉伸图片区域
            let stretchImage = model.fromMe ? WBAsset.SenderTextNodeBkg.image : WBAsset.ReceiverTextNodeBkg.image
            let bubbleImage = stretchImage.resizableImageWithCapInsets(UIEdgeInsetsMake(30, 28, 85, 28), resizingMode: .Stretch)
            self.bubbleImageView.image = bubbleImage;
        }
        
        timeLabel.text = model._sentTime
        
        self.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let model = self.model else {
            return
        }
        
        if  model.isEmoji {
            self.contentLabel.size = CGSizeMake(kChatEmojiWidth, 0)
        } else {
            self.contentLabel.size = model.richTextLayout!.textBoundingSize
        }
                
        self.timeLabel.setFrameWithString(model._sentTime, width: kChatTimeLabelMaxWidth)
        
        if model.fromMe {
            //value = 屏幕宽 - 头像的边距10 - 头像宽 - 气泡距离头像的 gap 值 - (文字宽 - 2倍的文字和气泡的左右距离 , 或者是最小的气泡图片距离)
            self.bubbleImageView.left = UIScreen.width - kChatAvatarMarginLeft - kChatAvatarWidth - kChatBubbleMaginLeft - max(self.contentLabel.width + kChatBubbleWidthBuffer, kChatBubbleImageViewWidth)
        } else {
            //value = 距离屏幕左边的距离
            self.bubbleImageView.left = kChatBubbleLeft
        }
        //设置气泡的宽
        self.bubbleImageView.width = max(self.contentLabel.width + kChatBubbleWidthBuffer, kChatBubbleImageViewWidth)
        //设置气泡的高度
        self.bubbleImageView.height = max(self.contentLabel.height + kChatBubbleHeightBuffer + kChatBubbleBottomTransparentHeight, kChatBubbleImageViewHeight)
        //value = 头像的底部 - 气泡透明间隔值
        self.bubbleImageView.top = self.nicknameLabel.bottom - kChatBubblePaddingTop
        //valeu = 气泡顶部 + 文字和气泡的差值
        self.contentLabel.top = self.bubbleImageView.top + kChatTextMarginTop
        //valeu = 气泡左边 + 文字和气泡的差值
        self.contentLabel.left = self.bubbleImageView.left + kChatTextMarginLeft
        
        if model.fromMe {
            self.timeLabel.bottom = self.bubbleImageView.bottom - kChatBubbleBottomTransparentHeight
            self.timeLabel.right = self.bubbleImageView.left
            self.timeIconImageView.right = self.timeLabel.left - kChatTimeMarginLeft
            self.timeIconImageView.bottom = self.timeLabel.bottom
        } else {
            self.timeIconImageView.left = self.bubbleImageView.right
            self.timeIconImageView.bottom = self.bubbleImageView.bottom - kChatBubbleBottomTransparentHeight
            self.timeLabel.left = self.timeIconImageView.right + kChatTimeMarginLeft
            self.timeLabel.bottom = self.timeIconImageView.bottom
        }
    }
    
    class func layoutHeight(model: ChatEntity) -> CGFloat {
        if model.cellHeight != 0 {
            return model.cellHeight
        }
        //解析富文本
        var attributedString: NSMutableAttributedString?
        
        if model.fromMe {
            
            attributedString = WBChatTextParser.parseText(model._content!, font: kChatTextFont, color: colorFromMe)!
            
        } else {
            
            attributedString = WBChatTextParser.parseText(model._content!, font: kChatTextFont, color: colorFromOther)!
        }
        model.richTextAttributedString = attributedString
        
        //初始化排版布局对象
        let modifier = WBYYTextLinePositionModifier(font: kChatTextFont)
        model.richTextLinePositionModifier = modifier
        
        //初始化 YYTextContainer
        let textContainer: YYTextContainer = YYTextContainer()
        textContainer.size = CGSize(width: kChatTextMaxWidth, height: CGFloat.max)
        textContainer.linePositionModifier = modifier
        textContainer.maximumNumberOfRows = 0
        
        //设置 layout
        let textLayout = YYTextLayout(container: textContainer, text: attributedString!)
        model.richTextLayout = textLayout
        
        //计算高度
        var height: CGFloat = kChatAvatarMarginTop + kChatBubblePaddingBottom
        let stringHeight = modifier.heightForLineCount(Int(textLayout!.rowCount))
        
        height += max(stringHeight + kChatBubbleHeightBuffer + kChatBubbleBottomTransparentHeight, kChatBubbleImageViewHeight)
        
        if model.isEmoji {
            model.cellHeight = height + kChatBubbleBottomTransparentHeight
        } else {
            model.cellHeight = height
        }        

        return model.cellHeight
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    /**
     解析点击文字
     
     - parameter label:     YYLabel
     - parameter textRange: 高亮文字的 NSRange，不是 range
     */
    private func didTapRichLabelText(label: YYLabel, textRange: NSRange) {
        //解析 userinfo 的文字
        let attributedString = label.textLayout!.text
        if textRange.location >= attributedString.length {
            return
        }
        guard let hightlight: YYTextHighlight = attributedString.yy_attribute(YYTextHighlightAttributeName, atIndex: UInt(textRange.location)) as? YYTextHighlight else {
            return
        }
        guard let info = hightlight.userInfo where info.count > 0 else {
            return
        }
        
        guard let delegate = self.delegate else {
            return
        }
        
        if let phone: String = info[kChatTextKeyPhone] as? String {
            delegate.cellDidTappedPhone(self, phoneString: phone)
        }
        
        if let URL: String = info[kChatTextKeyURL] as? String {
            delegate.cellDidTappedLink(self, linkString: URL)
        }
    }        
}
