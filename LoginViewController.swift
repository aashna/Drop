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
import Parse
import Social

extension UIView {
    func addBackground() {
        
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UIScreen.mainScreen().bounds.size.height
        
        let imageViewBackground = UIImageView(frame: CGRectMake(0, 0, width, height))
        imageViewBackground.image = UIImage(named: "drop-login-screen.png")
        // you can change the content mode:
        imageViewBackground.contentMode = UIViewContentMode.ScaleAspectFill
        
        self.addSubview(imageViewBackground)
        self.sendSubviewToBack(imageViewBackground)
    }}


class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate //PFLogInViewControllerDelegate,PFSignUpViewControllerDelegate //
{
    let transitionManager = TransitionManager()
    
    
    
    @IBOutlet weak var userPassword: UITextField!
    
    @IBOutlet weak var userName: UITextField!
    
    @IBOutlet weak var googleLoginButton: GIDSignInButton!
    
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    var email: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addBackground()
    }
    
    func vibrateForInvalidInput() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation.init(keyPath: "position.x")
        animation.values = [0, 10, -10, 10, 0]
        animation.keyTimes = [0, (1/6.0), (3/6.0), (5/6.0), 1]
        animation.duration = 0.4
        animation.additive = true
        
        return animation
    }
    
    /* referred from http://www.appcoda.com/login-signup-parse-swift/ */
    @IBAction func signIn(sender: AnyObject) {
        
        let username = self.userName.text
        let password = self.userPassword.text
        
        // Validate the text fields
        
        if(username?.characters.count < 5) {
            self.userName.layer.addAnimation(vibrateForInvalidInput(), forKey: "basic")
            let alert = UIAlertController(title: "Invalid", message:"Username must be greater than 5 characters", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
            self.presentViewController(alert, animated: true){}
            
        } else if(password?.characters.count < 8) {
            self.userPassword.layer.addAnimation(vibrateForInvalidInput(), forKey: "basic")
            let alert = UIAlertController(title: "Invalid", message:"Password must be greater than 8 characters", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
            self.presentViewController(alert, animated: true){}
            
        } else {
            // Run a spinner to show a task in progress
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
            spinner.startAnimating()
            
            // Send a request to login
            PFUser.logInWithUsernameInBackground(username!, password: password!, block: { (user, error) -> Void in
                
                // Stop the spinner
                spinner.stopAnimating()
                if ((user) != nil) {
                    self.performSegueToMainView()
                } else {
                    if(error?.code == 101) {
                        self.userName.layer.addAnimation(self.vibrateForInvalidInput(), forKey: "basic")
                        self.userPassword.layer.addAnimation(self.vibrateForInvalidInput(), forKey: "basic")
                        let alert = UIAlertController(title: "Invalid Credentials", message:"Username or Password Wrong", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
                        self.presentViewController(alert, animated: true){}
                    } else {
                        let alert = UIAlertController(title: "Error", message:"\(error)", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
                        self.presentViewController(alert, animated: true){}
                    }
                }
            })
        }
    }
    
    
    func performSegueToMainView() {
        AppDelegate.getAppDelegate().loaded = false
        self.performSegueWithIdentifier("segueToMain", sender: self)
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!)
    {
        if error == nil
        {
            print("Login complete.")
            performSegueToMainView()
            //            if (result.grantedPermissions.contains("email")) {
            //                setEmail()
            //            }
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
            self.performSegueToMainView()
        })
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!)
    {
        print("User logged out...")
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
                withError error: NSError!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            // ...
            self.performSegueWithIdentifier("segueToMain", sender: self)
        } else {
            print("\(error.localizedDescription)")
            
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if case let updateProfileVC as UpdateProfileViewController  = segue.destinationViewController
            where segue.identifier == "profileCompletion"
        {
            updateProfileVC.email = email
            updateProfileVC.transitioningDelegate = self.transitionManager
        }
        
    }
    
    @IBAction func signUp(sender: AnyObject) {
        self.performSegueWithIdentifier("profileCompletion", sender: self)
    }
    @IBAction func resetPassword(sender: AnyObject) {
        self.performSegueWithIdentifier("resetPassword", sender: self)
    }
    @IBAction func unwindToLogInScreen(segue:UIStoryboardSegue) {
    }
    @IBAction func unwindAfterLogout(segue:UIStoryboardSegue) {
         PFUser.logOut()
   showSimpleAlertWithTitle("Logged Out", message: "You have been successfully logged out of Drop", viewController: self)
    }
    
    @IBAction func addFriends(sender: AnyObject) {
        self.performSegueWithIdentifier("addFriend", sender: self)
    }
    
    
    //http://www.appcoda.com/social-framework-introduction/
    @IBAction func shareButtonPressed(sender: AnyObject) {
        let shareAlert = UIAlertController(title: "", message: "Share Us", preferredStyle: UIAlertControllerStyle.ActionSheet)
        // Configure a new action for sharing the note in Twitter.
        let twitter = UIAlertAction(title: "Share on Twitter", style: UIAlertActionStyle.Default) { (action) -> Void in
            // Check if sharing to Twitter is possible.
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
                // Initialize the default view controller for sharing the post.
                let twitterComposeVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                twitterComposeVC.setInitialText("Hey check out this wonderful App 'Drop'")
                // Display the compose view controller.
                self.presentViewController(twitterComposeVC, animated: true, completion: nil)
            }
            else {
                self.showAlertMessage("You are not logged in to your Twitter account.")
            }
        }
        
        let facebook = UIAlertAction(title: "Share on Facebook", style: UIAlertActionStyle.Default) { (action) -> Void in
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
                let facebookComposeVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                
                facebookComposeVC.setInitialText("Hey check out this wonderful App 'Drop'")
                
                self.presentViewController(facebookComposeVC, animated: true, completion: nil)
            }
            else {
                self.showAlertMessage("You are not connected to your Facebook account.")
            }
        }
        
        // Configure a new action to show the UIActivityViewController
        let more = UIAlertAction(title: "More", style: UIAlertActionStyle.Default) { (action) -> Void in
            let activityViewController = UIActivityViewController(activityItems: ["Hey check out this wonderful App 'Drop'"], applicationActivities: nil)
            
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }
        
        
        let dismiss = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (action) -> Void in
            
        }
        
        
        shareAlert.addAction(twitter)
        shareAlert.addAction(facebook)
        shareAlert.addAction(more)
        shareAlert.addAction(dismiss)
        
        presentViewController(shareAlert, animated: true, completion: nil)
    }
    
    func showAlertMessage( message: String!) {
        let alertController = UIAlertController(title: "Drop", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Share", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
}


