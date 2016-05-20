//
//  MuisicPlayer.swift
//  Drop
//
//  Created by Aashna Garg on 5/20/16.
//  Copyright © 2016 Aashna Garg. All rights reserved.
//

import UIKit
import AVFoundation

class MusicPlayerViewController: UITableViewController, MusicDataDelegate{
    
    // MARK: Constants
    
    private struct Storyboard {
        static let TrackCellIdentifier = "trackCellIdentifier"
    }

//http://api.soundcloud.com/users/228307235/playlists?client_id=14802fecba08aa53d2daa7d16434d02c
//stream_url = https://api.soundcloud.com/tracks/235185128/stream?client_id=14802fecba08aa53d2daa7d16434d02c

    @IBOutlet var musicPlayerView: UITableView!
    var tableData = []
    
    func getMusicData(results: NSArray){
         dispatch_async(dispatch_get_main_queue(), {
       self.tableData = results
       self.musicPlayerView!.reloadData()
        })

}
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TrackCellIdentifier, forIndexPath: indexPath)
        
        if let rowData: NSDictionary = self.tableData[indexPath.row] as? NSDictionary,
            duration = rowData["duration"] as? String,
            // Download an NSData representation of the image at the URL
           // imgData = NSData(contentsOfURL: imgURL),
            // Get the track name
            trackTitle = rowData["title"] as? String {
            cell.detailTextLabel?.text = duration
            // Update the imageView cell to use the downloaded image data
          //  cell.imageView?.image = UIImage(data: imgData)
            // Update the textLabel text to use the trackName from the API
            cell.textLabel?.text = trackTitle
        }
        return cell
    }

    
    
    
   }