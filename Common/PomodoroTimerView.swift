//
//  PomodoroTimerView.swift
//  Timeato
//
//  Created by Jeff Kelley on 1/1/20.
//  Copyright © 2020 Jeff Kelley. All rights reserved.
//

import SwiftUI

struct PomodoroTimerView: View {
    
    @EnvironmentObject var timerController: PomodoroTimerController
    
    @State private var displayedTimeRemaining: DateComponents?
    
    private let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    let displayLink = DisplayLink(preferredFramesPerSecond: 1)
    
    var startButtonFont: Font? {
        #if os(tvOS)
        return .system(size: 400)
        #elseif os(macOS)
        return .none
        #else
        return .system(size: 100)
        #endif
    }
    
    var buttonFont: Font? {
        #if os(tvOS)
        return .system(size: 200)
        #elseif os(macOS)
        return .none
        #else
        return .largeTitle
        #endif
    }
    
    var circleBackgroundColor: Color {
        #if os(iOS)
        return Color(.tertiarySystemFill)
        #else
        return Color(.darkGray)
        #endif
    }
    
    var circleStrokeColor: Color {
        #if os(iOS)
        return Color(.secondarySystemFill)
        #else
        return Color(.lightGray)
        #endif
    }
    
    var lineWidth: CGFloat {
        #if os(iOS)
        return 20
        #else
        return 5
        #endif
    }
    
    var buttonStyle: some PrimitiveButtonStyle {
        #if os(macOS)
        return DefaultButtonStyle()
        #else
        return PlainButtonStyle()
        #endif
    }
    
    var startButton: some View {
        let button = Button(action: self.userTappedStart) {
            #if os(macOS)
            Text("Start Timer")
            #elseif os(tvOS)
            Image(systemName: "play")
                .resizable()
                .font(startButtonFont)
                .padding(.all, 30)
                .background(Color(.lightGray))
            #else
            Image(systemName: "play.circle.fill")
                .font(startButtonFont)
            #endif
        }
            
        #if os(tvOS)
        return button.onPlayPauseCommand(perform: self.userTappedStart)
        #else
        return button
        #endif
    }
    
    var playPauseButton: some View {
        if timerController.isPaused {
            let button = Button(action: self.userTappedStart) {
                #if os(macOS)
                Text("Resume Timer")
                #else
                Image(systemName: "play.circle.fill")
                    .resizable(on: [.tvOS])
                #endif
            }
                
            #if os(tvOS)
            return button.onPlayPauseCommand(perform: self.userTappedStart)
            #else
            return button
            #endif
        }
        else {
            let button = Button(action: self.userTappedPause) {
                #if os(macOS)
                Text("Pause Timer")
                #else
                Image(systemName: "pause.circle.fill")
                    .resizable(on: [.tvOS])
                #endif
            }
                
            #if os(tvOS)
            return button.onPlayPauseCommand(perform: self.userTappedPause)
            #else
            return button
            #endif
        }
    }
    
    var cancelButton: some View {
        Button(action: self.userTappedCancel) {
            #if os(macOS)
            Text("Cancel Timer")
            #else
            Image(systemName: "stop.circle.fill")
                .resizable(on: [.tvOS])
            #endif
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0.0) {
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
                    if timerController.elapsedTime == nil {
                        startButton
                    }
                    else {
                        HStack {
                            playPauseButton
                            cancelButton
                        }
                        .padding(.all)
                    }
                }
                .buttonStyle(buttonStyle)
                .font(buttonFont)
            }
            .padding(.all, lineWidth * 5)
        }
        .padding(.all)
        .onReceive(timerController.objectWillChange) {
            DispatchQueue.main.async {
                self.updateTimeDisplay()
            }
        }
        .onAppear {
            self.updateTimeDisplay()
        }
    }
    
    private func userTappedCancel() {
        timerController.stop()
    }
    
    private func userTappedStart() {
        timerController.start()
    }
    
    private func userTappedPause() {
        timerController.pause()
    }
    
    private func updateTimeDisplay() {
        displayedTimeRemaining = timerController.timeRemaining
    }
    
}

enum Platform: Equatable, Hashable {
    case iOS, watchOS, tvOS, macOS, unknown
    
    static var current: Platform {
        #if os(iOS)
        return .iOS
        #elseif os(watchOS)
        return .watchOS
        #elseif os(tvOS)
        return .tvOS
        #elseif os(macOS)
        return .macOS
        #else
        return .unknown
        #endif
    }
}

extension Image {
    
    func resizable(on platforms: Set<Platform>) -> Image {
        if platforms.contains(Platform.current) {
            return resizable()
        }
        else {
            return self
        }
    }
    
}

#if DEBUG
struct PomodoroTimerView_Previews: PreviewProvider {
    
    static var previews: some View {
        #if os(iOS)
        return ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            return ForEach(PomodoroTimerController.previewControllers, id: \.self.0) { name, controller in
            PomodoroTimerView()
                .environmentObject(controller)
                .background(Color(.systemBackground))
                .environment(\.colorScheme, colorScheme)
                .previewLayout(.fixed(width: 250, height: 250))
                .previewDisplayName("\(name) - \(colorScheme)")
            }
        }
        #else
        return ForEach(PomodoroTimerController.previewControllers, id: \.self.0) { name, controller in
            PomodoroTimerView()
                .environmentObject(controller)
                .previewDisplayName(name)
        }
        #endif
    }
}
#endif
