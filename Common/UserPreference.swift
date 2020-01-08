//
//  UserPreference.swift
//  Timeato
//
//  Created by Jeff Kelley on 1/4/20.
//  Copyright © 2020 Jeff Kelley. All rights reserved.
//

import Foundation
import SwiftUI

@propertyWrapper
struct UserPreference<T> {
    
    let key: String
    let userDefaults = UserDefaults.standard
    
    var wrappedValue: T? {
        get {
            return userDefaults.object(forKey: key) as? T
        }
        nonmutating set { 
            userDefaults.set(newValue, forKey: key)
        }
    }
    
}
