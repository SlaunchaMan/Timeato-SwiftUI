//
//  ContentView.swift
//  Timeato
//
//  Created by Jeff Kelley on 1/1/20.
//  Copyright © 2020 Jeff Kelley. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State private var timerEndDate: Date?
    @State private var displayedTimeRemaining: DateComponents?
    @State private var pomodoroTimer: Timer?
    
    private let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        return formatter
    }()
    
    let displayLink = DisplayLink()
    
    var body: some View {
        VStack {
            displayedTimeRemaining.map {
                Text("\($0, formatter: timeFormatter)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .onReceive(displayLink, perform: { _ in
                        self.updateTimeDisplay()
                    })
            }
            Section {
                if timerEndDate == nil {
                    Button(action: self.userTappedStart) {
                        Text("Start Timer")
                    }
                }
                else {
                    Button(action: self.userTappedCancel) {
                        Text("Cancel Timer")
                            .foregroundColor(.red)
                    }
                }
            }
            .font(.title)
        }
    }
    
    var timeRemaining: DateComponents? {
        guard let endDate = timerEndDate else { return nil }
        
        return Calendar.current.dateComponents([.minute, .second],
                                               from: Date(),
                                               to: endDate)
    }
    
    private func userTappedCancel() {
        cancelTimer()
    }
    
    private func userTappedStart() {
        initializeTimer()
        updateTimeDisplay()
    }
    
    /// Create a `Date` instance 25 minutes into the future and store it, then
    /// start a `Timer` that fires at that date.
    private func initializeTimer() {
        let calendar = Calendar.current
        
        let components = DateComponents(minute: 25)
        
        if let endDate = calendar.date(byAdding: components, to: Date()) {
            timerEndDate = endDate
            
            let pomodoroTimer = Timer(fire: endDate,
                                      interval: 0,
                                      repeats: false,
                                      block: { _ in
                                        self.cancelTimer()
            })
            
            RunLoop.main.add(pomodoroTimer, forMode: .common)
            
            self.pomodoroTimer = pomodoroTimer
        }
        else {
            cancelTimer()
        }
    }
    
    private func cancelTimer() {
        self.timerEndDate = nil
        self.displayedTimeRemaining = nil
        self.pomodoroTimer = nil
    }
    
    private func updateTimeDisplay() {
        displayedTimeRemaining = timeRemaining
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
