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


class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate //PFLogInViewControllerDelegate,PFSignUpViewControllerDelegate //
{
    let transitionManager = TransitionManager()
    
//    override func viewWillAppear(animated: Bool) {
//        if (PFUser.currentUser() == nil) {
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                
//                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login") as! UIViewController
//                self.presentViewController(viewController, animated: true, completion: nil)
//            })
//        }
//    }
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        if (PFUser.currentUser() == nil) {
//            let loginViewController = PFLogInViewController()
//            loginViewController.delegate = self
//            loginViewController.fields = .UsernameAndPassword | .LogInButton | .PasswordForgotten | .SignUpButton | .Facebook | .Twitter
//            loginViewController.emailAsUsername = true
//            loginViewController.signUpController?.delegate = self
//            self.presentViewController(loginViewController, animated: false, completion: nil)
//            
//        }else {
//            presentLoggedInAlert()
//        }
//        
//    }


    @IBOutlet weak var userPassword: UITextField!
    
    @IBOutlet weak var userName: UITextField!
    
    @IBOutlet weak var googleLoginButton: GIDSignInButton!
   
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    var email: String = ""
    
//    func presentLoggedInAlert() {
//        let alertController = UIAlertController(title: "You're logged in", message: "Welcome to Vay.K", preferredStyle: .Alert)
//        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
//            self.dismissViewControllerAnimated(true, completion: nil)
//        }
//        alertController.addAction(OKAction)
//        self.presentViewController(alertController, animated: true, completion: nil)
//    }
    
//    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
//        self.dismissViewControllerAnimated(true, completion: nil)
//        presentLoggedInAlert()
//    }
//
//    
//    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
//        self.dismissViewControllerAnimated(true, completion: nil)
//        presentLoggedInAlert()
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
    
    
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
    
    @IBAction func signIn(sender: AnyObject) {
        
        let username = self.userName.text
        let password = self.userPassword.text
        
        // Validate the text fields
        
        if(username?.characters.count < 5) {
            let alert = UIAlertController(title: "Invalid", message:"Username must be greater than 5 characters", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
            self.presentViewController(alert, animated: true){}
            
        } else if(password?.characters.count < 8) {
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
                    let alert = UIAlertView(title: "Success", message: "Logged In", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                    self.performSegueWithIdentifier("segueToMain", sender: self)

                } else {
                    let alert = UIAlertView(title: "Error", message: "\(error)", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                }
            })
        }
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
             self.performSegueWithIdentifier("segueToMain", sender: self)
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
            self.performSegueWithIdentifier("segueToMain", sender: self)
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

    @IBAction func addFriends(sender: AnyObject) {
        self.performSegueWithIdentifier("addFriend", sender: self)
    }
    
    
}


