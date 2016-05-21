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
        return 10
        print(tableData)
        // return tableData.count
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
    
//    @IBAction func heartButtonPressed(sender: AnyObject) {
//    }
    @IBAction func heartButtonPressed(sender: AnyObject) {
        // the slider value returns a float (e.g. 10.4)
        // to work in the loop we need to round down as an Int (e.g. 10)
        let numberOfHearts = 5
        
        for loopNumber in 1...numberOfHearts  {
            
            // set up some constants for the animation
            let duration = 1.0
            let options = UIViewAnimationOptions.CurveLinear
            
            // randomly assign a delay of 0.9 to 1s
            let delay = NSTimeInterval(200 + arc4random_uniform(100)) / 1000
            
            // set up some constants for the heart
            let size : CGFloat = CGFloat( arc4random_uniform(40))+20
            let yPosition : CGFloat = CGFloat( arc4random_uniform(200))+20
            
            // create the heart
            let heart = UIImageView()
            heart.image = UIImage(named: "heartButton")
            heart.frame = CGRectMake(0-size, yPosition, size, size)
            self.view.addSubview(heart)
            
            // define the animation
            UIView.animateWithDuration(duration, delay: delay, options: options, animations: {
                
                // move the heart
                heart.frame = CGRectMake(320, yPosition, size, size)
                
                }, completion: { animationFinished in
                    
                    // remove the heart
                    heart.removeFromSuperview()
            })
        }
    }

    
    
}