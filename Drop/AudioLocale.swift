//
//  AudioLocale.swift
//  Drop
//
//  Created by Aashna Garg on 5/17/16.
//  Copyright © 2016 Aashna Garg. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation



class AudioLocale: NSObject {
    let audio: AVAudioPlayer
    let coordinates: CLLocation
    init(filePath: NSURL, coords:CLLocation) {
        let data =  NSData(contentsOfURL:filePath)
        self.audio = try! AVAudioPlayer(data: data!)
        self.coordinates = coords
        self.audio.prepareToPlay()
    }
    
    func play(location:CLLocation) {
        //plays this audio file based on distance
        self.audio.volume = self.volumeForCLLocation(location)
        self.audio.numberOfLoops = -1
        self.audio.play()
    }
    
    func playing() -> Bool{
        return self.audio.playing
    }
    
    func stop() {
        self.audio.stop();
    }
    
    func updateVolume(location:CLLocation) {
        //updates volume again based on distance
        self.audio.volume = self.volumeForCLLocation(location)
    }
    
    private func volumeForCLLocation(location:CLLocation) -> Float{
        //calculates the loudness based on distance
        let distance = location.distanceFromLocation(self.coordinates)
        if (distance < 5.0){return 1.0}
        if (distance > 100){return 0.0}
        return Float(25.0/(distance*distance))
    }
    
    private func panningForCLLocation(location:CLLocation) {
        //EXTENSION compass implementation
    }
}

