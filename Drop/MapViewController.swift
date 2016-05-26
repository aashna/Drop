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
//var audioArr = [
//    
//     AudioLocale.init(filePath: NSURL(string: "http://megdadhashem.wapego.ru/files/56727/tubidy_mp3_e2afc5.mp3")!, coords: CLLocation.init(latitude: 37.56748454, longitude: -122.38380578)) //done
//]
@objc protocol MusicDataDelegate: class {
    func getMusicData(results: NSArray)
}

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    
    
    
    var SoundCloud_CLIENT_ID = "14802fecba08aa53d2daa7d16434d02c"
    var user_id1 = "228307235"
    var user_id2 = "174400130"
    var user_id3 = "12061020"
    var musicPlaylist = [SongDetailsModel]()
    var geonotifications = [Geonotification]()
    
    let locationManager = CLLocationManager()
    weak var delegate: MusicDataDelegate?
//    let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
//    var dataTask: NSURLSessionDataTask?
    
    @IBOutlet weak var currentSong: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBAction func logout(sender: AnyObject) {
         PFUser.logOut()
    }

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
    
    func setCurrentSong(){
        if AppDelegate.getAppDelegate().currentSong == nil{
          //  currentSong.text = "No song currently playing"
        }
        else{
            currentSong.text = AppDelegate.getAppDelegate().currentSong.title
          //  startBlinking(currentSong)
        }
    }
    
    func setProfilePicture(){
        // Do any additional setup after loading the view, typically from a nib.
        if let userPicture = PFUser.currentUser()?["imageFile"] as? PFFile {
            userPicture.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                if (error == nil) {
                    self.profilePicture.image = UIImage(data:imageData!)
                }
            }
            
        }
    
    }
    
    func addLoadingScreen(){
        if(AppDelegate.getAppDelegate().loaded == false){
            if let loaderView = NSBundle.mainBundle().loadNibNamed("LoaderView", owner: self, options: nil).first as? LoaderView {
                loaderView.frame = UIScreen.mainScreen().bounds
                loaderView.animateLoader()
                loaderView.tag = 22
                self.view.addSubview(loaderView)
            }
        }
         AppDelegate.getAppDelegate().loaded = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
  //      self.splitViewController!.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
        
        setCurrentSong()
        setProfilePicture()
     //   addLoadingScreen()
     //   addLocations()
      //  loadAllGeonotifications()
        
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.startUpdatingLocation()
     //       self.mapView.showsUserLocation = true
        }
        addGeonotifications()
        
//
        mapView.delegate = self
//        self.mapView.showAnnotations(self.mapView.annotations, animated: true)

//        addAttractionPins()
    //    fetchMusicDataIntoModel()
  
    }
    
//    func addLocations() {
//        let huangFilePath = NSBundle.mainBundle().pathForResource("Huang", ofType: "plist")
//        let huangLocations = NSArray(contentsOfFile: huangFilePath!)
//        let huangPoint = CGPointFromString(huangLocations![Int(rand()%4)] as! String)
//        let huangCenterCoordinate = CLLocationCoordinate2DMake(CLLocationDegrees(huangPoint.x), CLLocationDegrees(huangPoint.y))
//        let huangRadius = CLLocationDistance(max(5, Int(rand()%40)))
//        let huang = Location(centerCoordinate:huangCenterCoordinate, radius:huangRadius)
//        //   huang.color = UIColor.blueColor()
//        
//        let raysFilePath = NSBundle.mainBundle().pathForResource("Rays", ofType: "plist")
//        let raysLocations = NSArray(contentsOfFile: raysFilePath!)
//        let raysPoint = CGPointFromString(raysLocations![Int(rand()%4)] as! String)
//        let raysCenterCoordinate = CLLocationCoordinate2DMake(CLLocationDegrees(raysPoint.x), CLLocationDegrees(raysPoint.y))
//        let raysRadius = CLLocationDistance(max(5, Int(rand()%40)))
//        let rays = Location(centerCoordinate:raysCenterCoordinate, radius:raysRadius)
//        //     rays.color = UIColor.orangeColor()
//        
//        let ovalFilePath = NSBundle.mainBundle().pathForResource("Oval", ofType: "plist")
//        let ovalLocations = NSArray(contentsOfFile: ovalFilePath!)
//        let ovalPoint = CGPointFromString(ovalLocations![Int(rand()%4)] as! String)
//        let ovalCenterCoordinate = CLLocationCoordinate2DMake(CLLocationDegrees(ovalPoint.x), CLLocationDegrees(ovalPoint.y))
//        let ovalRadius = CLLocationDistance(max(5, Int(rand()%40)))
//        let oval = Location(centerCoordinate:ovalCenterCoordinate, radius:ovalRadius)
//        //   oval.color = UIColor.yellowColor()
//        
//        mapView.addOverlay(huang)
//        mapView.addOverlay(rays)
//        mapView.addOverlay(oval)
//    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.strokeColor = UIColor(hue: 0.9472, saturation: 0.78, brightness: 0.92, alpha: 1.0)
        circleRenderer.fillColor = UIColor(hue: 0.9472, saturation: 0.71, brightness: 0.92, alpha: 1.0)
        return circleRenderer
    }
