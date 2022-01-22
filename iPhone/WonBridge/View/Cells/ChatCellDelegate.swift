//
//  ChatCellDelegate.swift
//  WonBridge
//
//  Created by July on 2016-09-25.
//  Copyright © 2016 elitedev. All rights reserved.
//

import Foundation

@objc protocol ChatCellDelegate: class {
    
    optional func cellDidTapped(cell: ChatBaseCell)
    
    func cellDidTappedAvatarImageView(cell: ChatBaseCell)
    
    func cellDidTappedImageView(cell: ChatBaseCell)
    
    func cellDidTappedLink(cell: ChatBaseCell, linkString: String)
    
    func cellDidTappedPhone(cell: ChatBaseCell, phoneString: String)
    
    func cellDidTappedVoiceButton(cell: ChatBaseCell, isPlayingVoice: Bool)
}
