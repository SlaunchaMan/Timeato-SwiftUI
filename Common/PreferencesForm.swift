//
//  PreferencesForm.swift
//  Timeato
//
//  Created by Jeff Kelley on 1/2/20.
//  Copyright © 2020 Jeff Kelley. All rights reserved.
//

import Combine
import SwiftUI

struct PreferencesForm: View {
    
    @EnvironmentObject var settingsStorage: SettingsStorage
    
    var body: some View {
        Form {
            Section(header: Text("Timing")) {
                #if os(iOS)
                Binding($settingsStorage.timerDuration).map {
                    Stepper("Pomodoro Duration (minutes): \($0.wrappedValue)",
                        value: $0,
                        in: 1...60)
                }
                #elseif os(watchOS)
                Binding($settingsStorage.timerDurationFloat).map { binding in
                    VStack {
                        Text("Pomodoro Duration (mintues): \(NumberFormatter.localizedString(from: NSNumber(value: binding.wrappedValue), number: .none))")
                        Slider(value: binding, in: 1...60, step: 1.0)
                    }
                    .padding(.vertical)
                }
                #elseif os(tvOS)
                Button(action: self.userAdjustedDuration) {
                    HStack {
                        Text("Timer Duration")
                        Spacer()
                        Text("\(self.settingsStorage.timerDuration!)")
                    }
                }
                #endif
            }
        }
    }
    
    #if os(tvOS)
    func userAdjustedDuration() {
        let possibleDurations = [1, 5, 10, 15, 25, 30, 60]
        
        let currentIndex = possibleDurations.firstIndex(of: self.settingsStorage.timerDuration!) ?? possibleDurations.startIndex
        
        var newIndex = possibleDurations.index(after: currentIndex)
        if newIndex == possibleDurations.endIndex {
            newIndex = possibleDurations.startIndex
        }
        
        settingsStorage.timerDuration = possibleDurations[newIndex]
    }
    #endif
    
}

struct PreferencesForm_Previews: PreviewProvider {
    static var previews: some View {
        #if os(iOS)
        return NavigationView {
            PreferencesForm()
                .environmentObject(SettingsStorage())
        }
        #else
        return PreferencesForm()
            .environmentObject(SettingsStorage())
        #endif
    }
}
