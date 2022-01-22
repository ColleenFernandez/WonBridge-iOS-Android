//
//  WBSystemSoundPlayer.swift
//  WonBridge
//
//  Created by Elite on 11/9/16.
//  Copyright © 2016 elitedev. All rights reserved.
//

import UIKit
import AudioToolbox

let kWBSystemSoundTypeCAF           =       "caf"
let kWBSystemSoundTypeAIF           =       "aif"
let kWBSystemSoundTypeAIFF          =       "aiff"
let kWBSystemSoundTypeWAV           =       "wav"
let kWBSystemSoundTypeMP3           =       "mp3"


class WBSystemSoundPlayer {
    
    static func playSoundWithType(type: MusicType) {
        
        var sound: SystemSoundID = 0
        if let soundURL = NSBundle.mainBundle().URLForResource(type.rawValue, withExtension: kWBSystemSoundTypeMP3) {
            AudioServicesCreateSystemSoundID(soundURL, &sound)
            AudioServicesPlaySystemSound(sound)
        }
    }
}

