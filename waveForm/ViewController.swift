//
//  ViewController.swift
//  waveForm
//
//  Created by Charlie Fang on 7/19/15.
//  Copyright (c) 2015 Charlie Fang. All rights reserved.
//

import UIKit
import CoreMedia
import MediaPlayer
import AVFoundation

class ViewController: UIViewController {
    
    var soundWaveView:SoundWaveView!

    override func viewDidLoad() {
        super.viewDidLoad()
        soundWaveView = SoundWaveView(frame: CGRectMake(5, 50, UIScreen.mainScreen().bounds.size.width-10, 100))
        var url = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("see", ofType: "mp3")!)
        
        var asset:AVURLAsset = AVURLAsset(URL: url, options: nil)
        soundWaveView.SetAsset(asset)
       

        self.view.addSubview(soundWaveView)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getSong(index: Int) -> MPMediaItem {
        var songCollection = MPMediaQuery.songsQuery()
        var uniqueSongs = (songCollection.items as! [MPMediaItem]).filter({song in song.playbackDuration > 30 })
        return uniqueSongs[index]
    }
     var count = 0
    
    @IBAction func playSound(sender: AnyObject) {
       
//        
        let filename:String! = "see.mp3"
       
        SoundManager.sharedManager(soundWaveView).playSound(filename, looping: false)
        
    }
}

