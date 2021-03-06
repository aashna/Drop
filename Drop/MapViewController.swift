//
//  ViewController.swift
//  Drop
//
//  Created by Aashna Garg on 5/15/16.
//  Copyright © 2016 Aashna Garg. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AVFoundation
import Parse

let kSavedItemsKey = "savedItems"
enum MapType: Int {
    case Standard = 0
    case Hybrid
    case Satellite
}

@objc protocol MusicDataDelegate: class {
    func getMusicData(results: NSArray)
}

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate,UIPopoverPresentationControllerDelegate {
    
    var SoundCloud_CLIENT_ID = "14802fecba08aa53d2daa7d16434d02c"
    var musicPlaylist = [SongDetailsModel]()
    var geonotifications = [Geonotification]()
    var myDict: NSArray?
    var loaderScreen = UIView()
    var locationName = ""
    let regionRadius: CLLocationDistance = 500
    
    let locationManager = CLLocationManager()
    weak var delegate: MusicDataDelegate?
    
    var zones = NSArray(contentsOfFile: NSBundle.mainBundle().pathForResource("Zones", ofType: "plist")!)
    
    @IBOutlet weak var currentSong: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBAction func logout(sender: AnyObject) {
        PFUser.logOut()
    }
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    
    /*
     Referred from https://www.raywenderlich.com/90971/introduction-mapkit-swift-tutorial
     **/
    
    @IBOutlet weak var bombButton: UIButton!
    /* Satellite/Hybrid Map views   */
    @IBAction func mapTypeChanged(sender: UISegmentedControl) {
        let mapType = MapType(rawValue: mapTypeSegmentedControl.selectedSegmentIndex)
        switch (mapType!) {
        case .Standard:
            mapView.mapType = MKMapType.Standard
        case .Hybrid:
            mapView.mapType = MKMapType.Hybrid
        case .Satellite:
            mapView.mapType = MKMapType.Satellite
        }
    }
    
    func bombButton(trueFalse:Bool){
        if let button = self.bombButton{
            button.enabled = trueFalse
        }
    }
    
    // Sets current song playing on the bottom view
    
    func setCurrentSong(){
        if AppDelegate.getAppDelegate().currentSong == nil{
        }
        else{
            currentSong.text = AppDelegate.getAppDelegate().currentSong.title
        }
    }
    
    // Sets profile picture of the user
    func setProfilePicture(){
        if let userPicture = PFUser.currentUser()?["imageFile"] as? PFFile {
            userPicture.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                if (error == nil) {
                    self.profilePicture.image = UIImage(data:imageData!)
                }
            }
            
        }
        
    }
    
    // Loading screen comes up when it fetches music
    
    func addLoadingScreen() -> UIView {
        if let loaderView = NSBundle.mainBundle().loadNibNamed("LoaderView", owner: self, options: nil).first as? LoaderView {
            loaderView.frame = UIScreen.mainScreen().bounds
            loaderView.animateLoader()
            return loaderView
        }
        return UIView()
    }
    
    override func viewWillAppear(animated: Bool) {
        activityIndicator.startAnimating()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCurrentSong()
        setProfilePicture()
        activityIndicator.stopAnimating()
        
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.startUpdatingLocation()
            self.mapView.showsUserLocation = true
        }
        addGeonotifications()
        mapView.delegate = self
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // Zones shown in pink overlays
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.strokeColor = UIColor(hue: 0.9472, saturation: 0.78, brightness: 0.92, alpha: 1.0)
        circleRenderer.fillColor = UIColor(hue: 0.9472, saturation: 0.71, brightness: 0.92, alpha: 1.0)
        return circleRenderer
    }
    
    /* Referred from https://www.raywenderlich.com/95014/geofencing-ios-swift  */
    func regionWithgeonotification(geonotification: Geonotification) -> CLCircularRegion {
        // 1
        let region = CLCircularRegion(center: geonotification.coordinate, radius: geonotification.radius, identifier: geonotification.identifier)
        // 2
        region.notifyOnEntry = (geonotification.eventType == .OnEntry)
        region.notifyOnExit = !region.notifyOnEntry
        return region
    }
    
    func startMonitoringgeonotification(geonotification: Geonotification) {
        if !CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion) {
            showSimpleAlertWithTitle("Error", message: "Geofencing is not supported on this device!", viewController: self)
            return
        }
        
        if CLLocationManager.authorizationStatus() != .AuthorizedAlways {
            showSimpleAlertWithTitle("Warning", message: "Your geonotification is saved but will only be activated once you grant Drop permission to access the device location.", viewController: self)
        }
        
        let region = regionWithgeonotification(geonotification)
        print("STARTED MONITORING \(geonotification.note)")
        locationManager.startMonitoringForRegion(region)
    }
    
    func stopMonitoringgeonotification(geonotification: Geonotification) {
        for region in locationManager.monitoredRegions {
            if let circularRegion = region as? CLCircularRegion {
                if circularRegion.identifier == geonotification.identifier {
                    print("stopped monitoring \(geonotification.note)")
                    locationManager.stopMonitoringForRegion(circularRegion)
                }
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("Errors: " + error.localizedDescription)
        
    }
    
    // Adding Geonotification for each zone in Zones.plist
    func addGeonotifications() {
        
        for zone in zones!{
            
            let lat = ((zone.objectForKey("latitude") as? NSString)?.doubleValue)!
            let long = ((zone.objectForKey("longitude") as? NSString)?.doubleValue)!
            let location = CLLocationCoordinate2D(latitude : lat, longitude : long )
            
            let geonotification = Geonotification(coordinate: location , radius: 500, identifier: NSUUID().UUIDString, note: zone.objectForKey("name") as! String, eventType: EventType.OnEntry)
            
            addRadiusOverlayForgeonotification(geonotification)
            geonotifications.append(geonotification)
            mapView.addAnnotation(geonotification)
            startMonitoringgeonotification(geonotification)
        }
        saveAllGeonotifications()
    }
    func saveAllGeonotifications() {
        let items = NSMutableArray()
        for geotification in geonotifications {
            let item = NSKeyedArchiver.archivedDataWithRootObject(geotification)
            items.addObject(item)
        }
        NSUserDefaults.standardUserDefaults().setObject(items, forKey: kSavedItemsKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func addRadiusOverlayForgeonotification(geonotification: Geonotification) {
        self.mapView?.addOverlay(MKCircle(centerCoordinate: geonotification.coordinate, radius: geonotification.radius))
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        centerMapOnLocation(userLocation)
    }
    
    func notefromRegionIdentifier(identifier: String) -> String? {
        if let savedItems = NSUserDefaults.standardUserDefaults().arrayForKey("savedItems") {
            for savedItem in savedItems {
                if let geonotification = NSKeyedUnarchiver.unarchiveObjectWithData(savedItem as! NSData) as? Geonotification {
                    if geonotification.identifier == identifier {
                        return geonotification.note
                    }
                }
            }
        }
        return nil
    }
    
    func handleRegionEvent(region: CLRegion!) {
        // Show an alert if application is active
        if UIApplication.sharedApplication().applicationState == .Active {
            if let message = notefromRegionIdentifier(region.identifier) {
                let alertController = UIAlertController(title: "Welcome", message: message, preferredStyle: .Alert)
                self.locationName = message
                
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: {
                    print(self.view.subviews)
                    for view in self.view.subviews {
                        if (view.isKindOfClass(LoaderView) ){
                            view.removeFromSuperview()
                        }
                    }
                })
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
        loaderScreen = addLoadingScreen()
        self.view.addSubview(loaderScreen)
        if region is CLCircularRegion {
            if let name = notefromRegionIdentifier(region.identifier){
                for zone in zones!{
                    if zone.objectForKey("name") as? String == String(name){
                        
                        // If we enter one of the zones, load the music playlist specific to that zone
                        
                        if let msg  = zone.objectForKey("url")  as? String{
                            print(msg)
                            print("REGION ENTERED \(region)")
                            heartButton.enabled = true
                            print("MUSIC LOADED")
                            fetchMusicDataIntoModel(msg)
                        }
                        handleRegionEvent(region)
                    }
                }
            }
            
        }
    }
    
    // Animation on pressing bomb button
    @IBAction func heartButtonPressed(sender: AnyObject) {
        let numberOfHearts = 5
        
        for _ in 1...numberOfHearts  {
            let duration = 3.0
            let options = UIViewAnimationOptions.CurveLinear
            let delay = NSTimeInterval(200 + arc4random_uniform(100)) / 1000
            let size : CGFloat = CGFloat( arc4random_uniform(40))+20
            _ = CGFloat( arc4random_uniform(200))+20
            let heart = UIImageView()
            heart.image = UIImage(named: "bomb-icon")
            heart.frame = CGRectMake(UIScreen.mainScreen().bounds.width-2*size, UIScreen.mainScreen().bounds.height, size, size)
            self.view.addSubview(heart)
            UIView.animateWithDuration(duration, delay: delay, options: options, animations: {
                heart.frame = CGRectMake(UIScreen.mainScreen().bounds.width-2*size, 0, size, size)
                heart.transform = CGAffineTransformMakeScale(3, 3)
                
                }, completion: { animationFinished in
                    heart.removeFromSuperview()
            })
        }
    }
    
    
    @IBAction func playSong(sender: AnyObject) {
        AppDelegate.getAppDelegate().currentSong.play()
    }
    @IBAction func stopSong(sender: AnyObject){
        AppDelegate.getAppDelegate().currentSong.stop()
    }
    func startBlinking(label: UIView) {
        let options : UIViewAnimationOptions = [.Repeat , .Autoreverse]
        UIView.animateWithDuration(0.25, delay:0.0, options:options, animations: {
            0.0
            }, completion: nil)
    }
    
    // Fetches playlist from SoundCloud specific to that location and fills the SongDetailsModel with it
    
    func fetchMusicDataIntoModel(urlPath: String){
        let url = NSURL(string: urlPath)
        let data = NSData(contentsOfURL: url!)
        var jsonResult: [NSDictionary]!
        
        do{
            jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! [NSDictionary]
        }catch{
            print(error)
        }
        
        if let tracks = jsonResult[0]["tracks"] as? [NSDictionary]{
            for track in tracks{
                if track["streamable"] as! Bool == true{
                    print(track["title"])
                    var streamUrl  = track["stream_url"]! as! String
                    streamUrl += "?client_id=\(self.SoundCloud_CLIENT_ID)"
                    
                    self.musicPlaylist.append(SongDetailsModel(title: track["title"]! as! String, duration: track["duration"]! as! Int, streamURL: streamUrl ))
                }
            }
        }
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.playList = self.musicPlaylist
        self.view.viewWithTag(22)?.removeFromSuperview()
    }
    
    // Popover segue for show profile
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showProfile" {
            let friendDetailsVC = segue.destinationViewController as! FriendDetailsViewController
            
            friendDetailsVC.modalPresentationStyle = UIModalPresentationStyle.Popover
            friendDetailsVC.popoverPresentationController!.delegate = self
        }
    }
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
}