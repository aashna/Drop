//
//  MusicPlayerTableView.swift
//  Drop
//
//  Created by Aashna Garg on 5/20/16.
//  Copyright © 2016 Aashna Garg. All rights reserved.
//

import UIKit


protocol PlaySongDelegate {
    func playSong(cell: MusicPlayerTableViewCell)
}
protocol StopSongDelegate {
    func stopSong(cell: MusicPlayerTableViewCell)
}

class MusicPlayerTableViewCell: UITableViewCell {

    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var trackDuration: UILabel!
    
    var delegatePlay: PlaySongDelegate?
     var delegateStop: StopSongDelegate?
    
    @IBAction func onPlay(sender: AnyObject) {
        if let delegate = delegatePlay{
            delegate.playSong(self)
        }
      }
    @IBAction func onStop(sender: AnyObject) {
        if let delegate = delegateStop{
            delegate.stopSong(self)
        }
    }
    
    var track: SongDetailsModel! {
        didSet {
            updateUI()
        }
    }
    private func updateUI()
    {
    trackTitle?.text = track.title
    trackDuration?.text = String(track.duration/600000) + (trackDuration?.text)!
    }

}
