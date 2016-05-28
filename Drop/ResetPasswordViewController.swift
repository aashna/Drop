//
//  resetPasswordViewController.swift
//  Drop
//
//  Created by Aashna Garg on 5/21/16.
//  Copyright © 2016 Aashna Garg. All rights reserved.
//

import UIKit
import Parse

extension UIView {
    func addBackgroundToReset() {
        
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UIScreen.mainScreen().bounds.size.height
        
        let imageViewBackground = UIImageView(frame: CGRectMake(0, 0, width, height))
        imageViewBackground.image = UIImage(named: "drop-reset-screen.png")
        // you can change the content mode:
        imageViewBackground.contentMode = UIViewContentMode.ScaleAspectFill
        
        self.addSubview(imageViewBackground)
        self.sendSubviewToBack(imageViewBackground)
    }}

class ResetPasswordViewController: UIViewController {
    
    @IBOutlet weak var userEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addBackgroundToReset()
      //  self.view.backgroundColor = UIColor(patternImage: UIImage(named: "drop-reset-screen.png")!)
    }
    
     /* referred from http://www.appcoda.com/login-signup-parse-swift/ */

    @IBAction func resetPassword(sender: AnyObject) {
        let email = self.userEmail.text
        let finalEmail = email!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        // Send a request to reset a password
        PFUser.requestPasswordResetForEmailInBackground(finalEmail)
        
        let alert = UIAlertController (title: "Password Reset", message: "An email containing information on how to reset your password has been sent to " + finalEmail + ".", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
