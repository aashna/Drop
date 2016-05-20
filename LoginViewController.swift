//
//  FbLoginViewController.swift
//  Drop
//
//  Created by Aashna Garg on 5/16/16.
//  Copyright © 2016 Aashna Garg. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import TwitterKit
import CloudKit


class LoginViewController: UIViewController, FBSDKLoginButtonDelegate
{
    
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    var email: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    
        if (FBSDKAccessToken.currentAccessToken() == nil)
        {
            print("Not logged in..")
        }
        else
        {
            print("Logged in..")
        }
        
   
        fbLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        fbLoginButton.delegate = self
    }
    
//        let logInButton = TWTRLogInButton { (session, error) in
//            if let unwrappedSession = session {
//                let alert = UIAlertController(title: "Logged In",
//                    message: "User \(unwrappedSession.userName) has logged in",
//                    preferredStyle: UIAlertControllerStyle.Alert
//                )
//                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
//                self.presentViewController(alert, animated: true, completion: nil)
//            } else {
//                NSLog("Login error: %@", error!.localizedDescription);
//            }
//        }
//    }
//
//        // TODO: Change where the log in button is positioned in your view
//        logInButton.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2, loginButton.center.y + 30)//self.view.center
//        self.view.addSubview(logInButton)
//        
//        Twitter.sharedInstance().logInWithCompletion {
//            (session, error) -> Void in
//            if (session != nil) {
//                
//                print(session!.userID)
//                print(session!.userName)
//                print(session!.authToken)
//                print(session!.authTokenSecret)
//              
//                
//            }else {
//                print("Not Login")
//            }
//            
//        }
//
//        
//    }


    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!)
    {
        if error == nil
        {
            print("Login complete.")
            if (result.grantedPermissions.contains("email")) {
                setEmail()
            }
        }
        else
        {
            print(error.localizedDescription)
        }
    }
    
    func setEmail() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) != nil) {
                // Process error
                print("Error: \(error)")
            } else {
                if let email = result.valueForKey("email") {
                    self.email = email as! String
                }
            }
            self.performSegueWithIdentifier("profileCompletion", sender: self)
        })
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!)
    {
        print("User logged out...")
    }
    /// async gets iCloud record ID object of logged-in iCloud user
    func iCloudUserIDAsync(complete: (instance: CKRecordID?, error: NSError?) -> ()) {
        let container = CKContainer.defaultContainer()
        container.fetchUserRecordIDWithCompletionHandler() {
            recordID, error in
            if error != nil {
                print(error!.localizedDescription)
                complete(instance: nil, error: error)
            } else {
                print("fetched ID \(recordID?.recordName)")
                complete(instance: recordID, error: nil)
            }
        }
    }
//    
//    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
//                withError error: NSError!) {
//        if (error == nil) {
//            // Perform any operations on signed in user here.
//            // ...
//        } else {
//            print("\(error.localizedDescription)")
//        }
//    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if case let updateProfileVC as UpdateProfileViewController  = segue.destinationViewController
            where segue.identifier == "profileCompletion"
        {
            updateProfileVC.email = email
        }

    }

    
    
}


