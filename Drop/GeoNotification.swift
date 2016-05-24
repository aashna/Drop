//
//  GeoNotification.swift
//  Drop
//
//  Created by Aashna Garg on 5/23/16.
//  Copyright © 2016 Aashna Garg. All rights reserved.
//

//
//  geonotification.swift
//  Geotify
//
//  Created by Ken Toh on 24/1/15.
//  Copyright (c) 2015 Ken Toh. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

let kgeonotificationLatitudeKey = "latitude"
let kgeonotificationLongitudeKey = "longitude"
let kgeonotificationRadiusKey = "radius"
let kgeonotificationIdentifierKey = "identifier"
let kgeonotificationNoteKey = "note"
let kgeonotificationEventTypeKey = "eventType"

enum EventType: Int {
    case OnEntry = 0
    case OnExit
}

class Geonotification: NSObject, NSCoding, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var radius: CLLocationDistance
    var identifier: String
    var note: String
    var eventType: EventType
    
    var title: String? {
        if note.isEmpty {
            return "No Note"
        }
        return note
    }
    
    var subtitle: String? {
        let eventTypeString = eventType == .OnEntry ? "On Entry" : "On Exit"
        return "Radius: \(radius)m - \(eventTypeString)"
    }
    
    init(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String, note: String, eventType: EventType) {
        self.coordinate = coordinate
        self.radius = radius
        self.identifier = identifier
        self.note = note
        self.eventType = eventType
    }
    
    // MARK: NSCoding
    
    required init?(coder decoder: NSCoder) {
        let latitude = decoder.decodeDoubleForKey(kgeonotificationLatitudeKey)
        let longitude = decoder.decodeDoubleForKey(kgeonotificationLongitudeKey)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        radius = decoder.decodeDoubleForKey(kgeonotificationRadiusKey)
        identifier = decoder.decodeObjectForKey(kgeonotificationIdentifierKey) as! String
        note = decoder.decodeObjectForKey(kgeonotificationNoteKey) as! String
        eventType = EventType(rawValue: decoder.decodeIntegerForKey(kgeonotificationEventTypeKey))!
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeDouble(coordinate.latitude, forKey: kgeonotificationLatitudeKey)
        coder.encodeDouble(coordinate.longitude, forKey: kgeonotificationLongitudeKey)
        coder.encodeDouble(radius, forKey: kgeonotificationRadiusKey)
        coder.encodeObject(identifier, forKey: kgeonotificationIdentifierKey)
        coder.encodeObject(note, forKey: kgeonotificationNoteKey)
        coder.encodeInt(Int32(eventType.rawValue), forKey: kgeonotificationEventTypeKey)
    }
}
