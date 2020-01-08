//
//  AppDelegate.swift
//  Timeato-macOS
//
//  Created by Jeff Kelley on 1/7/20.
//  Copyright © 2020 Jeff Kelley. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        UserDefaults.standard.register(defaults: ["PomodoroTimerDuration": 25])        
        
        // Create the SwiftUI view that provides the window contents.
        let contentView = RootView()
            .environmentObject(PomodoroTimerController())
            .environmentObject(SettingsStorage())

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        
        window.center()
        window.title = "Timeato"
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}

