//
//  DispatchTime.swift
//  IdentHubSDK
//

import Foundation

public extension Int {
    
    var seconds: DispatchTimeInterval {
        return DispatchTimeInterval.seconds(self)
    }
    
    var second: DispatchTimeInterval {
        return seconds
    }
    
    var milliseconds: DispatchTimeInterval {
        return DispatchTimeInterval.milliseconds(self)
    }
    
    var millisecond: DispatchTimeInterval {
        return milliseconds
    }
}

public extension DispatchTimeInterval {
    var fromNow: DispatchTime {
        return DispatchTime.now() + self
    }
}
