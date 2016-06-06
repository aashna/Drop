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
            if userEmail == "" {
                email.text = "None"
            }
            else {
                email.text = userEmail
            }
        }
        
        if let username = PFUser.currentUser()!["username"] as? String {
            if username == ""{
                userName.text = "None"
            }
            else{
                userName.text = username
                
            }
        }
        
        if let userDob = PFUser.currentUser()!["dob"] as? String {
            if userDob == ""{
                dob.text = "None"
            }
            else{
                dob.text = userDob
                
            }
        }
        
        if let userPhone = PFUser.currentUser()!["phone"] as? String {
            if userPhone == "" {
                phone.text = "None"
            }
            else{
                phone.text = userPhone
            }
        }
        if let userJoined = PFUser.currentUser()?.createdAt {
            joined.text =  userJoined.shortDate
        }
    }
}
