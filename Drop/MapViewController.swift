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

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    
    var SoundCloud_CLIENT_ID = "14802fecba08aa53d2daa7d16434d02c"
    var user_id1 = "228307235"
    var musicPlaylist = [SongDetailsModel]()
    var geonotifications = [Geonotification]()
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBAction func logout(sender: AnyObject) {
         PFUser.logOut()
    }
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    weak var delegate: MusicDataDelegate?

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

    @IBOutlet weak var mapTypeSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        addGeonotifications()
        
        // Do any additional setup after loading the view, typically from a nib.
        if let userPicture = PFUser.currentUser()?["imageFile"] as? PFFile {
            userPicture.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                if (error == nil) {
                    self.profilePicture.image = UIImage(data:imageData!)
                }
            }
        
        }
        
         mapView.delegate = self
        
        self.locationManager.requestWhenInUseAuthorization()
        self.mapView.showAnnotations(self.mapView.annotations, animated: true)

        addCharacterLocation()
        addAttractionPins()
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.startUpdatingLocation()
            self.mapView.showsUserLocation = true
            
        }
        fetchMusicDataIntoModel()
        
    }

    func regionWithgeonotification(geonotification: Geonotification) -> CLCircularRegion {
        // 1
        let region = CLCircularRegion(center: geonotification.coordinate, radius: geonotification.radius, identifier: geonotification.identifier)
        // 2
        region.notifyOnEntry = (geonotification.eventType == .OnEntry)
        region.notifyOnExit = !region.notifyOnEntry
        return region
    }
    
    func startMonitoringgeonotification(geonotification: Geonotification) {
        // 1
        if !CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion) {
            showSimpleAlertWithTitle("Error", message: "Geofencing is not supported on this device!", viewController: self)
            return
        }
        // 2
        if CLLocationManager.authorizationStatus() != .AuthorizedAlways {
            showSimpleAlertWithTitle("Warning", message: "Your geonotification is saved but will only be activated once you grant Geotify permission to access the device location.", viewController: self)
        }
        // 3
        let region = regionWithgeonotification(geonotification)
        // 4
        locationManager.startMonitoringForRegion(region)
    }
    
    func stopMonitoringgeonotification(geonotification: Geonotification) {
        for region in locationManager.monitoredRegions {
            if let circularRegion = region as? CLCircularRegion {
                if circularRegion.identifier == geonotification.identifier {
                    locationManager.stopMonitoringForRegion(circularRegion)
                }
            }
        }
    }
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Delete geonotification
        let geonotification = view.annotation as! Geonotification
        stopMonitoringgeonotification(geonotification)   // Add this statement
    }
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    
    let regionRadius: CLLocationDistance = 100
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            manager.startUpdatingLocation()
        }
        mapView.showsUserLocation = (status == .AuthorizedAlways)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("Errors: " + error.localizedDescription)
        
    }
    
    func removeGeonotification(geonotification: Geonotification) {
        if let indexInArray = geonotifications.indexOf(geonotification) {
            geonotifications.removeAtIndex(indexInArray)
        }
        
        mapView.removeAnnotation(geonotification)
        removeRadiusOverlayForgeonotification(geonotification)
    }
    
    func addGeonotifications() {
        let coordinate = CLLocationCoordinate2D(latitude:37.4301566, longitude:-122.175685)
        let geonotification = Geonotification(coordinate: coordinate, radius: 200, identifier: NSUUID().UUIDString, note: "Gates Station", eventType: EventType.OnEntry)
        geonotifications.append(geonotification)
        mapView.addAnnotation(geonotification)
        addRadiusOverlayForgeonotification(geonotification)
    }
    
    func addRadiusOverlayForgeonotification(geonotification: Geonotification) {
        mapView?.addOverlay(MKCircle(centerCoordinate: geonotification.coordinate, radius: geonotification.radius))
    }
    
    func removeRadiusOverlayForgeonotification(geonotification: Geonotification) {
        // Find exactly one overlay which has the same coordinates & radius to remove
        if let overlays = mapView?.overlays {
            for overlay in overlays {
                if let circleOverlay = overlay as? MKCircle {
                    let coord = circleOverlay.coordinate
                    if coord.latitude == geonotification.coordinate.latitude && coord.longitude == geonotification.coordinate.longitude && circleOverlay.radius == geonotification.radius {
                        mapView?.removeOverlay(circleOverlay)
                        break
                    }
                }
            }
        }
    }
    

    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let userLocation:CLLocation = locations[0]
