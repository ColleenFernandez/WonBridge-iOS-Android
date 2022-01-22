//
//  ChatBase.swift
//  WonBridge
//
//  Created by July on 2016-09-25.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxBlocking
import RxCocoa

let kChatNicknameLabelHeight: CGFloat = 24
let kChatAvatarMarginLeft: CGFloat = 10
let kChatAvatarMarginTop: CGFloat = 0
let kChatAvatarWidth: CGFloat = 45
let kChatTimeMarginLeft: CGFloat = 6

class ChatBaseCell: UITableViewCell {

    weak var delegate: ChatCellDelegate?
    
    @IBOutlet weak var avatarImageView: UIImageView! { didSet {
        avatarImageView.backgroundColor = UIColor.clearColor()
        avatarImageView.width = kChatAvatarWidth
        avatarImageView.height = kChatAvatarWidth
        avatarImageView.contentMode = .ScaleAspectFit
        avatarImageView.layer.cornerRadius = kChatAvatarWidth / 2.0
//        avatarImageView.layer.borderWidth = 1
//        avatarImageView.layer.borderColor = UIColor.whiteColor().CGColor
        avatarImageView.layer.masksToBounds = true
        }}
    
    @IBOutlet weak var nicknameLabel: UILabel! { didSet {
        nicknameLabel.font = UIFont.systemFontOfSize(15)
        nicknameLabel.textColor = UIColor(colorNamed: WBColor.chatFriendNameTextColor)
        }}
    
    @IBOutlet weak var timeIconImageView: UIImageView! { didSet {
        timeIconImageView.width = kTimeIconDimension
        timeIconImageView.height = kTimeIconDimension
        }}
    @IBOutlet weak var timeLabel: UILabel! { didSet {
        timeLabel.height = kTimeIconDimension
        timeLabel.textAlignment = .Center
        timeLabel.font = UIFont.systemFontOfSize(10.0)
        }}
    
    var model: ChatEntity?
    let disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        self.avatarImageView.image = nil
        self.nicknameLabel.text = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization Code
        self.selectionStyle = .None
        self.contentView.backgroundColor = UIColor.clearColor()
        self.backgroundColor = UIColor.clearColor()
        
        // AvatarImageView Tap Event
        let tap = UITapGestureRecognizer()
        self.avatarImageView.addGestureRecognizer(tap)
        self.avatarImageView.userInteractionEnabled = true
        tap.rx_event.subscribeNext { [weak self] _ in
            if let strongSelf = self {
                guard let delegate = strongSelf.delegate else { return }
                delegate.cellDidTappedAvatarImageView(strongSelf)
            }
        }.addDisposableTo(self.disposeBag)
    }
    
    func setCellContent(model: ChatEntity, room: RoomEntity?, user: UserEntity) {
        self.model = model
        
        if model.fromMe {
            avatarImageView.setImageWithUrl(NSURL(string:user._photoUrl)!, placeHolderImage: WBAsset.UserPlaceHolder.image)
        } else {
            let sender = Int(model._from)
            if sender == 0 {
                
                avatarImageView.image = WBAsset.WonBridge.image
            } else {
                var friend = user.getFriend(sender!)
                if friend == nil {
                    friend = room!.getParticipant(sender!)
                }
                avatarImageView.setImageWithUrl(NSURL(string:friend!._photoUrl)!, placeHolderImage: WBAsset.UserPlaceHolder.image)
            }
        }
        self.setNeedsLayout()
    }
    
    override func layoutSubviews() {        
        guard let model = self.model else { return }
        
        if model.fromMe {
            self.nicknameLabel.height = 0
            self.avatarImageView.left = UIScreen.width - kChatAvatarMarginLeft - kChatAvatarWidth
        } else {
            self.nicknameLabel.height = 0
            self.avatarImageView.left = kChatAvatarMarginLeft
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}







