//
//  DisplayLinkPublisher.swift
//  Timeato
//
//  Created by Jeff Kelley on 1/1/20.
//  Copyright © 2020 Jeff Kelley. All rights reserved.
//

import Combine
import Foundation

#if os(iOS) || os(tvOS)
import QuartzCore
#elseif os(macOS)
import CoreVideo
#endif

struct DisplayLink: Publisher {
    
    public typealias Output = Void
    
    public typealias Failure = Never

    class Subscription<S: Subscriber>: Combine.Subscription where S.Failure == Never, S.Input == Void {
        
        #if os(iOS) || os(tvOS)
        private lazy var link = CADisplayLink(
            target: self,
            selector: #selector(displayLinkFired)
        )
        #elseif os(macOS)
        private var link: CVDisplayLink
        #else
        private var timeInterval: TimeInterval
        private var timer: Timer? {
            didSet {
                oldValue?.invalidate()
            }
        }
        #endif
        
        private let subscriber: AnySubscriber<Void, Never>
        
        private var demand: Subscribers.Demand = .unlimited {
            didSet {
                #if os(iOS) || os(tvOS)
                self.link.isPaused = self.demand == .none
                #elseif os(macOS)
                if self.demand == .none, CVDisplayLinkIsRunning(link) {
                    CVDisplayLinkStop(link)
                }
                else if self.demand != .none, !CVDisplayLinkIsRunning(link) {
                    CVDisplayLinkStart(link)
                }
                #else
                if self.demand == .none {
                    self.timer = nil
                } else if self.timer == nil {
                    self.timer = Timer.scheduledTimer(
                        timeInterval: self.timeInterval,
                        target: self,
                        selector: #selector(self.timerFired(_:)),
                        userInfo: nil,
                        repeats: true
                    )
                }
                #endif
            }
        }
        
        fileprivate init(subscriber: S, preferredFramesPerSecond: Int) {
            self.subscriber = AnySubscriber(subscriber)
            #if os(iOS) || os(tvOS)
            self.link.preferredFramesPerSecond = preferredFramesPerSecond
            self.link.add(to: .main, forMode: .default)
            #elseif os(macOS)
            let linkPtr = UnsafeMutablePointer<CVDisplayLink?>.allocate(capacity: 1)
            
            guard CVDisplayLinkCreateWithActiveCGDisplays(linkPtr) == kCVReturnSuccess
                else { fatalError() }
            
            guard let link = linkPtr.pointee else { fatalError() }
            
            self.link = link
            
            CVDisplayLinkSetOutputHandler(link, displayLinkFired(_:now:outputTime:flagsIn:flagsOut:))
            #else
            self.timeInterval = preferredFramesPerSecond == 0 ? 1 / 60 : 1 / TimeInterval(preferredFramesPerSecond)
            #endif
        }
        
        deinit {
            #if os(iOS) || os(tvOS)
            link.invalidate()
            #elseif os(macOS)
            CVDisplayLinkStop(link)
            #else
            timer?.invalidate()
            #endif
        }
        
        func request(_ demand: Subscribers.Demand) {
            self.demand = demand
        }
        
        func cancel() {
            self.demand = .none
        }
        
        #if os(iOS) || os(tvOS)
        @objc private func displayLinkFired(_: CADisplayLink) {
            guard self.demand != .none else { return }
            // this seems to always return .max(0)
            _ = self.subscriber.receive()
        }
        #elseif os(macOS)
        @objc private func displayLinkFired(
            _ link: CVDisplayLink, 
            now: UnsafePointer<CVTimeStamp>,
            outputTime: UnsafePointer<CVTimeStamp>,
            flagsIn: CVOptionFlags,
            flagsOut: UnsafeMutablePointer<CVOptionFlags>
        ) -> CVReturn {
            guard self.demand != .none else { return kCVReturnSuccess }
            
            DispatchQueue.main.async {
                _ = self.subscriber.receive()
            }
            
            return kCVReturnSuccess
        }
        #else
        @objc private func timerFired(_ timer: Timer) {
            guard self.demand != .none else { return }
            // this seems to always return .max(0)
            _ = self.subscriber.receive()
        }
        #endif
    }
    
    public var preferredFramesPerSecond: Int
    
    public init(preferredFramesPerSecond: Int = 0) {
        self.preferredFramesPerSecond = preferredFramesPerSecond
    }
    
    public func receive<S: Subscriber>(subscriber: S) where S.Failure == Never, S.Input == Void {
        let subscription = Subscription(subscriber: subscriber, preferredFramesPerSecond: self.preferredFramesPerSecond)
        
        subscriber.receive(subscription: subscription)
    }
    
}
