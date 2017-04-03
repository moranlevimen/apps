//
//  Place.swift
//  finalPro2017
//
//  Created by moran levi on 9.1.2017.
//  Copyright © 2017 Moran Levi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class Place: NSObject, MKAnnotation {
    let location : CLLocation
    
    var coordinate: CLLocationCoordinate2D
    
    var title: String?
    var comantes : [String : Any]? = [:]
    var descrp : String?
    
    init(_ coor :CLLocationCoordinate2D) {
        self.coordinate = coor
        self.location = CLLocation(latitude: coor.latitude, longitude: coor.longitude)
        super.init()
    }

    
}
