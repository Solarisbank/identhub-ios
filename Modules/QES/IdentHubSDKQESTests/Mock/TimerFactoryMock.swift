//
//  TimerFactoryMock.swift
//  IdentHubSDKQESTests
//

import Foundation
@testable import IdentHubSDKQES

final class TimerFactoryMock: TimerFactory {
    var scheduledTimerReturnClosure: (TimeInterval, Bool, @escaping (IdentHubSDKQES.Timer) -> Void) -> TimerMock = { interval, _, completion in
        return TimerMock(tickCount: UInt(interval), completion: completion)
    }
    
    func scheduledTimer(withTimeInterval interval: TimeInterval, repeats: Bool, block: @escaping (IdentHubSDKQES.Timer) -> Void) -> IdentHubSDKQES.Timer {
        return scheduledTimerReturnClosure(interval, repeats, block)
    }
}
