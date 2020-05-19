//
//  User.swift
//  Uber
//
//  Created by trungnghia on 5/11/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import CoreLocation

enum AccountType: Int {
    case passenger
    case driver
}

struct Location {
    let title: String
    let address: String
    
    init(title: String, address: String) {
        self.title = title
        self.address = address
    }
}

struct User {
    let email: String
    let fullname: String
    var accountType: AccountType!
    let profileImageUrl: String
    var location: CLLocation?
    let uid: String
    var homeLocation: Location?
    var workLocation: Location?
    
    var firstInitial: String {
        return String(fullname.prefix(1))
    }
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        email = dictionary["email"] as? String ?? ""
        fullname = dictionary["fullname"] as? String ?? ""
        profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
       
        
        if let homeLocation = dictionary["homeLocation"] as? NSArray {
            guard let title = homeLocation[0] as? String else { return }
            guard let address = homeLocation[1] as? String else { return }
            self.homeLocation = Location(title: title, address: address)
        }
        
        if let workLocation = dictionary["workLocation"] as? NSArray {
            guard let title = workLocation[0] as? String else { return }
            guard let address = workLocation[1] as? String else { return }
            self.workLocation = Location(title: title, address: address)
        }
        
        if let index = dictionary["accountType"] as? Int {
            self.accountType = AccountType(rawValue: index)
        }
    }
}
