//
//  WBUIImage+WonBridge.swift
//  WonBridge
//
//  Created by July on 2016-09-25.
//  Copyright © 2016 elitedev. All rights reserved.
//



/*
 https://github.com/AliSoftware/SwiftGen is a suite of tools written in Swift to auto-generate Swift code or anything else actually for various assets of your project
 
 CLI 切换到：./WonBridge/Resources
 命令：swiftgen images Media.xcassets
 */

typealias WBAsset = UIImage.Asset

import Foundation
import UIKit

extension UIImage {
    enum Asset: String {
        
        case WonBridge                      =       "icon_logo"
        
        case ReceiverImageNodeBorder        =       "ReceiverImageNodeBorder"
        case ReceiverImageNodeMask          =       "ReceiverImageNodeMask"
        case ReceiverTextNodeBkg            =       "ReceiverTextNodeBkg"
        case SenderImageNodeBorder          =       "SenderImageNodeBorder"
        case SenderImageNodeMask            =       "SenderImageNodeMask"
        case SenderTextNodeBkg              =       "SenderTextNodeBkg"
        case ShareMorePicture               =       "button_gallery_chat"
        case ShareMoreVideo                 =       "button_vedio_chat"
        case ShareMoreCamera                =       "button_take-pic_chat"
        case ShareMoreVoiceCall             =       "button_voice-call_chat"
        case ShareMoreVideoCall             =       "button_vedio-call_chat"
        case ShareMoreGift                  =       "button_gift_chat"
        case Emoticon_keyboard_magnifier    =       "emoticon_keyboard_magnifier"
        case Emotion_delete                 =       "emotion_delete"
        case Tool_keyboard_1                =       "ToolViewKeyboard"
        case Tool_keyboard_2                =       "ToolViewKeyboardHL"
        case Tool_emotion_1                 =       "button_imoji_chat"
        case Tool_chat_selection_1          =       "button_method_chat"
        case Tool_image_chat_cancel_1       =       "button_cancel-img_chat"
        case Tool_chat_send_1               =       "button_send_chat"
        case Tool_chat_can_send1            =       "button_send_press_chat"
        case Menu_block_icon                =       "icon_ban_set"
        case Menu_unblock_icon              =       "icon_add_set"
        case Menu_Setting_Icon              =       "button_set_chat"
        case Name_Left_Icon                 =       "userimage"
        case Password_Left_Icon             =       "password"
        case SplashBkg                      =       "splash"
        case BackButton                     =       "button_back"
        
        case UserPlaceHolder                =       "img_user"
        case GroupPlaceHolder               =       "img_group"
        
        case Female_Icon                    =       "icon_woman"
        case Male_Icon                      =       "icon_man"
        
        case Map_Pin_No_Sex                 =       "map_pin_no_sex"
        case Map_Pin_Female                 =       "map_pin_female"
        case Map_Pin_Male                   =       "map_pin_male"
        
        case Map_Info_Man                   =       "icon_man_info_map"
        case Map_Info_Woman                 =       "icon_woman_info_map"
        
        
        case Selected                       =       "icon_img_selected"
        case Unselected                     =       "icon_img_unselected"
        case InviteUser                     =       "button_invite_group"
        case BanishUser                     =       "button_banish_group"
        
        case NoImagePlaceHolder             =       "noimg"
        case NoVideoPlaceHolder             =       "nomov"
        case VideoPlayMark                  =       "video_play"
        
        case Loading_1                      =       "loading1"
        case Loading_2                      =       "loading2"
        case Loading_3                      =       "loading3"
        case Loading_4                      =       "loading4"
        case Loading_5                      =       "loading5"
        case Loading_6                      =       "loading6"
        case Loading_7                      =       "loading7"
        case Loading_8                      =       "loading8"
        
        case Button_DislikeTimeLine         =       "button_like_off"
        case Button_LikeTimeLine            =       "button_like_on"
        case TimeLine_TextBack              =       "timeline_text_back"
        
        case Service_Item_1                 =       "icon_jiazheng"
        case Service_Item_2                 =       "icon_zhongjie"
        case Service_Item_3                 =       "icon_chuguo"
        case Service_Item_4                 =       "icon_coutrue"
        case Service_Item_5                 =       "icon_liuxue"
        case Service_Item_6                 =       "icon_trip"
        case Service_Item_7                 =       "icon_touzi"
        case Service_Item_8                 =       "icon_shopping"
        
        case Departure_Item_1               =       "icon_nkow"
        case Departure_Item_2               =       "icon_visa"
        case Departure_Item_3               =       "icon_country"
        case Departure_Item_4               =       "icon_verify"
        case Departure_Item_5               =       "icon_flight"
        case Departure_Item_6               =       "icon_cash"
        case Departure_Item_7               =       "icon_train"
        case Departure_Item_8               =       "icon_hotel"
        
        case General_PlaceHolder            =       "placeholder"
        
        case Icon_Fold                      =       "icon_fold"
        case Icon_Opened                    =       "icon_opened"
        
        case IconVideoOff                   =       "button_no_camera"
        case IconVideoOn                    =       "button_on-camera"
        
        var image: UIImage {
            return UIImage(asset: self)
        }
    }
    
    convenience init!(asset: Asset) {
        self.init(named: asset.rawValue)
    }
}

