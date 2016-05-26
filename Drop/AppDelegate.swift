//
//  AppDelegate.swift
//  Drop
//
//  Created by Aashna Garg on 5/15/16.
//  Copyright © 2016 Aashna Garg. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import TwitterKit
import Parse
import ParseUI
import ParseTwitterUtils
import ParseFacebookUtilsV4
import Contacts
import AVFoundation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, CLLocationManagerDelegate  {
    var contactStore = CNContactStore()
    var window: UIWindow?
    var playList = [SongDetailsModel]()
    let locationManager = CLLocationManager()
    var currentSong: SongDetailsModel!
    var loaded = true
    var mapVC = MapViewController()
    var SoundCloud_CLIENT_ID = "14802fecba08aa53d2daa7d16434d02c"
    var user_id1 = "228307235"
    var user_id2 = "174400130"
    var user_id3 = "12061020"
   
    

//    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
//        // Override point for customization after application launch.
//        Fabric.with([Twitter.self])

//        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
//    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(application: UIApplication,
                     openURL url: NSURL, options: [String: AnyObject]) -> Bool {
        return GIDSignIn.sharedInstance().handleURL(url,
                                                    sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String,
                                                    annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
    }
    class func getAppDelegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }

    
    func application(application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Initialize Google sign-in
        GIDSignIn.sharedInstance().clientID = "733867161078-fs7f41440j5sfccssep3jnvufk30b64u.apps.googleusercontent.com"
        
        GIDSignIn.sharedInstance().delegate = self
        
        Parse.enableLocalDatastore()
        
        // Initialize Parse.
        Parse.setApplicationId("W7Tyw7f6ISFxiU9yYu5NjXR0L58GCRLI8iWY8bXn", clientKey: "cOgN2acYpqgusYfNAADqgy3EMXyMLQpT8ozdjdcd")
        
        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
    
//        
//        PFTwitterUtils.initializeWithConsumerKey("xgtd5SUvYAHrvdVuk2H1KAh0c", consumerSecret:"jhxHZ3Ceo3qbBdigSfnvLlQHY4NrVWxUDnQIIc8dStwsN4rh9O")
//        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil))
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        return true

    }
    func handleRegionEvent(region: CLRegion!) {
            // Show an alert if application is active
            if UIApplication.sharedApplication().applicationState == .Active {
                if let message = notefromRegionIdentifier(region.identifier) {
                    var alert = UIAlertController(title: "Welcome to Station", message: message, preferredStyle: .Alert)
                    var topVC = UIApplication.sharedApplication().keyWindow?.rootViewController
                    while ((topVC!.presentedViewController) != nil) {
                        topVC = topVC!.presentedViewController;
                    }
                   // self.presentViewController(alert, animated: true, completion: nil)
                   // let importAlert: UIAlertController = UIAlertController(title: "Action Sheet", message: message, preferredStyle: .ActionSheet)
                    //self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
//                    if let viewController = window?.rootViewController?.presentViewController {
                        showSimpleAlertWithTitle(nil, message: message, viewController: topVC!)
//                    }
                }
            } else {
                // Otherwise present a local notification
                let notification = UILocalNotification()
                notification.alertBody = notefromRegionIdentifier(region.identifier)
                notification.soundName = "Default";
                UIApplication.sharedApplication().presentLocalNotificationNow(notification)
            }
    }
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            print("REGION ENTERED")
            mapVC.bombButton(true)
            handleRegionEvent(region)
        }
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            print("REGION EXITED")
            handleRegionEvent(region)
            mapVC.bombButton(false)
        }
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
                withError error: NSError!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
//            let userId = user.userID                  // For client-side use only!
//            let idToken = user.authentication.idToken // Safe to send to the server
//            let fullName = user.profile.name
//            let givenName = user.profile.givenName
//            let familyName = user.profile.familyName
//            let email = user.profile.email
            // ...
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    func requestForAccess(completionHandler: (accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
        
        switch authorizationStatus {
        case .Authorized:
            completionHandler(accessGranted: true)
            
        case .Denied, .NotDetermined:
            AppDelegate.getAppDelegate().contactStore.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(accessGranted: access)
                }
                else {
                    if authorizationStatus == CNAuthorizationStatus.Denied {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                            self.showMessage(message)
                        })
                    }
                }
            })
            
        default:
            completionHandler(accessGranted: false)
        }
    }
    
    func showMessage(message: String) {
        let alertController = UIAlertController(title: "Birthdays", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
        }
        
        alertController.addAction(dismissAction)
        
                let pushedViewControllers = (self.window?.rootViewController as! UINavigationController).viewControllers
                let presentedViewController = pushedViewControllers[pushedViewControllers.count - 1]
        
        presentedViewController.presentViewController(alertController, animated: true, completion: nil)
    }


    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func notefromRegionIdentifier(identifier: String) -> String? {
        if let savedItems = NSUserDefaults.standardUserDefaults().arrayForKey("savedItems") {
            for savedItem in savedItems {
                if let geonotification = NSKeyedUnarchiver.unarchiveObjectWithData(savedItem as! NSData) as? Geonotification {
                    if geonotification.identifier == identifier {
                        mapVC.fetchMusicDataIntoModel("http://api.soundcloud.com/users/\(user_id1)/playlists?client_id=\(SoundCloud_CLIENT_ID)")
                        return geonotification.note
                    }
                }
            }
        }
        return nil
    }


}

