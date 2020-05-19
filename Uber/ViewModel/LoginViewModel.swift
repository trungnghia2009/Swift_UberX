//
//  LoginViewModel.swift
//  FireChat
//
//  Created by trungnghia on 5/4/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import Foundation

protocol AuthenticationProtocal {
    var formIsValid: Bool { get }
}

struct LoginViewModel: AuthenticationProtocal {
    var email: String?
    var password: String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false
            && password?.isEmpty == false
    }
}