//
//    // MARK: Loading and saving functions
//    
////    func loadAllGeonotifications() {
////        geonotifications = []
////        
////        if let savedItems = NSUserDefaults.standardUserDefaults().arrayForKey(kSavedItemsKey) {
////            for savedItem in savedItems {
////                if let geonotification = NSKeyedUnarchiver.unarchiveObjectWithData(savedItem as! NSData) as? Geonotification {
////                    addGeonotification(geonotification)
////                }
////            }
////        }
////    }
//    
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
//    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        // Delete geonotification
//        let geonotification = view.annotation as! Geonotification
//        stopMonitoringgeonotification(geonotification)   // Add this statement
//        saveAllGeonotifications()
//    }
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
//
//    
//    let regionRadius: CLLocationDistance = 100
//    
//    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
//        if status == .AuthorizedWhenInUse {
//            manager.startUpdatingLocation()
//        }
//        mapView.showsUserLocation = (status == .AuthorizedAlways)
//    }
//    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("Errors: " + error.localizedDescription)
        
    }
//
//    func removeGeonotification(geonotification: Geonotification) {
//        if let indexInArray = geonotifications.indexOf(geonotification) {
//            geonotifications.removeAtIndex(indexInArray)
//        }
//        
//        mapView.removeAnnotation(geonotification)
//        removeRadiusOverlayForgeonotification(geonotification)
//    }
//    
    func addGeonotifications() {
        

//        let gatesCenterCoordinate = CLLocationCoordinate2DMake(37.43015659999997,-122.175685)
//        let gatesRadius = CLLocationDistance(500)
//        let gates = Location(centerCoordinate:gatesCenterCoordinate, radius:gatesRadius)
//        let mcFarlandCenterCoordinate = CLLocationCoordinate2DMake(37.4264022,-122.1600607)
//        let mcFarlandRadius = CLLocationDistance(500)
//        let mcFarland = Location(centerCoordinate:mcFarlandCenterCoordinate, radius:mcFarlandRadius)
       // mapView.addOverlay(gates)
       // mapView.addOverlay(mcFarland)
        let geonotification1 = Geonotification(coordinate: CLLocationCoordinate2D(latitude:37.43015659999997, longitude: -122.175685), radius: 500, identifier: NSUUID().UUIDString, note: "Gates Station", eventType: EventType.OnEntry)
        let geonotification11 = Geonotification(coordinate: CLLocationCoordinate2D(latitude:37.43015659999997, longitude: -122.175685), radius: 500, identifier: NSUUID().UUIDString, note: "Gates Station", eventType: EventType.OnExit)
        let geonotification2 = Geonotification(coordinate: CLLocationCoordinate2D(latitude:37.4264022, longitude:-122.1600607), radius: 500, identifier: NSUUID().UUIDString, note: "McFarland Station", eventType: EventType.OnEntry)
        let geonotification22 = Geonotification(coordinate: CLLocationCoordinate2D(latitude:37.4264022, longitude:-122.1600607), radius: 500, identifier: NSUUID().UUIDString, note: "McFarland Station", eventType: EventType.OnExit)
        
        addRadiusOverlayForgeonotification(geonotification1)
        addRadiusOverlayForgeonotification(geonotification2)
        geonotifications.append(geonotification1)
        geonotifications.append(geonotification2)

        mapView.addAnnotation(geonotification1)
        mapView.addAnnotation(geonotification2)
      //  addRadiusOverlayForgeonotification(geonotification)
        startMonitoringgeonotification(geonotification1)
        startMonitoringgeonotification(geonotification2)
        
        addRadiusOverlayForgeonotification(geonotification11)
        addRadiusOverlayForgeonotification(geonotification22)
        geonotifications.append(geonotification11)
        geonotifications.append(geonotification22)
        
        mapView.addAnnotation(geonotification11)
        mapView.addAnnotation(geonotification22)
        //  addRadiusOverlayForgeonotification(geonotification)
        startMonitoringgeonotification(geonotification11)
        startMonitoringgeonotification(geonotification22)
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
//
    func addRadiusOverlayForgeonotification(geonotification: Geonotification) {
      //  self.mapView?.removeOverlays(self..overlays)
        self.mapView?.addOverlay(MKCircle(centerCoordinate: geonotification.coordinate, radius: geonotification.radius))
    }
//
//    func removeRadiusOverlayForgeonotification(geonotification: Geonotification) {
//        // Find exactly one overlay which has the same coordinates & radius to remove
//        if let overlays = mapView?.overlays {
//            for overlay in overlays {
//                if let circleOverlay = overlay as? MKCircle {
//                    let coord = circleOverlay.coordinate
//                    if coord.latitude == geonotification.coordinate.latitude && coord.longitude == geonotification.coordinate.longitude && circleOverlay.radius == geonotification.radius {
//                        mapView?.removeOverlay(circleOverlay)
//                        break
//                    }
//                }
//            }
//        }
//    }
//    
//
//    
//    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
//        if(locations[0] == CLLocation(latitude: geonotifications[0].coordinate.latitude,longitude: geonotifications[0].coordinate.longitude)){
//           fetchMusicDataIntoModel("http://api.soundcloud.com/users/\(user_id2)/playlists?client_id=\(SoundCloud_CLIENT_ID)")
//        }
//        
        
//        if let masterViewController = self.delegate as? MusicPlayerViewController {
//            splitViewController?.showMa showDetailViewController(MapViewController, sender: nil)
//        }
//
//        for audio in audioArr {
//            audio.updateVolume(userLocation)
//            if !audio.playing() {
//                audio.play(userLocation)
//            }
//
//        }
    }
