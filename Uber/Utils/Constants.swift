//
//  Constants.swift
//  Uber
//
//  Created by trungnghia on 5/11/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import Firebase

public let kDB_REF = Database.database().reference()
public let kREF_USERS = kDB_REF.child("users")
public let kREF_DRIVER_LOCATIONS = kDB_REF.child("driver-locations")
public let kREF_TRIPS = kDB_REF.child("trips")
