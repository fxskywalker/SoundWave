//
//  Sound.swift
//  waveForm
//
//  Created by Charlie Fang on 7/19/15.
//  Copyright (c) 2015 Charlie Fang. All rights reserved.
//

import UIKit

//GCC diagnostic push
//GCC diagnostic ignored: "-Wobjc-missing-property-synthesis"
//
//import Availability
//#if TARGET_OS_IPHONE
//    let SM_USE_AV_AUDIO_PLAYER = 1
//    #else
//    import Cocoa
//    //#if !defined(SM_USE_AV_AUDIO_PLAYER) && \_
//    //_MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_7
//    let SM_USE_AV_AUDIO_PLAYER = 1
//    //#endif
//#endif
//    
//    #if SM_USE_AV_AUDIO_PLAYER
//    import AVFoundation
//    let SM_SOUNDAVAudioPlayer
//        #else
//    let SM_SOUND:NSSound
//#endif
//

import AVFoundation
import Foundation

let SoundDidFinishPlayingNotification:NSString = "SoundDidFinishPlayingNotification"

typealias SoundCompletionHandler = (didFinish:Bool) -> Void

class Sound: NSObject, AVAudioPlayerDelegate {
    
    var name:NSString!
    var URL:NSURL!
    var playing:Bool!
    var looping:Bool!
    var duration:NSTimeInterval!
    var currentTime:NSTimeInterval!
    var completionHandler:SoundCompletionHandler!
    var baseVolume:Float32!
    var volume:Float32!
    var pan:Float32!
    var startVolume:Float32!
    var targetVolume:Float32!
    var fadeTime:NSTimeInterval!
    var fadeStart:NSTimeInterval!
    var timer:NSTimer?
    var selfReference:Sound!
    var sound:AVAudioPlayer!
    var soundWaveView:SoundWaveView!
    
    
      func  soundNamed(name:AnyObject) -> Sound {
        var path:NSString = name as! NSString
        if !(path.absolutePath){
            if (name.pathExtension).isEmpty {
                self.name = name.stringByAppendingPathExtension("caf")
            }
            path = NSBundle.mainBundle().pathForResource(name as? String, ofType: "")!
        }
        return self.soundWithContentOfFile(path as String)
    }
    
    func soundWithContentOfFile(path:NSString) -> Sound{
        return self.initWithContentsOfFile(path)
    }
    
    func soundWithContentsOfURL( URL:NSURL)->Sound
    {
        return self.initWithContentsOfURL(URL)
    }
    
    func initWithContentsOfFile(path:NSString)->Sound
    {
        return self.initWithContentsOfURL(NSURL.fileURLWithPath(path as String)!)
    }
    
    func initWithContentsOfURL(URL:NSURL)->Sound
    {
        
            self.URL = URL
            self.baseVolume = 1.0
            self.sound = AVAudioPlayer(contentsOfURL: URL, error: nil)
            self.volume = 1.0
        
        return self
    }
    
    func prepareToPlay(){
        var prepared:Bool = false
        if !prepared{
            prepared = true
        }
        AVAudioSession.sharedInstance()
        sound.prepareToPlay()
    }
    
    func Name() -> NSString{
        return URL.path!.lastPathComponent
    }
    
    
    func setbaseVolume(baseVolume:Float32){
        self.baseVolume = fminf(1.0, baseVolume)
        if(abs(self.baseVolume - baseVolume) < 0.001){
            var previousVolume:Float32 = self.volume
            self.baseVolume = baseVolume
            self.volume = previousVolume
        }
    }
    
    func Volume() -> Float32{
        if (timer != nil){
            return targetVolume / baseVolume
        }else{
            return sound.volume / baseVolume
        }
    }
    
    func setVolume(volume:Float32){
        self.volume = fminf(1.0, volume)
        targetVolume = volume * baseVolume
    }
    
    func Pan() -> Float32{
        return sound.pan
    }
    
    func synced(lock: AnyObject, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
   
    func play(){
       
            self.selfReference = self
            sound.delegate = self
            sound.play()
        timer?.invalidate()
        synced(self) {
            self.timer = NSTimer.scheduledTimerWithTimeInterval(self.sound.duration/1000, target: self,
                selector: "onUpdate", userInfo: nil, repeats: true)
        }
        
       
        
        
    }
    
    func onUpdate(){
        let c = sound.currentTime
       // println(c)
        if c > 0.0 {
            let t=sound.duration

            let p:CGFloat=CGFloat(c/t)
            //println(p)
            
            
            UIView.animateWithDuration((sound.duration/1000), delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                println(p)
                self.soundWaveView.setProgress(p)
                
                }, completion: { finished in Void() } )

            
            
            
        }
    }
    
    func stop(){
        if(self.playing as Bool){
            sound.stop()
            
            timer?.invalidate()
            self.timer = nil
        }
    }
    
}
