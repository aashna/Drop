//
//  SongDetailsModel.swift
//  Drop
//
//  Created by Ayush Gupta on 5/20/16.
//  Copyright © 2016 Aashna Garg. All rights reserved.
//

import UIKit
import AVFoundation

class SongDetailsModel: NSObject {
    var title: String
    var duration: Int
    var streamURL: String
    let audio: AVAudioPlayer
   //var streamable: Bool
    
    init(title: String, duration: Int, streamURL: String) {
        self.title = title
        self.duration = duration
        self.streamURL = streamURL
        let data =  NSData(contentsOfURL:NSURL(string:streamURL)!)
        self.audio = try! AVAudioPlayer(data: data!)
        self.audio.prepareToPlay()
    }
    
    func play() {
        //plays this audio file based on distance
      //  self.audio.volume = self.volumeForCLLocation(location)
        self.audio.numberOfLoops = -1
        
        self.audio.play()
        
    }
    
    func playing() -> Bool{
        return self.audio.playing
    }
    
    func stop() {
        self.audio.stop();
    }
    func pause() {
        self.audio.pause();
    }
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool)
    {
        
    }
  
    
//    func updateVolume(location:CLLocation) {
//        //updates volume again based on distance
//        self.audio.volume = self.volumeForCLLocation(location)
//    }
}
