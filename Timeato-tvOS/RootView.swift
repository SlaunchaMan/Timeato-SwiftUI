//
//  RootView.swift
//  Timeato-tvOS
//
//  Created by Jeff Kelley on 1/4/20.
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
    static var previews: some View {
        ForEach(PomodoroTimerController.previewControllers, id: \.self.0) { name, controller in
            ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
                RootView()
                    .background(Color(colorScheme == .dark ? .black : .white))
                    .environment(\.colorScheme, colorScheme)
                    .environmentObject(controller)
                    .environmentObject(SettingsStorage())
                    .previewDisplayName("\(name) - \(colorScheme)")
            }
        }
    }
}
#endif
