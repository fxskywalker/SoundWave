//
//  SoundManager.swift
//  waveForm
//
//  Created by Charlie Fang on 7/19/15.
//  Copyright (c) 2015 Charlie Fang. All rights reserved.
//

import UIKit
import AVFoundation


class SoundManager: NSObject {
    
    var playingMusic:Bool!
    var  allowsBackgroundMusic:Bool!
    var soundVolume:Float32!
    var  musicVolume:Float32!
    var soundFadeDuration:NSTimeInterval!
    var  musicFadeDuration:NSTimeInterval!
    var currentMusic:Sound!
    var currentSounds:NSMutableArray!
    var soundWaveView:SoundWaveView!
    
    
    class func sharedManager(soundWaveView:SoundWaveView) ->SoundManager {
        var sharedManager:SoundManager?
        if sharedManager == nil{
            sharedManager = SoundManager()
            sharedManager!.soundWaveView = soundWaveView
            sharedManager!.setUp()
        }
        
        return sharedManager!
        
    }
    

    
    
     func setUp() {
        soundVolume = 1.0
        musicVolume = 1.0
        soundFadeDuration = 1.0
        musicFadeDuration = 1.0
        currentSounds = NSMutableArray();
    }
    
    func sefAllowBackgroundMusic(allow:Bool){
        if(allowsBackgroundMusic != allow){
            allowsBackgroundMusic = allow
            var session:AVAudioSession = AVAudioSession.sharedInstance()
            session.setCategory(allow ? AVAudioSessionCategoryAmbient : AVAudioSessionCategorySoloAmbient, error: nil)
        }
    }
    
    internal func playSound(soundOrName:AnyObject, looping:Bool, fadeIn:Bool){
        
        var sound:Sound = Sound()
        sound.soundWaveView = self.soundWaveView
        sound.soundNamed(soundOrName)
        
        if !currentSounds.containsObject(sound){
            currentSounds.addObject(sound)
        }
        sound.looping = looping
        sound.volume = fadeIn ? 0.0 : soundVolume
        sound.play()
        
    }
    
    func playSound(soundOrName:NSString, looping:Bool){
        self.playSound(soundOrName, looping: looping, fadeIn: false)
    }
    
    func playSound(soundOrName:NSString){
         self.playSound(soundOrName, looping: false, fadeIn: false)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
   
}
