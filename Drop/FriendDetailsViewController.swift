//
//  FriendDetailsViewController.swift
//  Drop
//
//  Created by Aashna Garg on 5/29/16.
//  Copyright © 2016 Aashna Garg. All rights reserved.
//

import UIKit
import Parse

class FriendDetailsViewController: UIViewController {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var dob: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var joined: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userEmail = PFUser.currentUser()!["email"] as? String {
            email.text = userEmail
        }
        if let username = PFUser.currentUser()!["username"] as? String {
            userName.text = username
        }
        if let userDob = PFUser.currentUser()!["dob"] as? String {
            dob.text = userDob
        }
        if let userPhone = PFUser.currentUser()!["phone"] as? String {
            phone.text = userPhone
        }
        if let userJoined = PFUser.currentUser()!["createdAt"] as? String {
            joined.text = userJoined
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
   

}
