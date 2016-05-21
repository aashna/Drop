//
//  MuisicPlayer.swift
//  Drop
//
//  Created by Aashna Garg on 5/20/16.
//  Copyright © 2016 Aashna Garg. All rights reserved.
//

import UIKit

class MusicPlayerViewController: UITableViewController, MusicDataDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: Constants
    
    private struct Storyboard {
        static let TrackCellIdentifier = "trackCellIdentifier"
    }
    
    @IBOutlet var musicPlayerView: UITableView!
    var tableData = [SongDetailsModel]()
    
    func getMusicData(results: NSArray){
       // dispatch_async(dispatch_get_main_queue(), {
            self.tableData = results as! [SongDetailsModel]
            self.musicPlayerView!.reloadData()
     //   })
        
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return 10
        print(tableData)
         return tableData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TrackCellIdentifier, forIndexPath: indexPath)
        
//        if let rowData: NSDictionary = self.tableData[indexPath.row] as? NSDictionary,
//            duration = rowData["duration"] as? String,
//            // Download an NSData representation of the image at the URL
//            // imgData = NSData(contentsOfURL: imgURL),
//            // Get the track name
//            trackTitle = rowData["title"] as? String {
//            cell.detailTextLabel?.text = duration
//            // Update the imageView cell to use the downloaded image data
//            //  cell.imageView?.image = UIImage(data: imgData)
//            // Update the textLabel text to use the trackName from the API
//            cell.textLabel?.text = trackTitle
//        }
        return cell
    }
    @IBAction func unwindToMusicPlayerViewController(sender: UIStoryboardSegue) {
    }
    
}