//
    
//
//    func addAttractionPins() {
//        let filePath = NSBundle.mainBundle().pathForResource("Zones", ofType: "plist")
//        let attractions = NSArray(contentsOfFile: filePath!)
//        for attraction in attractions! {
//            let point = CGPointFromString((attraction.objectForKey("location") as? String)!)//attraction["location"] as! String)
//            let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(point.x), CLLocationDegrees(point.y))
//            let title = attraction.objectForKey("name") as! String//attraction["name"] as! String
//            let typeRawValue = Int(attraction.objectForKey("type") as! String)! //Int((attraction["type"] as! String))!
//            let type = AttractionType(rawValue: typeRawValue)!
//            let subtitle = attraction.objectForKey("subtitle") as! String //attraction["subtitle"] as! String
//            let annotation = AttractionAnnotation(coordinate: coordinate, title: title, subtitle: subtitle, type: type)
//            mapView.addAnnotation(annotation)
//        }
////        mapView.setRegion(MKCoordinateRegion(center:CLLocationCoordinate2D(latitude: 37.7735546, longitude: -122.4234522), span: MKCoordinateSpanMake(0.01, 0.01)), animated: false)
//        mapView.setUserTrackingMode(MKUserTrackingMode.FollowWithHeading, animated: false)
//    }
//    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
//        let annotationView = AttractionAnnotationView(annotation: annotation, reuseIdentifier: "Attraction")
//        annotationView.canShowCallout = true
//        return annotationView
//    }
    @IBAction func heartButtonPressed(sender: AnyObject) {
        // the slider value returns a float (e.g. 10.4)
        // to work in the loop we need to round down as an Int (e.g. 10)
        let numberOfHearts = 5
        
        for _ in 1...numberOfHearts  {
            
            // set up some constants for the animation
            let duration = 3.0
            
            let options = UIViewAnimationOptions.CurveLinear
            
            // randomly assign a delay of 0.9 to 1s
            let delay = NSTimeInterval(200 + arc4random_uniform(100)) / 1000
            
            // set up some constants for the heart
            let size : CGFloat = CGFloat( arc4random_uniform(40))+20
            let yPosition : CGFloat = CGFloat( arc4random_uniform(200))+20
            
            // create the heart
            let heart = UIImageView()
            heart.image = UIImage(named: "bomb-icon")
            heart.frame = CGRectMake(UIScreen.mainScreen().bounds.width-2*size, UIScreen.mainScreen().bounds.height, size, size)
            self.view.addSubview(heart)
            
            // define the animation
            UIView.animateWithDuration(duration, delay: delay, options: options, animations: {
                
                // move the heart
                heart.frame = CGRectMake(UIScreen.mainScreen().bounds.width-2*size, 0, size, size)
                heart.transform = CGAffineTransformMakeScale(3, 3)
                
                }, completion: { animationFinished in
                    
                    // remove the heart
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
    
    /**
     Tells the label to stop blinking.
     */
    //    func stopBlinking() {
    //        alpha = 1
    //        layer.removeAllAnimations()
    //    }
    func fetchMusicDataIntoModel(urlPath: String){
        
        let url = NSURL(string: urlPath)
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED,0))
        {
            
            let data = NSData(contentsOfURL: url!)
            
            dispatch_async(dispatch_get_main_queue()) {
                var jsonResult: [NSDictionary]!
                
                // UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                
                do{
                    jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! [NSDictionary]
                }catch{
                    print(error)
                }
                
                if let tracks = jsonResult[0]["tracks"] as? [NSDictionary]{
                    for track in tracks{
                        if track["streamable"] as! Bool == true{
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
        }
    }
}