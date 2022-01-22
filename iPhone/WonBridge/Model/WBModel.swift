//
//  WBModel.swift
//  WonBridge
//
//  Created by July on 2016-09-24.
//  Copyright © 2016 elitedev. All rights reserved.
//

import Foundation

enum MessageSendSuccessType: Int {
    
    case Success = 0    //
    case Failed
    case Sending
}

/**
 *  Chat Message Content Type
 */
enum MessageContentType: String {
    
    case SYSTEM =   "0"
    case TIME   =   "1"
    case TEXT   =   "2"
    case IMAGE  =   "3"
    case VIDEO  =   "4"
    case FILE   =   "5"
}

/**
 *  User Gender
 */
enum GenderType: Int {
    case NONE = -1, MALE = 0, FEMALE
}

enum BlockUserType: Int {
    case BLOCKED_USER = 0, UNBLOCKED_USER
}

enum BlockStatusType: Int {
    case BLOCKED = 0, UNBLOCKED
}

enum MusicType: String {
    case Chat           =   "chatting"
    case Notification   =   "noti"
    case Ring_1         =   "videocall"
    case Ring_2         =   "ring"
}

enum ModelStatus: String {
    case Normal         =       "Normal"
    case Uploading      =       "Uploading"
    case Downloading    =       "Downloading"
}

