//
//  TimerMock.swift
//  IdentHubSDKQESTests
//

import Foundation
@testable import IdentHubSDKQES

final class TimerMock: IdentHubSDKQES.Timer {
    let tickCount: UInt
    
    var completion: (IdentHubSDKQES.Timer) -> Void
    var delayForTicks: TimeInterval
    var isInvalidated = false
    var ticks: UInt = 0
    
    init(
        tickCount: UInt,
        delayForTicks: TimeInterval = 0.0,
        completion: @escaping (IdentHubSDKQES.Timer) -> Void
    ) {
        self.completion = completion
        self.delayForTicks = delayForTicks
        self.tickCount = tickCount
        
        scheduleTickIfNeeded()
    }
    
    private func scheduleTickIfNeeded() {
        guard ticks < tickCount else { return }
        
        ticks += 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delayForTicks) {
            self.tick()
        }
    }
    
    private func tick() {
        guard !isInvalidated else { return }
        
        completion(self)
        
        scheduleTickIfNeeded()
    }
    
    func invalidate() {
        isInvalidated = true
    }
}
