//
//  MuisicPlayer.swift
//  Drop
//
//  Created by Aashna Garg on 5/20/16.
//  Copyright © 2016 Aashna Garg. All rights reserved.
//

import UIKit
import AVFoundation

class MusicPlayerTableViewController: UITableViewController, MusicDataDelegate, PlaySongDelegate, StopSongDelegate{
    
    var musicPlaylist = [SongDetailsModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: Constants
    
    private struct Storyboard {
        static let TrackCellIdentifier = "trackCellIdentifier"
    }
    @IBAction func onResume(sender: AnyObject) {
        
    }
    
    @IBAction func onStop(sender: AnyObject) {
        for index in 1...self.musicPlaylist.count-1{
            if self.musicPlaylist[index].playing() == true{
                self.musicPlaylist[index].stop()
            }
        }
    }
    @IBAction func onPause(sender: AnyObject) {
        for index in 1...self.musicPlaylist.count-1{
            if self.musicPlaylist[index].playing() == true{
               self.musicPlaylist[index].pause()
            }
        }
    }
    override func viewWillAppear(animated: Bool) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.musicPlaylist = appDelegate.playList
//        for audio in self.musicPlaylist{
//        
//            if !audio.playing() {
//                audio.play()
//            }
//        }
//
//        }
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
        return self.musicPlaylist.count
        // return tableData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TrackCellIdentifier, forIndexPath: indexPath) as! MusicPlayerTableViewCell
        cell.trackTitle.text = self.musicPlaylist[indexPath.row].title
        cell.trackDuration.text = String(self.musicPlaylist[indexPath.row].duration)
        return cell
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        var selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        selectedCell.contentView.backgroundColor = UIColor.redColor()
        
    }
    
    func playSong(cell: MusicPlayerTableViewCell){
    self.musicPlaylist[musicPlayerView.indexPathForCell(cell)!.row].play()
    }
    func stopSong(cell: MusicPlayerTableViewCell){
         self.musicPlaylist[musicPlayerView.indexPathForCell(cell)!.row].stop()
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
            heart.image = UIImage(named: "Heart-fill")
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