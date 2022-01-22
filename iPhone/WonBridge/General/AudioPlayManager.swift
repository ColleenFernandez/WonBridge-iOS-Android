//
//  AudioPlayManager.swift
//  WonBridge
//
//  Created by July on 2016-09-28.
//  Copyright © 2016 elitedev. All rights reserved.
//

import Foundation
import AVFoundation

let AudioPlayInstance = AudioPlayManager.sharedInstance


private let kMusicRepeatDuration = 2.5

private let kMp3TypeOfSound = "mp3"

class AudioPlayManager: NSObject {
    
    var isPlaying = false
    
    var type: MusicType = .Chat
    
    private var audioPlayer: AVAudioPlayer?
    
    class var sharedInstance: AudioPlayManager {
        struct Static {
            static let instance: AudioPlayManager = AudioPlayManager()
        }
        
        return Static.instance
    }
    
    private override init() {
        super.init()
    }
    
    func playSoundWithType(type: MusicType) {
        
        guard !isPlaying else {
//            debugPrint("now playing...")
            return
        }
        
        guard let audioFilePath = NSBundle.mainBundle().pathForResource(type.rawValue, ofType: kMp3TypeOfSound) else {
            debugPrint("audio file not found:\(type)")
            return
        }
        
        let audioFileUrl = NSURL.fileURLWithPath(audioFilePath)
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOfURL: audioFileUrl)
            
            guard let player = self.audioPlayer else { return }
            
            player.delegate = self
            player.prepareToPlay()
            
            isPlaying = true
            
            if type == .Ring_2 {
                
                player.numberOfLoops = -1
            }
            
            self.type = type
            
            player.play()
            
        } catch {
            self.destoryPlayer()
        }
    }
    
    func destoryPlayer() {
        self.stopPlayer()
    }
    
    func stopPlayer() {
        
        self.isPlaying = false
        
        guard self.audioPlayer != nil else { return }
        
        self.audioPlayer!.stop()
        self.audioPlayer = nil
    }
}

extension AudioPlayManager: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        self.isPlaying = false
        
        if self.type != .Ring_1  {
            self.stopPlayer()
        } else {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(kMusicRepeatDuration * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                self.audioPlayer?.play()
            })
        }
        
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
       self.stopPlayer()
    }
    
    func audioPlayerBeginInterruption(player: AVAudioPlayer) {
       self.stopPlayer()
    }
    
    func audioPlayerEndInterruption(player: AVAudioPlayer) {
       
    }
}
