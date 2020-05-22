//
//  Helper.swift
//  Uber
//
//  Created by trungnghia on 5/21/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import Foundation

func delay(seconds: Double, completion: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
}