//        
//        for audio in audioArr {
//            audio.updateVolume(userLocation)
//            if !audio.playing() {
//                audio.play(userLocation)
//            }
//
//        }
    }
    
    func addCharacterLocation() {
        let huangFilePath = NSBundle.mainBundle().pathForResource("Huang", ofType: "plist")
        let huangLocations = NSArray(contentsOfFile: huangFilePath!)
        let huangPoint = CGPointFromString(huangLocations![Int(rand()%4)] as! String)
        let huangCenterCoordinate = CLLocationCoordinate2DMake(CLLocationDegrees(huangPoint.x), CLLocationDegrees(huangPoint.y))
        let huangRadius = CLLocationDistance(max(5, Int(rand()%40)))
        let huang = Character(centerCoordinate:huangCenterCoordinate, radius:huangRadius)
     //   huang.color = UIColor.blueColor()
        
        let raysFilePath = NSBundle.mainBundle().pathForResource("Rays", ofType: "plist")
        let raysLocations = NSArray(contentsOfFile: raysFilePath!)
        let raysPoint = CGPointFromString(raysLocations![Int(rand()%4)] as! String)
        let raysCenterCoordinate = CLLocationCoordinate2DMake(CLLocationDegrees(raysPoint.x), CLLocationDegrees(raysPoint.y))
        let raysRadius = CLLocationDistance(max(5, Int(rand()%40)))
        let rays = Character(centerCoordinate:raysCenterCoordinate, radius:raysRadius)
   //     rays.color = UIColor.orangeColor()
        
        let ovalFilePath = NSBundle.mainBundle().pathForResource("Oval", ofType: "plist")
        let ovalLocations = NSArray(contentsOfFile: ovalFilePath!)
        let ovalPoint = CGPointFromString(ovalLocations![Int(rand()%4)] as! String)
        let ovalCenterCoordinate = CLLocationCoordinate2DMake(CLLocationDegrees(ovalPoint.x), CLLocationDegrees(ovalPoint.y))
        let ovalRadius = CLLocationDistance(max(5, Int(rand()%40)))
        let oval = Character(centerCoordinate:ovalCenterCoordinate, radius:ovalRadius)
     //   oval.color = UIColor.yellowColor()
        
        mapView.addOverlay(huang)
        mapView.addOverlay(rays)
        mapView.addOverlay(oval)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.strokeColor = UIColor.greenColor()
            circleRenderer.fillColor = UIColor(
                red: 0,
                green: 1.0,
                blue: 0,
                alpha: 0.5)
            
            return circleRenderer
    }
    
    func addAttractionPins() {
        let filePath = NSBundle.mainBundle().pathForResource("Zones", ofType: "plist")
        let attractions = NSArray(contentsOfFile: filePath!)
        for attraction in attractions! {
            let point = CGPointFromString((attraction.objectForKey("location") as? String)!)//attraction["location"] as! String)
            let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(point.x), CLLocationDegrees(point.y))
            let title = attraction.objectForKey("name") as! String//attraction["name"] as! String
            let typeRawValue = Int(attraction.objectForKey("type") as! String)! //Int((attraction["type"] as! String))!
            let type = AttractionType(rawValue: typeRawValue)!
            let subtitle = attraction.objectForKey("subtitle") as! String //attraction["subtitle"] as! String
            let annotation = AttractionAnnotation(coordinate: coordinate, title: title, subtitle: subtitle, type: type)
            mapView.addAnnotation(annotation)
        }
//        mapView.setRegion(MKCoordinateRegion(center:CLLocationCoordinate2D(latitude: 37.7735546, longitude: -122.4234522), span: MKCoordinateSpanMake(0.01, 0.01)), animated: false)
        mapView.setUserTrackingMode(MKUserTrackingMode.FollowWithHeading, animated: false)
    }
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = AttractionAnnotationView(annotation: annotation, reuseIdentifier: "Attraction")
        annotationView.canShowCallout = true
        return annotationView
    }
    
    func fetchMusicDataIntoModel(){
        let urlPath = "http://api.soundcloud.com/users/\(user_id1)/playlists?client_id=\(SoundCloud_CLIENT_ID)"
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
                var streamUrl  = track["stream_url"]! as! String
                streamUrl += "?client_id=\(SoundCloud_CLIENT_ID)"
                
                self.musicPlaylist.append(SongDetailsModel(title: track["title"]! as! String, duration: track["duration"]! as! Int, streamURL: streamUrl ))
//                audioArr.append(AudioLocale.init(filePath: NSURL(string: track["stream_url"]! as! String)!, coords: CLLocation.init(latitude: 37.428454, longitude: -122.170578)))
            }
          }
        }
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.playList = self.musicPlaylist
     //   appDelegate.audioList = audioArr
    }
}