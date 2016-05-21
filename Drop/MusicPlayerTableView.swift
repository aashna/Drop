//
//  MusicPlayerTableView.swift
//  Drop
//
//  Created by Aashna Garg on 5/20/16.
//  Copyright © 2016 Aashna Garg. All rights reserved.
//

import UIKit

class MusicPlayerTableView: UITableViewCell {

    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var trackDuration: UILabel!
    
    var track: SongDetailsModel! {
        didSet {
            updateUI()
        }
    }
    private func updateUI()
    {
    trackTitle?.text = track.title
    trackDuration?.text = String(track.duration)
    }

}
