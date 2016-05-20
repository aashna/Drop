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

enum MapType: Int {
    case Standard = 0
    case Hybrid
    case Satellite
}
var audioArr = [
    
     AudioLocale.init(filePath: NSURL(string: "http://megdadhashem.wapego.ru/files/56727/tubidy_mp3_e2afc5.mp3")!, coords: CLLocation.init(latitude: 37.428454, longitude: -122.170578)) //done
//    AudioLocale.init(filePath: NSURL( fileURLWithPath: "http://megdadhashem.wapego.ru/files/56727/tubidy_mp3_e2afc5.mp3"), coords: CLLocation.init(latitude: 37.428454, longitude: -122.170578)), //done
//    AudioLocale.init(filePath: NSURL( fileURLWithPath: "http://megdadhashem.wapego.ru/files/56727/tubidy_mp3_e2afc5.mp3"), coords: CLLocation.init(latitude: 37.428454, longitude: -122.170578)), //done
//    AudioLocale.init(filePath: NSURL( fileURLWithPath: "http://megdadhashem.wapego.ru/files/56727/tubidy_mp3_e2afc5.mp3"), coords: CLLocation.init(latitude: 37.428454, longitude: -122.170578)), //done
//    AudioLocale.init(filePath: NSURL( fileURLWithPath: "http://megdadhashem.wapego.ru/files/56727/tubidy_mp3_e2afc5.mp3"), coords: CLLocation.init(latitude: 37.428454, longitude: -122.170578)), //done
//    AudioLocale.init(filePath: NSURL( fileURLWithPath: "http://megdadhashem.wapego.ru/files/56727/tubidy_mp3_e2afc5.mp3"), coords: CLLocation.init(latitude: 37.428454, longitude: -122.170578)), //done
]
@objc protocol MusicDataDelegate: class {
    func getMusicData(results: NSArray)
}

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
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
        // Do any additional setup after loading the view, typically from a nib.

        
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
        
    }
    
    
    let regionRadius: CLLocationDistance = 100
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
 
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("Errors: " + error.localizedDescription)
        
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        
        for audio in audioArr {
            audio.updateVolume(userLocation)
            if !audio.playing() {
                audio.play(userLocation)
            }
            
        }
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
            let point = CGPointFromString(attraction["location"] as! String)
            let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(point.x), CLLocationDegrees(point.y))
            let title = attraction["name"] as! String
            let typeRawValue = Int((attraction["type"] as! String))!
            let type = AttractionType(rawValue: typeRawValue)!
            let subtitle = attraction["subtitle"] as! String
            let annotation = AttractionAnnotation(coordinate: coordinate, title: title, subtitle: subtitle, type: type)
            mapView.addAnnotation(annotation)
        }
        mapView.setRegion(MKCoordinateRegion(center:CLLocationCoordinate2D(latitude: 37.7735546, longitude: -122.4234522), span: MKCoordinateSpanMake(0.01, 0.01)), animated: false)
        mapView.setUserTrackingMode(MKUserTrackingMode.FollowWithHeading, animated: false)
    }
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = AttractionAnnotationView(annotation: annotation, reuseIdentifier: "Attraction")
        annotationView.canShowCallout = true
        return annotationView
    }
    
    var SoundCloud_CLIENT_ID = "14802fecba08aa53d2daa7d16434d02c"
    var user_id1 = "228307235"
    var musicPlaylist = [SongDetailsModel]()
    
    func fetchMusicDataIntoModel(){
        let urlPath = "http://api.soundcloud.com/users/\(user_id1)/playlists?client_id=\(SoundCloud_CLIENT_ID)"//"http://itunes.apple.com/search?term=\(escapedSearchTerm)&media=software"
        let url = NSURL(string: urlPath)
        let session = NSURLSession.sharedSession()
        
        _ = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            print("Task completed")
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                print(error!.localizedDescription)
            }
            var jsonResult: NSDictionary!
            
            do{
                jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
            }
            catch{
                print(error)
            }
            
            if let tracks: NSArray = jsonResult["tracks"] as? NSArray{
                for track in tracks{
                    if track["streamable"] == True{
            
            self.musicPlaylist.append(SongDetailsModel(title: track["title"], duration: track["duration"], streamURL: track["stream_url"]))
                }
                }
            }
            self.delegate?.getMusicData(self.musicPlaylist)    
}

