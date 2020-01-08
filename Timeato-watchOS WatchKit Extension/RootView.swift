//
//  RootView.swift
//  Timeato-watchOS WatchKit Extension
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
        ZStack {
            HStack {
                Spacer()
                VStack {
                    Button(action: self.userTappedSettings) {
                        Image(systemName: "gear")
                    }
                    .font(.system(size: 24))
                    .buttonStyle(PlainButtonStyle())
                    Spacer()
                }
                .padding(.top)
            }
            
            ProgressCircle(progress: $displayedPercentComplete,
                           lineWidth: 5)
                .onReceive(displayLink) { _ in
                    self.updatePercentComplete()
            }
            PomodoroTimerView()
        }
        .navigationBarTitle("Timeato")
        .sheet(isPresented: $isDisplayingPreferences) {
            PreferencesForm()
                .navigationBarTitle("Done")
                .environmentObject(self.settingsStorage)
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

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(PomodoroTimerController.previewControllers, id: \.self.0) { name, controller in
            RootView()
                .environmentObject(controller)
                .previewDisplayName(name)
        }
    }
}
