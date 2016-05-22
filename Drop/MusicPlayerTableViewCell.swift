//
//  MusicPlayerTableView.swift
//  Drop
//
//  Created by Aashna Garg on 5/20/16.
//  Copyright © 2016 Aashna Garg. All rights reserved.
//

import UIKit


@objc protocol PlaySongDelegate {
    func playSong(cell: MusicPlayerTableViewCell)
}
@objc protocol StopSongDelegate {
    func stopSong(cell: MusicPlayerTableViewCell)
}

class MusicPlayerTableViewCell: UITableViewCell {

    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var trackDuration: UILabel!
    
    weak var delegateStop: StopSongDelegate?
    weak var delegatePlay: PlaySongDelegate?
    
    @IBAction func onPlay(sender: AnyObject) {
            self.delegatePlay?.playSong(self)
      }
    @IBAction func onStop(sender: AnyObject) {
            self.delegateStop?.stopSong(self)
    }
    
    var track: SongDetailsModel! {
        didSet {
            updateUI()
        }
    }
    private func updateUI()
    {
    trackTitle?.text = track.title
    trackDuration?.text = String(track.duration) + (trackDuration?.text)!
    }

}
