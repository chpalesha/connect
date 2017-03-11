//
//  Annotation.swift
//  Connect
//
//  Created by Chirag Palesha on 12/6/16.
//  Copyright © 2016 Chirag Palesha. All rights reserved.
//

import UIKit
import MapKit
class Annotation: NSObject, MKAnnotation{
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    var mapPinDescription: String{
        return "\(title): \(subtitle )"
    }
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D){
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}
