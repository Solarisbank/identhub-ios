//
//  TimerFactory.swift
//  IdentHubSDKQES
//

import Foundation

internal protocol Timer {
    func invalidate()
}

extension Foundation.Timer: Timer {}

internal protocol TimerFactory {
    func scheduledTimer(withTimeInterval interval: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Void) -> Timer
}

internal struct TimerFactoryImpl: TimerFactory {
    func scheduledTimer(withTimeInterval interval: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Void) -> Timer {
        return Foundation.Timer.scheduledTimer(withTimeInterval: interval, repeats: repeats, block: block)
    }
}
