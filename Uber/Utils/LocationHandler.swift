//
//  LocationHandler.swift
//  Uber
//
//  Created by trungnghia on 5/12/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import CoreLocation

class LocationHandler: NSObject, CLLocationManagerDelegate {
    
    // Make sure to create one instant for LocationHandler, and then use that our application
    static let shared = LocationHandler()
    
    var locationManager: CLLocationManager!
    //var location: CLLocation?
    
    override init() {
        super.init()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    //... 
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
}
