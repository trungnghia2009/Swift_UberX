//
//  DriverAnnotation.swift
//  Uber
//
//  Created by trungnghia on 5/12/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import MapKit

class DriverAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var uid: String
    
    init(uid: String, coordinate: CLLocationCoordinate2D) {
        self.uid = uid
        self.coordinate = coordinate
    }
    
    func updateAnnotationPostion(withCoordinate coordinate: CLLocationCoordinate2D) {
        UIView.animate(withDuration: 0.2) {
            self.coordinate = coordinate
        }
    }
    
    
}
