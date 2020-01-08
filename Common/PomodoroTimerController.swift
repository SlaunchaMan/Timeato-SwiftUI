//
//  PomodoroTimerController.swift
//  Timeato
//
//  Created by Jeff Kelley on 1/4/20.
//  Copyright © 2020 Jeff Kelley. All rights reserved.
//

import Combine
import Foundation

class PomodoroTimerController: ObservableObject {
    
    enum State {
        case notRunning
        case running(endDate: Date, totalTime: DateComponents)
        case paused(elapsedTime: TimeInterval, totalTime: DateComponents)
    }
    
    let objectWillChange = ObservableObjectPublisher()
    
    let settingsStorage: SettingsStorage
    
    init(
        settingsStorage: @autoclosure() -> SettingsStorage = SettingsStorage()
    ) {
        self.settingsStorage = settingsStorage()
        state = .notRunning
    }
    
    fileprivate init(
        settingsStorage: @autoclosure() -> SettingsStorage = SettingsStorage(),
        state: State
    ) {
        self.settingsStorage = settingsStorage()
        self.state = state
    }
    
    private var state: State {
        willSet {
            objectWillChange.send()
        }
        didSet {
            if let oldTimer = pomodoroTimer {
                oldTimer.invalidate()
            }
            
            if case .running(let endDate, _) = state {
                let pomodoroTimer = Timer(fire: endDate,
                                          interval: 0,
                                          repeats: false,
                                          block: { _ in
                                            self.state = .notRunning
                })
                
                RunLoop.main.add(pomodoroTimer, forMode: .common)
                
                self.pomodoroTimer = pomodoroTimer
            }
            else {
                pomodoroTimer = nil
            }
        }
    }
    
    private var pomodoroTimer: Timer?
    
    private func endDate(with components: DateComponents,
                         elapsedTime: TimeInterval = 0) -> Date? {
        return Calendar.current.date(byAdding: components, to: Date())?
            .addingTimeInterval(-elapsedTime)
    }
    
    func start() {
        switch state {
        case .running:
            break
        case let .paused(elapsedTime: elapsedTime, totalTime: components):
            guard let endDate = endDate(with: components,
                                        elapsedTime: elapsedTime)
                else {
                    state = .notRunning
                    return
            }
            
            state = .running(endDate: endDate, totalTime: components)
        case .notRunning:
            let components = DateComponents(minute: settingsStorage.timerDuration)
            
            guard let endDate = endDate(with: components) else {
                state = .notRunning
                return
            }
            
            state = .running(endDate: endDate, totalTime: components)
        }
    }
    
    func stop() {
        state = .notRunning
    }
    
    var startDate: Date? {
        switch state {
        case let .running(endDate: endDate, totalTime: components):
            return Calendar.current.date(byAdding: components.inversed(),
                                         to: endDate)
        default:
            return nil
        }
    }
    
    var elapsedTime: TimeInterval? {
        switch state {
        case let .running(endDate: endDate, totalTime: components):
            let inverseComponents = components.inversed()
            
            guard let startDate = Calendar.current
                .date(byAdding: inverseComponents, to: endDate)
                else { return nil } 
            
            return Date().timeIntervalSince(startDate)
        case let .paused(elapsedTime: elapsedTime, totalTime: _):
            return elapsedTime
        default:
            return nil
        }
    }
    
    func pause() {
        switch state {
        case .running(endDate: _, totalTime: let components):
            guard let elapsedTime = elapsedTime else { return }
            state = .paused(elapsedTime: elapsedTime, totalTime: components)
        default:
            break
        }
    }
    
    var timeRemaining: DateComponents? {
        switch state {
        case let .running(endDate: endDate, totalTime: _):
            return Calendar.current.dateComponents([.minute, .second],
                                                   from: Date(),
                                                   to: endDate)
        case let .paused(elapsedTime: elapsedTime, totalTime: components):
            guard let endDate = self.endDate(with: components) else {
                return nil
            }
            
            return Calendar.current.dateComponents([.minute, .second],
                                                   from: Date(),
                                                   to: endDate.addingTimeInterval(-elapsedTime))
        default:
            return nil
        }
    }
    
    var percentageComplete: Double? {
        switch state {
        case .running(endDate: _, totalTime: let components),
             .paused(elapsedTime: _, totalTime: let components):
            guard let elapsedTime = elapsedTime else { return nil }
            
            let newStartDate = Date()
            
            guard let newEndDate = Calendar.current.date(byAdding: components,
                                                         to: newStartDate)
                else { return nil }
            
            return elapsedTime / newEndDate.timeIntervalSince(newStartDate)
        default:
            return nil
        }
    }
    
    var isPaused: Bool {
        if case .paused = state {
            return true
        }
        else {
            return false
        }
    }
    
}

extension Optional where Wrapped: SignedNumeric {
    
    func inversed() -> Self {
        return map { $0 * -1}
    }
    
}

extension DateComponents {
    
    func inversed() -> Self {
        return DateComponents(hour: hour.inversed(),
                              minute: minute.inversed(),
                              second: second.inversed(),
                              nanosecond: nanosecond.inversed())
    }
    
}

#if DEBUG
extension PomodoroTimerController {
    
    static var inProgressController: PomodoroTimerController {
        return PomodoroTimerController(
            state: .running(endDate: Date().addingTimeInterval(10 * 60),
                            totalTime: DateComponents(minute: 25))
        )
    }

    static var pausedController: PomodoroTimerController {
        return PomodoroTimerController(
            state: .paused(elapsedTime: 10 * 60,
                           totalTime: DateComponents(minute: 25))
        )
    }
    
    static var almostCompleteController: PomodoroTimerController {
        return PomodoroTimerController(
            state: .running(endDate: Date().addingTimeInterval(30),
                            totalTime: DateComponents(minute: 25))
        )
    }

    static let previewControllers: [(String, PomodoroTimerController)] = [
        ("Not Started", PomodoroTimerController(settingsStorage: SettingsStorage())),
        ("In Progress", .inProgressController),
        ("Paused", .pausedController),
        ("Almost Complete", .almostCompleteController),
    ]
    
}
#endif
