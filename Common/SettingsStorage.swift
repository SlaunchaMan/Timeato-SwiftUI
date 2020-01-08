//
//  SettingsStorage.swift
//  Timeato
//
//  Created by Jeff Kelley on 1/4/20.
//  Copyright © 2020 Jeff Kelley. All rights reserved.
//

import Combine
import Foundation

class SettingsStorage: ObservableObject {
    
    let objectWillChange = ObservableObjectPublisher()
    
    @UserPreference(key: "PomodoroTimerDuration") var timerDuration: Int? {
        willSet {
            objectWillChange.send()
        }
    }
    
    var timerDurationFloat: Double? {
        get { return timerDuration.map(Double.init) }
        set { timerDuration = newValue.map(Int.init) }
    }
    
}
