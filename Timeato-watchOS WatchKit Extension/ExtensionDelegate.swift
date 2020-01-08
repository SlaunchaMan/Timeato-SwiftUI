//
//  ExtensionDelegate.swift
//  Timeato-watchOS WatchKit Extension
//
//  Created by Jeff Kelley on 1/1/20.
//  Copyright © 2020 Jeff Kelley. All rights reserved.
//

import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    func applicationDidFinishLaunching() {
        UserDefaults.standard.register(defaults: ["PomodoroTimerDuration": 25])
    }
    
}
