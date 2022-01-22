//
//  UIColor+WonBridge.swift
//  WonBridge
//
//  Created by July on 2016-09-25.
//  Copyright © 2016 elitedev. All rights reserved.
//

typealias WBColor = UIColor.LocalColorName

import Foundation

extension UIColor {
    enum LocalColorName: Int {
        case colorAccent                    =   0x7f7f7f
        case lightGray                      =   0xf2f2f2
        case Gray                           =   0xd5d5d5
        case darkGray                       =   0x919191        // system message normal (leave room, delegater, invite, basish)
        
        case colorTabBarTint                =   0x2d3035
        case colorWhiteBlue                 =   0x8efbff
        case colorNormal                    =   0x94979b
        
        case colorGrid                      =   0xcacaca
        case colorGridBackground            =   0xf5f5f5
        
        case colorStartBtn                  =   0x396193
        
        case colorError                     =   0xfa0606
        
        case colorText1                     =   0xdbee88
        case colorText2                     =   0x5f99fb    // photo placeholder image background color, group notification
        case colorText3                     =   0x5b5b5b    // timeline cell    dark gray
        case colorText4                     =   0x898e91    // timeline cell    gray
        case colorHintText                  =   0xbebebe
        
        case colorButtonGreen               =   0x6fe36c
        case colorButtonGray                =   0xd1d1d1
        
        case friendAcceptBtnBkgColor        =   0xfa970b
        case chatListCotentGray             =   0x525252
        
        case chatFriendNameTextColor        =   0x303030
    }
    
    convenience init!(colorNamed name: LocalColorName) {
        self.init(netHex: name.rawValue)
    }
}

