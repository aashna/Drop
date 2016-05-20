//
//  SongDetailsModel.swift
//  Drop
//
//  Created by Ayush Gupta on 5/20/16.
//  Copyright © 2016 Aashna Garg. All rights reserved.
//

import UIKit

class SongDetailsModel: NSObject {
    var title: String
    var duration: Int
    var streamable: Bool
    
    init(title: String, duration: Int, streamable: Bool) {
        self.title = title
        self.duration = duration
        self.streamable = streamable
    }
}


/*
 To use this do the following in your class where you want to populate:
 
 1. loop through the JSON for track and fetch the title,duration and streamable value
 2. Use the following line to populate playlist array with values
 
     var playlist = [SongDetailsModel]()
     playlist.append(SongDetailsModel(title: <#T##String#>, duration: <#T##Int#>, streamable: <#T##Bool#>)
 
 3. Pass the values to tableviewcontroller
 4. Now you have the array, just use each value in cellForRowAtIndexPath() as playlist[index].valueforKey("title")
 
 
 */