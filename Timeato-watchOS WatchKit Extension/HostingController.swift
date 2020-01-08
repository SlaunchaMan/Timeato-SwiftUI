//
//  HostingController.swift
//  Timeato-watchOS WatchKit Extension
//
//  Created by Jeff Kelley on 1/1/20.
//  Copyright © 2020 Jeff Kelley. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI

class HostingController: WKHostingController<AnyView> {
    
    let settingsStorage = SettingsStorage()

    override var body: AnyView {        
        return AnyView(
            RootView()
                .environmentObject(settingsStorage)
                .environmentObject(PomodoroTimerController(settingsStorage: settingsStorage))
        )
    }
}
