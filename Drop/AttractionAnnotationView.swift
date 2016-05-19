//
//  AnnotationView.swift
//  Drop
//
//  Created by Aashna Garg on 5/15/16.
//  Copyright © 2016 Aashna Garg. All rights reserved.
//

import UIKit
import MapKit

class AttractionAnnotationView: MKAnnotationView {
    
    // Required for MKAnnotationView
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Called when drawing the AttractionAnnotationView
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
//        let attractionAnnotation = self.annotation as! AttractionAnnotation
//        switch (attractionAnnotation.type) {
//        case .Arrillaga:
//            image = UIImage(named: "arrillaga.JPG")
//        case .Gates:
//            image = UIImage(named: "gates.jpg")
//        case .Memorial:
//            image = UIImage(named: "memorial.jpg")
//        default:
//            image = UIImage(named: "gates.jpg")
//        }
    }
}