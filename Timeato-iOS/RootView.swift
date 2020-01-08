//
//  RootView.swift
//  Timeato-iOS
//
//  Created by Jeff Kelley on 1/2/20.
//  Copyright © 2020 Jeff Kelley. All rights reserved.
//

import SwiftUI

struct RootView: View {
    
    @EnvironmentObject var timerController: PomodoroTimerController
    @EnvironmentObject var settingsStorage: SettingsStorage
    
    @State var isDisplayingPreferences = false
    @State var displayedPercentComplete: CGFloat?
    
    let displayLink = DisplayLink()
    
    var body: some View {
        NavigationView {
            ZStack {
                ProgressCircle(progress: $displayedPercentComplete,
                               lineWidth: 10)
                    .onReceive(displayLink) { _ in
                        self.updatePercentComplete()
                }
                .padding(.all, 10)

                
                PomodoroTimerView()
                    .navigationBarTitle("Timeato")
                    .navigationBarItems(
                        trailing: Button(action: self.userTappedSettings) { 
                            Image(systemName: "gear")
                    })
                    .sheet(isPresented: $isDisplayingPreferences) {
                        NavigationView {
                            PreferencesForm()
                                .environmentObject(self.settingsStorage)
                                .navigationBarTitle("Settings", displayMode: .inline)
                                .navigationBarItems(trailing: Button(action: { self.isDisplayingPreferences = false }) {
                                    Text("Done")
                                })
                        }
                }
            }
            .onAppear { self.updatePercentComplete() }
        }
    }
    
    private func userTappedSettings() {
        isDisplayingPreferences = true
    }
    
    private func updatePercentComplete() {
        self.displayedPercentComplete = self.timerController
            .percentageComplete.map { CGFloat($0) }
    }
    
}

#if DEBUG
struct RootView_Previews: PreviewProvider {
    
    static let previewDevices = [
        "iPhone SE",
//        "iPhone 8",
//        "iPhone 8 Plus",
//        "iPhone 11 Pro",
//        "iPhone 11",
//        "iPhone 11 Pro Max"
    ]
    
    static var previews: some View {
        ForEach(previewDevices, id: \.self) { device in
            ForEach(PomodoroTimerController.previewControllers, id: \.self.0) { name, controller in
                ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
                    RootView()
                        .environment(\.colorScheme, colorScheme)
                        .environmentObject(controller)
                        .environmentObject(SettingsStorage())
                        .previewDevice(PreviewDevice(rawValue: device))
                        .previewDisplayName("\(device) - \(name) - \(colorScheme)")
                }
            }
        }
    }
}
#endif
