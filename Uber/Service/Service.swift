//
//  Service.swift
//  Uber
//
//  Created by trungnghia on 5/11/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import Firebase
import CoreLocation
import GeoFire

struct DriverService {
    static let shared = DriverService()
    private init() {}
    
    func observeTrips(completion: @escaping(Trip) -> Void) {
        kREF_TRIPS.observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let uid = snapshot.key
            let trip =  Trip(passengerUid: uid, dictionary: dictionary)
            completion(trip)
        }
    }
    
    func observeTripCanceled(trip: Trip, completion: @escaping() -> Void) {
        kREF_TRIPS.child(trip.passengerUid).observeSingleEvent(of: .childRemoved) { (snapshot) in
            completion()
        }
    }
    
    func acceptTrip(trip: Trip, completion: @escaping (Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let values = ["driverUid": uid,
                      "state": TripState.accepted.rawValue] as [String : Any]
        
        kREF_TRIPS.child(trip.passengerUid).updateChildValues(values, withCompletionBlock: completion)
    }
    
    func updateTripState(trip: Trip, state: TripState, completion: @escaping (Error?, DatabaseReference) -> Void) {
        kREF_TRIPS.child(trip.passengerUid).child("state").setValue(state.rawValue, withCompletionBlock: completion)
        
        // remove observer when trip.state is completed
        if state == .completed {
            kREF_TRIPS.child(trip.passengerUid).removeAllObservers()
        }
        
    }
    
    func updateDriverLocation(location: CLLocation) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let geofire = GeoFire(firebaseRef: kREF_DRIVER_LOCATIONS)
        geofire.setLocation(location, forKey: uid)
    }
    
    
}

struct PassengerService {
    static let shared = PassengerService()
    private init() {}
    
    func fetchDrivers(location: CLLocation, withRadius radius: Double? = nil, completion: @escaping (User) -> Void) {
        let geofire = GeoFire(firebaseRef: kREF_DRIVER_LOCATIONS)
        
        kREF_DRIVER_LOCATIONS.observe(.value) { (snapshot) in
            // observe -> listen for changes of data
            geofire.query(at: location, withRadius: 50).observe(.keyEntered, with: { (uid, location) in
                Service.shared.fetchUserData(uid: uid) { (user) in
                    var driver = user
                    driver.location = location
                    completion(driver)
                }
            })
        }
    }
    
    func uploadTrip(_ pickupCoordinates: CLLocationCoordinate2D, _ destinationCoordinates: CLLocationCoordinate2D, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid  = Auth.auth().currentUser?.uid else { return }
        
        let pickupArray = [pickupCoordinates.latitude, pickupCoordinates.longitude]
        let destinationArray = [destinationCoordinates.latitude, destinationCoordinates.longitude]
        
        let values = ["pickupCoordinates": pickupArray,
                      "destinationCoordinates": destinationArray,
                      "state": TripState.requested.rawValue] as [String : Any]
        
        kREF_TRIPS.child(uid).updateChildValues(values, withCompletionBlock: completion)
        
    }
    
    func observeCurrentTrip(completion: @escaping(Trip) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        kREF_TRIPS.child(uid).observe(.value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let uid = snapshot.key
            let trip =  Trip(passengerUid: uid, dictionary: dictionary)
            completion(trip)
        }
    }
    
    func deleteTrip(completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        kREF_TRIPS.child(uid).removeValue(completionBlock: completion)
    }
    
    func saveLocation(location: [String], type: LocationType, completion: @escaping (Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let key: String = type == LocationType.home ? "homeLocation" : "workLocation"
        kREF_USERS.child(uid).child(key).setValue(location, withCompletionBlock: completion)
    }
    
}

struct Service {
    
    static let shared = Service()
    
    private init() {}

    func fetchUserData(uid: String, completion: @escaping (User) -> Void) {
        // observeSingleEvent -> Just get data, not observing data
        kREF_USERS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, dictionary: dictionary)
            completion(user)
        }
    }
    
    
    
    
    
    
}
