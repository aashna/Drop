//
//  FriendDetailsViewController.swift
//  Drop
//
//  Created by Aashna Garg on 5/29/16.
//  Copyright © 2016 Aashna Garg. All rights reserved.
//

import UIKit
import Parse

extension NSDate {
        struct Date {
            static let formatterShortDate = NSDateFormatter()
        }
        var shortDate: String {
            return Date.formatterShortDate.stringFromDate(self)
        }
    
}

class FriendDetailsViewController: UIViewController {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var dob: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var joined: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(PFUser.currentUser()!["email"])
        
        if let userEmail = PFUser.currentUser()!["email"] as? String {
            email.text = userEmail
        }
        else{
            email.text = "None"
        }
        if let username = PFUser.currentUser()!["username"] as? String {
            userName.text = username
        }
        else{
            userName.text = "None"
        }
        if let userDob = PFUser.currentUser()!["dob"] as? String {
            dob.text = userDob
        }
        else{
            dob.text = "None"
        }
        if let userPhone = PFUser.currentUser()!["phone"] as? String {
            phone.text = userPhone
        }
        else{
            phone.text = "None"
        }
        print(PFUser.currentUser()?.createdAt)
        if let userJoined = PFUser.currentUser()?.createdAt {
            joined.text =  userJoined.shortDate
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
