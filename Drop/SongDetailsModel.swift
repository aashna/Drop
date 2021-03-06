//
//  SongDetailsModel.swift
//  Drop
//
//  Created by Aashna Garg on 5/20/16.
//  Copyright © 2016 Aashna Garg. All rights reserved.
//

import UIKit
import AVFoundation

class SongDetailsModel: NSObject {
    var title: String
    var duration: Int
    var streamURL: String
    let audio: AVAudioPlayer
    
    init(title: String, duration: Int, streamURL: String) {
        self.title = title
        self.duration = duration/60000
        self.streamURL = streamURL
        let data =  NSData(contentsOfURL:NSURL(string:streamURL)!)
        self.audio = try! AVAudioPlayer(data: data!)
        self.audio.prepareToPlay()
    }
    
    func play() {
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
}
